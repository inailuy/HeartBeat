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
    @IBOutlet weak var switchCell: UISwitch!
    @IBOutlet weak var segmentedControl : UISegmentedControl!
    @IBOutlet weak var textField : UITextField!

    func updateSettings() {
        var text = "0"
        if textField != nil {
            text = textField.text!
        }
        
        let userModel = UserModel.sharedInstance
        switch textLabel!.text! {
        case "Sex":
            userModel.sex = segmentedControl.selectedSegmentIndex
            break
        case "Units":
            userModel.unit = segmentedControl.selectedSegmentIndex
            break
        case "Health App":
            userModel.healthEnable = switchCell.on
            break
        case "Debug Mode":
            userModel.debug = switchCell.on
            break
        case "Age":
            userModel.age = Int(text)!
            break
        case "Weight":
            userModel.weight = Float(text)!
            break
        default: break
        }
        //Save Data Call here
        userModel.saveToDisk()
        resignFirstResponder()
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        textField.becomeFirstResponder()
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        updateSettings()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        return true
    }
    
    @IBAction func textFieldDidChange(sender: UITextField) {
        updateSettings()
    }
    
    @IBAction func switchPressed(sender: UISwitch) {
        updateSettings()
    }
    
    @IBAction func segmentedControlPressed(sender: UISegmentedControl) {
        updateSettings()
    }
    
}