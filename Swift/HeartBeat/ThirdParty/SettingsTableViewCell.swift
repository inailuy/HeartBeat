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
        var text = textField.text
        if text == "" { text = "0" }
        
        switch textLabel!.text! {
        case "Sex":
            UserModel.sharedInstance.sex = segmentedControl.selectedSegmentIndex
            break
        case "Units":
            UserModel.sharedInstance.unit = segmentedControl.selectedSegmentIndex
            break
        case "Health App":
            UserModel.sharedInstance.healthEnable = switchCell.on
            break
        case "Debug Mode":
            UserModel.sharedInstance.debug = switchCell.on
            break
        case "Age":
            UserModel.sharedInstance.age = Int(text!)!
            break
        case "Weight":
            UserModel.sharedInstance.weight = Float(text!)!
            break
        default: break
        }
        //Save Data Call here
        UserModel.sharedInstance.saveToDisk()
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