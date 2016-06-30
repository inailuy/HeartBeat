//
//  AudioCuesTVC.swift
//  HeartBeat
//
//  Created by inailuy on 6/15/16.
//  Copyright © 2016 Mxtapes. All rights reserved.
//

import Foundation
import UIKit

class AudioCuesVC: BaseVC, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    var selectedIndexPath = NSIndexPath()
    let minutesArray = [0, 1, 2, 5, 10]
    let typesArray = ["Elapsed Time", "Current Heartbeat", "Average Heartbeat", "Calories Burned"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Audio Cues"
        let index = minutesArray.indexOf(UserModel.sharedInstance.audioTiming)
        selectedIndexPath = NSIndexPath(forItem: index!, inSection: 0)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return minutesArray.count
        case 1:
            return typesArray.count
        default:
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("audioCell", forIndexPath: indexPath)
        cell.textLabel!.font = UIFont(name: "HelveticaNeue-Thin", size: 22.0)
        
        switch indexPath.section {
        case 0:
            cell.textLabel!.text = String(format:"     %d Minutes", minutesArray[indexPath.row])
            if selectedIndexPath == indexPath {
                cell.accessoryType = .Checkmark
            }
            break
        case 1:
            cell.textLabel!.text = String(format:"     %@", typesArray[indexPath.row])
            if UserModel.sharedInstance.checkSpokenCueIndex(indexPath.row) {
                cell.accessoryType = .Checkmark
            }
            break
        default: break
        }
        return cell
    }
    
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        let previousCell = tableView.cellForRowAtIndexPath(selectedIndexPath)
        let currentCell = tableView.cellForRowAtIndexPath(indexPath)
        switch indexPath.section {
        case 0:
            selectedIndexPath = indexPath
            previousCell!.accessoryType = .None
            currentCell!.accessoryType = .Checkmark
            break
        case 1:
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
        case 0://Audio Timing
            let number = minutesArray[indexPath.row] as NSNumber
            UserModel.sharedInstance.audioTiming = number.integerValue
            UserModel.sharedInstance.saveToDisk()
            break
        case 1://Spoken Cues
            var check = false
            let currentCell = tableView.cellForRowAtIndexPath(indexPath)
            if currentCell?.accessoryType == .Checkmark {
                check = true
            }
            UserModel.sharedInstance.spokenCues.replaceObjectAtIndex(indexPath.row, withObject: NSNumber(bool: check))
            UserModel.sharedInstance.saveToDisk()
            break
        default: break
        }
    }
 
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var title = ""
        switch (section) {
        case 0:
            title = "  Audio Timing";
            break;
        case 1:
            title = "  Spoken Cues";
        default:
            break;
        }
        return createSectionHeaderView(title)
    }
}