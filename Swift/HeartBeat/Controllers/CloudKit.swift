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

class CloudKit {
    
    static let sharedInstance =  CloudKit()
    
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
    
    //MARK: Query
    func queryPublicDatabaseForRecord(type:String, with sortDescriptors:[NSSortDescriptor]?, completion: (results: [CKRecord]) -> Void) {
        queryWithRecord(recordType, with: publicDB, and: sortDescriptors, completion: { results in
            completion(results: results)
        })
    }
    
    func queryPrivateDatabaseForRecord(type:String, with sortDescriptors:[NSSortDescriptor]?, completion: (results: [CKRecord]) -> Void) {
        queryWithRecord(recordType, with: privateDB, and: sortDescriptors, completion: { results in
            completion(results: results)
        })
    }
    
    func queryWithRecord(type:String, with database: CKDatabase, and sortDescriptors:[NSSortDescriptor]?, completion: (results: [CKRecord]) -> Void) {
        let query = CKQuery(recordType: recordType, predicate: NSPredicate(format: truePredicate, argumentArray: nil))
        if sortDescriptors != nil {
            query.sortDescriptors = sortDescriptors!
        }
        database.performQuery(query, inZoneWithID: nil) { results, error in
            if error == true {
                self.printError(error!)
            }
            else {
                completion(results: results!)
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
                let workout = CoreData.sharedInstance.createWorkoutRemote(record!)
                DataController.sharedInstance.workoutArray.insert(workout, atIndex: 0)
                NSNotificationCenter.defaultCenter().postNotificationName(CloudKitWrapperNotificationId, object: nil)
            }
        })
    }
    
    //MARK: Save
    func saveRecordToPublicDatabase(record:CKRecord, completion: (record: CKRecord) -> Void) {
        saveRecord(record, withDatabase: publicDB, completion: { newRecord in
           completion(record: newRecord)
        })
    }
    
    func saveRecordToPrivateDatabase(record:CKRecord, completion: (record: CKRecord) -> Void) {
        saveRecord(record, withDatabase: privateDB, completion: { newRecord in
            completion(record: newRecord)
        })
    }
    
    func saveRecord(record:CKRecord, withDatabase database:CKDatabase, completion: (record: CKRecord) -> Void) {
        database.saveRecord(record) { savedRecord, error in
            completion(record: savedRecord!)
        }
    }
    
    //MARK: Delete
    func deleteRecordFromPublicDatabase(recordID:CKRecordID, completion:(success: Bool) -> Void) {
        deleteRecord(recordID, with: publicDB, completion: { success in
            completion(success: success)
        })
    }
    
    func deleteRecordFromPrivateDatabase(recordID:CKRecordID, completion:(success: Bool) -> Void) {
        deleteRecord(recordID, with: privateDB, completion: { success in
            completion(success: success)
        })
    }
    
    func deleteRecord(recordID:CKRecordID, with dabase:CKDatabase, completion:(success: Bool) -> Void) {
        dabase.deleteRecordWithID(recordID, completionHandler: {recordID, error in
            if error == true {
                self.printError(error!)
                completion(success: false)
            } else {
                completion(success: true)
            }
        })
    }
    
    //TODO:
    //MARK: Debug
    //MARK: Subcriptions
    //MARK: Other
    
    func printError(error:NSError) {
        if UserSettings.sharedInstance.debug {
            print(error.localizedDescription)
        }
    }
}
