//
//  WorkoutManager.swift
//
//  Created by Taeyoung Yeon.
//


import Foundation
import HealthKit
import WatchConnectivity


class WorkoutManager: NSObject, ObservableObject, HKWorkoutSessionDelegate, HKLiveWorkoutBuilderDelegate {
    func workoutBuilder(_ workoutBuilder: HKLiveWorkoutBuilder, didCollectDataOf collectedTypes: Set<HKSampleType>) {
        guard let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate),
            collectedTypes.contains(heartRateType),
            let statistics = workoutBuilder.statistics(for: heartRateType),
            let quantity = statistics.mostRecentQuantity() else {
            return
        }

        let heartRateUnit = HKUnit.count().unitDivided(by: HKUnit.minute())
        let heartRate = quantity.doubleValue(for: heartRateUnit)
        let timestamp = NSDate().timeIntervalSince1970
        
        let heartRateString = "\(timestamp) \(heartRate) \n"
        //print(heartRateString)
        
        if WCSession.default.isReachable {
            WCSession.default.sendMessage(
                ["heartRateData": heartRateString],
                replyHandler: nil,
                errorHandler: { error in
                    print("Error sending heart rate data: \(error.localizedDescription)")
                }
            )
            print("HR data sent.")
        } else {
            print("WCSession is not activated.")
        }
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
            sessionBuilder?.dataSource = HKLiveWorkoutDataSource(healthStore: healthStore, workoutConfiguration: configuration)
            workoutSession?.startActivity(with: Date())
            sessionBuilder?.beginCollection(withStart: Date(), completion: { (success, error) in
                if let error = error {
                    print("Error starting workout session: \(error.localizedDescription)")
                } else {
                    print("Workout started!")
                }
            })
        } catch {
            print("Failed to start workout session: \(error.localizedDescription)")
        }
    }

    func endWorkout() {
        workoutSession?.end()
            sessionBuilder?.endCollection(withEnd: Date()) { [weak self] (success, error) in
                if let error = error {
                    print("Error ending workout session: \(error.localizedDescription)")
                } else {
                    self?.sessionBuilder?.finishWorkout { (workout, error) in
                        if let error = error {
                            print("Error finishing workout: \(error.localizedDescription)")
                        } else {
                            print("Workout finished!")
                        }
                    }
                }
            }
    }

    // MARK: - HKWorkoutSessionDelegate

    func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: Date) {
        // Handle state changes if necessary
        print("Workout session changed from \(fromState.rawValue) to \(toState.rawValue) at \(date)")

    }

    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
        print("Workout session failed: \(error.localizedDescription)")
    }

    // MARK: - HKLiveWorkoutBuilderDelegate

    func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {
        // Handle events if necessary
    }
}
