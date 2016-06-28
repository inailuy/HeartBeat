//
//  SettingsVC.swift
//  HeartBeat
//
//  Created by inailuy on 6/15/16.
//  Copyright © 2016 Mxtapes. All rights reserved.
//

import Foundation
import UIKit

class SettingsVC: BaseVC, UITableViewDelegate, UITableViewDataSource {
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
        
        createBlurEffect()
        createHeartNavigationButton(Direction.left.rawValue)
        UserModel.sharedInstance.loadFromDisk()
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var title = ""
        var reuseID = ""
        var itemBool = false
        var text = ""
        
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0: //AGE
                title = "Age"
                reuseID = IDENTIFIER.textfieldCell.rawValue
                text = String(UserModel.sharedInstance.age)
                break
            case 1: //Weight
                title = "Weight"
                reuseID = IDENTIFIER.textfieldCell.rawValue
                text = String(UserModel.sharedInstance.weight)
                break
            case 2: //SEX
                title = "Sex"
                reuseID = IDENTIFIER.segmentedSexCell.rawValue
                itemBool = Bool(UserModel.sharedInstance.sex)
                break
            default: break
            }
        case 1:
            switch indexPath.row {
            case 0: //Units
                title = "Units"
                reuseID = IDENTIFIER.segmentedMetricCell.rawValue
                itemBool = Bool(UserModel.sharedInstance.unit)
                break
            case 1: //Health
                title = "Health App"
                reuseID = IDENTIFIER.switchCell.rawValue
                itemBool = UserModel.sharedInstance.healthEnable
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
        case 2:
            switch indexPath.row {
            case 0: //Debug
                title = "Debug Mode"
                reuseID = IDENTIFIER.switchCell.rawValue
                itemBool = UserModel.sharedInstance.debug
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
        cell.textLabel?.font = UIFont(name: "HelveticaNeue-Thin", size: 22.0)
        
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
        var title = "Personal Info"
        switch section {
        case 1:
            title = "App Details"
            break
        case 2:
            title = "Other"
            break
        default: break
        }
        
        let frame = CGRectMake(20, 0, tableView.bounds.size.width, 40)
        let headerView = UIView(frame: frame)
        let label = UILabel(frame: frame)
        label.font = UIFont(name: "HelveticaNeue-Thin", size: 20.0)
        
        let style = NSParagraphStyle.defaultParagraphStyle().mutableCopy()
        let attrText = NSAttributedString(string: title, attributes: [NSParagraphStyleAttributeName: style])
        label.numberOfLines = 0
        label.attributedText = attrText
        
        headerView.addSubview(label)
        headerView.backgroundColor = UIColor(white: 0.7, alpha: 0.35)
        
        return headerView
    }
}