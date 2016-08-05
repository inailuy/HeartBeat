//
//  WorkoutController.swift
//  HeartBeat
//
//  Created by inailuy on 7/2/16.
//  Copyright © 2016 Mxtapes. All rights reserved.
//

import Foundation

class WorkoutController {
    static let sharedInstance = WorkoutController()
    var workout :Workout?
    
    var pause = Bool()
    var caloriesBurned = Int()
    var heartBeatArray = NSMutableArray()
    var timer = NSTimer()
    var seconds = Int()
    var minutes = Int()
    weak var delegate:WorkoutControllerDelegate?
    
    func startWorkout() {
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(WorkoutController.secondsInterval), userInfo: nil, repeats: true)
        seconds = 0
        pause = false
        SpeechUtterance.sharedInstance.speakStartWorkoutController()
        
        workout = Workout()
        workout?.startTime = NSDate()
    }
    
    func pauseWorkoutController() {
        if pause == false {
            timer.pause()
        } else {
            timer.resume()
        }
        pause = !pause
        SpeechUtterance.sharedInstance.speakPauseValues()
    }
    
    func endWorkoutController() {
        timer.pause()
        SpeechUtterance.sharedInstance.speakCompletedWorkoutControllerValues()
        //populating workout
        workout!.arrayBeatsPerMinute = heartBeatArray
        workout!.caloriesBurned = caloriesBurned
        workout!.secondsElapsed = seconds
        workout!.beatsPerMinuteAverage = averageBPMInt()
        workout!.endTime = NSDate()
        print(workout.debugDescription)
        //TODO: create a save model mechanism
    }
    
    @objc func secondsInterval()  {
        let ran = Int(arc4random_uniform(200) + 1)
        let bpm = /*Bluetooth.sharedInstance.beatPerMinuteValue*/ran
        //add beats to array
        heartBeatArray.addObject(bpm)
        //modify variables
        seconds += 1
        //refreash UI
        delegate?.updateUI(self)
        //speech utter
        let audioTiming = UserSettings.sharedInstance.audioTiming
        if audioTiming != 0 && minutes % audioTiming == 0 && seconds % 60 == 0 {
            SpeechUtterance.sharedInstance.speakWorkoutControllerValues()
        }
    }
    
    func grabVO2MaxData()  -> String{
        //create instances
        let user = UserSettings.sharedInstance
        let vo2max = VO2Max(sex: user.sex)
        //assign variables
        let minutes = Double(self.minutes)
        let age = vo2max.modifyAge(Double(user.age))
        let weight = vo2max.modifyWeight(Double(user.weight))
        let bpm = vo2max.modifyBPM(Double(Bluetooth.sharedInstance.beatPerMinuteValue))
        //calculate burn rate
        caloriesBurned = vo2max.calculateVO2Max(age, weight: weight, bpm: bpm, minutes: minutes)
        //return as string
        return String(caloriesBurned)
    }
    
    func getTimeStr() -> String {
        let sec = seconds % 60
        minutes = seconds / 60
        return String(format: "%02d:%02d", minutes, sec)
    }
    
    func getTimeFromSeconds(seconds: Int) -> String {
        let sec = seconds % 60
        minutes = seconds / 60
        return String(format: "%02d:%02d", minutes, sec)
    }
    
    func averageBPMString() -> String {
        var average = 0
        for bpm in heartBeatArray{
            average += bpm as! Int
        }
        return String(average / heartBeatArray.count)
    }
    
    func averageBPMInt() -> Int {
        if heartBeatArray.count < 3 { return 0 }
        
        var average = 0
        for bpm in heartBeatArray{
            average += bpm as! Int
        }
        
        return average / heartBeatArray.count
    }
    
    func currentBPM() -> String {
        return String(Bluetooth.sharedInstance.beatPerMinuteValue)
    }
}

protocol WorkoutControllerDelegate: class {
    func updateUI(sender: WorkoutController)
}