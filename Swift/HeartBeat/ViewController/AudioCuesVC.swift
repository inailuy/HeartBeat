//
//  AudioCuesTVC.swift
//  HeartBeat
//
//  Created by inailuy on 6/15/16.
//  Copyright © 2016 Mxtapes. All rights reserved.
//

import Foundation
import UIKit

class AudioCuesVC: BaseVC, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    @IBOutlet weak var tableView: UITableView!
    var user = UserSettings.sharedInstance
    var selectedIndexPath = NSIndexPath()
    var selectedTextFieldIndexPath :NSIndexPath?
    let minutesArray = [0, 1, 2, 5, 10]
    let typesArray = ["Elapsed Time", "Current Heartbeat", "Average Heartbeat", "Calories Burned"]
    var didAppearModally = Bool()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Audio Cues"
        let index = minutesArray.indexOf(user.audioTiming)
        selectedIndexPath = NSIndexPath(forItem: index!, inSection: 1)
        
        if didAppearModally {
            let navButton = UIBarButtonItem(title: "hide", style: .Done, target: self, action: #selector(AudioCuesVC.dismissView))
            navigationItem.leftBarButtonItem = navButton
            tableView.backgroundColor = UIColor.whiteColor()
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 2
        case 1:
            return minutesArray.count
        case 2:
            return typesArray.count
        default:
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellID = indexPath.section == 0 ? "textFieldCell" : "audioCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellID, forIndexPath: indexPath) as! SettingsTableViewCell
        cell.textLabel!.font = UIFont(name: helveticaThinFont, size: 22.0)
        
        switch indexPath.section {
        case 0:
            let title = indexPath.row == 0 ? "     Minimum" : "     Maximum"
            cell.textLabel!.text = title
            let textField = cell.viewWithTag(100) as! UITextField
            textField.delegate = cell
            if indexPath.row == 0 {
                textField.text = String(user.minimumBPM)
            } else {
                textField.text = String(user.maximunBPM)
            }
            break
        case 1:
            cell.textLabel!.text = String(format:"     %d Minutes", minutesArray[indexPath.row])
            if selectedIndexPath == indexPath {
                cell.accessoryType = .Checkmark
            }
            break
        case 2:
            cell.textLabel!.text = String(format:"     %@", typesArray[indexPath.row])
            if user.checkSpokenCueIndex(indexPath.row) {
                cell.accessoryType = .Checkmark
            }
        default: break
        }
        return cell
    }
    
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        let previousCell = tableView.cellForRowAtIndexPath(selectedIndexPath)
        let currentCell = tableView.cellForRowAtIndexPath(indexPath)
        switch indexPath.section {
        case 0:
            selectedTextFieldIndexPath = indexPath
            break
        case 1:
            selectedIndexPath = indexPath
            previousCell?.accessoryType = .None
            currentCell!.accessoryType = .Checkmark
            break
        case 2:
            if currentCell?.accessoryType == .Checkmark {
                currentCell?.accessoryType = .None
            } else {
                currentCell?.accessoryType = .Checkmark
            }
            break
        default: break
        }
        return indexPath
    }
 
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        switch indexPath.section {
        case 0://Limites
            let cell = tableView.cellForRowAtIndexPath(indexPath)
            let textField = cell?.viewWithTag(100) as! UITextField
            textField.becomeFirstResponder()
            break
        case 1://Audio Timing
            let number = minutesArray[indexPath.row] as NSNumber
            user.audioTiming = number.integerValue
            user.saveToDisk()
            break
        case 2://Spoken Cues
            var check = false
            let currentCell = tableView.cellForRowAtIndexPath(indexPath)
            if currentCell?.accessoryType == .Checkmark {
                check = true
            }
            user.spokenCues.replaceObjectAtIndex(indexPath.row, withObject: NSNumber(bool: check))
            user.saveToDisk()
            break
        default: break
        }
    }
 
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var title = ""
        switch (section) {
        case 0:
            title = "  BPM Limits"
        case 1:
            title = "  Audio Timing"
            break
        case 2:
            title = "  Spoken Cues"
            break
        default:
            break
        }
        return createSectionHeaderView(title)
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        user.saveToDisk()
        view.window?.endEditing(true)
    }
    
    func dismissView() {
        dismissViewControllerAnimated(true, completion: nil)
    }
}
