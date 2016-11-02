//
//  CloudKitWrapper.swift
//  HeartBeat
//
//  Created by inailuy on 8/5/16.
//  Copyright © 2016 Mxtapes. All rights reserved.
//

import Foundation
import CloudKit

let CloudKitWrapperNotificationId = "CloudKitWrapper"
let recordType = "Workout"
let truePredicate = "TRUEPREDICATE"

class CloudKitWrapper {
    static let sharedInstance = CloudKitWrapper()
    
    let publicDB = CKContainer.defaultContainer().publicCloudDatabase
    let privateDB = CKContainer.defaultContainer().privateCloudDatabase
    
    init() {
        let predicate = NSPredicate(format: truePredicate, argumentArray: nil)
        let subscription = CKSubscription(recordType: recordType, predicate: predicate, options:.FiresOnRecordCreation)
        
        privateDB.fetchAllSubscriptionsWithCompletionHandler({subscriptions, error in
            //TODO:create delete/update subsciptions
            if error != nil {
                print(error?.localizedDescription)
            } else if subscriptions?.count == 0 {
                self.privateDB.saveSubscription(subscription, completionHandler: ({ returnedRecord, error in
                    if error == true {
                        self.printError(error!)
                    }
                }))
            }
        })
    }
    
    func saveRecordToPublicDatabase(record:CKRecord) {
        saveRecord(record, withDatabase: publicDB)
    }
    
    func saveRecordToPrivateDatabase(record:CKRecord) {
        saveRecord(record, withDatabase: privateDB)
    }
    
    func saveRecord(record:CKRecord, withDatabase database:CKDatabase) {
        database.saveRecord(record) { savedRecord, error in
            // handle errors here
            /*
             if let retryAfterValue = error!.userInfo[CKErrorRetryAfterKey] as? NSTimeInterval {
             let retryAfterDate = NSDate(timeIntervalSinceNow: retryAfterValue)
             // TODO:create retry save mechanism
             }
             */
            if error == true {
                self.printError(error!)
            } else {
                let workout = Workout(record: savedRecord!)
                WorkoutController.sharedInstance.workoutArray?.insert(workout, atIndex: 0)
                NSNotificationCenter.defaultCenter().postNotificationName(CloudKitWrapperNotificationId, object: nil)
            }
        }
    }
    
    func queryPublicDatabaseForRecord(type:String, with sortDescriptors:[NSSortDescriptor]?) {
        queryWithRecord(recordType, with: publicDB, and: sortDescriptors)
    }
    
    func queryPrivateDatabaseForRecord(type:String, with sortDescriptors:[NSSortDescriptor]?) {
        queryWithRecord(recordType, with: privateDB, and: sortDescriptors)
    }
    
    func queryWithRecord(type:String, with database: CKDatabase, and sortDescriptors:[NSSortDescriptor]?) {
        let query = CKQuery(recordType: recordType, predicate: NSPredicate(format: truePredicate, argumentArray: nil))
        if sortDescriptors != nil {
            query.sortDescriptors = sortDescriptors!
        }
        database.performQuery(query, inZoneWithID: nil) { results, error in
            if error == true {
                self.printError(error!)
            }
            else {
                var array = [Workout]()
                for record in results! {
                    let workout = Workout(record: record)
                    array.append(workout)
                }
                WorkoutController.sharedInstance.workoutArray = array
                NSNotificationCenter.defaultCenter().postNotificationName(CloudKitWrapperNotificationId, object: nil)
            }
        }
    }
    
    func queryPublicDatabaseWithRecordID(recordID:CKRecordID) {
        queryWithRecordID(recordID, with: publicDB)
    }
    
    func queryPrivateDatabaseWithRecordID(recordID:CKRecordID) {
        queryWithRecordID(recordID, with: privateDB)
    }
    
    func queryWithRecordID(recordID:CKRecordID, with databse: CKDatabase) {
        privateDB.fetchRecordWithID(recordID, completionHandler: { record, error in
            if error == true {
                self.printError(error!)
            } else {
                let workout = Workout(record: record!)
                WorkoutController.sharedInstance.workoutArray?.insert(workout, atIndex: 0)
                NSNotificationCenter.defaultCenter().postNotificationName(CloudKitWrapperNotificationId, object: nil)
            }
        })
    }
    
    func deleteRecordFromPublicDatabase(recordID:CKRecordID) {
        deleteRecord(recordID, with: publicDB)
    }
    
    func deleteRecordFromPrivateDatabase(recordID:CKRecordID) {
        deleteRecord(recordID, with: privateDB)
    }
    
    func deleteRecord(recordID:CKRecordID, with dabase:CKDatabase) {
        dabase.deleteRecordWithID(recordID, completionHandler: {recordID, error in
            if error == true {
                self.printError(error!)
            } else {
                let arr = WorkoutController.sharedInstance.workoutArray!.filter( {$0.recordID != recordID} )
                WorkoutController.sharedInstance.workoutArray = arr
                NSNotificationCenter.defaultCenter().postNotificationName(CloudKitWrapperNotificationId, object: recordID)
            }
        })
    }
    
    func printError(error:NSError) {
        if UserSettings.sharedInstance.debug {
            print(error.localizedDescription)
        }
    }
}