//
//  InterfaceController.swift
//  HeartBeatWatch Extension
//
//  Created by yulz on 6/21/17.
//  Copyright © 2017 Mxtapes. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController,WorkoutControllerDelegate {

    @IBOutlet var helloButton: WKInterfaceButton!
    @IBOutlet var timerLabel: WKInterfaceLabel!
    @IBOutlet var currentBPMLabel: WKInterfaceLabel!

    
    var startBool = true
//    @IBOutlet private weak var deviceLabel : WKInterfaceLabel!
//    @IBOutlet private weak var heart: WKInterfaceImage!
    //@IBOutlet private weak var startStopButton : WKInterfaceButton!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        // Configure interface objects here.
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        WorkoutController.sharedInstance.delegate = self
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    @IBAction func buttonPressed() {
        startBool = !startBool
        helloButton.setTitle("Stop")
        if startBool == true {
         helloButton.setTitle("Start")
            //WorkoutController.sharedInstance.endWorkout()
        } else {
            //WorkoutController.sharedInstance.startWorkout()
        }
        
    }
    
    func updateTimer() {
        
    }
    
    func updateUI(_ sender: WorkoutController) {
        currentBPMLabel.setText(sender.currentBPM() + " Current bpm")
        timerLabel.setText(sender.getTimeStr())
    }

}
