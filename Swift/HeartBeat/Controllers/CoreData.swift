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

let workoutEntityName = "Workout"

class CoreData {
    
    static let sharedInstance = CoreData()
    
    func managedContext() -> NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.managedObjectContext
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
        let workout = Workout.init(entity: NSEntityDescription.entity(forEntityName: workoutEntityName, in:AppDelegate.sharedInstance.managedObjectContext)!, insertInto: AppDelegate.sharedInstance.managedObjectContext)
        workout.id = UUID().uuidString //unique ID for workouts
        return workout
    }
    
    //MARK: Delete
    
    func deleteWorkout(_ workout: Workout, completion: (_ success: Bool) -> Void) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        appDelegate.managedObjectContext.delete(workout)
        do {
            DataController.sharedInstance.workoutArray = DataController.sharedInstance.workoutArray.filter { $0 != workout }

            try appDelegate.managedObjectContext.save()
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
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            try appDelegate.persistentStoreCoordinator.execute(deleteRequest, with: managedContext())
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
}
