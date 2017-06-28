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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        muteButton.isSelected = UserSettings.sharedInstance.mute
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        WorkoutController.sharedInstance.delegate = self
        //map setup
        mapSetup()
        //line graph setup
        lineGraphSetup()
    }
    
    @IBAction func activityButtonPressed(_ sender: AnyObject) {
        //might delete feature
        self.performSegue(withIdentifier: "SegueCues", sender: nil)
    }
    
    @IBAction func muteButtonPressed(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        UserSettings.sharedInstance.mute = sender.isSelected
        UserSettings.sharedInstance.saveToDisk()
    }

    @IBAction func utterSummary(_ sender: UIButton) {
        SpeechUtterance.sharedInstance.speakWorkoutValues()
    }
    
    @IBAction func endButtonPressed(_ sender: AnyObject) {
        let alertController = UIAlertController(title: nil, message: "are you sure you want to end workout?", preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "cancel", style: .cancel) { (action) in}
        let deleteAction = UIAlertAction(title: "delete", style: .destructive) { (action) in
            WorkoutController.sharedInstance.endWorkout()
            self.dismiss(animated: true, completion: nil)
        }
        let saveAction = UIAlertAction(title: "save", style: .default) { (action) in
            WorkoutController.sharedInstance.endWorkout()
            WorkoutController.sharedInstance.saveWorkout()
            self.performSegue(withIdentifier: "WorkoutSummarySegue", sender: nil)
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(deleteAction)
        alertController.addAction(saveAction)
        
        self.present(alertController, animated: true) { }
    }
    
    @IBAction func pauseButtonPressed(_ sender: UIButton) {
        if WorkoutController.sharedInstance.pause {
            sender.setTitle("pause", for:UIControlState())
        } else {
            sender.setTitle("resume", for:UIControlState())
        }
        WorkoutController.sharedInstance.pauseWorkout()
    }
    
    
    @IBAction func hideGraphButtonPressed(_ sender: AnyObject) {
        if WorkoutController.sharedInstance.seconds < 10 { return }
        
        if disclousureBool {
            lineGraphView.isHidden = false
            blurView.isHidden = false
        } else {
            lineGraphView.isHidden = true
            blurView.isHidden = true
        }
        disclousureBool = !disclousureBool
    }
    //MARK: WorkoutControllerDelegate
    func updateUI(_ sender: WorkoutController) {
        if sender.seconds > 9 {
            
            averageBPMLabel.text = sender.averageBPMString() + " Average bpm"
            currentBPMLabel.text = sender.currentBPM() + " Current bpm"
            caloriesBurnedLabel.text = sender.grabVO2MaxData() + " Calories burned"
            if disclousureBool != true {
                lineGraphView.isHidden = false
                if sender.minutes < 4 && sender.seconds % 5 == 0 {
                    lineGraphView.reloadGraph()
                } else if sender.seconds % 10 == 0 {
                    lineGraphView.reloadGraph()
                }
            }
        } else {
            lineGraphView.isHidden = true
        }
        timerLabel.text = sender.getTimeStr()
        currentBPMLabel.text = sender.currentBPM() + " Current bpm"
    }
    //MARK: Map & CLLocation Delegates
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //TODO: Tracking GPS Distance for running
        if (mapView.showsUserLocation){
            let newLocation = locations[0]
            let region = MKCoordinateRegionMakeWithDistance(newLocation.coordinate, 100, 100)
            mapView.setRegion(region, animated: true)
        }
    }
    
    //MARK: BEMSimpleLineGraphView DataSource/Delegate
    /** The vertical position for a point at the given index. It corresponds to the Y-axis value of the Graph.
     @param graph The graph object requesting the point value.
     @param index The index from left to right of a given point (X-axis). The first value for the index is 0.
     @return The Y-axis value at a given index. */
    func lineGraph(_ graph: BEMSimpleLineGraphView, valueForPointAt index: UInt) -> CGFloat {
            let point = WorkoutController.sharedInstance.filterHeartBeatArray()[Int(index)]
            return CGFloat(point as! NSNumber)
    }
    
    func numberOfPoints(inLineGraph graph: BEMSimpleLineGraphView) -> UInt {
        return UInt(WorkoutController.sharedInstance.filterHeartBeatArray().count)
    }
    
    private func lineGraph(_ graph: BEMSimpleLineGraphView, labelOnXAxisFor index: Int) -> String {
            return WorkoutController.sharedInstance.getTimeFromSeconds(index)
    }

    private func numberOfYAxisLabels(onLineGraph graph: BEMSimpleLineGraphView) -> Int {
        return 5
    }

    private func numberOfGapsBetweenLabels(onLineGraph graph: BEMSimpleLineGraphView) -> Int {
        return WorkoutController.sharedInstance.filterHeartBeatArray().count / 5
    }
    
    func lineGraph(_ graph: BEMSimpleLineGraphView, valueForPointAt index: Int) -> CGFloat {
        let point = WorkoutController.sharedInstance.filterHeartBeatArray()[index]
        return CGFloat(point as! NSNumber)
    }

    func maxValue(forLineGraph graph: BEMSimpleLineGraphView) -> CGFloat {
        var max = 0
        for num in WorkoutController.sharedInstance.filterHeartBeatArray() {
            let n = num as! NSNumber
            if max < n.intValue {
                max = n.intValue
            }
        }
        return CGFloat(max)
    }
    
    func minValue(forLineGraph graph: BEMSimpleLineGraphView) -> CGFloat {
        var min = 200
        for num in WorkoutController.sharedInstance.filterHeartBeatArray() {
            let n = num as! NSNumber
            if min > n.intValue {
                min = n.intValue
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
        lineGraphView.animationGraphStyle = .none
    }
    
    func mapSetup()  {
        let authstate = CLLocationManager.authorizationStatus()
        if authstate == CLAuthorizationStatus.notDetermined {
            locationManager.requestAlwaysAuthorization()
        } else if authstate == CLAuthorizationStatus.denied {
            //TODO: defend against rejection
        }
        
        mapView.frame = view.frame
        view.addSubview(mapView)
        view.sendSubview(toBack: mapView)
        
        mapView.showsUserLocation = true
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
            locationManager.distanceFilter = 5
            self.mapView.showsUserLocation = true;
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "WorkoutSummarySegue" {
            let vc = segue.destination as! WorkoutSummaryVC
            vc.shouldDisplaySaveOptions = true
            vc.region = mapView.region
            vc.workout = WorkoutController.sharedInstance.workout
        } else if segue.identifier == "SegueCues" {
             let nc = segue.destination as! UINavigationController
            let vc = nc.viewControllers[0] as! AudioCuesVC
            vc.didAppearModally = true
        }
    }
}
