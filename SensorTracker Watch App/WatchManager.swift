//
//  WatchManager.swift
//  SensorTracker Watch App
//
//

import Foundation
import WatchConnectivity
import SwiftUI

class WatchConnectivityManager: NSObject, ObservableObject, WCSessionDelegate {
    static let shared = WatchConnectivityManager()

    var motionManager = MotionManager()
    var audioManager = AudioManager()
    var workoutManager = WorkoutManager()
    
    @Published var recordingText: String = "Not recording..."
    @Published var samplingRate: Double = 25.0
    @Published var ipAddress: String = "10.150.68.148"
    
    @State var socketClient: SocketClient?
    
    override init() {
        super.init()
        motionManager = MotionManager()
        audioManager = AudioManager()
        workoutManager = WorkoutManager()
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }
    
    
    func createSocketConnection(ip: String) {
        let port = 8002
        let deviceIdentifier = "left"
        print("Try to connect \(ip):\(port) with device id \(deviceIdentifier)")
        socketClient = SocketClient(ip: ip, portInt: UInt16(port), deviceID: deviceIdentifier) { (status) in
            print("Starting socket...")
        }
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        // Handle session activation completion
    }
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        // Handle receiving application context, update your properties here
        DispatchQueue.main.async { // Ensure UI updates happen on the main thread
            if let frequency = applicationContext["samplingRate"] as? Double {
                self.motionManager.setSamplingRate(value: frequency)
                self.recordingText = "Sampling Rate: \(frequency)"
                self.samplingRate = frequency
                print("Recevied Sampling Rate: \(self.samplingRate)")
            }
            
            if let ip = applicationContext["ipAddress"] as? String {
                self.ipAddress = ip
                // self.createSocketConnection(ip: ip)
                print("Received IP address: \(self.ipAddress)")
            }
            
            if let command = applicationContext["command"] as? String {
                switch command {
                case "start":
                    print("WatchManager: Starting...")
                    self.recordingText = "Recording..."
                    self.motionManager.setSamplingRate(value: self.samplingRate)
                    self.motionManager.startRecording()
                    self.audioManager.startRecording()
                    self.workoutManager.startWorkout()
                case "stop":
                    print("Watch Ending...")
                    self.recordingText = "Not recording..."
                    self.motionManager.stopRecording()
                    self.audioManager.stopRecording()
                    self.workoutManager.endWorkout()
                default:
                    break
                }
            }
        }
    }
    
    // Handle incoming messages
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        if let request = message["requestSamplingRate"] as? Bool, request == true {
            replyHandler(["samplingRate": self.samplingRate])
        }
        
        // Handle other messages
    }
}

