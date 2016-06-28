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
    }
    var weight = Float()
    var age = Int()
    var unit = Int()
    var sex = Int()
    var debug = Bool()
    var healthEnable = Bool()
    var sessionActive = Bool()
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
}
