//
//  PermissionsVC.swift
//  HeartBeat
//
//  Created by Yuliani Noriega on 12/4/16.
//  Copyright © 2016 Mxtapes. All rights reserved.
//

import Foundation

class PermissionsVC: UIViewController {
    
    @IBAction func gpsButtonClicked(sender: AnyObject) {
    }
    
    
    @IBAction func healthButtonClicked(sender: AnyObject) {
        Health.sharedInstance.askPermissionForHealth()
    }
    
    
    @IBAction func continueButtonClicked(sender: AnyObject) {
    }
}
