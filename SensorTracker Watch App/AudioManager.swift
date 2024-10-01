//
//  AudioManager.swift
//  SensorTracker Watch App
//
//

import WatchKit
import AVFoundation
import CloudKit


class AudioManager: NSObject, AVAudioRecorderDelegate {
    var audioURL: URL!
    var timeURL: URL!
    var recorder: AVAudioRecorder?
    var audioPlayer: AVAudioPlayer!
    var timeText = ""
    
    override init() {
        audioURL = FileManager.default.getDocumentsDirectory().appendingPathComponent("test_audio.wav")
        timeURL = FileManager.default.getDocumentsDirectory().appendingPathComponent("test_audiotime.txt")
    }
    
    func startRecording() {
        let settings = [
          AVFormatIDKey: Int(kAudioFormatLinearPCM),
          AVSampleRateKey: 32000,
          AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        do {
            recorder = try AVAudioRecorder(url: audioURL, settings: settings)
            recorder?.delegate = self
            recorder?.record()
            timeText += "Start time: \(NSDate().timeIntervalSince1970) \n"
            print("Starting recording...")
        } catch {
            print("Recording failed...")
        }
    }
    
    func stopRecording() {
        recorder?.stop()
        timeText += "End time: \(NSDate().timeIntervalSince1970)"
        print("Ending recording...")
        do {
            try timeText.write(to: timeURL, atomically: true, encoding: .utf8)
        } catch {
            print("Error", error)
        }
        recorder = nil
    }
    
    func setupView() {
        Task {
            if await AVAudioApplication.requestRecordPermission() {
                // allow recording
            }
            else {
                print("Failed to record!")
            }
        }
    }
}

