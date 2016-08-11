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
    
    //MARK: Permission/Acess
    func askPermissionForHealth() {
        if HKHealthStore.isHealthDataAvailable() {
            let newCompletion: ((Bool, NSError?) -> Void) = {
                (success, error) -> Void in
                if !success {
                    print("You didn't allow HealthKit to access these write data types.\nThe error was:\n \(error!.description).")
                    return
                } else {
                    self.isHealthKitEnabled = true
                    UserSettings.sharedInstance.loadInstances()
                }
            }
            let writeDataTypes = dataTypesToWrite() as! Set<HKSampleType>
            let readDataTypes = dataTypesToRead() as! Set<HKObjectType>//{ (success: Bool!, error: NSError!) -> Void in
            healthStore.requestAuthorizationToShareTypes(writeDataTypes, readTypes: readDataTypes, completion: newCompletion)
        }
    }
    //MARK: Retreive Data
    func weight(completion: (weight: Float) -> Void)  {
        let sampleType = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBodyMass)
        readMostRecentSample(sampleType!, completion: { (mostRecentWeight, error) -> Void in
            if( error != nil ) {
                print("Error reading weight from HealthKit Store: \(error.localizedDescription)")
                return;
            }
            let weightSample = mostRecentWeight as! HKQuantitySample
            let kilograms = weightSample.quantity.doubleValueForUnit(HKUnit.gramUnitWithMetricPrefix(.Kilo))
            completion(weight: Float(kilograms))
        })
    }
    // Function from HealthKit Tutorial with Swift: Getting Started
    // www.raywenderlich.com/86336/ios-8-healthkit-swift-getting-started
    func readMostRecentSample(sampleType:HKSampleType , completion: ((HKSample!, NSError!) -> Void)!) {
        // 1. Build the Predicate
        let past = NSDate.distantPast()
        let now   = NSDate()
        let mostRecentPredicate = HKQuery.predicateForSamplesWithStartDate(past, endDate:now, options: .None)
        // 2. Build the sort descriptor to return the samples in descending order
        let sortDescriptor = NSSortDescriptor(key:HKSampleSortIdentifierStartDate, ascending: false)
        // 3. we want to limit the number of samples returned by the query to just 1 (the most recent)
        let limit = 1
        // 4. Build samples query
        let sampleQuery = HKSampleQuery(sampleType: sampleType, predicate: mostRecentPredicate, limit: limit, sortDescriptors: [sortDescriptor])
        { (sampleQuery, results, error ) -> Void in
            if let queryError = error {
                completion(nil,queryError)
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
        healthStore.executeQuery(sampleQuery)
    }
    //MARK: Modify/Save
    func saveWorkoutToHealthKit(workout:Workout) {
        //TODO: Save WorkoutModel to healthkit
        //1.check if can/should save
        
        //2.create all variables
        
        //3.create hkworkout object
        
        //4.call healthkit save function
    }
    //MARK: Misc
    func dataTypesToWrite() -> NSSet {
        let set = NSMutableSet()
        set.addObject(HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)!)
        set.addObject(HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDistanceWalkingRunning)!)
        set.addObject(HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierActiveEnergyBurned)!)
        set.addObject(HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeartRate)!)
        //set.addObject(HKObjectType.WorkoutControllerType())
        
        return set
    }
    
    func dataTypesToRead() -> NSSet {
        let set = NSMutableSet()
        set.addObject(HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBodyMass)!)
        set.addObject(HKObjectType.characteristicTypeForIdentifier(HKCharacteristicTypeIdentifierDateOfBirth)!)
        set.addObject(HKObjectType.characteristicTypeForIdentifier(HKCharacteristicTypeIdentifierBiologicalSex)!)

        return set
    }
}