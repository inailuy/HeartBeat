//
//  HistoryVC.swift
//  HeartBeat
//
//  Created by inailuy on 6/15/16.
//  Copyright © 2016 Mxtapes. All rights reserved.
//

import Foundation
import UIKit

class HistoryVC: BaseVC, UITableViewDelegate, UITableViewDataSource {
    
    let refreshControl = UIRefreshControl()
    @IBOutlet weak var tableView: UITableView!
    var selectedIndexPath :NSIndexPath?
    
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
            self.refreshControl.endRefreshing()
            self.tableView.reloadData()
            self.stopSpinner()
        }
    }
    
    func refreshTableView(refreshControl: UIRefreshControl) {
        CloudKitWrapper.sharedInstance.queryPrivateDatabaseForRecord(recordType, with: Workout.SortDescriptor())
    }
    
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cellId")
        let workout = WorkoutController.sharedInstance.workoutArray![indexPath.row]
        //
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MM/dd"
        let dateInFormat = dateFormatter.stringFromDate(workout.endTime!)
        //
        
        cell?.textLabel?.font = UIFont(name: helveticaUltraLightFont, size: 30)
        cell?.detailTextLabel?.font = UIFont(name: helveticaUltraLightFont, size: 15)
        cell!.textLabel!.text = String(format: "   %i min",workout.minutes())
        cell!.detailTextLabel!.text = String(format: "      %@  -  %@bpm  -  %@", workout.workoutType, workout.averageBPMString(), dateInFormat)
        return cell!
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count = 0
        if WorkoutController.sharedInstance.workoutArray != nil {
            count = (WorkoutController.sharedInstance.workoutArray?.count)!
        }
        return  count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedIndexPath = indexPath
        self.performSegueWithIdentifier("WorkoutSummarySegue", sender: nil)
    }
    
    func longPress(longPressGestureRecognizer: UILongPressGestureRecognizer) {    
        if longPressGestureRecognizer.state == UIGestureRecognizerState.Began {
            let touchPoint = longPressGestureRecognizer.locationInView(tableView)
            if let indexPath = tableView.indexPathForRowAtPoint(touchPoint) {
                let alertController = UIAlertController(title: nil, message: "are you sure you want to delete this workout?", preferredStyle: .ActionSheet)
                let cancelAction = UIAlertAction(title: "cancel", style: .Cancel) { (action) in }
                let destroyAction = UIAlertAction(title: "delete", style: .Destructive) { (action) in
                    self.startSpinner()
                    let workout = WorkoutController.sharedInstance.workoutArray![indexPath.row]
                    CloudKitWrapper.sharedInstance.deleteRecordFromPrivateDatabase(workout.recordID!)
                }
                alertController.addAction(cancelAction)
                alertController.addAction(destroyAction)
                
                self.presentViewController(alertController, animated: true) { }
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        if segue.identifier == "WorkoutSummarySegue" {
            let vc = segue.destinationViewController as! WorkoutSummaryVC
            vc.shouldDisplaySaveOptions = false
            vc.workout = WorkoutController.sharedInstance.workoutArray![selectedIndexPath!.row]
        }
    }
}
