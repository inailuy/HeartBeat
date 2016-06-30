//
//  UserModel.swift
//  HeartBeat
//
//  Created by inailuy on 6/28/16.
//  Copyright © 2016 Mxtapes. All rights reserved.
//

import Foundation

class UserSettings {
    enum Sex:Int {
        case male = 0
        case female
    }
    enum Unit:Int {
        case metric = 0
        case imperial
    }
    enum Key:String {
        case weight = "WeightKey"
        case age = "AgeKey"
        case unit = "UnitKey"
        case sex = "SexKey"
        case debug = "DebugKey"
        case userEnabledHealth = "userEnabledHealthKey"
        case session = "SessionKey"
        case audioTiming = "AudioTimingKey"
        case spokenCues = "SpokenCuesKey"
    }
    var weight = Float() //Always store in kg
    var age = Int()
    var unit = Int()
    var sex = Int()
    var debug = Bool()
    var userEnabledHealth = Bool()
    var sessionActive = Bool()
    var audioTiming = Int()
    var spokenCues = NSMutableArray()
    static let sharedInstance = UserSettings()
    
    init () {
        loadFromDisk()
    }
    
    func loadInstances() {
            loadFromDisk()
            loadFromHealthKit()
    }
    
    func loadFromDisk() {
        var numberObject = numberObjectForKey(Key.weight.rawValue)
        weight = numberObject.floatValue
        numberObject = numberObjectForKey(Key.age.rawValue)
        age = numberObject.integerValue
        numberObject = numberObjectForKey(Key.unit.rawValue)
        unit = numberObject.integerValue
        numberObject = numberObjectForKey(Key.sex.rawValue)
        sex = numberObject.integerValue
        numberObject = numberObjectForKey(Key.debug.rawValue)
        debug = numberObject.boolValue
        numberObject = numberObjectForKey(Key.userEnabledHealth.rawValue)
        userEnabledHealth = numberObject.boolValue
        numberObject = numberObjectForKey(Key.session.rawValue)
        sessionActive = numberObject.boolValue
        numberObject = numberObjectForKey(Key.audioTiming.rawValue)
        audioTiming = numberObject.integerValue
        if (NSUserDefaults.standardUserDefaults().objectForKey(Key.spokenCues.rawValue) != nil) {
            let arr = NSUserDefaults.standardUserDefaults().objectForKey(Key.spokenCues.rawValue) as! NSArray
            spokenCues = NSMutableArray(array: arr)
        } else {
            spokenCues = [0,0,0,0]
        }
    }
    
    func loadFromHealthKit() {
        let health = Health.sharedInstance
        if userEnabledHealth && health.isHealthKitEnabled {
            do {// Age
                let birthDay = try health.healthStore.dateOfBirth()
                age = NSCalendar.currentCalendar().components(.Year, fromDate: birthDay, toDate: NSDate(), options: []).year
            } catch let error as NSError {
                print(error.localizedDescription)
            }
            do {// Sex
                let bioSexObject = try health.healthStore.biologicalSex()
                switch bioSexObject.biologicalSex {
                case .Female:
                    sex = Sex.female.rawValue
                    break
                case .Male:
                    sex = Sex.male.rawValue
                    break
                default: break
                }
            } catch let error as NSError {
                print(error.localizedDescription)
            }
            // Weight
            health.weight({ (result: Float) in
                self.weight = result
                self.saveToDisk()
                dispatch_async(dispatch_get_main_queue()) {
                    NSNotificationCenter.defaultCenter().postNotificationName("Units_Changed", object: nil)
                }
            })
        }
        saveToDisk()
    }
    
    func saveToDisk() {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setFloat(weight, forKey: Key.weight.rawValue)
        userDefaults.setInteger(age, forKey: Key.age.rawValue)
        userDefaults.setInteger(unit, forKey: Key.unit.rawValue)
        userDefaults.setInteger(sex, forKey: Key.sex.rawValue)
        userDefaults.setBool(debug, forKey: Key.debug.rawValue)
        userDefaults.setBool(userEnabledHealth, forKey: Key.userEnabledHealth.rawValue)
        userDefaults.setBool(sessionActive, forKey: Key.session.rawValue)
        userDefaults.setInteger(audioTiming, forKey: Key.audioTiming.rawValue)
        userDefaults.setObject(spokenCues, forKey: Key.spokenCues.rawValue)
        
        userDefaults.synchronize()
    }
    
    func resetValues() {
        weight = 0.0
        age = 0
        unit = 0
        sex = 0
        debug = false
        userEnabledHealth = false
        sessionActive = false
        audioTiming = 0
        spokenCues = [0,0,0,0]
        saveToDisk()
    }
    
    func numberObjectForKey(key: String) -> NSNumber {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        var number = NSNumber()
        if (userDefaults.objectForKey(key) != nil) {
            number = userDefaults.objectForKey(key) as! NSNumber
        }
        return  number
    }
    
    func weightWithDisplayFormat() -> Int {
        var weight = self.weight
        if Unit.imperial.rawValue == unit {
            weight = weight * 2.2046
        }
        return Int(weight)
    }
    
    func modifyWeight(value:Float) {
        if Unit.imperial.rawValue == unit {
            weight = value / 2.2046
        }
    }
    
    func checkSpokenCueIndex(index:Int) -> Bool {
        let check = spokenCues[index] as! NSNumber
        if check.boolValue {
            return true
        }
        return false
    }
}
