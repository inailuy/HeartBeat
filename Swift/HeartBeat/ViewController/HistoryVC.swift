//
//  HistoryVC.swift
//  HeartBeat
//
//  Created by inailuy on 6/15/16.
//  Copyright © 2016 Mxtapes. All rights reserved.
//

import Foundation
import UIKit

class HistoryVC: BaseVC, UITableViewDelegate, UITableViewDataSource {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "history"
        
        createHeartNavigationButton(Direction.right.rawValue)
        self.performSegueWithIdentifier("WorkoutSummarySegue", sender: nil)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cellId")
        cell!.textLabel!.text = "hi"
        
        return cell!
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 26
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("WorkoutSummarySegue", sender: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "WorkoutSummarySegue" {
            let vc = segue.destinationViewController as! WorkoutSummaryVC
            vc.shouldDisplaySaveOptions = false
        }
    }
}