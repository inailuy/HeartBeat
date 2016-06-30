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
        var text = ""
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
            let num = Int(text)
            if num != nil { userModel.age = num! }
            break
        case "Weight":
            let num = Float(text)
            if num != nil { userModel.weight = num! }
            break
        default: break
        }
        //Save Data Call here
        userModel.saveToDisk()
        resignFirstResponder()
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        if textField.text == "0" { textField.text = "" }
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