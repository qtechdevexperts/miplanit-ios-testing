//
//  ShareLinkTimeRangeViewController+Action.swift
//  MiPlanIt
//
//  Created by Febin Paul on 26/03/21.
//  Copyright © 2021 Arun. All rights reserved.
//

import Foundation

extension ShareLinkTimeRangeViewController {
    
    override func initialiseUIComponents() {
        self.viewFSCalendar.delegate = self
        self.viewFSCalendar.dataSource = self
        self.viewInvitees.isHidden = self.invitees.isEmpty
        self.viewUsersList.distanceInterBubbles = -6
        self.viewUsersList.maxNumberOfBubbles = 15
        self.datePicker.minimumDate = self.startingTime.initialHour()
        self.datePicker.maximumDate = self.startingTime.initialHour().adding(days: 1).adding(minutes: -15)
        self.viewUsersList.reloadUsersListWith(self.invitees, enableEventColor: false)
        self.viewSeperator.backgroundColor = (!self.buttonDate.isSelected && self.invitees.isEmpty ? UIColor.clear : UIColor.init(red: 233/255.0, green: 233/255.0, blue: 233/255.0, alpha: 1))
    }
    
    override func userResizableViewDidEndEditing(_ userResizableView: RKUserResizableView, point: CGPoint) {
        self.scrollView.isScrollEnabled = true
        lastEditedView = userResizableView
        self.updateTimeAndEventView(userResizableView, onEnd: true)
    }
    
    override func updateTimeAndEventView(_ userResizableView: RKUserResizableView, onEnd flag: Bool = false) {
        self.findTime(rect: userResizableView.frame, onEnd: flag)
        if self.endingTime.secondDiffrence(from: self.startingTime) < self.durationInSeconds && flag {
            if userResizableView.isUpperAnchorPoint() {
                self.updateEndTimeWithDuration()
            }
            else {
                self.updateStartTimeWithDuration()
            }
            self.setResizableViewFrame(initially: true)
        }
        self.setEventTimeView()
    }
    
    func updateEndTimeWithDuration() {
        let endTime = self.startingTime.adding(seconds: self.durationInSeconds)
        if let endOfDay = self.startingTime.endOfDay, endOfDay < endTime {
            self.endingTime = self.startingTime.endOfDay ?? Date()
            self.startingTime = self.endingTime.adding(seconds: -self.durationInSeconds).adding(minutes: 1)
        }
        else {
            self.endingTime = endTime
        }
    }
    
    func updateStartTimeWithDuration() {
        let startTime = self.endingTime.adding(seconds: -self.durationInSeconds)
        if self.endingTime.initialHour() > startTime {
            self.startingTime = self.startingTime.initialHour()
            let endingTime = self.startingTime.adding(seconds: self.durationInSeconds)
            let endingDayLightInterval = Int(TimeZone.current.daylightSavingTimeOffset(for: self.startingTime)) - Int(TimeZone.current.daylightSavingTimeOffset(for: endingTime))
            self.endingTime = endingTime.adding(seconds: endingDayLightInterval)
        }
        else {
            self.startingTime = startTime
        }
    }
    
    override func updateStartTime(_ date: Date) {
        self.startingTime = date
        if self.endingTime <= self.startingTime {
            self.endingTime = self.startingTime.adding(minutes: 15)
            if let endTime = self.startingTime.endOfDay, self.endingTime > endTime {
                self.endingTime = endTime
            }
        }
        if self.endingTime.secondDiffrence(from: self.startingTime) < self.durationInSeconds {
            self.updateStartTimeWithDuration()
            self.datePicker.setDate(self.startingTime, animated: false)
        }
        self.setResizableViewFrame(initially: true)
    }
    
    override func updateEndTime(_ date: Date) {
        if let endTime = self.startingTime.endOfDay, date > endTime {
            self.endingTime = endTime
        }
        else {
            self.endingTime = date
        }
        if self.endingTime <= self.startingTime {
            self.startingTime = self.endingTime.adding(minutes: -15)
        }
        if self.endingTime.secondDiffrence(from: self.startingTime) < self.durationInSeconds {
            self.updateEndTimeWithDuration()
            self.datePicker.setDate(self.endingTime, animated: false)
        }
        self.setResizableViewFrame(initially: true)
    }
}
