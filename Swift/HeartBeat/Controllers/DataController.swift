//
//  DataController.swift
//  HeartBeat
//
//  Created by inailuy on 9/3/16.
//  Copyright © 2016 Mxtapes. All rights reserved.
//

import Foundation
import CloudKit
import CoreData

let DataControllerNotificationId = "DataControllerNotificationId"

class DataController {
    
    static let sharedInstance = DataController()
    var isCloudKitAvailable = Bool()
    var workoutArray = [Workout]()
    
    init() {
        CKContainer.default().accountStatus { (accountStat, error) in
            if (accountStat == .available) {
                print("iCloud is available")
                self.isCloudKitAvailable = true
            }
            else {
                print("iCloud is not available")
                self.isCloudKitAvailable = false
            }
        }
    }
    
    //MARK: Fetch
    func load() {
        CoreData.sharedInstance.fetchAllWorkouts(withpredicate: nil, completion: { array in
            self.workoutArray = array
            if self.isCloudKitAvailable {
                CloudKit.sharedInstance.queryPrivateDatabaseForRecord(recordType, with: Workout.SortDescriptor(), completion: { results in
                    var array = [Workout]()
                    
                    for record in results {
                        let predicate = CoreData.sharedInstance.createPredicate("recordName", value: record.recordID.recordName)
                        if CoreData.sharedInstance.checkIfWorkoutExists(predicate) == nil {
                            // record doesn't exist create locally
                            let workout = CoreData.sharedInstance.createWorkoutRemote(record)
                            array.append(workout)
                        }
                    }
                    self.workoutArray += array
                    self.postNotification()
                })
            }
            
            self.postNotification()
        })
    }
    
    func loadAll() {
        CoreData.sharedInstance.fetchAllWorkouts(withpredicate: nil, completion: { array in
            self.workoutArray = array
            self.postNotification()
            
            if self.isCloudKitAvailable {
                CloudKit.sharedInstance.queryPrivateDatabaseForRecord(recordType, with: Workout.SortDescriptor(), completion: { results in
                    var array = [Workout]()
                    
                    for record in results {
                        let predicate = CoreData.sharedInstance.createPredicate("recordName", value: record.recordID.recordName)
                        if CoreData.sharedInstance.checkIfWorkoutExists(predicate) == nil {
                            // record doesn't exist create locally
                            let workout = CoreData.sharedInstance.createWorkoutRemote(record)
                            array.append(workout)
                        }
                    }
                    self.workoutArray += array
                    self.postNotification()
                })
            }
        })
    }
    
    //MARK: Add
    func createWorkout(_ workout:Workout, completion:(_ success: Bool) -> Void) {
        var w = workout
        CoreData.sharedInstance.createWorkoutLocal(&w)
        if self.isCloudKitAvailable {
            CloudKit.sharedInstance.saveRecordToPrivateDatabase(w.record(), completion: { record in
                w.recordName = record.recordID.recordName
                CoreData.sharedInstance.saveDatabase()
            })
        }
        self.workoutArray.insert(w, at: 0)
        postNotification()
        completion(true)
    }
    
    //MARK: Delete
    func deleteWorkout(_ workout: Workout, completion:@escaping (_ success: Bool) -> Void) {
        if workout.recordName != nil {
            
            // check if workout exist in CK
            let recordID = CKRecordID(recordName: workout.recordName!)
            if isCloudKitAvailable {
                CloudKit.sharedInstance.deleteRecordFromPrivateDatabase(recordID, completion: { success in
                    if success {
                        CoreData.sharedInstance.deleteWorkout(workout, completion: { success in
                            completion(success)
                        })
                    } else {
                        completion(success)
                    }
                })
            }
        } else {
            CoreData.sharedInstance.deleteWorkout(workout, completion: { success in
                completion(success)
            })
        }
        
    }
    
    //MARK: Other
    func postNotification() {
        NotificationCenter.default.post(name: Notification.Name(rawValue: DataControllerNotificationId), object: nil)
    }
    
    //MARK: Examples
    func exampleCreateWorkout() { // Complete demonstration of CD + CK save integration
        // create empty workout
        let w = CoreData.sharedInstance.createEmptyWorkout()
        
        // populate
        w.createDummy()
        
        // create
        createWorkout(w, completion: { success in
            if success {
                print("success")
            }
        })
    }
    
    func exampleFetchAll() {
        CoreData.sharedInstance.fetchAllWorkouts(withpredicate: nil, completion: { array in
            
            // update model CD
            self.workoutArray = array
            
            // print results
            CoreData.sharedInstance.printNumberOfEntities()
            
            // update model CK
            CloudKit.sharedInstance.queryPrivateDatabaseForRecord(recordType, with: Workout.SortDescriptor(), completion: { results in
                var array = [Workout]()
                
                for record in results {
                    let predicate = CoreData.sharedInstance.createPredicate("recordName", value: record.recordID.recordName)
                    if CoreData.sharedInstance.checkIfWorkoutExists(predicate) == nil {
                        // record doesn't exist create locally
                        let workout = CoreData.sharedInstance.createWorkoutRemote(record)
                        array.append(workout)
                    }
                }
                print(array.count)
                
                // update model CK
                self.workoutArray += array
                
                // print results
                CoreData.sharedInstance.printNumberOfEntities()
                
                // notify
                self.postNotification()
            })
            
            // notify
            self.postNotification()
        })
    }
    
    func exampleDelete() {
        CoreData.sharedInstance.printNumberOfEntities()
        
        // create enviorment
        CoreData.sharedInstance.fetchAllWorkouts(withpredicate: nil, completion: { array in
            self.workoutArray = array
            let w = self.workoutArray.first
            
            // delete
            self.deleteWorkout(w!, completion: { success in
                // filter array
                self.workoutArray = self.workoutArray.filter() { $0 !== w }
                
                // print result
                CoreData.sharedInstance.printNumberOfEntities()
            })
        })
    }
}
