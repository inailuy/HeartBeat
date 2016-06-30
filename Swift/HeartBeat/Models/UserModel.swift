//
//  UserModel.swift
//  HeartBeat
//
//  Created by inailuy on 6/28/16.
//  Copyright © 2016 Mxtapes. All rights reserved.
//

import Foundation

class UserModel {
    enum Sex:Int {
        case female = 0
        case male
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
        case health = "HealthKey"
        case session = "SessionKey"
        case audioTiming = "AudioTimingKey"
        case spokenCues = "SpokenCuesKey"
    }
    var weight = Float()
    var age = Int()
    var unit = Int()
    var sex = Int()
    var debug = Bool()
    var healthEnable = Bool()
    var sessionActive = Bool()
    var audioTiming = Int()
    var spokenCues = NSMutableArray()
    static let sharedInstance = UserModel()
    
    init () {
        loadFromDisk()
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
        numberObject = numberObjectForKey(Key.health.rawValue)
        healthEnable = numberObject.boolValue
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
    
    func saveToDisk() {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setFloat(weight, forKey: Key.weight.rawValue)
        userDefaults.setInteger(age, forKey: Key.age.rawValue)
        userDefaults.setInteger(unit, forKey: Key.unit.rawValue)
        userDefaults.setInteger(sex, forKey: Key.sex.rawValue)
        userDefaults.setBool(debug, forKey: Key.debug.rawValue)
        userDefaults.setBool(healthEnable, forKey: Key.health.rawValue)
        userDefaults.setBool(sessionActive, forKey: Key.session.rawValue)
        userDefaults.setInteger(audioTiming, forKey: Key.audioTiming.rawValue)
        userDefaults.setObject(spokenCues, forKey: Key.spokenCues.rawValue)
        print(spokenCues)
        userDefaults.synchronize()
    }
    
    func resetValues() {
        weight = 0.0
        age = 0
        unit = 0
        sex = 0
        debug = false
        healthEnable = false
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
    
    func weightInt() -> Int {
        return Int(weight)
    }
    
    func checkSpokenCueIndex(index:Int) -> Bool {
        let check = spokenCues[index] as! NSNumber
        if check.boolValue {
            return true
        }
        return false
    }
}
