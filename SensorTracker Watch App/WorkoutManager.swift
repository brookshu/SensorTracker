//
//  WorkoutManager.swift
//
//  Created by Taeyoung Yeon.
//


import Foundation
import HealthKit

class WorkoutManager: NSObject, ObservableObject, HKWorkoutSessionDelegate, HKLiveWorkoutBuilderDelegate {
    func workoutBuilder(_ workoutBuilder: HKLiveWorkoutBuilder, didCollectDataOf collectedTypes: Set<HKSampleType>) {
        
    }
    
    @Published var workoutSession: HKWorkoutSession?
    @Published var sessionBuilder: HKLiveWorkoutBuilder?
    private var healthStore = HKHealthStore()
    
    func requestAuthorization() {
        let typesToShare: Set = [
            HKObjectType.workoutType()
        ]
        
        let typesToRead: Set = [
            HKObjectType.quantityType(forIdentifier: .heartRate)!
        ]
        
        healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead) { (success, error) in
            if !success {
                print("HealthKit authorization failed: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }

    func startWorkout() {
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = .other
        configuration.locationType = .unknown

        do {
            workoutSession = try HKWorkoutSession(healthStore: healthStore, configuration: configuration)
            sessionBuilder = workoutSession?.associatedWorkoutBuilder()
            workoutSession?.delegate = self
            sessionBuilder?.delegate = self

            workoutSession?.startActivity(with: Date())
            sessionBuilder?.beginCollection(withStart: Date(), completion: { (success, error) in
                if let error = error {
                    print("Error starting workout session: \(error.localizedDescription)")
                }
            })
        } catch {
            print("Failed to start workout session: \(error.localizedDescription)")
        }
    }

    func endWorkout() {
        workoutSession?.end()
        sessionBuilder?.endCollection(withEnd: Date(), completion: { (success, error) in
            if let error = error {
                print("Error ending workout session: \(error.localizedDescription)")
            }
        })
    }

    // MARK: - HKWorkoutSessionDelegate

    func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: Date) {
        // Handle state changes if necessary
    }

    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
        print("Workout session failed: \(error.localizedDescription)")
    }

    // MARK: - HKLiveWorkoutBuilderDelegate

    func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {
        // Handle events if necessary
    }
}
