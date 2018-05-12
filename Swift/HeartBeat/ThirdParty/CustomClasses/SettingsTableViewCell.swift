//
//  SettingsTableViewCell.swift
//  HeartBeat
//
//  Created by inailuy on 6/27/16.
//  Copyright © 2016 Mxtapes. All rights reserved.
//

import Foundation
import UIKit

class SettingsTableViewCell: UITableViewCell, UITextFieldDelegate {
    var user = UserSettings.sharedInstance
    @IBOutlet weak var switchCell: UISwitch!
    @IBOutlet weak var segmentedControl : UISegmentedControl!
    @IBOutlet weak var textField : UITextField!

    func updateSettings() {
        var text = ""
        if textField != nil {
            text = textField.text!
        }
        
        switch textLabel!.text! {
        case "Sex":
            user.sex = segmentedControl.selectedSegmentIndex
            break
        case "Units":
            user.unit = segmentedControl.selectedSegmentIndex
            NotificationCenter.default.post(name: Notification.Name(rawValue: "Units_Changed"), object: nil)
            break
        case "Health App":
            user.userEnabledHealth = switchCell.isOn
            break
        case "Debug Mode":
            user.debug = switchCell.isOn
            break
        case "Age":
            let num = Int(text)
            if num != nil { user.age = num! }
            break
        case "Weight":
            let num = Float(text)
            if num != nil { user.modifyWeight(num!) }
            break
        case "     Minimum":
            let num = Int(text)
            if num != nil { user.minimumBPM = num! }
            break
        case "     Maximum":
            let num = Int(text)
            if num != nil { user.maximunBPM = num! }
            break
        default: break
        }
        //Save Data Call here
        user.saveToDisk()
        resignFirstResponder()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.text == "0" { textField.text = "" }
        textField.becomeFirstResponder()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        updateSettings()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
    
    @IBAction func textFieldDidChange(_ sender: UITextField) {
        updateSettings()
    }
    
    @IBAction func switchPressed(_ sender: UISwitch) {
        updateSettings()
    }
    
    @IBAction func segmentedControlPressed(_ sender: UISegmentedControl) {
        updateSettings()
    }
    
}
