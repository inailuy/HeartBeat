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

    // Initiate Class
    override init() {
        super.init()
        speechSynthesizer.delegate = self
    }
    // Create All Spoken Cues
    func speakStartWorkoutController() {
        let utter = "starting workout"
        speak(utter)
    }
    
    func speakWorkoutControllerValues() {
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
            utter = utter.stringByAppendingString(str)
        }
        //average heartbeat
        check = user.spokenCues[2] as! NSNumber
        if check.boolValue {
            let str = "average heart rate " + String(workoutController.averageBPMInt()) + comma
            utter = utter.stringByAppendingString(str)
        }
        //calories burned
        check = user.spokenCues[3] as! NSNumber
        if check.boolValue {
            let str = "calories burned " + String(workoutController.caloriesBurned) + comma
            utter = utter.stringByAppendingString(str)
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
    
    func speakCompletedWorkoutControllerValues() {//TODO: better complete sentence
        let utter = "workout complete"
        speak(utter)
    }
    // Talk
    func speak(utter:String) {
        if UserSettings.sharedInstance.mute { return } //TODO: initual launch unmutes *BUG*
        
        speechUtterance = AVSpeechUtterance(string: utter)
        speechUtterance.rate = UTTERANCE_RATE
        speechSynthesizer.speakUtterance(speechUtterance)
    }
    //MARK: AVSpeechSynthesizerDelegate
    func speechSynthesizer(synthesizer: AVSpeechSynthesizer, didStartSpeechUtterance utterance: AVSpeechUtterance) {
        do {
            try AVAudioSession.sharedInstance().setActive(true)
        } catch { }
    }
    
    func speechSynthesizer(synthesizer: AVSpeechSynthesizer, didFinishSpeechUtterance utterance: AVSpeechUtterance) {
        do {
            try AVAudioSession.sharedInstance().setActive(false)
        } catch { }
    }
}