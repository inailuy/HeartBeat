//
//  TimeTracker.swift
//  HeartBeat
//
//  Created by yulz on 6/27/17.
//  Copyright © 2017 Mxtapes. All rights reserved.
//

import Foundation

class TimeTracker : Timer {
    private var startTime:TimeInterval?
    var timer:Timer?
    private var elapsedTime = 0.0
    private var pausedTimeDifference = 0.0
    private var timeUserPaused = 0.0
    //var delegate:TimeTrackerDelegate?
    
    func setTimer(timer:Timer){
        self.timer = timer
    }
    
    func isPaused() -> Bool {
        return !timer!.isValid
    }
    
    func start(){
        if startTime == nil {
            startTime = Date.timeIntervalSinceReferenceDate
            newTimer()
        }
    }
    
    func pauseTimer(){
        timer!.invalidate()
        timeUserPaused = Date.timeIntervalSinceReferenceDate
    }
    
    func resumeTimer(){
        pausedTimeDifference += Date.timeIntervalSinceReferenceDate - timeUserPaused;
        newTimer()
    }
    
    @objc func handleTimer(){
        let currentTime = Date.timeIntervalSinceReferenceDate
        elapsedTime = currentTime - pausedTimeDifference - startTime!
        //delegate!.handleTime(elapsedTime)
    }
    
    func reset(){
        pausedTimeDifference = 0.0
        timeUserPaused = 0.0
        startTime = Date.timeIntervalSinceReferenceDate
        newTimer()
    }
    
    private func newTimer(){
        timer = Timer.scheduledTimer(timeInterval: 0.1, target:self ,  selector: #selector(TimeTracker.handleTimer), userInfo: nil, repeats: true)
    }
}
