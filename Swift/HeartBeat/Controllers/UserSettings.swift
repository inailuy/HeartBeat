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
        case mute = "MuteKey"
        case spokenCues = "SpokenCuesKey"
        case minimumBPM = "minimumBPM"
        case maximumBPM = "maximumBPM"
    }

    static let sharedInstance = UserSettings()
    var weight = Float() //Always store in kg
    var age = Int()
    var unit = Int()
    var sex = Int()
    var debug = Bool()
    var userEnabledHealth = Bool()
    var sessionActive = Bool()
    var audioTiming = Int()
    var mute = Bool()
    var spokenCues = NSMutableArray()
    var minimumBPM = Int()
    var maximunBPM = Int()
    
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
        age = numberObject.intValue
        numberObject = numberObjectForKey(Key.unit.rawValue)
        unit = numberObject.intValue
        numberObject = numberObjectForKey(Key.sex.rawValue)
        sex = numberObject.intValue
        numberObject = numberObjectForKey(Key.debug.rawValue)
        debug = numberObject.boolValue
        numberObject = numberObjectForKey(Key.userEnabledHealth.rawValue)
        userEnabledHealth = numberObject.boolValue
        numberObject = numberObjectForKey(Key.session.rawValue)
        sessionActive = numberObject.boolValue
        numberObject = numberObjectForKey(Key.audioTiming.rawValue)
        audioTiming = numberObject.intValue
        numberObject = numberObjectForKey(Key.mute.rawValue)
        mute = numberObject.boolValue
        numberObject = numberObjectForKey(Key.minimumBPM.rawValue)
        minimumBPM = numberObject.intValue
        numberObject = numberObjectForKey(Key.maximumBPM.rawValue)
        maximunBPM = numberObject.intValue
        
        if (UserDefaults.standard.object(forKey: Key.spokenCues.rawValue) != nil) {
            let arr = UserDefaults.standard.object(forKey: Key.spokenCues.rawValue) as! NSArray
            spokenCues = NSMutableArray(array: arr)
        } else {
            spokenCues = [0,0,0,0]
        }
    }
    
    func loadFromHealthKit() {
        let health = Health.sharedInstance
        if userEnabledHealth {
            do {// Age
                let birthDay = try health.healthStore.dateOfBirth()
                age = (Calendar.current as NSCalendar).components(.year, from: birthDay, to: Date(), options: []).year!
            } catch let error as NSError {
                print(error.localizedDescription)
            }
            do {// Sex
                let bioSexObject = try health.healthStore.biologicalSex()
                switch bioSexObject.biologicalSex {
                case .female:
                    sex = Sex.female.rawValue
                    break
                case .male:
                    sex = Sex.male.rawValue
                    break
                default: break
                }
            } catch let error as NSError {
                print(error.localizedDescription)
            }
            // Weight
            health.weight({ (result: Float) in
                if result > 0.0 {
                    self.weight = result
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(name: Notification.Name(rawValue: "HealthStorePermission"), object: nil)
                    }
                }
            })
        }
        saveToDisk()
    }
    
    func saveToDisk() {
        let userDefaults = UserDefaults.standard
        userDefaults.set(weight, forKey: Key.weight.rawValue)
        userDefaults.set(age, forKey: Key.age.rawValue)
        userDefaults.set(unit, forKey: Key.unit.rawValue)
        userDefaults.set(sex, forKey: Key.sex.rawValue)
        userDefaults.set(debug, forKey: Key.debug.rawValue)
        userDefaults.set(userEnabledHealth, forKey: Key.userEnabledHealth.rawValue)
        userDefaults.set(sessionActive, forKey: Key.session.rawValue)
        userDefaults.set(audioTiming, forKey: Key.audioTiming.rawValue)
        userDefaults.set(spokenCues, forKey: Key.spokenCues.rawValue)
        userDefaults.set(mute, forKey: Key.mute.rawValue)
        userDefaults.set(minimumBPM, forKey: Key.minimumBPM.rawValue)
        userDefaults.set(maximunBPM, forKey: Key.maximumBPM.rawValue)
        
        userDefaults.synchronize()
    }
    
    func resetValues() {
        weight = 0
        age = 0
        unit = 0
        sex = 0
        debug = false
        userEnabledHealth = false
        sessionActive = false
        mute = false
        audioTiming = 0
        spokenCues = [0,0,0,0]
        minimumBPM = 0
        maximunBPM = 0
        
        saveToDisk()
    }
    
    func numberObjectForKey(_ key: String) -> NSNumber {
        let userDefaults = UserDefaults.standard
        var number = NSNumber()
        if (userDefaults.object(forKey: key) != nil) {
            number = userDefaults.object(forKey: key) as! NSNumber
        }
        return  number
    }
    
    func weightWithDisplayFormat() -> Int {
        var weight = self.weight > 0.0 ? self.weight : 0.0
        if Unit.imperial.rawValue == unit {
            weight = weight * 2.2046
        }
        return Int(weight)
    }
    
    func modifyWeight(_ value:Float) {
        if Unit.imperial.rawValue == unit {
            weight = value / 2.2046
        } else {
            weight = value
        }
    }
    
    func checkSpokenCueIndex(_ index:Int) -> Bool {
        let check = spokenCues[index] as! NSNumber
        if check.boolValue {
            return true
        }
        return false
    }
}
