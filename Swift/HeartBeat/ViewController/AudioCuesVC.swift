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
    var selectedIndexPath = IndexPath()
    var selectedTextFieldIndexPath :IndexPath?
    let minutesArray = [0, 1, 2, 5, 10]
    let typesArray = ["Elapsed Time", "Current Heartbeat", "Average Heartbeat", "Calories Burned"]
    var didAppearModally = Bool()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Audio Cues"
        let index = minutesArray.index(of: user.audioTiming)
        selectedIndexPath = IndexPath(item: index!, section: 1)
        
        if didAppearModally {
            let navButton = UIBarButtonItem(title: "hide", style: .done, target: self, action: #selector(AudioCuesVC.dismissView))
            navigationItem.leftBarButtonItem = navButton
            tableView.backgroundColor = UIColor.white
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellID = indexPath.section == 0 ? "textFieldCell" : "audioCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! SettingsTableViewCell
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
                cell.accessoryType = .checkmark
            }
            break
        case 2:
            cell.textLabel!.text = String(format:"     %@", typesArray[indexPath.row])
            if user.checkSpokenCueIndex(indexPath.row) {
                cell.accessoryType = .checkmark
            }
        default: break
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        let previousCell = tableView.cellForRow(at: selectedIndexPath)
        let currentCell = tableView.cellForRow(at: indexPath)
        switch indexPath.section {
        case 0:
            selectedTextFieldIndexPath = indexPath
            break
        case 1:
            selectedIndexPath = indexPath
            previousCell?.accessoryType = .none
            currentCell!.accessoryType = .checkmark
            break
        case 2:
            if currentCell?.accessoryType == .checkmark {
                currentCell?.accessoryType = .none
            } else {
                currentCell?.accessoryType = .checkmark
            }
            break
        default: break
        }
        return indexPath
    }
 
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        switch indexPath.section {
        case 0://Limites
            let cell = tableView.cellForRow(at: indexPath)
            let textField = cell?.viewWithTag(100) as! UITextField
            textField.becomeFirstResponder()
            break
        case 1://Audio Timing
            let number = minutesArray[indexPath.row] as NSNumber
            user.audioTiming = number.intValue
            user.saveToDisk()
            break
        case 2://Spoken Cues
            var check = false
            let currentCell = tableView.cellForRow(at: indexPath)
            if currentCell?.accessoryType == .checkmark {
                check = true
            }
            user.spokenCues.replaceObject(at: indexPath.row, with: NSNumber(value: check as Bool))
            user.saveToDisk()
            break
        default: break
        }
    }
 
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
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
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        user.saveToDisk()
        view.window?.endEditing(true)
    }
    
    func dismissView() {
        dismiss(animated: true, completion: nil)
    }
}
