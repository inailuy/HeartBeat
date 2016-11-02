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

let helveticaThinFont = "HelveticaNeue-Thin"
let helveticaLightFont = "HelveticaNeue-Light"
let helveticaFont = "HelveticaNeue"
let helveticaMediumFont = "HelveticaNeue-Medium"
let helveticaUltraLightFont = "HelveticaNeue-UltraLight"

class BaseVC: UIViewController {
    var healthStore : HKHealthStore!
    var WorkoutControllerTypesArray = NSArray()
    var appDelegate : AppDelegate! //Might Delete
    var blurView = UIView()
    
    var activityIndicatorView :DGActivityIndicatorView?
    
    enum Direction:Int{
        case left = 0, right = 1
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        createBlurEffect()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        view.hidden = false
    }
    
    func createBlurEffect() {
        //creating blurs variables
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.ExtraLight)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        //modifying properties
        blurView.frame = view.frame
        blurView.backgroundColor = UIColor.whiteColor()
        view.backgroundColor = UIColor.clearColor()
        blurView.alpha = 0.45
        //adding subviews
        blurView.addSubview(blurEffectView)
        view.addSubview(blurView)
        view.sendSubviewToBack(blurView)
    }
    
    func createHeartNavigationButton(direction: Int) {
        let btn = UIButton.init(type: UIButtonType.Custom)
        btn.frame = CGRectMake(0, 0, 25, 25)
        btn.setImage(UIImage(named: "heartNav.png"), forState: UIControlState.Normal)
        btn.addTarget(self, action: #selector(BaseVC.backButtonPressed), forControlEvents: UIControlEvents.TouchUpInside)
        let btnBack = UIBarButtonItem(customView: btn)
        switch direction {
        case Direction.left.rawValue:
            navigationItem.leftBarButtonItem = btnBack
            break
        case Direction.right.rawValue:
            navigationItem.rightBarButtonItem = btnBack
            break
        default: break
        }
    }
    
    func createSectionHeaderView(title: String) -> UIView {
        let frame = CGRectMake(20, 0, view.bounds.size.width, 40)
        let headerView = UIView(frame: frame)
        let label = UILabel(frame: frame)
        label.font = UIFont(name: helveticaThinFont, size: 20.0)
        
        let style = NSParagraphStyle.defaultParagraphStyle().mutableCopy()
        let attrText = NSAttributedString(string: title, attributes: [NSParagraphStyleAttributeName: style])
        label.numberOfLines = 0
        label.attributedText = attrText
        
        headerView.addSubview(label)
        headerView.backgroundColor = UIColor(white: 0.7, alpha: 0.35)
        
        return headerView
    }
    
    func backButtonPressed() {
        appDelegate.swipeBetweenVC.scrollToViewControllerAtIndex(1, animated: true)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        view.hidden = true
    }
    
    func startSpinner() {
        if activityIndicatorView == nil {
            activityIndicatorView = DGActivityIndicatorView(type: .DoubleBounce, tintColor: UIColor.darkGrayColor(), size: 75.0)
            activityIndicatorView!.frame = self.view.frame
        }
        view.addSubview(activityIndicatorView!)
        activityIndicatorView!.startAnimating()
    }
    
    func stopSpinner() {
        if activityIndicatorView != nil {
            activityIndicatorView!.stopAnimating()
            activityIndicatorView!.removeFromSuperview()
        }
    }
}
