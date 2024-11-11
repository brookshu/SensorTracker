//
//  ContentView.swift
//  SensorTracker Watch App
//
//  Created by Vasco Xu on 9/30/24.
//

import SwiftUI

struct ContentView: View {
    @State private var isRecording = false
    @State var samplingRate: Double = 25.0
    
    // watch connectivity
    @ObservedObject var connectivityManager = WatchConnectivityManager.shared
    
    // managers
    var motionManager = MotionManager()
    var audioManager = AudioManager()
    
    // workout manager
    @StateObject private var workoutManager = WorkoutManager()

    // define sampling rate options
    let minSamplingRate: Double = 10.0
    let maxSamplingRate: Double = 100.0
    let step: Double = 5.0
    
    var body: some View {
        VStack {
            Spacer()
            Text(connectivityManager.recordingText)
                .foregroundColor(.white)
            
            // start button
            Button(action: {
                start()
            }) {
             Text("Start")
                 .foregroundColor(.white)
            }
            .buttonBorderShape(.roundedRectangle(radius: 10))
            .disabled(isRecording)

            // stop button
            Button(action: {
                stop()
            }) {
             Text("Stop")
                 .foregroundColor(.white)
            }
            .buttonBorderShape(.roundedRectangle(radius: 10))
            .disabled(!isRecording)
            Spacer()
         }
        .padding(.horizontal, 5)
        
        
         // Sampling Rate Stepper
         VStack(spacing: 20) {
             Text("Sampling Rate")
                 .font(.headline)
                 .foregroundColor(.white)
             
             HStack(spacing: 20) {
                 // Decrement Button
                 Button(action: {
                     decrementSamplingRate()
                 }) {
                     Image(systemName: "minus.circle.fill")
                         .resizable()
                         .frame(width: 40, height: 40)
                         .foregroundColor(samplingRate > minSamplingRate ? .blue : .gray)
                 }
                 .disabled(samplingRate <= minSamplingRate)
                 
                 // Current Sampling Rate Display
                 Text("\(Int(samplingRate)) Hz")
                     .font(.title)
                     .foregroundColor(.white)
                     .frame(width: 100, height: 50)
                     .background(
                         RoundedRectangle(cornerRadius: 10)
                             .fill(Color.gray.opacity(0.3))
                     )
                 
                 // Increment Button
                 Button(action: {
                     incrementSamplingRate()
                 }) {
                     Image(systemName: "plus.circle.fill")
                         .resizable()
                         .frame(width: 40, height: 40)
                         .foregroundColor(samplingRate < maxSamplingRate ? .blue : .gray)
                 }
                 .disabled(samplingRate >= maxSamplingRate)
             }
         }
        .onAppear {
            // Initialize the picker with the current sampling rate
            self.samplingRate = connectivityManager.samplingRate
        }

        Spacer()
    }
    
    private func incrementSamplingRate() {
        let newRate = samplingRate + step
        if newRate <= maxSamplingRate {
            samplingRate = newRate
        }
    }
    
    private func decrementSamplingRate() {
        let newRate = samplingRate - step
        if newRate >= minSamplingRate {
            samplingRate = newRate
        }
    }
    
    
    private func start() {
        print("Starting...")
        workoutManager.requestAuthorization() // request authorization before starting workout
        self.workoutManager.startWorkout() // start workout to prevent screen
        connectivityManager.recordingText = "Recording."
        motionManager.setSamplingRate(value: samplingRate)
        motionManager.startRecording()
        audioManager.startRecording()
        isRecording = true
    }
    
    private func stop() {
        print("Ending...")
        self.workoutManager.endWorkout() // stop workout manager
        connectivityManager.recordingText = "Not recording."
        motionManager.stopRecording()
        audioManager.stopRecording()
        isRecording = false
    }
}


#Preview {
    ContentView()
}
