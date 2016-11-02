//
//  WorkoutObj+CoreDataProperties.swift
//  HeartBeat
//
//  Created by inailuy on 8/30/16.
//  Copyright © 2016 Mxtapes. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension WorkoutObj {

    @NSManaged var arrayBeatsPerMinute: NSObject?
    @NSManaged var beatsPerMinuteAverage: NSNumber?
    @NSManaged var caloriesBurned: NSNumber?
    @NSManaged var endTime: NSDate?
    @NSManaged var savedToCloudKit: NSNumber?
    @NSManaged var savedToHealthKit: NSNumber?
    @NSManaged var secondsElapsed: NSNumber?
    @NSManaged var startTime: NSDate?
    @NSManaged var workoutType: String?

}
