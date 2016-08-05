//
//  WorkoutControllerModel.swift
//  HeartBeat
//
//  Created by inailuy on 8/1/16.
//  Copyright © 2016 Mxtapes. All rights reserved.
//

import Foundation

struct Workout {
    var arrayBeatsPerMinute :NSMutableArray?
    var beatsPerMinuteAverage :Int?
    var caloriesBurned :Int?
    
    var startTime :NSDate?
    var endTime :NSDate?
    //var timeElapsed :NSDate?
    var secondsElapsed :Int?
    
    var distancedTraveled :Double?
    var arrayGPSCoordinates :[Double]?//TODO: Wrong array type
    
    var workoutType :String?
    var interations :Int?
    
    func minutes() -> Int {
        return Int(secondsElapsed! / 60)
    }
    
    func getTimeFromSeconds(seconds: Int) -> String {
        let sec = seconds % 60
        let minutes = seconds / 60
        return String(format: "%02d:%02d", minutes, sec)
    }
    
    func averageBPMString() -> String {
        var average = 0
        for bpm in arrayBeatsPerMinute!{
            average += bpm as! Int
        }
        return String(average / arrayBeatsPerMinute!.count)
    }
}