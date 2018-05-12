//
//  Health.swift
//  HeartBeat
//
//  Created by inailuy on 6/30/16.
//  Copyright © 2016 Mxtapes. All rights reserved.
//

import Foundation
import HealthKit

class Health {
    static let sharedInstance = Health()
    let healthStore = HKHealthStore()
    let user = UserSettings.sharedInstance
    var isHealthKitEnabled = Bool()
    
    init() {
        isHealthKitEnabled = user.userEnabledHealth
    }
    
    //MARK: Permission/Acess`
    func askPermissionForHealth() {
        if HKHealthStore.isHealthDataAvailable() {
            let _: ((Bool, NSError?) -> Void) = {
                (success, error) -> Void in
                if !success {
                    print("You didn't allow HealthKit to access these write data types.\nThe error was:\n \(error!.description).")
                    return
                } else {
                    self.isHealthKitEnabled = true
                    UserSettings.sharedInstance.userEnabledHealth = true
                    UserSettings.sharedInstance.saveToDisk()
                    UserSettings.sharedInstance.loadInstances()
                }
                NotificationCenter.default.post(name: Notification.Name(rawValue: "HealthStorePermission"), object: nil)
            }
            let writeDataTypes = dataTypesToWrite() as! Set<HKSampleType>
            let readDataTypes = dataTypesToRead() as! Set<HKObjectType>//{ (success: Bool!, error: NSError!) -> Void in
            
            healthStore.requestAuthorization(toShare: writeDataTypes, read: readDataTypes) { (success, error) -> Void in }
        }
    }
    //MARK: Retreive Data
    func weight(_ completion: @escaping (_ weight: Float) -> Void)  {
        let sampleType = HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)
        readMostRecentSample(sampleType!, completion: { (mostRecentWeight, error) -> Void in
            if( error != nil ) {
                print("Error reading weight from HealthKit Store: \(String(describing: error?.localizedDescription))")
                return;
            }
            
            var kilograms = 0.0
            if mostRecentWeight != nil {
                let weightSample = mostRecentWeight as! HKQuantitySample
                kilograms = weightSample.quantity.doubleValue(for: HKUnit.gramUnit(with: .kilo))
            }
        
            completion(Float(kilograms))
        })
    }
    // Function from HealthKit Tutorial with Swift: Getting Started
    // www.raywenderlich.com/86336/ios-8-healthkit-swift-getting-started
    func readMostRecentSample(_ sampleType:HKSampleType , completion: ((HKSample?, NSError?) -> Void)!) {
        // 1. Build the Predicate
        let past = Date.distantPast
        let now   = Date()
        let mostRecentPredicate = HKQuery.predicateForSamples(withStart: past, end:now, options: HKQueryOptions())
        // 2. Build the sort descriptor to return the samples in descending order
        let sortDescriptor = NSSortDescriptor(key:HKSampleSortIdentifierStartDate, ascending: false)
        // 3. we want to limit the number of samples returned by the query to just 1 (the most recent)
        let limit = 1
        // 4. Build samples query
        let sampleQuery = HKSampleQuery(sampleType: sampleType, predicate: mostRecentPredicate, limit: limit, sortDescriptors: [sortDescriptor])
        { (sampleQuery, results, error ) -> Void in
            if let queryError = error {
                completion(nil,queryError as NSError)
                return;
            }
            // Get the first sample
            let mostRecentSample = results!.first as? HKQuantitySample
            // Execute the completion closure
            if completion != nil {
                completion(mostRecentSample,nil)
            }
        }
        // 5. Execute the Query
        healthStore.execute(sampleQuery)
    }
    //MARK: Modify/Save
    func saveWorkoutToHealthKit(_ workout:Workout) {
        //1.check if can/should save
        if HKHealthStore.isHealthDataAvailable() && UserSettings.sharedInstance.userEnabledHealth {
            //2.create all variables
            let energyBurnedQuantity = HKQuantity(unit: HKUnit.kilocalorie(), doubleValue: Double(workout.caloriesBurned!))
            let metadata: [String: AnyObject] = [
                HKMetadataKeyGroupFitness: false as AnyObject,
                HKMetadataKeyIndoorWorkout: false as AnyObject,
                HKMetadataKeyCoachedWorkout: true as AnyObject
            ]
            //3.create hkworkout object
            let workoutSample = HKWorkout(
                activityType: .functionalStrengthTraining,
                start: workout.startTime!,
                end: workout.endTime!,
                workoutEvents: nil,
                totalEnergyBurned: energyBurnedQuantity,
                totalDistance: nil,
                device: nil,
                metadata: metadata
            )
            //4.call healthkit save function
            healthStore.save(workoutSample, withCompletion: { (success, error) in
                if success == false {
                    // Workout was not successfully saved
                    print(error?.localizedDescription ?? "Error")
                }
            })
        }
    }
    
    func readWorkoutData() {
        if HKHealthStore.isHealthDataAvailable() && UserSettings.sharedInstance.userEnabledHealth {
           
          
            let sampleType = HKObjectType.workoutType()
           
            let startDate = NSDate()
            let endDate = startDate.addingTimeInterval(-3600)
            
            _ = HKQuery.predicateForSamples(withStart: startDate as Date, end: endDate as Date, options: .strictStartDate)
            let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
            let limit = 0
            
            let query = HKSampleQuery(sampleType: sampleType, predicate: nil, limit: limit, sortDescriptors:[sortDescriptor], resultsHandler: { (query, results: [HKSample]?, error) in
                var workouts: [HKWorkout] = []
                
                if let results = results {
                    for result in results {
                        if let workout = result as? HKWorkout {
                            // Here's a HKWorkout object
                            workouts.append(workout)
                            print(workout.totalDistance ?? "Error")
                        }
                    }
                    //print(workouts)
                }
                else {  
                    // No results were returned, check the error
                }
            })
            
            healthStore.execute(query)
//            {
//                
//                // Use a sortDescriptor to get the recent data first
//                let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
//                
//                // we create our query with a block completion to execute
//                let query = HKSampleQuery(sampleType: sampleType, predicate: nil, limit: 30, sortDescriptors: [sortDescriptor]) { (query, tmpResult, error) -> Void in
//                    
//                    if error != nil {
//                        
//                        // something happened
//                        return
//                        
//                    }
//                    
//                    if let result = tmpResult {
//                        
//                        // do something with my data
//                        for item in result {
//                            if let sample = item as? HKCategorySample {
//                                //let value = (sample.value == HKCategoryValueSleepAnalysis.inBed.rawValue) ? "InBed" : "Asleep"
//                                print("Healthkit workout: \(sample)")
//                            }
//                        }
//                    }
//                }
//                
//                // finally, we execute our query
//                healthStore.execute(query)
//            }
        }
    }
    
    //MARK: Misc
    func dataTypesToWrite() -> NSSet {
        let set = NSMutableSet()
        set.add(HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!)
        set.add(HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.distanceWalkingRunning)!)
        set.add(HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.activeEnergyBurned)!)
        set.add(HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!)
        set.add(HKObjectType.workoutType())
        
        return set
    }
    
    func dataTypesToRead() -> NSSet {
        let set = NSMutableSet()
        set.add(HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)!)
        set.add(HKObjectType.characteristicType(forIdentifier: HKCharacteristicTypeIdentifier.dateOfBirth)!)
        set.add(HKObjectType.characteristicType(forIdentifier: HKCharacteristicTypeIdentifier.biologicalSex)!)
        set.add(HKObjectType.workoutType())
        return set
    }
}
