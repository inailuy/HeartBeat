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
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        createBlurEffect()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.isHidden = false
    }
    
    func createBlurEffect() {
        //creating blurs variables
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.extraLight)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        //modifying properties
        blurView.frame = view.frame
        blurView.backgroundColor = UIColor.white
        view.backgroundColor = UIColor.clear
        blurView.alpha = 0.45
        //adding subviews
        blurView.addSubview(blurEffectView)
        view.addSubview(blurView)
        view.sendSubview(toBack: blurView)
    }
    
    func createHeartNavigationButton(_ direction: Int) {
        let btn = UIButton.init(type: UIButtonType.custom)
        btn.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
        btn.setImage(UIImage(named: "heartNav.png"), for: UIControlState())
        btn.addTarget(self, action: #selector(BaseVC.backButtonPressed), for: UIControlEvents.touchUpInside)
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
    
    func createSectionHeaderView(_ title: String) -> UIView {
        let frame = CGRect(x: 20, y: 0, width: view.bounds.size.width, height: 40)
        let headerView = UIView(frame: frame)
        let label = UILabel(frame: frame)
        label.font = UIFont(name: helveticaThinFont, size: 20.0)
        
        let style = NSParagraphStyle.default.mutableCopy()
        let attrText = NSAttributedString(string: title, attributes: [NSParagraphStyleAttributeName: style])
        label.numberOfLines = 0
        label.attributedText = attrText
        
        headerView.addSubview(label)
        headerView.backgroundColor = UIColor(white: 0.7, alpha: 0.35)
        
        return headerView
    }
    
    func backButtonPressed() {
        appDelegate.swipeBetweenVC.scrollToViewController(at: 1, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        view.isHidden = true
    }
    
    func startSpinner() {
        if activityIndicatorView == nil {
            activityIndicatorView = DGActivityIndicatorView(type: .doubleBounce, tintColor: UIColor.darkGray, size: 75.0)
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
