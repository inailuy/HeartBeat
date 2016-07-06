//
//  Workout.swift
//  HeartBeat
//
//  Created by inailuy on 7/2/16.
//  Copyright © 2016 Mxtapes. All rights reserved.
//

import Foundation

class Workout {

    var pause = Bool()
    var caloriesBurned = Int()
    var heartBeatArray = NSMutableArray()
    var timer = NSTimer()
    var seconds = Int()
    var minutes = Int()
    static let sharedInstance = Workout()
    weak var delegate:WorkoutDelegate?
    
    func startWorkout() {
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(Workout.secondsInterval), userInfo: nil, repeats: true)
        seconds = 0
        pause = false
    }
    
    @objc func secondsInterval()  {
        let bpm = Bluetooth.sharedInstance.beatPerMinuteValue
        //add beats to array
        heartBeatArray.addObject(bpm)
        //modify variables
        seconds += 1
        //refreash UI
        delegate?.updateUI(self)
    }
    
    func pauseWorkout() {
        if pause == false {
            timer.pause()
        } else {
            timer.resume()
        }
        pause = !pause
    }
    
    func endWorkout() {
        timer.pause()
        //TODO: create a save model mechanism
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
        let caloriesBurned = vo2max.calculateVO2Max(age, weight: weight, bpm: bpm, minutes: minutes)
        //return as string
        return String(Int(caloriesBurned))
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

protocol WorkoutDelegate: class {
    func updateUI(sender: Workout)
}