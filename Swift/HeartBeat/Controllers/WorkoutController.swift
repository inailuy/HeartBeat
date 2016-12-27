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
        heartBeatArray.removeAllObjects()
        seconds = 0
        pause = false
        SpeechUtterance.sharedInstance.speakStartWorkout()
        
        workout = CoreData.sharedInstance.createEmptyWorkout()
        workout?.startTime = NSDate()
    }
    
    func pauseWorkout() {
        if pause == false {
            timer.pause()
        } else {
            timer.resume()
        }
        pause = !pause
        SpeechUtterance.sharedInstance.speakPauseValues()
    }
    
    func endWorkout() {
        timer.pause()
        //populating workout
        workout!.arrayBeatsPerMinute = heartBeatArray
        workout!.caloriesBurned = caloriesBurned
        workout!.secondsElapsed = seconds
        workout!.beatsPerMinuteAverage = averageBPMInt()
        workout!.endTime = NSDate()
    }
    
    func saveWorkout() {
        SpeechUtterance.sharedInstance.speakCompletedWorkoutValues()
        Health.sharedInstance.saveWorkoutToHealthKit(workout!)
        
        DataController.sharedInstance.createWorkout(workout!, completion: { success in })
    }
    
    @objc func secondsInterval()  {
        let bpm = Int(Bluetooth.sharedInstance.beatPerMinuteValue)
        //add beats to array
        heartBeatArray.addObject(bpm)
        //modify variables
        seconds += 1
        //refreash UI
        delegate?.updateUI(self)
        //speech utter
        let audioTiming = UserSettings.sharedInstance.audioTiming
        if audioTiming != 0 && minutes % audioTiming == 0 && seconds % 60 == 0 {
            SpeechUtterance.sharedInstance.speakWorkoutValues()
        }
        SpeechUtterance.sharedInstance.speakBPMValue()
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
        return String(heartBeatArray.lastObject!)
    }
    
    func filterHeartBeatArray() -> NSMutableArray {
        var max = 0
        if heartBeatArray.count < 999 {
            max = 2
        } else if heartBeatArray.count < 4999 {
            max = 6
        } else {
            max = 8
        }
        
        let array = NSMutableArray()
        var tmpArray = [Int]()
        for i in 0..<heartBeatArray.count {
            if i % max == 0 && i != 0 {
                var tmpI = 0
                for x in tmpArray {
                    tmpI += x
                }
                array.addObject(NSNumber(integer: tmpI / tmpArray.count))
                tmpArray.removeAll()
            } else {
                let value = heartBeatArray[i] as! NSNumber
                tmpArray.append(value.integerValue)
            }
        }

        return array
    }
}

protocol WorkoutControllerDelegate: class {
    func updateUI(sender: WorkoutController)
}
