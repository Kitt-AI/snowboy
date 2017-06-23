//
//  ViewController.swift
//  SnowboyTest
//
//  Created by Bi, Sheng on 2/13/17.
//  Copyright © 2017 Bi, Sheng. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVAudioRecorderDelegate, AVAudioPlayerDelegate {
    
    @IBOutlet weak var instructionLabel: UILabel!
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var btn: UIButton!
    
    let WAKE_WORD = "Alexa"
    let RESOURCE = Bundle.main.path(forResource: "common", ofType: "res")
    let MODEL = Bundle.main.path(forResource: "alexa_02092017", ofType: "umdl")
    
    var wrapper: SnowboyWrapper! = nil
    
    var audioRecorder: AVAudioRecorder!
    var audioPlayer: AVAudioPlayer!
    var soundFileURL: URL!

    var timer: Timer!
    var isStarted = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        wrapper = SnowboyWrapper(resources: RESOURCE, modelStr: MODEL)
        wrapper.setSensitivity("0.5")
        wrapper.setAudioGain(1.0)
        print("Sample rate: \(wrapper?.sampleRate()); channels: \(wrapper?.numChannels()); bits: \(wrapper?.bitsPerSample())")
    }

    @IBAction func onClickBtn(_ sender: Any) {
        if (isStarted) {
            stopRecording()
            timer.invalidate()
            btn.setTitle("Start", for: .normal)
            isStarted = false
        } else {
            timer = Timer.scheduledTimer(timeInterval: 4, target: self, selector: #selector(startRecording), userInfo: nil, repeats: true)
            timer.fire()
            btn.setTitle("Stop", for: .normal)
            isStarted = true
        }
    }
    
    func runSnowboy() {

        let file = try! AVAudioFile(forReading: soundFileURL)
        let format = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: 16000.0, channels: 1, interleaved: false)
        let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: AVAudioFrameCount(file.length))
        try! file.read(into: buffer)
        let array = Array(UnsafeBufferPointer(start: buffer.floatChannelData![0], count:Int(buffer.frameLength)))
        
        print("Frame capacity: \(AVAudioFrameCount(file.length))")
        print("Int16 channel array: \(array)")
        print("Buffer frame length: \(buffer.frameLength)")

        let result = wrapper.runDetection(array, length: Int32(buffer.frameLength))
        resultLabel.text = "Snowboy result: \(result)"
        print("Result: \(result)")
    }
    
    func startRecording() {
        do {
            let fileMgr = FileManager.default
            let dirPaths = fileMgr.urls(for: .documentDirectory,
                                        in: .userDomainMask)
            soundFileURL = dirPaths[0].appendingPathComponent("temp.wav")
            let recordSettings =
                [AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue,
                 AVEncoderBitRateKey: 128000,
                 AVNumberOfChannelsKey: 1,
                 AVSampleRateKey: 16000.0] as [String : Any]
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(AVAudioSessionCategoryRecord)
            try audioRecorder = AVAudioRecorder(url: soundFileURL,
                                                settings: recordSettings as [String : AnyObject])
            audioRecorder.delegate = self
            audioRecorder.prepareToRecord()
            audioRecorder.record(forDuration: 2.0)
            instructionLabel.text = "Speak wake word: \(WAKE_WORD)"
            
            print("Started recording...")
        } catch let error {
            print("Audio session error: \(error.localizedDescription)")
        }
    }
    
    func stopRecording() {
        if (audioRecorder != nil && audioRecorder.isRecording) {
            audioRecorder.stop()
        }
        instructionLabel.text = "Stop"
        print("Stopped recording...")
    }
    
    func playAudio() {
        do {
            try audioPlayer = AVAudioPlayer(contentsOf:(soundFileURL))
            audioPlayer!.delegate = self
            audioPlayer!.prepareToPlay()
            audioPlayer!.play()
        } catch let error {
            print("Audio player error: \(error.localizedDescription)")
        }
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        print("Audio Recorder did finish recording.")
        stopRecording()
        runSnowboy()
    }
    
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        print("Audio Recorder encode error.")
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        print("Audio player did finish playing.")
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        print("Audio player decode error.")
    }
}

