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

class CloudController {
    
    static let sharedInstance =  CloudController()
    
    let publicDB = CKContainer.default().publicCloudDatabase
    let privateDB = CKContainer.default().privateCloudDatabase
    
    init() {
//      let predicate = NSPredicate(format: truePredicate, argumentArray: nil)
//       let subscription = CKSubscription(recordType: recordType, predicate: predicate, options:.firesOnRecordCreation)
        
//        privateDB.fetchAllSubscriptions(completionHandler: {nil, error in
//            //TODO:create delete/update subsciptions
//            if error != nil {
//                print(error?.localizedDescription as Any)
//            } else if subscriptions?.count == 0 {
//                self.privateDB.save(subscription, completionHandler: ({ returnedRecord, error in
//                    if (error != nil) {
//                        self.printError(error! as NSError)
//                    }
//                }))
//            }
//        })
    }
    
    //MARK: Query
    func queryPublicDatabaseForRecord(_ type:String, with sortDescriptors:[NSSortDescriptor]?, completion: @escaping (_ results: [CKRecord]) -> Void) {
        queryWithRecord(recordType, with: publicDB, and: sortDescriptors, completion: { results in
            completion(results)
        })
    }
    
    func queryPrivateDatabaseForRecord(_ type:String, with sortDescriptors:[NSSortDescriptor]?, completion: @escaping (_ results: [CKRecord]) -> Void) {
        queryWithRecord(recordType, with: privateDB, and: sortDescriptors, completion: { results in
            completion(results)
        })
    }
    
    func queryWithRecord(_ type:String, with database: CKDatabase, and sortDescriptors:[NSSortDescriptor]?, completion: @escaping (_ results: [CKRecord]) -> Void) {
        let query = CKQuery(recordType: recordType, predicate: NSPredicate(format: truePredicate, argumentArray: nil))
        if sortDescriptors != nil {
            query.sortDescriptors = sortDescriptors!
        }
        database.perform(query, inZoneWith: nil) { results, error in
            if error != nil {
                self.printError(error! as NSError)
            }
            else {
                completion(results!)
            }
        }
    }
    
    func queryPublicDatabaseWithRecordID(_ recordID:CKRecordID) {
        queryWithRecordID(recordID, with: publicDB)
    }
    
    func queryPrivateDatabaseWithRecordID(_ recordID:CKRecordID) {
        queryWithRecordID(recordID, with: privateDB)
    }
    
    func queryWithRecordID(_ recordID:CKRecordID, with databse: CKDatabase) {
        privateDB.fetch(withRecordID: recordID, completionHandler: { record, error in
            if error != nil {
                self.printError(error! as NSError)
            } else {
                let workout = CoreData.sharedInstance.createWorkoutRemote(record!)
                DataController.sharedInstance.workoutArray.insert(workout, at: 0)
                NotificationCenter.default.post(name: Notification.Name(rawValue: CloudKitWrapperNotificationId), object: nil)
            }
        })
    }
    
    //MARK: Save
    func saveRecordToPublicDatabase(_ record:CKRecord, completion: @escaping (_ record: CKRecord) -> Void) {
        saveRecord(record, withDatabase: publicDB, completion: { newRecord in
           completion(newRecord)
        })
    }
    
    func saveRecordToPrivateDatabase(_ record:CKRecord, completion: @escaping (_ record: CKRecord) -> Void) {
        saveRecord(record, withDatabase: privateDB, completion: { newRecord in
            completion(newRecord)
        })
    }
    
    func saveRecord(_ record:CKRecord, withDatabase database:CKDatabase, completion: @escaping (_ record: CKRecord) -> Void) {
        database.save(record, completionHandler: { savedRecord, error in
            completion(savedRecord!)
        }) 
    }
    
    //MARK: Delete
    func deleteRecordFromPublicDatabase(_ recordID:CKRecordID, completion:@escaping (_ success: Bool) -> Void) {
        deleteRecord(recordID, with: publicDB, completion: { success in
            completion(success)
        })
    }
    
    func deleteRecordFromPrivateDatabase(_ recordID:CKRecordID, completion:@escaping (_ success: Bool) -> Void) {
        deleteRecord(recordID, with: privateDB, completion: { success in
            completion(success)
        })
    }
    
    func deleteRecord(_ recordID:CKRecordID, with dabase:CKDatabase, completion:@escaping (_ success: Bool) -> Void) {
        dabase.delete(withRecordID: recordID, completionHandler: {recordID, error in
            if error != nil {
                self.printError(error! as NSError)
                completion(false)
            } else {
                completion(true)
            }
        })
    }
    
    //TODO:
    //MARK: Debug
    //MARK: Subcriptions
    //MARK: Other
    
    func printError(_ error:NSError) {
        if UserSettings.sharedInstance.debug {
            print(error.localizedDescription)
        }
    }
}
