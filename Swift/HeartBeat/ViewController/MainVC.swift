//
//  MainVC.swift
//  HeartBeat
//
//  Created by inailuy on 6/15/16.
//  Copyright © 2016 Mxtapes. All rights reserved.
//

import Foundation
import UIKit
import AccountKit

class MainVC: BaseVC {
    @IBOutlet weak var bpmLabel: UILabel!
    @IBOutlet weak var startWorkoutControllerLabel: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "heartbeat"
        let historyButton = UIBarButtonItem(title: "History", style: UIBarButtonItemStyle.Done, target: self, action: #selector(historyButtonPressed))
        let settingsButton = UIBarButtonItem(title: "Settings", style: UIBarButtonItemStyle.Done, target: self, action: #selector(settingsButtonPressed))
        navigationItem.leftBarButtonItem = historyButton
        navigationItem.rightBarButtonItem = settingsButton
        
        NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(MainVC.updateBluetoothData), userInfo:nil, repeats: true)
        //startWorkoutButtonPressed(UIButton())
        //startWorkoutButtonPressed(UIButton())
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if (appDelegate.accountKit.currentAccessToken == nil) {
            //User is logged out
            performLoginOperation()
        }
    }
    
    func historyButtonPressed() {
        appDelegate.swipeBetweenVC.scrollToViewControllerAtIndex(0, animated: true)
    }
    
    func settingsButtonPressed() {
        appDelegate.swipeBetweenVC.scrollToViewControllerAtIndex(2, animated: true)
    }
    
    func performLoginOperation() {
        performSegueWithIdentifier("loginSegue", sender: nil)
    }
    
    @IBAction func startWorkoutButtonPressed(sender: UIButton) {
        WorkoutController.sharedInstance.startWorkout()
        performSegueWithIdentifier("WorkoutSegue", sender: nil)
    }
    
    func updateBluetoothData() {
        bpmLabel.text = String(Bluetooth.sharedInstance.beatPerMinuteValue) + " bpm"
    }
}
