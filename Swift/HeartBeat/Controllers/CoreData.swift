//
//  CoreData.swift
//  HeartBeat
//
//  Created by inailuy on 8/29/16.
//  Copyright © 2016 Mxtapes. All rights reserved.
//

import Foundation
import CoreData
import CloudKit
import UIKit

let workoutEntityName = "Workout"

class CoreData {
    
    static let sharedInstance = CoreData()
    
    func managedContext() -> NSManagedObjectContext {
        return managedObjectContext
    }
    
    //MARK: Save
    
    func saveDatabase() {
        do {
            try managedContext().save()
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
    }
 
    //MARK: Search
    func fetchAllWorkouts(withpredicate predicate: NSPredicate?, completion: (_ array: [Workout]) -> Void) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: workoutEntityName)
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = Workout.SortDescriptor()
        do {
            let results = try managedContext().fetch(fetchRequest)
            let workoutObjects = results as! [Workout]
            DataController.sharedInstance.workoutArray = workoutObjects

            completion(workoutObjects)
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }
    
    func createPredicate(_ entity:String, value:String) -> NSPredicate {
        return NSPredicate(format: "%K == %@", entity, value)
    }
    
    func checkIfWorkoutExists(_ predicate: NSPredicate) -> Workout? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: workoutEntityName)
        let entityDescription = NSEntityDescription.entity(forEntityName: "Workout", in: managedContext())
        
        fetchRequest.entity = entityDescription
        fetchRequest.predicate = predicate
        
        do {
            let result = try managedContext().fetch(fetchRequest)
            if let obj = result.first {
                return obj as? Workout
            }
        } catch {
            let fetchError = error as NSError
            print(fetchError)
        }
        
        return nil
    }
    
    //MARK: Create

    func createWorkoutLocal(_ workout:inout Workout) {
        let workoutObject = NSEntityDescription.insertNewObject(forEntityName: workoutEntityName, into: managedContext()) as! Workout
        workoutObject.withWorkout(workout)
        saveDatabase()
        workout = workoutObject
    }
    
    func createWorkoutRemote(_ record: CKRecord) -> Workout {
        let predicate = createPredicate("recordName", value: record.recordID.recordName)
        if let workoutObject = checkIfWorkoutExists(predicate) {
            return workoutObject //found a entity matching record's id name
        } else {
            let workoutObject = NSEntityDescription.insertNewObject(forEntityName: workoutEntityName, into: managedContext()) as! Workout
            workoutObject.withRecord(record)
            saveDatabase()
            
            return workoutObject //create a managed context from scratch
        }
    }
    
    func createEmptyWorkout() -> Workout {
        let workout = Workout.init(entity: NSEntityDescription.entity(forEntityName: workoutEntityName, in:managedObjectContext)!, insertInto: managedObjectContext)
        workout.id = UUID().uuidString //unique ID for workouts
        return workout
    }
    
    //MARK: Delete
    
    func deleteWorkout(_ workout: Workout, completion: (_ success: Bool) -> Void) {
        managedObjectContext.delete(workout)
        do {
            DataController.sharedInstance.workoutArray = DataController.sharedInstance.workoutArray.filter { $0 != workout }

            try managedObjectContext.save()
            completion(true)
        } catch let error as NSError  {
            completion(false)
            print("Could not save \(error), \(error.userInfo)")
        }
    }
    
    func deleteEntireDB() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: workoutEntityName)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try persistentStoreCoordinator.execute(deleteRequest, with: managedContext())
        } catch let error as NSError {
            // handle the error
            print(error)
        }
    }
    
    //MARK: Other
    
    func printNumberOfEntities() {
        print("printNumberOfEntities")
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: workoutEntityName)
        let entityDescription = NSEntityDescription.entity(forEntityName: "Workout", in: managedContext())
        fetchRequest.entity = entityDescription
        
        do {
            let result = try managedContext().fetch(fetchRequest)
            print(result.count)
        } catch {
            let fetchError = error as NSError
            print(fetchError)
        }
    }
    
    func printAllEntitiesID() {
        print("printAllEntitiesID")
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: workoutEntityName)
        let entityDescription = NSEntityDescription.entity(forEntityName: "Workout", in: managedContext())
        fetchRequest.entity = entityDescription
        
        do {
            let result = try managedContext().fetch(fetchRequest)
            for obj in result as! [Workout] {
                print(obj.id!)
            }
        } catch {
            let fetchError = error as NSError
            print(fetchError)
        }
    }
    
    func printAllEntitiesRecordName() {
        print("printNumberOfEntitiesRecordName")
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: workoutEntityName)
        let entityDescription = NSEntityDescription.entity(forEntityName: "Workout", in: managedContext())
        fetchRequest.entity = entityDescription
        
        do {
            let result = try managedContext().fetch(fetchRequest)
            for obj in result as! [Workout] {
                print(obj.recordName!)
            }
        } catch {
            let fetchError = error as NSError
            print(fetchError)
        }
    }
    
    //MARK: MOVING UIAPP MANAGED CONTEXT
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("SingleViewCoreData.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject
            
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }
    
    lazy var applicationDocumentsDirectory: URL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "inailuy.HeartBeat" in the application's documents Application Support directory.
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = Bundle.main.url(forResource: "HeartBeat", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
}
