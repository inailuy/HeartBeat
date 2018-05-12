//
//  HistoryVC.swift
//  HeartBeat
//
//  Created by inailuy on 6/15/16.
//  Copyright © 2016 Mxtapes. All rights reserved.
//

import Foundation
import UIKit
import CloudKit

class HistoryVC: BaseVC, UITableViewDelegate, UITableViewDataSource {
    
    let refreshControl = UIRefreshControl()
    @IBOutlet weak var tableView: UITableView!
    var selectedIndexPath :IndexPath?
    
    var tableviewArray = NSMutableArray() //sorted workouts by date
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "history"
        
        //TODO:implement maybe later?
        //let btnBack = UIBarButtonItem(title: "edit", style: .Plain, target: self, action: #selector(HistoryVC.backButtonPressed))
        //navigationItem.leftBarButtonItem = btnBack
        
        createHeartNavigationButton(Direction.right.rawValue)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(dataUpdate),
            name: NSNotification.Name(rawValue: DataControllerNotificationId),
            object: nil)
        
        refreshControl.addTarget(self, action: #selector(HistoryVC.refreshTableView(_:)), for: .valueChanged)
        tableView.addSubview(refreshControl)
        
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(HistoryVC.longPress(_:)))
        tableView.addGestureRecognizer(longPressRecognizer)
        
        if DataController.sharedInstance.workoutArray.count > 0 {
            sortWorkoutValuesForTableView()
            tableView.reloadData()
        }
        
        Health.sharedInstance.readWorkoutData()
    }
    
    @objc func dataUpdate(_ notification: Notification){
        DispatchQueue.main.async { () -> Void in
            if notification.object != nil && self.selectedIndexPath != nil {
                /*
                let recordID = notification.object as! CKRecordID
                let arr = self.tableviewArray[self.selectedIndexPath!.section] as! NSMutableArray
                let workout = arr[self.selectedIndexPath!.row] as! Workout
                
                if workout.recordID?.recordName == recordID.recordName {
                    if arr.count == 1 {
                        self.tableviewArray.removeObject(arr)
                        self.tableView.deleteSections(NSIndexSet(index: self.selectedIndexPath!.section), withRowAnimation: .Fade)
                    } else {
                        arr.removeObject(workout)
                        self.tableView.deleteRowsAtIndexPaths([self.selectedIndexPath!], withRowAnimation: .Fade)
                    }
                }
                 */
            } else {
                self.sortWorkoutValuesForTableView()
                self.tableView.reloadData()
            }
            self.refreshControl.endRefreshing()
            self.stopSpinner()
        }
    }
    
    @objc func refreshTableView(_ refreshControl: UIRefreshControl) {
        DataController.sharedInstance.loadAll()
    }
    //MARK:Tableview Delegate & Datasource
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId")
        
        let arr = tableviewArray[indexPath.section] as! NSMutableArray
        let workoutObject = arr[indexPath.row] as! Workout

        cell?.textLabel?.font = UIFont(name: helveticaUltraLightFont, size: 30)
        cell?.detailTextLabel?.font = UIFont(name: helveticaUltraLightFont, size: 15)
        cell!.textLabel!.text = String(format: "   %i min",workoutObject.minutes())
        
        if workoutObject.workoutType == nil { workoutObject.workoutType = "no type" }
        cell!.detailTextLabel!.text = String(format: "      %@  -  %@bpm", workoutObject.workoutType!, workoutObject.averageBPMString())
        return cell!
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  (tableviewArray[section] as AnyObject).count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return tableviewArray.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        selectedIndexPath = indexPath
        self.performSegue(withIdentifier: "WorkoutSummarySegue", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        //grab workout in array
        let array = tableviewArray[section] as! NSMutableArray
        let workout = array[0] as! Workout
        //create date formatter
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/YYYY";
        //create title
        let title = dateFormatter.string(from: workout.startTime!)
        
        return createSectionHeaderView(title)
    }
    
    @objc func longPress(_ longPressGestureRecognizer: UILongPressGestureRecognizer) {    
        if longPressGestureRecognizer.state == UIGestureRecognizerState.began {
            let touchPoint = longPressGestureRecognizer.location(in: tableView)
            if let indexPath = tableView.indexPathForRow(at: touchPoint) {
                let alertController = UIAlertController(title: nil, message: "are you sure you want to delete this workout?", preferredStyle: .actionSheet)
                let cancelAction = UIAlertAction(title: "cancel", style: .cancel) { (action) in }
                let destroyAction = UIAlertAction(title: "delete", style: .destructive) { (action) in
                    self.startSpinner()
                    self.selectedIndexPath = indexPath

                    let tmpArr = self.tableviewArray[indexPath.section] as! [Workout]
                    let workout = tmpArr[indexPath.row]
                    
                    DataController.sharedInstance.deleteWorkout(workout, completion: { success in
                        if success {
                            self.sortWorkoutValuesForTableView()
                            DispatchQueue.main.async { () -> Void in
                                self.tableView.reloadData()
                                self.stopSpinner()
                            }
                        }
                    })
                }
                alertController.addAction(cancelAction)
                alertController.addAction(destroyAction)
                
                self.present(alertController, animated: true) { }
            }
        }
    }
    
    func sortWorkoutValuesForTableView() {
        //create new array
        let arr = NSMutableArray()
        //start loop from workouts
        
        for workout in DataController.sharedInstance.workoutArray {
            var shouldCreateNewArray = true
            for i in arr {
                //grab each arrays first value
                let tmpArr = i as! NSMutableArray
                if tmpArr.count > 0 {
                    let w = tmpArr[0] as! Workout
                    //check if current value matches first arrays value
                    if Calendar.current.isDate(w.startTime!, inSameDayAs: workout.startTime!){
                        shouldCreateNewArray = false
                        tmpArr.add(workout)
                        break
                    }
                }
            }
            //if loop ends without a matched value create new subarray and insert current value
            if shouldCreateNewArray {
                let tmpArr = NSMutableArray()
                tmpArr.add(workout)
                arr.add(tmpArr)
            }
        }
        //assign new array to tableviewArray
        tableviewArray = arr
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if segue.identifier == "WorkoutSummarySegue" {
            let vc = segue.destination as! WorkoutSummaryVC
            vc.shouldDisplaySaveOptions = false
            let arr = tableviewArray[selectedIndexPath!.section] as! NSMutableArray
            vc.workout = arr[selectedIndexPath!.row] as! Workout
        }
    }
}
