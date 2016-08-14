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
    var selectedIndexPath :NSIndexPath?
    
    var tableviewArray = NSMutableArray() //sorted workouts by date
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "history"
        
        createHeartNavigationButton(Direction.right.rawValue)
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: #selector(cloudKitUpdate),
            name: CloudKitWrapperNotificationId,
            object: nil)
        
        refreshControl.addTarget(self, action: #selector(HistoryVC.refreshTableView(_:)), forControlEvents: .ValueChanged)
        tableView.addSubview(refreshControl)
        
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(HistoryVC.longPress(_:)))
        tableView.addGestureRecognizer(longPressRecognizer)
    }
    
    @objc func cloudKitUpdate(notification: NSNotification){
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            if notification.object != nil && self.selectedIndexPath != nil {
                let recordID = notification.object as! CKRecordID
                let arr = self.tableviewArray[self.selectedIndexPath!.section]
                let workout = arr[self.selectedIndexPath!.row] as! Workout
                
                if workout.recordID == recordID {
                    if arr.count == 1 {
                        self.tableviewArray.removeObject(arr)
                        self.tableView.deleteSections(NSIndexSet(index: self.selectedIndexPath!.section), withRowAnimation: .Fade)
                    } else {
                        arr.removeObject(workout)
                        self.tableView.deleteRowsAtIndexPaths([self.selectedIndexPath!], withRowAnimation: .Fade)
                    }
                }
            } else {
                self.sortWorkoutValuesForTableView()
                self.tableView.reloadData()
            }
            self.refreshControl.endRefreshing()
            self.stopSpinner()
        }
    }
    
    func refreshTableView(refreshControl: UIRefreshControl) {
        CloudKitWrapper.sharedInstance.queryPrivateDatabaseForRecord(recordType, with: Workout.SortDescriptor())
    }
    //MARK:Tableview Delegate & Datasource
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cellId")
        
        let arr = tableviewArray[indexPath.section]
        let workout = arr[indexPath.row] as! Workout

        cell?.textLabel?.font = UIFont(name: helveticaUltraLightFont, size: 30)
        cell?.detailTextLabel?.font = UIFont(name: helveticaUltraLightFont, size: 15)
        cell!.textLabel!.text = String(format: "   %i min",workout.minutes())
        cell!.detailTextLabel!.text = String(format: "      %@  -  %@bpm", workout.workoutType, workout.averageBPMString())
        return cell!
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  tableviewArray[section].count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return tableviewArray.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        selectedIndexPath = indexPath
        self.performSegueWithIdentifier("WorkoutSummarySegue", sender: nil)
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        //grab workout in array
        let array = tableviewArray[section]
        let workout = array[0] as! Workout
        //create date formatter
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MM/dd/YYYY";
        //create title
        let title = dateFormatter.stringFromDate(workout.startTime!)
        
        return createSectionHeaderView(title)
    }
    
    func longPress(longPressGestureRecognizer: UILongPressGestureRecognizer) {    
        if longPressGestureRecognizer.state == UIGestureRecognizerState.Began {
            let touchPoint = longPressGestureRecognizer.locationInView(tableView)
            if let indexPath = tableView.indexPathForRowAtPoint(touchPoint) {
                let alertController = UIAlertController(title: nil, message: "are you sure you want to delete this workout?", preferredStyle: .ActionSheet)
                let cancelAction = UIAlertAction(title: "cancel", style: .Cancel) { (action) in }
                let destroyAction = UIAlertAction(title: "delete", style: .Destructive) { (action) in
                    self.startSpinner()
                    self.selectedIndexPath = indexPath
                    let workout = WorkoutController.sharedInstance.workoutArray![indexPath.row]
                    CloudKitWrapper.sharedInstance.deleteRecordFromPrivateDatabase(workout.recordID!)
                }
                alertController.addAction(cancelAction)
                alertController.addAction(destroyAction)
                
                self.presentViewController(alertController, animated: true) { }
            }
        }
    }
    
    func sortWorkoutValuesForTableView() {
        //create new array
        let arr = NSMutableArray()
        //start loop from workouts
        for workout in WorkoutController.sharedInstance.workoutArray! {
            var shouldCreateNewArray = true
            for tmpArr in arr {
                //grab each arrays first value
                if tmpArr.count > 0 {
                    let w = tmpArr[0] as! Workout
                    //check if current value matches first arrays value
                    print(w.startTime)
                    print(workout.startTime)
                    if NSCalendar.currentCalendar().isDate(w.startTime!, inSameDayAsDate: workout.startTime!){
                        shouldCreateNewArray = false
                        tmpArr.addObject(workout)
                        break
                    }
                }
            }
            //if loop ends without a matched value create new subarray and insert current value
            if shouldCreateNewArray {
                let tmpArr = NSMutableArray()
                tmpArr.addObject(workout)
                arr.addObject(tmpArr)
            }
        }
        //assign new array to tableviewArray
        tableviewArray = arr
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        if segue.identifier == "WorkoutSummarySegue" {
            let vc = segue.destinationViewController as! WorkoutSummaryVC
            vc.shouldDisplaySaveOptions = false
            let arr = tableviewArray[selectedIndexPath!.section]
            vc.workout = arr[selectedIndexPath!.row] as! Workout
        }
    }
}
