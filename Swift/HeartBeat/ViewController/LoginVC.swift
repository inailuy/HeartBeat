//
//  LoginVC.swift
//  HeartBeat
//
//  Created by inailuy on 6/15/16.
//  Copyright © 2016 Mxtapes. All rights reserved.
//

import Foundation
import UIKit
import AccountKit


class LoginVC: UIViewController, AKFViewControllerDelegate {
    var pendingLoginViewController :UIViewController!
    var authorizationCode :String!
    var state :String!
    var appDelegate : AppDelegate! //Might Delete
    
    override func viewDidLoad() {
        super.viewDidLoad()
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    }
    
    @IBAction func loginWithFacebook(sender: UIButton) {
        //TODO: Finish FB Login
        dismiss()
    }
    
    @IBAction func loginWithPhone(sender: UIButton) {
        let preFillPhoneNumber = AKFPhoneNumber(countryCode: "", phoneNumber: "")
        let inputState = NSUUID().UUIDString
        let viewController = appDelegate.accountKit.viewControllerForPhoneLoginWithPhoneNumber(preFillPhoneNumber, state: inputState) as! AKFViewController
        viewController.delegate = self
        viewController.enableSendToFacebook = true
        self.presentViewController(viewController as! UIViewController, animated: true, completion: nil)
    }
    
    //MARK: AKFViewControllerDelegate
    func viewController(viewController: UIViewController!, didCompleteLoginWithAccessToken accessToken: AKFAccessToken!, state: String!) {
        appDelegate.accountKit.requestAccount({ (account:AKFAccount?, error:NSError?) in
            self.performSegueWithIdentifier("permissionSegue", sender: nil)
        })
    }
    
    func dismiss() {
        self.dismissViewControllerAnimated(false, completion: nil)
    }
}
