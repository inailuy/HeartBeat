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

class WorkoutVC: BaseVC, WorkoutControllerDelegate, BEMSimpleLineGraphDelegate, BEMSimpleLineGraphDataSource,CLLocationManagerDelegate {
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var averageBPMLabel: UILabel!
    @IBOutlet weak var currentBPMLabel: UILabel!
    @IBOutlet weak var caloriesBurnedLabel: UILabel!
    @IBOutlet weak var endWorkoutControllerButton: UIButton!
    @IBOutlet weak var pauseWorkoutControllerButton: UIButton!
    @IBOutlet weak var disclousureButton: UIButton!
    @IBOutlet weak var activityButton: UIButton!
    @IBOutlet weak var muteButton: UIButton!
    @IBOutlet weak var lineGraphView: BEMSimpleLineGraphView!
    
    var disclousureBool = Bool()
    let mapView = MKMapView()
    let locationManager = CLLocationManager()
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        muteButton.selected = UserSettings.sharedInstance.mute
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        WorkoutController.sharedInstance.delegate = self
        //map setup
        mapSetup()
        //line graph setup
        lineGraphSetup()
    }
    
    @IBAction func activityButtonPressed(sender: AnyObject) {
        //might delete feature
        self.performSegueWithIdentifier("SegueCues", sender: nil)
    }
    
    @IBAction func muteButtonPressed(sender: UIButton) {
        sender.selected = !sender.selected
        UserSettings.sharedInstance.mute = sender.selected
        UserSettings.sharedInstance.saveToDisk()
    }

    @IBAction func utterSummary(sender: UIButton) {
        SpeechUtterance.sharedInstance.speakWorkoutValues()
    }
    
    @IBAction func endButtonPressed(sender: AnyObject) {
        let alertController = UIAlertController(title: nil, message: "are you sure you want to end workout?", preferredStyle: .ActionSheet)
        let cancelAction = UIAlertAction(title: "cancel", style: .Cancel) { (action) in}
        let deleteAction = UIAlertAction(title: "delete", style: .Destructive) { (action) in
            WorkoutController.sharedInstance.endWorkout()
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        let saveAction = UIAlertAction(title: "save", style: .Default) { (action) in
            WorkoutController.sharedInstance.endWorkout()
            WorkoutController.sharedInstance.saveWorkout()
            self.performSegueWithIdentifier("WorkoutSummarySegue", sender: nil)
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(deleteAction)
        alertController.addAction(saveAction)
        
        self.presentViewController(alertController, animated: true) { }
    }
    
    @IBAction func pauseButtonPressed(sender: UIButton) {
        if WorkoutController.sharedInstance.pause {
            sender.setTitle("pause", forState:.Normal)
        } else {
            sender.setTitle("resume", forState:.Normal)
        }
        WorkoutController.sharedInstance.pauseWorkout()
    }
    
    
    @IBAction func hideGraphButtonPressed(sender: AnyObject) {
        if WorkoutController.sharedInstance.seconds < 10 { return }
        
        if disclousureBool {
            lineGraphView.hidden = false
            blurView.hidden = false
        } else {
            lineGraphView.hidden = true
            blurView.hidden = true
        }
        disclousureBool = !disclousureBool
    }
    //MARK: WorkoutControllerDelegate
    func updateUI(sender: WorkoutController) {
        if sender.seconds > 9 {
            
            averageBPMLabel.text = sender.averageBPMString() + " Average bpm"
            currentBPMLabel.text = sender.currentBPM() + " Current bpm"
            caloriesBurnedLabel.text = sender.grabVO2MaxData() + " Calories burned"
            if disclousureBool != true {
                lineGraphView.hidden = false
                if sender.minutes < 4 && sender.seconds % 5 == 0 {
                    lineGraphView.reloadGraph()
                } else if sender.seconds % 10 == 0 {
                    lineGraphView.reloadGraph()
                }
            }
        } else {
            lineGraphView.hidden = true
        }
        timerLabel.text = sender.getTimeStr()
        currentBPMLabel.text = sender.currentBPM() + " Current bpm"
    }
    //MARK: Map & CLLocation Delegates
    func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation) {
        //TODO: Tracking GPS Distance for running
        
        if (mapView.showsUserLocation){
            let region = MKCoordinateRegionMakeWithDistance(newLocation.coordinate, 100, 100)
            mapView.setRegion(region, animated: true)
        }
    }
    
    //MARK: BEMSimpleLineGraphView DataSource/Delegate
    func numberOfPointsInLineGraph(graph: BEMSimpleLineGraphView) -> Int {
        return WorkoutController.sharedInstance.filterHeartBeatArray().count
    }
    
    func lineGraph(graph: BEMSimpleLineGraphView, labelOnXAxisForIndex index: Int) -> String {
            return WorkoutController.sharedInstance.getTimeFromSeconds(index)
    }
    
    
    func numberOfYAxisLabelsOnLineGraph(graph: BEMSimpleLineGraphView) -> Int {
        return 5
    }

    func numberOfGapsBetweenLabelsOnLineGraph(graph: BEMSimpleLineGraphView) -> Int {
        return WorkoutController.sharedInstance.filterHeartBeatArray().count / 5
    }
    
    func lineGraph(graph: BEMSimpleLineGraphView, valueForPointAtIndex index: Int) -> CGFloat {
        let point = WorkoutController.sharedInstance.filterHeartBeatArray()[index]
        return CGFloat(point.doubleValue)
    }
    
    func maxValueForLineGraph(graph: BEMSimpleLineGraphView) -> CGFloat {
        var max = 0
        for num in WorkoutController.sharedInstance.filterHeartBeatArray() {
            let n = num as! NSNumber
            if max < n.integerValue {
                max = n.integerValue
            }
        }
        return CGFloat(max)
    }
    
    func minValueForLineGraph(graph: BEMSimpleLineGraphView) -> CGFloat {
        var min = 200
        for num in WorkoutController.sharedInstance.filterHeartBeatArray() {
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
    
    func mapSetup()  {
        let authstate = CLLocationManager.authorizationStatus()
        if authstate == CLAuthorizationStatus.NotDetermined {
            locationManager.requestAlwaysAuthorization()
        } else if authstate == CLAuthorizationStatus.Denied {
            //TODO: defend against rejection
        }
        
        mapView.frame = view.frame
        view.addSubview(mapView)
        view.sendSubviewToBack(mapView)
        
        mapView.showsUserLocation = true
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
            locationManager.distanceFilter = 5
            self.mapView.showsUserLocation = true;
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "WorkoutSummarySegue" {
            let vc = segue.destinationViewController as! WorkoutSummaryVC
            vc.shouldDisplaySaveOptions = true
            vc.region = mapView.region
            vc.workout = WorkoutController.sharedInstance.workout
        } else if segue.identifier == "SegueCues" {
             let nc = segue.destinationViewController as! UINavigationController
            let vc = nc.viewControllers[0] as! AudioCuesVC
            vc.didAppearModally = true
        }
    }
}
