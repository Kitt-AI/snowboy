//
//  ViewController.swift
//  Snowboy-example
//
//  Created by Chashmeet Singh on 2017-06-07.
//  Copyright © 2017 Chashmeet Singh. All rights reserved.
//

import UIKit
import AudioKit

class ViewController: UIViewController, EZMicrophoneDelegate {
    
    var microphone: EZMicrophone!
    
    let WAKE_WORD = "Susi"
    let RESOURCE = Bundle.main.path(forResource: "common", ofType: "res")
    let MODEL = Bundle.main.path(forResource: "alexa_02092017", ofType: "umdl")
    
    var wrapper: SnowboyWrapper! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initPermissions()
        initSnowboy()
        initMic()
    }
    
    func initPermissions() {
        AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeAudio, completionHandler: nil)
    }
    
    func initSnowboy() {
        wrapper = SnowboyWrapper(resources: RESOURCE, modelStr: MODEL)
        wrapper.setSensitivity("0.5")
        wrapper.setAudioGain(1.0)
        print("Sample rate: \(wrapper?.sampleRate()); channels: \(wrapper?.numChannels()); bits: \(wrapper?.bitsPerSample())")
    }
    
    func initMic() {
        var audioStreamBasicDescription: AudioStreamBasicDescription = EZAudioUtilities.monoFloatFormat(withSampleRate: 16000)
        audioStreamBasicDescription.mFormatID = kAudioFormatLinearPCM
        audioStreamBasicDescription.mSampleRate = 16000
        audioStreamBasicDescription.mFramesPerPacket = 1
        audioStreamBasicDescription.mBytesPerPacket = 2
        audioStreamBasicDescription.mBytesPerFrame = 2
        audioStreamBasicDescription.mChannelsPerFrame = 1
        audioStreamBasicDescription.mBitsPerChannel = 16
        audioStreamBasicDescription.mFormatFlags = kAudioFormatFlagIsSignedInteger | kAudioFormatFlagsNativeEndian | kAudioFormatFlagIsPacked
        audioStreamBasicDescription.mReserved = 0
    
        microphone = EZMicrophone.shared()
        microphone.delegate = self
        let inputs: [Any] = EZAudioDevice.inputDevices()
        microphone.device = inputs.last as! EZAudioDevice
        microphone.startFetchingAudio()
    }
    
    func microphone(_ microphone: EZMicrophone!, hasAudioReceived buffer: UnsafeMutablePointer<UnsafeMutablePointer<Float>?>!, withBufferSize bufferSize: UInt32, withNumberOfChannels numberOfChannels: UInt32) {
        DispatchQueue.main.async(execute: {() -> Void in
            
            let array = Array(UnsafeBufferPointer(start: buffer.pointee, count:Int(bufferSize)))
            
            let result: Int =  Int(self.wrapper.runDetection(array, length: Int32(bufferSize)))
            if result == 1 {
                print("Hotword Detected")
            }
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        initSnowboy()
    }

}

