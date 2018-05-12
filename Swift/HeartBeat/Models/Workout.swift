//
//  WorkoutControllerModel.swift
//  HeartBeat
//
//  Created by inailuy on 8/1/16.
//  Copyright © 2016 Mxtapes. All rights reserved.
//

import Foundation
import CloudKit
import CoreData
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}


class Workout: NSManagedObject {
    
    // Insert code here to add functionality to your managed object subclass
    var filteredArrayBeatsPerMinute = NSMutableArray()
    var lastCountedFiltered = Int()
}

extension Workout {
    
    @NSManaged var arrayBeatsPerMinute: NSMutableArray?
    @NSManaged var beatsPerMinuteAverage: NSNumber?
    @NSManaged var caloriesBurned: NSNumber?
    @NSManaged var endTime: Date?
    @NSManaged var savedToCloudKit: NSNumber?
    @NSManaged var savedToHealthKit: NSNumber?
    @NSManaged var secondsElapsed: NSNumber?
    @NSManaged var startTime: Date?
    @NSManaged var workoutType: String?
    @NSManaged var recordName: String?
    @NSManaged var id: String?
    
    /*
    func createWorkout() -> CKRecord {
        let workout = CKRecord()
        workout.arrayBeatsPerMinute = arrayBeatsPerMinute
        workout.beatsPerMinuteAverage = beatsPerMinuteAverage?.integerValue
        workout.caloriesBurned = caloriesBurned?.integerValue
        workout.endTime = endTime
        workout.savedToHealthKit = savedToHealthKit?.boolValue
        workout.savedToCloudKit = savedToCloudKit?.boolValue
        workout.secondsElapsed = secondsElapsed?.integerValue
        workout.startTime = startTime
        workout.workoutType = workoutType
        workout.recordID = CKRecordID(recordName: recordName!)
        
        return workout
    }
    */
    
    
    func withWorkout(_ workout:Workout) {
        arrayBeatsPerMinute = workout.arrayBeatsPerMinute
        beatsPerMinuteAverage = workout.beatsPerMinuteAverage
        caloriesBurned = workout.caloriesBurned
        startTime = workout.startTime
        endTime = workout.endTime
        secondsElapsed = workout.secondsElapsed
        recordName = workout.recordName
        workoutType = workout.workoutType
        id = workout.id

        let priority = DispatchQoS.QoSClass.default
        DispatchQueue.global(qos: priority).async {
            _ = self.filterHeartBeatArray()
        }
    }
    
    func withRecord(_ record:CKRecord) {
        arrayBeatsPerMinute = record.value(forKey: "arrayBeatsPerMinute") as? NSMutableArray
        var temp = record.value(forKey: "beatsPerMinuteAverage") as! NSNumber
        beatsPerMinuteAverage = temp.intValue as NSNumber
        temp = record.value(forKey: "caloriesBurned") as! NSNumber
        caloriesBurned = temp.intValue as NSNumber
        startTime = record.value(forKey: "startTime") as? Date
        endTime = record.value(forKey: "endTime") as? Date
        temp = record.value(forKey: "secondsElapsed") as! NSNumber
        secondsElapsed = temp.intValue as NSNumber
        recordName = record.recordID.recordName
        workoutType = record.value(forKey: "workoutType") as? String
        id = record.value(forKey: "id") as? String
        
        let priority = DispatchQoS.QoSClass.default
        DispatchQueue.global(qos: priority).async {
            _ = self.filterHeartBeatArray()
        }
    }
    
    func createDummy() {
        arrayBeatsPerMinute = [4,6,4,5,5,6,3,35]
        beatsPerMinuteAverage = 5
        caloriesBurned = 150
        startTime = Date()
        endTime = Date()
        secondsElapsed = 1500
        workoutType = "workoutType"
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
        record.setValue(id, forKey: "id")
        
        return record
    }
    /*
    func createWorkoutObject(workout:Workout) {
        arrayBeatsPerMinute = workout.arrayBeatsPerMinute
        beatsPerMinuteAverage = NSNumber(integer: workout.beatsPerMinuteAverage!)
        caloriesBurned = NSNumber(integer: workout.caloriesBurned!)
        endTime = workout.endTime
        secondsElapsed = NSNumber(integer: workout.secondsElapsed!)
        startTime = workout.startTime
        workoutType = workout.workoutType
        recordName = workout.recordID?.recordName
    }
 
    func compareWith(workout: Workout) -> Bool {
        if recordName == workout.recordID?.recordName {
            return true
        }
        return false
    }
    */
    func minutes() -> Int {
        return Int(secondsElapsed!.intValue / 60)
    }
    
    func getTimeFromSeconds(_ seconds: Int) -> String {
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
    
    static func SortDescriptor() -> [NSSortDescriptor]!{
        return [NSSortDescriptor(key: "startTime", ascending: false)]
    }
    //TODO: find a way to only do this once!
    func filterHeartBeatArray() -> NSMutableArray {
        if filteredArrayBeatsPerMinute.count > 0 && arrayBeatsPerMinute?.count == lastCountedFiltered {
            return filteredArrayBeatsPerMinute
        }
        
        var max = 0
        if arrayBeatsPerMinute?.count < 999 {
            max = 2
        } else if arrayBeatsPerMinute?.count < 4999 {
            max = 6
        } else {
            max = 8
        }
        
        let array = NSMutableArray()
        var tmpArray = [Int]()
        for i in 0..<arrayBeatsPerMinute!.count {
            if i % max == 0 && i != 0 {
                var tmpI = 0
                for x in tmpArray {
                    tmpI += x
                }
                array.add(NSNumber(value: tmpI / tmpArray.count as Int))
                tmpArray.removeAll()
            } else {
                let value = arrayBeatsPerMinute![i] as! NSNumber
               tmpArray.append(value.intValue)
            }
        }
        
        filteredArrayBeatsPerMinute = array
        lastCountedFiltered = arrayBeatsPerMinute!.count
        return array
    }
}
