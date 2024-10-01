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
