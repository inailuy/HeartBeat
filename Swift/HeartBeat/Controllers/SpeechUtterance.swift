//
//  SpeechUtterance.swift
//  HeartBeat
//
//  Created by inailuy on 7/6/16.
//  Copyright © 2016 Mxtapes. All rights reserved.
//

import Foundation
import AVFoundation

class SpeechUtterance: NSObject, AVSpeechSynthesizerDelegate {
    static let sharedInstance = SpeechUtterance()
    let UTTERANCE_RATE :Float = 0.45 //speed in which to speak values
    var speechUtterance = AVSpeechUtterance()
    let speechSynthesizer = AVSpeechSynthesizer()
    var canSpeakLimitsValues = Bool()

    // Initiate Class
    override init() {
        super.init()
        speechSynthesizer.delegate = self
        
        let session = AVAudioSession.sharedInstance()
        try! session.setCategory(AVAudioSessionCategoryPlayback, with: .duckOthers)
        try! session.setActive(true)
    }
    // Create All Spoken Cues
    func speakStartWorkout() {
        let utter = "starting workout"
        speak(utter)
    }
    
    func speakWorkoutValues() {
        let workoutController = WorkoutController.sharedInstance
        let user = UserSettings.sharedInstance
        let comma = ", "
        var check = NSNumber()
        var utter = String()
        //elapsed time
        check = user.spokenCues[0] as! NSNumber
        if check.boolValue {
            let min = workoutController.minutes == 1 ? "minute" : "minutes"
            utter = String(format: "time, %d %@, ", workoutController.minutes, min)
        }
        //current hearbeat
        check = user.spokenCues[1] as! NSNumber
        if check.boolValue {
            let str = "current heart rate " + workoutController.currentBPM() + comma
            utter = utter + str
        }
        //average heartbeat
        check = user.spokenCues[2] as! NSNumber
        if check.boolValue {
            let str = "average heart rate " + String(workoutController.averageBPMInt()) + comma
            utter = utter + str
        }
        //calories burned
        check = user.spokenCues[3] as! NSNumber
        if check.boolValue {
            let str = "calories burned " + String(workoutController.caloriesBurned) + comma
            utter = utter + str
        }
        speak(utter)
    }
    
    func speakPauseValues() {
        var utter = "resuming workout"
        if WorkoutController.sharedInstance.pause {
            utter = "pausing workout"
        }
        speak(utter)
    }
    
    func speakCompletedWorkoutValues() {//TODO: better complete sentence
        let utter = "workout complete"
        speak(utter)
    }
    
    func speakBPMValue() {
        if canSpeakLimitsValues == false {
            var speech = ""
            if Bluetooth.sharedInstance.beatPerMinuteValue > UserSettings.sharedInstance.maximunBPM &&
            UserSettings.sharedInstance.maximunBPM != 0{
                speech = String(format: "You have passed your max limit of %i bpm", UserSettings.sharedInstance.maximunBPM)
            } else if Bluetooth.sharedInstance.beatPerMinuteValue < UserSettings.sharedInstance.minimumBPM &&
            UserSettings.sharedInstance.minimumBPM != 0{
                speech = String(format: "You have passed your minimum limit of %i bpm", UserSettings.sharedInstance.minimumBPM)
            }
            if speech != "" {
                canSpeakLimitsValues = true
                Timer.scheduledTimer(timeInterval: 45.0, target: self, selector: #selector(SpeechUtterance.resetSpeechLimits), userInfo:nil, repeats: false)
            }
        }
    }
    
    @objc func resetSpeechLimits() {
        canSpeakLimitsValues = false
    }
    
    // Talk
    func speak(_ utter:String) {
        if UserSettings.sharedInstance.mute { return }
        
        speechUtterance = AVSpeechUtterance(string: utter)
        speechUtterance.rate = UTTERANCE_RATE
        speechSynthesizer.speak(speechUtterance)
    }
    //MARK: AVSpeechSynthesizerDelegate
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        do {
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
        
        }
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        do {
            try AVAudioSession.sharedInstance().setActive(false)
        } catch { }
    }
}
