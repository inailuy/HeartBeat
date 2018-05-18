//
//  MainVC.swift
//  HeartBeat
//
//  Created by inailuy on 6/15/16.
//  Copyright © 2016 Mxtapes. All rights reserved.
//

import Foundation
import UIKit
//import AccountKit

class MainVC: BaseVC {
    @IBOutlet weak var bpmLabel: UILabel!
    @IBOutlet weak var startWorkoutControllerLabel: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "heartbeat"
        let historyButton = UIBarButtonItem(title: "History", style: UIBarButtonItemStyle.done, target: self, action: #selector(historyButtonPressed))
        let settingsButton = UIBarButtonItem(title: "Settings", style: UIBarButtonItemStyle.done, target: self, action: #selector(settingsButtonPressed))
        navigationItem.leftBarButtonItem = historyButton
        navigationItem.rightBarButtonItem = settingsButton
        
        Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(MainVC.updateBluetoothData), userInfo:nil, repeats: true)
        //startWorkoutButtonPressed(UIButton())
        //startWorkoutButtonPressed(UIButton())
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        /*
        if (appDelegate.accountKit.currentAccessToken == nil) {
            //User is logged out
            performLoginOperation()
        }
        */
    }
    
    @objc func historyButtonPressed() {
        appDelegate.swipeBetweenVC.scrollToViewController(at: 0, animated: true)
    }
    
    @objc func settingsButtonPressed() {
        appDelegate.swipeBetweenVC.scrollToViewController(at: 2, animated: true)
    }
    
    func performLoginOperation() {
        performSegue(withIdentifier: "loginSegue", sender: nil)
    }
    
    @IBAction func startWorkoutButtonPressed(_ sender: UIButton) {
        WorkoutController.sharedInstance.startWorkout()
        performSegue(withIdentifier: "WorkoutSegue", sender: nil)
    }
    
    @objc func updateBluetoothData() {
        bpmLabel.text = String(Bluetooth.sharedInstance.beatPerMinuteValue) + " bpm"
    }
}
