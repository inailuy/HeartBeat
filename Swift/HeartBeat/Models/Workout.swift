//
//  WorkoutControllerModel.swift
//  HeartBeat
//
//  Created by inailuy on 8/1/16.
//  Copyright © 2016 Mxtapes. All rights reserved.
//

import Foundation
import CloudKit

struct Workout {
    var arrayBeatsPerMinute :NSMutableArray?
    var beatsPerMinuteAverage :Int?
    var caloriesBurned :Int?
    
    var startTime :NSDate?
    var endTime :NSDate?
    var secondsElapsed :Int?
    
    var distancedTraveled :Double?
    var arrayGPSCoordinates :[Double]?//TODO: Wrong array type
    
    var workoutType :String!
    var interations :Int?
    
    var recordID :CKRecordID?
    
    var savedToHealthKit :Bool?
   
    
    init() {
        workoutType = "Cardio"
    }
    
    init(record:CKRecord) {
        arrayBeatsPerMinute = record.valueForKey("arrayBeatsPerMinute") as? NSMutableArray
        var temp = record.valueForKey("beatsPerMinuteAverage") as! NSNumber
        beatsPerMinuteAverage = temp.integerValue
        temp = record.valueForKey("caloriesBurned") as! NSNumber
        caloriesBurned = temp.integerValue
        startTime = record.valueForKey("startTime") as? NSDate
        endTime = record.valueForKey("endTime") as? NSDate
        temp = record.valueForKey("secondsElapsed") as! NSNumber
        secondsElapsed = temp.integerValue
        recordID = record.recordID
        workoutType = record.valueForKey("workoutType") as? String
    }
    
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
    
    func record() -> CKRecord {
        let record = CKRecord(recordType: recordType)
        
        record.setValue(arrayBeatsPerMinute, forKey: "arrayBeatsPerMinute")
        record.setValue(beatsPerMinuteAverage, forKey: "beatsPerMinuteAverage")
        record.setValue(startTime, forKey: "startTime")
        record.setValue(endTime, forKey: "endTime")
        record.setValue(secondsElapsed, forKey: "secondsElapsed")
        record.setValue(caloriesBurned, forKey: "caloriesBurned")
        record.setValue(workoutType, forKey: "workoutType")
        
        return record
    }
    
    static func SortDescriptor() -> [NSSortDescriptor]!{
       return [NSSortDescriptor(key: "startTime", ascending: false)]
    }
}