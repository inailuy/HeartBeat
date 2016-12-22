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


class LoginVC: BaseVC, AKFViewControllerDelegate {
    var accountKit :AKFAccountKit!
    var pendingLoginViewController :UIViewController!
    var authorizationCode :String!
    var state :String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //performSegueWithIdentifier("permissionSegue", sender: nil)
        
         // initialize Account Kit
         if (accountKit == nil) {
         // may also specify AKFResponseTypeAccessToken
            accountKit = AKFAccountKit(responseType: .AuthorizationCode)
         }
         
         // view controller for resuming login
        pendingLoginViewController = accountKit.viewControllerForLoginResume()
         //
        if accountKit == nil {
            accountKit = AKFAccountKit(responseType: .AuthorizationCode)
        }
        pendingLoginViewController = accountKit.viewControllerForLoginResume()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if authorizationCode != nil {
            self.dismiss()
        }
    }
    
    @IBAction func loginWithFacebook(sender: UIButton) {
        dismiss()
    }
    
    
    @IBAction func loginWithPhone(sender: UIButton) {
        let preFillPhoneNumber = AKFPhoneNumber(countryCode: "", phoneNumber: "")
        let inputState = NSUUID().UUIDString
        let viewController = accountKit.viewControllerForPhoneLoginWithPhoneNumber(preFillPhoneNumber, state: inputState) as! AKFViewController
        viewController.delegate = self
        viewController.enableSendToFacebook = true
        self.prepareLoginViewController(viewController)
        self.presentViewController(viewController as! UIViewController, animated: true, completion: nil)
    }
    
    func prepareLoginViewController(viewcontroller: AKFViewController) {
        //self.dismiss()
    }
    
    func viewController(viewController: UIViewController!, didCompleteLoginWithAuthorizationCode code: String!, state: String!) {
        authorizationCode = code
        self.state = state
    }
    
    func viewController(viewController: UIViewController!, didCompleteLoginWithAccessToken accessToken: AKFAccessToken!, state: String!) {
        
        accountKit.requestAccount({ (account:AKFAccount?, error:NSError?) in
            
            if let phoneNumber = account?.phoneNumber?.stringRepresentation(){
                
                print(phoneNumber)
                
                //self.IBlblLoggedInState.text = "LoggedIn with \(phoneNumber)"
                
            }
            
            
            
            if let emailAddress = account?.emailAddress{
                
                print(emailAddress)
                
                //self.IBlblLoggedInState.text = "LoggedIn with \(emailAddress)"
                
            }
            
            
            
            if let accountID = account?.accountID{
                
                print(accountID)
                
            }
            
            
            
        })
        
    }
    
    func dismiss() {
        self.dismissViewControllerAnimated(false, completion: nil)
    }
}
