//
//  Vo2Max.swift
//  HeartBeat
//
//  Created by inailuy on 7/5/16.
//  Copyright © 2016 Mxtapes. All rights reserved.
//

import Foundation
/*
    http://www.calories-calculator.net/Calculator_Formulars.html#burned_by_hr
  
    Accurate Calorie Burned Calculator Formula for Men(kCal):
    Calorie Burned = [ (AGE_IN_YEAR x 0.2017) + (WEIGHT_IN_KILOGRAM x 0.1988)+ (HEART_BEAT_PER_MINUTE x 0.6309) - 55.0969] x DURATION_IN_MINUTE / 4.184
    
    Accurate Calorie Burned Calculator Formula for Women(kCal):
    Calorie Burned = [ (AGE_IN_YEAR x 0.074) + (WEIGHT_IN_KILOGRAM x 0.1263) + (HEART_BEAT_PER_MINUTE x 0.4472) - 20.4022] x DURATION_IN_MINUTE / 4.184
    
 Formular provided
    by: Journal of S port Science
*/
struct VO2Max {
    enum Age:Double {
        case male = 0.2017
        case female = 0.074
    }
    enum Weight:Double {
        case male = 0.1988
        case female = 0.1263
    }
    enum BPM:Double {
        case male = 0.6309
        case female = 0.4472
    }
    enum Minutes:Double {
        case male = 55.0969
        case female = 20.4022
    }
    
    var sex = Int()
    
    init(sex:Int) {
        self.sex = sex
    }
    
    func modifyAge(_ age:Double) -> Double {
        if sex == UserSettings.Sex.male.rawValue {
            return age * Age.male.rawValue
        } else {
            return age * Age.female.rawValue
        }
    }
    
    func modifyWeight(_ weight:Double) -> Double {
        if sex == UserSettings.Sex.male.rawValue {
            return weight * Weight.male.rawValue
        } else {
            return weight * Weight.female.rawValue
        }
    }
    
    func modifyBPM(_ bpm:Double) -> Double {
        if sex == UserSettings.Sex.male.rawValue {
            return bpm * BPM.male.rawValue
        } else {
            return bpm * BPM.female.rawValue
        }
    }
    
    func calculateVO2Max(_ age:Double, weight:Double, bpm:Double, minutes:Double) -> Int {
        var result = age + weight + bpm
        if sex == UserSettings.Sex.male.rawValue {
            result = result - Minutes.male.rawValue
        } else {
            result = result - Minutes.female.rawValue
        }
        result = result * minutes
        return Int(result / 4.184)
    }
}
