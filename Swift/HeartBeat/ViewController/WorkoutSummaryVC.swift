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
    
    func pressedOptionHideButton(_ sender: UIButton!) {
        dismiss(animated: true, completion: nil)
    }
    //MARK: TableView Delegate/Datasource
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
        
        var cell = tableview.dequeueReusableCell(withIdentifier: stringId)
        if cell == nil {
            cell = UITableViewCell()
            cell?.backgroundColor = UIColor.clear
        }
        cell!.selectionStyle = .none
        return cell!
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        //if workout!.filterHeartBeatArray() == nil { return }
        
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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 4 : 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
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
            mapView.isHidden = false
            view.sendSubview(toBack: mapView)
            
            let height:CGFloat = 75
            let y = self.view.frame.size.height - height
            let frame = CGRect(x: 0, y: y, width: self.view.frame.width, height: height)
            // creating bottom button
            bottomView = UIView(frame: frame)
            bottomView.backgroundColor = UIColor.init(white: 0.65, alpha: 0.75)
            
            let buttonWidth = bottomView.frame.size.width
            let font = UIFont(name: helveticaThinFont, size: 22)
            // creating save button
            let saveButton = UIButton(type: .system)
            saveButton.frame = CGRect(x: 0, y: 0, width: buttonWidth, height: height)
            saveButton.setTitle("hide", for: UIControlState())
            saveButton.titleLabel?.font = font
            saveButton.addTarget(self, action: #selector(WorkoutSummaryVC.pressedOptionHideButton(_:)), for: .touchUpInside)
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
    
    func timeCellSetup(_ cell:UITableViewCell) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm a"
        
        startTimeLabel.text = dateFormatter.string(from: workout.startTime!)
        durationTimeLabel.text = String.localizedStringWithFormat("%i minutes", workout.minutes())
        endTimeLabel.text = dateFormatter.string(from: workout.endTime!)
        
        startTimeLabel.font = UIFont(name: helveticaMediumFont, size: 14)
        durationTimeLabel.font = UIFont(name: helveticaLightFont, size: 26)
        endTimeLabel.font = UIFont(name: helveticaMediumFont, size: 14)
        
        let fontColor = UIColor.darkGray
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
    
    func lineGraphCellSetup(_ cell:UITableViewCell) {
        lineGraphView.frame = cell.contentView.frame
        
        lineGraphView.enableBezierCurve = true
        lineGraphView.enablePopUpReport = true
        lineGraphView.enableTouchReport = true
        lineGraphView.enableXAxisLabel = true
        lineGraphView.enableYAxisLabel = true
        lineGraphView.enableReferenceXAxisLines = true
        lineGraphView.enableReferenceYAxisLines = true
        lineGraphView.enableBezierCurve = true
        lineGraphView.animationGraphStyle = .none
        
        lineGraphView.reloadGraph()
        cell.contentView.addSubview(lineGraphView)
    }
    
    func caloriesBurnedCellSetup(_ cell:UITableViewCell) {
        caloriesBurnedLabel.frame = cell.contentView.frame
        caloriesBurnedLabel.text = String.localizedStringWithFormat("%i calories burned", workout.caloriesBurned!)
        caloriesBurnedLabel.textAlignment = .center
        caloriesBurnedLabel.font = UIFont(name: helveticaLightFont, size: 24)
        caloriesBurnedLabel.textColor = UIColor.darkGray
        
        cell.contentView.addSubview(caloriesBurnedLabel)
    }
    
    func bpmCellSetup(_ cell:UITableViewCell) {
        var sortedArray = NSMutableArray(array: workout.filterHeartBeatArray())
            QuickSort.sort(&sortedArray, left: 0, right: (workout.filterHeartBeatArray().count)-1)
        let lastObj = sortedArray.lastObject as! NSNumber

        let width :CGFloat = cell.contentView.frame.size.width / 3
        let height :CGFloat = cell.contentView.frame.size.height
        
        minBpmLabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: height))
        avgBpmLabel = UILabel(frame: CGRect(x: width, y: 0, width: width, height: height))
        maxBpmLabel = UILabel(frame: CGRect(x: width*2, y: 0, width: width, height: height))
        
        minBpmLabel.text = String.localizedStringWithFormat("%i min", (sortedArray[0] as AnyObject).int32Value)
        avgBpmLabel.text = String.localizedStringWithFormat("%i avg", workout.beatsPerMinuteAverage!)
        maxBpmLabel.text = String.localizedStringWithFormat("%i max", lastObj.int32Value)
        
        minBpmLabel.textAlignment = .center
        avgBpmLabel.textAlignment = .center
        maxBpmLabel.textAlignment = .center
        
        let font = UIFont(name: helveticaFont, size: 20)
        minBpmLabel.font = font
        avgBpmLabel.font = font
        maxBpmLabel.font = font
        
        let color = UIColor.darkGray
        minBpmLabel.textColor = color
        avgBpmLabel.textColor = color
        maxBpmLabel.textColor = color
        
        cell.contentView.addSubview(minBpmLabel)
        cell.contentView.addSubview(avgBpmLabel)
        cell.contentView.addSubview(maxBpmLabel)
    }
    //MARK: BEMSimpleLineGraphView DataSource/Delegate
    func numberOfPoints(inLineGraph graph: BEMSimpleLineGraphView) -> Int {
        return workout.filterHeartBeatArray().count
    }
    
    func lineGraph(_ graph: BEMSimpleLineGraphView, labelOnXAxisFor index: Int) -> String {
        return workout.getTimeFromSeconds(index)
    }
    
    
    func numberOfYAxisLabels(onLineGraph graph: BEMSimpleLineGraphView) -> Int {
        return 1
    }
    
    func numberOfGapsBetweenLabels(onLineGraph graph: BEMSimpleLineGraphView) -> Int {
        return workout.filterHeartBeatArray().count
    }
    
    func lineGraph(_ graph: BEMSimpleLineGraphView, valueForPointAt index: Int) -> CGFloat {
        let point = workout.filterHeartBeatArray()[index]
        return CGFloat((point as AnyObject).doubleValue)
    }
    
    func maxValue(forLineGraph graph: BEMSimpleLineGraphView) -> CGFloat {
        var max = 0
        for num in workout.filterHeartBeatArray() {
            let n = num as! NSNumber
            if max < n.intValue {
                max = n.intValue
            }
        }
        return CGFloat(max)
    }
    
    func minValue(forLineGraph graph: BEMSimpleLineGraphView) -> CGFloat {
        var min = 200
        for num in workout.filterHeartBeatArray() {
            let n = num as! NSNumber
            if min > n.intValue {
                min = n.intValue
            }
        }
        return CGFloat(min)
    }
    
    func lineGraph(_ graph: BEMSimpleLineGraphView, didTouchGraphWithClosestIndex index: Int) {
        let position :Float = ((Float(index) / Float(workout.filterHeartBeatArray().count)) * Float(workout.minutes()))
    
        var min = " minutes"
        if position <= 1 { min = " minute" }
        
        durationTimeLabel.text = String(Int(position+1)) + min
    }
    
//    func didReleaseGraphWithClosestIndex(index: Float) {
//        durationTimeLabel.text = String.localizedStringWithFormat("%i minutes", workout.minutes())
//    }
    
    func lineGraph(_ graph: BEMSimpleLineGraphView, didReleaseTouchFromGraphWithClosestIndex index: CGFloat) {
        durationTimeLabel.text = String.localizedStringWithFormat("%i minutes", workout.minutes())
    }
}
