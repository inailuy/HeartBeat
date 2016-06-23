//
//  BaseVC.swift
//  HeartBeat
//
//  Created by inailuy on 6/15/16.
//  Copyright © 2016 Mxtapes. All rights reserved.
//

import Foundation
import UIKit
import HealthKit

class BaseVC: UIViewController {
    var healthStore : HKHealthStore!
    var workoutTypesArray = NSArray()
    var appDelegate : AppDelegate!
    //Class methods workoutTypesSetup and updateWorkoutType
    
    override func viewDidLoad() {
        super.viewDidLoad()
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        if self.healthStore == nil {
            healthStore = appDelegate.healthStore
        }
    }
    
    func createBlurEffect() {
        /*
 UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
 UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
 [blurEffectView setFrame:self.view.bounds];
 self.blurView.backgroundColor = [UIColor clearColor];
 self.blurView.alpha = .8;
 [self.blurView addSubview:blurEffectView];
 */
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.ExtraLight)
        let blurEffectView = UIVisualEffectView(effect: <#T##UIVisualEffect?#>)
    }
}
