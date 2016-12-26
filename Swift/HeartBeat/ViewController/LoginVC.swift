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
    //var appDelegate : AppDelegate! //Might Delete
    @IBOutlet weak var heartbeatImageView: UIImageView!
    @IBOutlet weak var heartbeatLabel: UILabel!
    @IBOutlet weak var loginButton: UIButton!
    
    var appDelegate : AppDelegate! //Might Delete
    
    override func viewDidLoad() {
        super.viewDidLoad()
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        loginButton.alpha = 0
        heartbeatLabel.alpha = 0
        heartbeatImageView.alpha = 0
        
        UIView.animateWithDuration(0.4, animations: {
            self.heartbeatLabel.alpha = 1.0
            self.heartbeatImageView.alpha = 1.0
            }, completion: { finished in
                UIView.animateWithDuration(0.9, animations: {
                    var labelFrame = self.heartbeatLabel.frame
                    var imageFrame = self.heartbeatImageView.frame
                    
                    imageFrame.origin.y = imageFrame.origin.y - (imageFrame.origin.y / 1.5)
                    labelFrame.origin.y = imageFrame.origin.y + imageFrame.size.height + 8
                    
                    self.heartbeatImageView.frame = imageFrame
                    self.heartbeatLabel.frame = labelFrame
                    }, completion: { finished in
                        self.loginButton.alpha = 0.1
                        UIView.animateWithDuration(0.55, animations: {
                            self.loginButton.alpha = 1.0
                        })
                })
        })
    }
    
    @IBAction func loginWithFacebook(sender: UIButton) {
        //TODO: Finish FB Login
        permissionSegue()
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

       NSTimer.scheduledTimerWithTimeInterval(0.6, target: self, selector: #selector(self.permissionSegue), userInfo:nil, repeats: false)
        
        //TODO: save user login 
        /*
        appDelegate.accountKit.requestAccount({ (account:AKFAccount?, error:NSError?) in
         
        })
        */
    }
    
    func dismiss() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func permissionSegue() {
        performSegueWithIdentifier("permissionSegue", sender: nil)
    }
}
