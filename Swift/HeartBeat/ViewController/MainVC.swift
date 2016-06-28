//
//  MainVC.swift
//  HeartBeat
//
//  Created by inailuy on 6/15/16.
//  Copyright © 2016 Mxtapes. All rights reserved.
//

import Foundation
import UIKit


class MainVC: BaseVC {
    //2 labels
    //perfromLoginOperation class method
    
    @IBOutlet weak var bpmLabel: UILabel!
    @IBOutlet weak var startWorkoutLabel: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "heartbeat"
        let historyButton = UIBarButtonItem(title: "History", style: UIBarButtonItemStyle.Done, target: self, action: #selector(historyButtonPressed))
        let settingsButton = UIBarButtonItem(title: "Settings", style: UIBarButtonItemStyle.Done, target: self, action: #selector(settingsButtonPressed))
        navigationItem.leftBarButtonItem = historyButton
        navigationItem.rightBarButtonItem = settingsButton
        
        createBlurEffect()
    }
    
    func historyButtonPressed() {
        appDelegate.swipeBetweenVC.scrollToViewControllerAtIndex(0, animated: true)
    }
    
    func settingsButtonPressed() {
        appDelegate.swipeBetweenVC.scrollToViewControllerAtIndex(2, animated: true)
    }
    @IBAction func startWorkoutButtonPressed(sender: UIButton) {
        print("startWorkoutButtonPressed")
    }
}