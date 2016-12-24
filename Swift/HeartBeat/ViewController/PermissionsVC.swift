//
//  PermissionsVC.swift
//  HeartBeat
//
//  Created by Yuliani Noriega on 12/4/16.
//  Copyright © 2016 Mxtapes. All rights reserved.
//
import Foundation

class PermissionsVC: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var healthButton: UIButton!
    @IBOutlet weak var ageTextField: UITextField!
    @IBOutlet weak var weightTextField: UITextField!
    @IBOutlet weak var unitSegmentControl: UISegmentedControl!
    @IBOutlet weak var sexSegmentControl: UISegmentedControl!
    @IBOutlet weak var continueButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ageTextField.addTarget(self, action: #selector(textFieldDidChange), forControlEvents: .EditingChanged)
        weightTextField.addTarget(self, action: #selector(textFieldDidChange), forControlEvents: .EditingChanged)
        
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: #selector(healthPermissionResponse),
            name: "HealthStorePermission",
            object: nil)
        
        updateValuesFromSettings()
    }
    
    @objc func healthPermissionResponse(notification: NSNotification){
        //notification once health permission exits
        dispatch_async(dispatch_get_main_queue(), {
            self.updateValuesFromSettings()
            self.unitSegmentControl.selectedSegmentIndex = 0
        })
    }
    
    func updateValuesFromSettings() {
        let settings = UserSettings.sharedInstance
        healthButton.enabled = !settings.userEnabledHealth
        
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
        NSNotificationCenter.defaultCenter().postNotificationName("UpdateSettings", object: nil)
    }
    
    func shouldContinueButtonBeEnabled() {
        //check if continue button should be enabled
        continueButton.enabled = true
        if ageTextField.text == "" || weightTextField.text == "" ||
            Int(ageTextField.text!) == 0 || Int(weightTextField.text!) == 0 ||
            ageTextField.text == nil || weightTextField.text == nil
        {
            continueButton.enabled = false
        }
    }
    
    //MARK: Button Pressed
    @IBAction func healthButtonPressed(sender: AnyObject) {
        Health.sharedInstance.askPermissionForHealth()
    }
    
    @IBAction func continueButtonPressed(sender: UIButton) {
        saveSettings()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func unitSegmentedControlPressed(sender: UISegmentedControl) {
        if UserSettings.sharedInstance.weight != 0.0 {
            if sender.selectedSegmentIndex == 0 {
                weightTextField.text = String(UserSettings.sharedInstance.weight)
            } else {
                weightTextField.text = String(UserSettings.sharedInstance.weight * 2.2046)
            }
        }
    }
    
    @IBAction func dismissKeyboard(sender: AnyObject) {
        view.window?.endEditing(true)
    }
    
    //MARK: TextFieldDelegate
    func textFieldDidBeginEditing(textField: UITextField) {
        if Float(textField.text!) == 0 { textField.text = "" }
        textField.becomeFirstResponder()
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        shouldContinueButtonBeEnabled()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldDidChange() {
        shouldContinueButtonBeEnabled()
    }
}
