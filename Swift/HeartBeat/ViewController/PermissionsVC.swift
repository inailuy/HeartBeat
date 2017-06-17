//
//  PermissionsVC.swift
//  HeartBeat
//
//  Created by Yuliani Noriega on 12/4/16.
//  Copyright © 2016 Mxtapes. All rights reserved.
//
import Foundation
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class PermissionsVC: BaseVC, UITextFieldDelegate {
    
    @IBOutlet weak var healthButton: UIButton!
    @IBOutlet weak var ageTextField: UITextField!
    @IBOutlet weak var weightTextField: UITextField!
    @IBOutlet weak var unitSegmentControl: UISegmentedControl!
    @IBOutlet weak var sexSegmentControl: UISegmentedControl!
    @IBOutlet weak var continueButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ageTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        weightTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(healthPermissionResponse),
            name: NSNotification.Name(rawValue: "HealthStorePermission"),
            object: nil)
        
        title = "Permissions"
        
        updateValuesFromSettings()
    }
    
    @objc func healthPermissionResponse(_ notification: Notification){
        //notification once health permission exits
        DispatchQueue.main.async(execute: {
            self.updateValuesFromSettings()
            self.unitSegmentControl.selectedSegmentIndex = 0
        })
    }
    
    func updateValuesFromSettings() {
        let settings = UserSettings.sharedInstance
        healthButton.isEnabled = !settings.userEnabledHealth
        
        sexSegmentControl.selectedSegmentIndex = settings.sex
        unitSegmentControl.selectedSegmentIndex = settings.unit
        if settings.age > 0 {
            ageTextField.text = String(settings.age)
        }
        if settings.weight > 0 {
            weightTextField.text = String(settings.weightWithDisplayFormat())
        }
        
        shouldContinueButtonBeEnabled()
    }
    
    func saveSettings() {
        let settings = UserSettings.sharedInstance
        
        settings.sex = sexSegmentControl.selectedSegmentIndex
        settings.unit = unitSegmentControl.selectedSegmentIndex
        if Int(ageTextField.text!) > 0 {
            settings.age = Int(ageTextField.text!)!
        }
        if Float(weightTextField.text!) > 0.0 {
            settings.modifyWeight(Float(weightTextField.text!)!)
        }
        
        settings.saveToDisk()
        NotificationCenter.default.post(name: Notification.Name(rawValue: "UpdateSettings"), object: nil)
    }
    
    func shouldContinueButtonBeEnabled() {
        //check if continue button should be enabled
        continueButton.isEnabled = true
        if ageTextField.text == "" || weightTextField.text == "" ||
            Int(ageTextField.text!) == 0 || Int(weightTextField.text!) == 0 ||
            ageTextField.text == nil || weightTextField.text == nil
        {
            continueButton.isEnabled = false
        }
    }
    
    //MARK: Button Pressed
    @IBAction func healthButtonPressed(_ sender: AnyObject) {
        Health.sharedInstance.askPermissionForHealth()
    }
    
    @IBAction func continueButtonPressed(_ sender: UIButton) {
        saveSettings()
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func unitSegmentedControlPressed(_ sender: UISegmentedControl) {
        if UserSettings.sharedInstance.weight != 0.0 {
            if sender.selectedSegmentIndex == 0 {
                weightTextField.text = String(UserSettings.sharedInstance.weight)
            } else {
                weightTextField.text = String(UserSettings.sharedInstance.weight * 2.2046)
            }
        }
    }
    
    @IBAction func dismissKeyboard(_ sender: AnyObject) {
        view.window?.endEditing(true)
    }
    
    //MARK: TextFieldDelegate
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if Float(textField.text!) == 0 { textField.text = "" }
        textField.becomeFirstResponder()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        shouldContinueButtonBeEnabled()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldDidChange() {
        shouldContinueButtonBeEnabled()
    }
}
