//
//  WorkoutControllerSummaryVC.swift
//  HeartBeat
//
//  Created by inailuy on 6/15/16.
//  Copyright © 2016 Mxtapes. All rights reserved.
//

import Foundation
import MapKit
import UIKit

class WorkoutSummaryVC: BaseVC, UITableViewDelegate, UITableViewDataSource, BEMSimpleLineGraphDelegate, BEMSimpleLineGraphDataSource {
    var workout :Workout!
    
    var region :MKCoordinateRegion?
    @IBOutlet weak var mapView :MKMapView!
    @IBOutlet weak var tableview: UITableView!
    
    var shouldDisplaySaveOptions = Bool()
    var bottomView = UIView()
    
    var startTimeLabel = UILabel()
    var durationTimeLabel = UILabel()
    var endTimeLabel = UILabel()
    
    var lineGraphView = BEMSimpleLineGraphView()
    
    var minBpmLabel = UILabel()
    var avgBpmLabel = UILabel()
    var maxBpmLabel = UILabel()
    
    var caloriesBurnedLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createSaveOptionView()
        adjustTableview()
        
        lineGraphView.delegate = self
        lineGraphView.dataSource = self
        
        title = workout.workoutType
    }
    
    func pressedOptionHideButton(sender: UIButton!) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    //MARK: TableView Delegate/Datasource
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var stringId = ""
        if indexPath.row == 0 {
            stringId = "duration"
        } else if indexPath.row == 1 {
            stringId = "graph"
        }  else if indexPath.row == 2 {
            stringId = "calories"
        } else if indexPath.row == 3 {
            stringId = "bpm"
        }
        
        var cell = tableview.dequeueReusableCellWithIdentifier(stringId)
        if cell == nil {
            cell = UITableViewCell()
            cell?.backgroundColor = UIColor.clearColor()
        }
        cell!.selectionStyle = .None
        return cell!
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if workout!.arrayBeatsPerMinute == nil { return }
        
        switch indexPath.section {
        case 0:
            if indexPath.row == 0 {
                if cell.contentView.subviews.contains(startTimeLabel) == false {
                    timeCellSetup(cell)
                }
            } else if indexPath.row == 1 {
                if cell.contentView.subviews.contains(lineGraphView) == false {
                    lineGraphCellSetup(cell)
                }
            }  else if indexPath.row == 2 {
                if cell.contentView.subviews.contains(caloriesBurnedLabel) == false {
                    caloriesBurnedCellSetup(cell)
                }
            } else if indexPath.row == 3 {
                if cell.contentView.subviews.contains(minBpmLabel) == false {
                    bpmCellSetup(cell)
                }
            }
            break
        default:
            break
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 4 : 0
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var height :CGFloat
        switch indexPath.row {
        case 0:
            height = 60
            break
        case 1:
            height = 350
            break
        case 2:
            height = 80
            break
        case 3:
            height = 60
            break
        default:
            height = 0
            break
        }
        return height
    }
    //MARK: Views Setup
    func createSaveOptionView(){
        if shouldDisplaySaveOptions {
            mapView.setRegion(region!, animated: false)
            mapView.hidden = false
            view.sendSubviewToBack(mapView)
            
            let height:CGFloat = 75
            let y = self.view.frame.size.height - height
            let frame = CGRect(x: 0, y: y, width: self.view.frame.width, height: height)
            // creating bottom button
            bottomView = UIView(frame: frame)
            bottomView.backgroundColor = UIColor.init(white: 0.65, alpha: 0.75)
            
            let buttonWidth = bottomView.frame.size.width
            let font = UIFont(name: helveticaThinFont, size: 22)
            // creating save button
            let saveButton = UIButton(type: .System)
            saveButton.frame = CGRect(x: 0, y: 0, width: buttonWidth, height: height)
            saveButton.setTitle("hide", forState: UIControlState.Normal)
            saveButton.titleLabel?.font = font
            saveButton.addTarget(self, action: #selector(WorkoutSummaryVC.pressedOptionHideButton(_:)), forControlEvents: .TouchUpInside)
            bottomView.addSubview(saveButton)
            
            view.addSubview(bottomView)
        }
    }
    
    func adjustTableview() {
        //Adjusting tableview because of navigationbar
        if shouldDisplaySaveOptions {
            let point = CGFloat(bottomView.frame.size.height)
            let insets = UIEdgeInsets(top: 0, left: 0, bottom: point, right: 0)
            tableview.contentInset = insets
            tableview.scrollIndicatorInsets = insets
        } else {
            let navigationBarHeight = self.navigationController!.navigationBar.frame.size.height
            let insets = UIEdgeInsets(top: navigationBarHeight, left: 0, bottom: 0, right: 0)
            tableview.contentInset = insets
            tableview.scrollIndicatorInsets = insets
            tableview.setContentOffset(CGPoint(x: 0, y: -navigationBarHeight), animated: false)
        }
    }
    
    func timeCellSetup(cell:UITableViewCell) {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "hh:mm a"
        
        startTimeLabel.text = dateFormatter.stringFromDate(workout.startTime!)
        durationTimeLabel.text = String.localizedStringWithFormat("%i minutes", workout.minutes())
        endTimeLabel.text = dateFormatter.stringFromDate(workout.endTime!)
        
        startTimeLabel.font = UIFont(name: helveticaMediumFont, size: 14)
        durationTimeLabel.font = UIFont(name: helveticaLightFont, size: 26)
        endTimeLabel.font = UIFont(name: helveticaMediumFont, size: 14)
        
        let fontColor = UIColor.darkGrayColor()
        startTimeLabel.textColor = fontColor
        durationTimeLabel.textColor = fontColor
        endTimeLabel.textColor = fontColor
        
        startTimeLabel.sizeToFit()
        durationTimeLabel.sizeToFit()
        endTimeLabel.sizeToFit()
        
        var frame = startTimeLabel.frame
        frame.origin.x = CGFloat(4)
        frame.origin.y = cell.contentView.frame.height - startTimeLabel.frame.size.height - 5
        startTimeLabel.frame = frame
        
        frame = durationTimeLabel.frame
        frame.origin.x = (cell.contentView.frame.width / 2) - (durationTimeLabel.frame.size.width / 2)
        frame.origin.y = cell.contentView.frame.height - durationTimeLabel.frame.size.height - 5
        durationTimeLabel.frame = frame
        
        frame = endTimeLabel.frame
        frame.origin.x = cell.contentView.frame.width - endTimeLabel.frame.size.width  - 4
        frame.origin.y = cell.contentView.frame.height - endTimeLabel.frame.size.height - 5
        endTimeLabel.frame = frame
        
        cell.contentView.addSubview(startTimeLabel)
        cell.contentView.addSubview(durationTimeLabel)
        cell.contentView.addSubview(endTimeLabel)
    }
    
    func lineGraphCellSetup(cell:UITableViewCell) {
        lineGraphView.frame = cell.contentView.frame
        
        lineGraphView.enableBezierCurve = true
        lineGraphView.enablePopUpReport = true
        lineGraphView.enableTouchReport = true
        lineGraphView.enableXAxisLabel = true
        lineGraphView.enableYAxisLabel = true
        lineGraphView.enableReferenceXAxisLines = true
        lineGraphView.enableReferenceYAxisLines = true
        lineGraphView.enableBezierCurve = true
        lineGraphView.animationGraphStyle = .None
        
        lineGraphView.reloadGraph()
        cell.contentView.addSubview(lineGraphView)
    }
    
    func caloriesBurnedCellSetup(cell:UITableViewCell) {
        caloriesBurnedLabel.frame = cell.contentView.frame
        caloriesBurnedLabel.text = String.localizedStringWithFormat("%i calories burned", workout.caloriesBurned!)
        caloriesBurnedLabel.textAlignment = .Center
        caloriesBurnedLabel.font = UIFont(name: helveticaLightFont, size: 24)
        caloriesBurnedLabel.textColor = UIColor.darkGrayColor()
        
        cell.contentView.addSubview(caloriesBurnedLabel)
    }
    
    func bpmCellSetup(cell:UITableViewCell) {
        var sortedArray = NSMutableArray(array: workout.arrayBeatsPerMinute!)
            QuickSort.sort(&sortedArray, left: 0, right: (workout.arrayBeatsPerMinute?.count)!-1)
        let lastObj = sortedArray.lastObject as! NSNumber

        let width :CGFloat = cell.contentView.frame.size.width / 3
        let height :CGFloat = cell.contentView.frame.size.height
        
        minBpmLabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: height))
        avgBpmLabel = UILabel(frame: CGRect(x: width, y: 0, width: width, height: height))
        maxBpmLabel = UILabel(frame: CGRect(x: width*2, y: 0, width: width, height: height))
        
        minBpmLabel.text = String.localizedStringWithFormat("%i min", sortedArray[0].intValue)
        avgBpmLabel.text = String.localizedStringWithFormat("%i avg", workout.beatsPerMinuteAverage!)
        maxBpmLabel.text = String.localizedStringWithFormat("%i max", lastObj.intValue)
        
        minBpmLabel.textAlignment = .Center
        avgBpmLabel.textAlignment = .Center
        maxBpmLabel.textAlignment = .Center
        
        let font = UIFont(name: helveticaFont, size: 20)
        minBpmLabel.font = font
        avgBpmLabel.font = font
        maxBpmLabel.font = font
        
        let color = UIColor.darkGrayColor()
        minBpmLabel.textColor = color
        avgBpmLabel.textColor = color
        maxBpmLabel.textColor = color
        
        cell.contentView.addSubview(minBpmLabel)
        cell.contentView.addSubview(avgBpmLabel)
        cell.contentView.addSubview(maxBpmLabel)
    }
    //MARK: BEMSimpleLineGraphView DataSource/Delegate
    func numberOfPointsInLineGraph(graph: BEMSimpleLineGraphView) -> Int {
        return workout.arrayBeatsPerMinute!.count
    }
    
    func lineGraph(graph: BEMSimpleLineGraphView, labelOnXAxisForIndex index: Int) -> String {
        return workout.getTimeFromSeconds(index)
    }
    
    
    func numberOfYAxisLabelsOnLineGraph(graph: BEMSimpleLineGraphView) -> Int {
        return 5
    }
    
    func numberOfGapsBetweenLabelsOnLineGraph(graph: BEMSimpleLineGraphView) -> Int {
        return workout.arrayBeatsPerMinute!.count / 5
    }
    
    func lineGraph(graph: BEMSimpleLineGraphView, valueForPointAtIndex index: Int) -> CGFloat {
        let point = workout.arrayBeatsPerMinute![index]
        return CGFloat(point.doubleValue)
    }
    
    func maxValueForLineGraph(graph: BEMSimpleLineGraphView) -> CGFloat {
        var max = 0
        for num in workout.arrayBeatsPerMinute! {
            let n = num as! NSNumber
            if max < n.integerValue {
                max = n.integerValue
            }
        }
        return CGFloat(max)
    }
    
    func minValueForLineGraph(graph: BEMSimpleLineGraphView) -> CGFloat {
        var min = 200
        for num in workout.arrayBeatsPerMinute! {
            let n = num as! NSNumber
            if min > n.integerValue {
                min = n.integerValue
            }
        }
        return CGFloat(min)
    }
    
    func lineGraph(graph: BEMSimpleLineGraphView, didTouchGraphWithClosestIndex index: Int) {
        let position :Float = ((Float(index) / Float(workout.arrayBeatsPerMinute!.count)) * Float(workout.minutes()))
    
        var min = " minutes"
        if position <= 1 { min = " minute" }
        
        durationTimeLabel.text = String(Int(position+1)) + min
    }
    
    func didReleaseGraphWithClosestIndex(index: Float) {
        durationTimeLabel.text = String.localizedStringWithFormat("%i minutes", workout.minutes())
    }
}
