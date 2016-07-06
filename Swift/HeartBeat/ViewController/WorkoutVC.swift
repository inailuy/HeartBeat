//
//  WorkoutVC.swift
//  HeartBeat
//
//  Created by inailuy on 6/15/16.
//  Copyright © 2016 Mxtapes. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class WorkoutVC: BaseVC, WorkoutDelegate, BEMSimpleLineGraphDelegate, BEMSimpleLineGraphDataSource {
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var averageBPMLabel: UILabel!
    @IBOutlet weak var currentBPMLabel: UILabel!
    @IBOutlet weak var caloriesBurnedLabel: UILabel!
    @IBOutlet weak var endWorkoutButton: UIButton!
    @IBOutlet weak var pauseWorkoutButton: UIButton!
    @IBOutlet weak var disclousureButton: UIButton!
    @IBOutlet weak var activityButton: UIButton!
    @IBOutlet weak var lineGraphView: BEMSimpleLineGraphView!
    
    var disclousureBool = Bool()
    let mapView = MKMapView()
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Workout.sharedInstance.delegate = self
        //map setup
        mapView.frame = view.frame
        view.addSubview(mapView)
        view.sendSubviewToBack(mapView)
        //line graph setup
        lineGraphSetup()
    }
    
    @IBAction func activityButtonPressed(sender: AnyObject) {
        //might delete feature
    }
    
    @IBAction func muteButtonPressed(sender: UIButton) {
        sender.selected = !sender.selected
        //TODO: mute speech utterance
    }
    
    @IBAction func endButtonPressed(sender: AnyObject) {
        Workout.sharedInstance.endWorkout()
        let alertController = UIAlertController(title: nil, message: "Are you sure you want to end workout?", preferredStyle: .ActionSheet)
        let cancelAction = UIAlertAction(title: "cancel", style: .Cancel) { (action) in}
        let destroyAction = UIAlertAction(title: "end", style: .Destructive) { (action) in
              self.performSegueWithIdentifier("endWorkoutSegue", sender: nil)
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(destroyAction)
        
        self.presentViewController(alertController, animated: true) { }
    }
    
    @IBAction func pauseButtonPressed(sender: UIButton) {
        if Workout.sharedInstance.pause {
            sender.setTitle("pause", forState:.Normal)
        } else {
            sender.setTitle("resume", forState:.Normal)
        }
        Workout.sharedInstance.pauseWorkout()
    }
    
    
    @IBAction func hideGraphButtonPressed(sender: AnyObject) {
        if disclousureBool {
            lineGraphView.hidden = false
            blurView.hidden = false
        } else {
            lineGraphView.hidden = true
            blurView.hidden = true
        }
        disclousureBool = !disclousureBool
    }
    //MARK: WorkoutDelegate
    func updateUI(sender: Workout) {
        if sender.seconds > 10 {
            averageBPMLabel.text = sender.averageBPMString() + " Average bpm"
            currentBPMLabel.text = sender.currentBPM() + " Current bpm"
            caloriesBurnedLabel.text = sender.grabVO2MaxData() + " Calories burned"
            if sender.minutes < 4 && sender.seconds % 5 == 0 {
                lineGraphView.reloadGraph()
            } else if sender.seconds % 15 == 0 {
                lineGraphView.reloadGraph()
            }
        }
        timerLabel.text = sender.getTimeStr()
        currentBPMLabel.text = sender.currentBPM() + " Current bpm"
    }
    //MARK: BEMSimpleLineGraphView DataSource/Delegate
    func numberOfPointsInLineGraph(graph: BEMSimpleLineGraphView) -> Int {
        return Workout.sharedInstance.heartBeatArray.count
    }
    
    func lineGraph(graph: BEMSimpleLineGraphView, labelOnXAxisForIndex index: Int) -> String {
            return Workout.sharedInstance.getTimeFromSeconds(index)
    }
    
    
    func numberOfYAxisLabelsOnLineGraph(graph: BEMSimpleLineGraphView) -> Int {
        return 5
    }

    func numberOfGapsBetweenLabelsOnLineGraph(graph: BEMSimpleLineGraphView) -> Int {
        return Workout.sharedInstance.heartBeatArray.count / 5
    }
    
    func lineGraph(graph: BEMSimpleLineGraphView, valueForPointAtIndex index: Int) -> CGFloat {
        let point = Workout.sharedInstance.heartBeatArray[index]
        return CGFloat(point.doubleValue)
    }
    
    func maxValueForLineGraph(graph: BEMSimpleLineGraphView) -> CGFloat {
        var max = 0
        for num in Workout.sharedInstance.heartBeatArray {
            let n = num as! NSNumber
            if max < n.integerValue {
                max = n.integerValue
            }
        }
        return CGFloat(max)
    }
    
    func minValueForLineGraph(graph: BEMSimpleLineGraphView) -> CGFloat {
        var min = 200
        for num in Workout.sharedInstance.heartBeatArray {
            let n = num as! NSNumber
            if min > n.integerValue {
                min = n.integerValue
            }
        }
        return CGFloat(min)
    }
    
    func lineGraphSetup() {
        lineGraphView.enableBezierCurve = true
        lineGraphView.enablePopUpReport = true
        lineGraphView.enableTouchReport = true
        lineGraphView.enableXAxisLabel = true
        lineGraphView.enableYAxisLabel = true
        lineGraphView.enableReferenceXAxisLines = true
        lineGraphView.enableReferenceYAxisLines = true
        lineGraphView.enableBezierCurve = true
        lineGraphView.animationGraphStyle = .None
    }
}
