//
//  SettingsVC.swift
//  HeartBeat
//
//  Created by inailuy on 6/15/16.
//  Copyright © 2016 Mxtapes. All rights reserved.
//

import Foundation
import UIKit

class SettingsVC: BaseVC, UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate {
    //identifiers 
    enum IDENTIFIER:String {
        case textfieldCell
        case switchCell
        case segmentedSexCell
        case segmentedMetricCell
        case normalCell
    }
    
    @IBOutlet weak var tableView: UITableView!
 
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "settings"

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SettingsVC.observeredUnitsChange), name: "Units_Changed", object: nil)
        createHeartNavigationButton(Direction.left.rawValue)
        UserSettings.sharedInstance.loadFromDisk()
    }
    // MARK: - TableView Delegate/DataSource
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var title = ""
        var reuseID = ""
        var itemBool = false
        var text = ""
        let user = UserSettings.sharedInstance
        switch indexPath.section {
        case 0://Section
            switch indexPath.row {
            case 0: //AGE
                title = "Age"
                reuseID = IDENTIFIER.textfieldCell.rawValue
                text = String(user.age)
                break
            case 1: //Weight
                title = "Weight"
                reuseID = IDENTIFIER.textfieldCell.rawValue
                text = String(user.weightWithDisplayFormat())
                break
            case 2: //SEX
                title = "Sex"
                reuseID = IDENTIFIER.segmentedSexCell.rawValue
                itemBool = Bool(user.sex)
                break
            default: break
            }
        case 1://Section
            switch indexPath.row {
            case 0: //Units
                title = "Units"
                reuseID = IDENTIFIER.segmentedMetricCell.rawValue
                itemBool = Bool(user.unit)
                break
            case 1: //Health
                title = "Health App"
                reuseID = IDENTIFIER.switchCell.rawValue
                itemBool = user.userEnabledHealth
                break
            case 2: //Audio
                title = "Audio Cues"
                reuseID = IDENTIFIER.normalCell.rawValue
                break
            case 3: //Hardware
                title = "Connect Hardware"
                reuseID = IDENTIFIER.normalCell.rawValue
                break
            default: break
            }
        case 2://Section
            switch indexPath.row {
            case 0: //Debug
                title = "Debug Mode"
                reuseID = IDENTIFIER.switchCell.rawValue
                itemBool = user.debug
                break
            case 1: //LogOut
                title = "Log Out"
                reuseID = IDENTIFIER.normalCell.rawValue
                break
            default: break
            }
        default: break
        }
 
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseID) as! SettingsTableViewCell
        if reuseID == IDENTIFIER.normalCell.rawValue ||
            reuseID == IDENTIFIER.textfieldCell.rawValue {
            cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        }
        
        if cell.reuseIdentifier == IDENTIFIER.textfieldCell.rawValue {
            cell.textField.text = text
        } else if cell.reuseIdentifier == IDENTIFIER.switchCell.rawValue {
            cell.switchCell.on = itemBool
        } else if cell.reuseIdentifier == IDENTIFIER.segmentedMetricCell.rawValue ||
            cell.reuseIdentifier == IDENTIFIER.segmentedSexCell.rawValue {
            cell.segmentedControl.selectedSegmentIndex = itemBool ? 1 : 0
        }
        
        cell.backgroundColor = UIColor(white: 0.9, alpha: 0.4)
        cell.textLabel?.text = title
        cell.textLabel?.font = UIFont(name: helveticaFont, size: 22.0)
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var sect = 0
        if section == 0 {
            sect = 3
        }else if section == 1 {
            sect = 4
        }else if section == 2 {
            sect = 2
        }
        return sect
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var title = ""
        switch section {
        case 0:
            title = "Personal Info"
            break
        case 1:
            title = "App Details"
            break
        case 2:
            title = "Other"
            break
        default: break
        }
        return createSectionHeaderView(title)
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! SettingsTableViewCell
        if cell.reuseIdentifier == IDENTIFIER.textfieldCell.rawValue {
            cell.textField.becomeFirstResponder()
        }
        
        switch indexPath.section {
        case 1:
            switch indexPath.row {
            case 2://Audio Segue
                performSegueWithIdentifier("audioSegue", sender: self)
                break
            case 3://Bluetooth
                let bluetooth = Bluetooth.sharedInstance
                if bluetooth.isPeripheralConnected() {
                    bluetooth.disconnectPeripheral()
                } else {
                    bluetooth.connectPeripheral()
                }
                break
            default: break
            }
            break
        case 2:
            switch indexPath.row {
            case 0://Debug
                break
            case 1://LogOut
                let alertController = UIAlertController(title: nil, message: "Are you sure you want to log out?", preferredStyle: .ActionSheet)
                let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in}
                let destroyAction = UIAlertAction(title: "Logout", style: .Destructive) { (action) in
                  //TODO: perform Logout Function
                }
                alertController.addAction(cancelAction)
                alertController.addAction(destroyAction)
                
                self.presentViewController(alertController, animated: true) {
                    // ...
                }
                break
            default: break
            }
        default: break
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }
    // MARK: - End Editing
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        view.window?.endEditing(true)
    }
    
    func observeredUnitsChange() {
        tableView.reloadData()//Needs better implementation
    }
    // TODO: create tap gesture to cancel textfield input
    // add to view when keyboard is displayed, removed when editing is done
}