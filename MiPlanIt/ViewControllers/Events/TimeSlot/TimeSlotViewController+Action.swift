//
//  TimeSlotViewController+Action.swift
//  MiPlanIt
//
//  Created by Febin Paul on 13/04/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

extension TimeSlotViewController {
    
    @objc func initialiseUIComponents() {
        self.viewFSCalendar.delegate = self
        self.viewFSCalendar.dataSource = self
        self.viewInvitees.isHidden = self.invitees.isEmpty
        self.viewUsersList.distanceInterBubbles = -6
        self.viewUsersList.maxNumberOfBubbles = 15
        self.datePicker.minimumDate = self.startingTime.initialHour()
        self.datePicker.maximumDate = self.startingTime.initialHour().adding(days: 1).adding(minutes: -15)
        self.viewUsersList.reloadUsersListWith(self.invitees, enableEventColor: false)
        self.viewSeperator.backgroundColor = (!self.buttonDate.isSelected && self.invitees.isEmpty ? UIColor.clear : UIColor.init(red: 233/255.0, green: 233/255.0, blue: 233/255.0, alpha: 1))
        self.setOtherUserEventFrame()
        self.setCurrentUserEventFrame()
    }
    
    @objc func updateStartTime(_ date: Date) {
        self.startingTime = date
        if self.endingTime <= self.startingTime {
            self.endingTime = self.startingTime.adding(minutes: 15)
            if let endTime = self.startingTime.endOfDay, self.endingTime > endTime {
                self.endingTime = endTime
            }
        }
        self.setResizableViewFrame(initially: true)
    }
    
    @objc func updateEndTime(_ date: Date) {
        if let endTime = self.startingTime.endOfDay, date > endTime {
            self.endingTime = endTime
        }
        else {
            self.endingTime = date
        }
        if self.endingTime <= self.startingTime {
            self.startingTime = self.endingTime.adding(minutes: -15)
        }
        self.setResizableViewFrame(initially: true)
    }
    
    func setData() {
        self.viewFSCalendar.select(self.startingTime)
        self.buttonDate.setTitle(self.startingTime.stringFromDate(format: DateFormatters.EEEDDHMMMHYYY), for: .normal)
    }
    
    func scollToEvent() {
        let contentSizeHeight = self.scrollView.contentSize.height
        let scrollViewHeight = self.scrollView.frame.height
        if contentSizeHeight - (self.userResizableView.frame.minY-80) > scrollViewHeight {
            var yPosition = self.userResizableView.frame.minY
            if let eventTimeView = self.eventTimeView, eventTimeView.frame.minY < self.userResizableView.frame.minY {
                yPosition = self.userResizableView.frame.minY-80
            }
            self.scrollView.setContentOffset(CGPoint(x: 0, y: yPosition), animated: true)
        }
        else {
            let bottomOffset = CGPoint(x: 0, y: self.scrollView.contentSize.height - self.scrollView.bounds.size.height)
            scrollView.setContentOffset(bottomOffset, animated: true)
        }
    }
    
    
    func setResizableViewFrame(initially: Bool) {
        var yPosition: CGFloat = 50.0
        var totalSeconds = self.getHoursMinutesToSeconds(of: self.startingTime)
        let startingDate = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: self.startingTime)!
        
        let finalDate = startingDate.adding(seconds: totalSeconds)
        let actualDate = finalDate.adding(seconds: Int(TimeZone.current.daylightSavingTimeOffset(for: startingDate)) - Int(TimeZone.current.daylightSavingTimeOffset(for: finalDate)))
        
        let fullStartDate = actualDate
        self.startingTime = fullStartDate
        totalSeconds = self.getHoursMinutesToSeconds(of: fullStartDate)
        yPosition = CGFloat((Double(totalSeconds))/53.7313432836)
        var height: CGFloat = 46
        if initially {
            let yStartPosition: CGFloat = self.getPositionbyTime(time: self.startingTime)
            let yEndPosition: CGFloat = self.getPositionbyTime(time: self.endingTime)
            height = CGFloat(Int(yEndPosition-yStartPosition)+13)
        }
        let gripFrame = CGRect(x: self.view.frame.maxX*0.234-2, y: yPosition, width: (scrollView.frame.width*0.766+2), height: initially ? (height < 29 ? 29 : height) : (self.userResizableView.frame.maxY - yPosition))
        self.setUserResizableView(by: gripFrame)
    }
    
    func removeAllOtherUserEventTimeView() {
        self.otherUserEventTimeViews.forEach { (view) in
            view.removeFromSuperview()
        }
        self.otherUserEventTimeViews.removeAll()
    }
    
    func removeAllCurrentUserEventTimeView() {
        self.currentUserEventTimeViews.forEach { (view) in
            view.removeFromSuperview()
        }
        self.currentUserEventTimeViews.removeAll()
    }
    
    func setOtherUserEventFrame() {
        self.removeAllOtherUserEventTimeView()
        OtherUserEventOperator.default.cancelAllOperations()
        self.operationCount += 1
        OtherUserEventOperator.default.getUserEvents(of: self.invitees, startDateTime: self.startingTime, endDateTime: self.endingTime, delegate: self)
    }
    
    func setCurrentUserEventFrame() {
        UserEventOperator.default.cancelAllOperations()
        let endOfDate = self.endingTime.initialHour().adding(days: 2)
        let startOfDate = self.startingTime.initialHour().adding(days: -2)
        let allEvents = DatabasePlanItEvent().readAllEventsFrom(startOfMonth: startOfDate, endOfMonth: endOfDate)
        self.operationCount += 1
        UserEventOperator.default.getUserEvents(allEvents, startDateTime: startOfDate, endDateTime: endOfDate, delegate: self)
    }
    
    func eventContainsDateRange(startDate: Date, endDate: Date) -> Bool {
        return startDate < self.startingTime && endDate > self.startingTime
    }
    
    func getPositionbyTime(time: Date) -> CGFloat {
        let startDate = self.startingTime.initialHour()
        let offsetDate = time.adding(seconds: 500)
        let startTime = self.startingTime.initialHour().timeIntervalSince1970 + (TimeZone.current.daylightSavingTimeOffset(for: startDate) - TimeZone.current.daylightSavingTimeOffset(for: offsetDate))
        let currentTime = offsetDate.timeIntervalSince1970
        let difference = currentTime - startTime
        return CGFloat(difference/53.738)
    }
    
    func readAllTimeSlotEvents(_ allEvents: [Any], start: Date, end: Date) -> [TimeSlotEvent] {
        var arrayTimeSlotEvent: [TimeSlotEvent] = []
        if let calendarEvents = allEvents as? [PlanItEvent] {
            calendarEvents.forEach { (event) in
                arrayTimeSlotEvent += event.readAllAvailableDates(from: start, to: end).map({ return  TimeSlotEvent(with: $0, event: event) })
            }
        }
        else if let calendarEvents = allEvents as? [OtherUserEvent] {
            calendarEvents.forEach { (event) in
                arrayTimeSlotEvent += event.readAllAvailableDates(from: start, to: end).map({ return  TimeSlotEvent(with: $0, event: event) })
            }
        }
        return arrayTimeSlotEvent
    }
    
    func setUserResizableView(by frame: CGRect) {
        if self.userResizableView != nil {
            self.userResizableView?.removeFromSuperview()
        }
        let userEventAvailable = self.getUserEventAvailableInTimeRaange(range: self.startingTime...self.endingTime)
        userResizableView = RKUserResizableView(frame: frame, color: userEventAvailable.count > 0 ? Colors.eventTimeSlotRedColor : Colors.eventTimeSlotGreenColor)
        userResizableView.delegate = self
        let contentView = StripesView(frame: frame)
        userResizableView.contentView = contentView
        userResizableView.showEditingHandles()
        userResizableView.isPreventsPositionOutsideSuperview = true
        currentlyEditingView = userResizableView
        lastEditedView = userResizableView
        self.viewScrollViewContainer.addSubview(userResizableView)
        self.setEventTimeView()
        self.userResizableView.isUserInteractionEnabled = true
        self.viewContainer.setUserResizableView(userResizableView: self.userResizableView, scrollView: self.scrollView)
        self.scrollView.userResizableView = self.userResizableView
        userResizableView.tag = 99
    }
    
    func getHoursMinutesToSeconds(of date: Date) -> Int {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let minutes = calendar.component(.minute, from: date)
        let seconds = calendar.component(.second, from: date)
        return self.hoursMinutesToSeconds(time: (hour, minutes, seconds))
    }
    
    func setEventTimeView() {
            if self.eventTimeView != nil {
                self.eventTimeView?.removeFromSuperview()
                self.eventTimeView = nil
            }
            self.eventTimeView = EventTimeView()
            self.eventTimeView?.isUserInteractionEnabled = false
            let eventTimePostionToShow = self.findEventTimePostionToShow()
            eventTimeView?.frame = eventTimePostionToShow.0
            self.viewScrollViewContainer.addSubview(self.eventTimeView!)
            let userEventAvailable = self.getUserEventAvailableInTimeRaange(range: self.startingTime...self.endingTime)
            let otherUserEvents = self.getUniqueOtherUserEvent(otherUserEvents: userEventAvailable.compactMap({$0 as? OtherUserEventTimeView}) )
            self.eventTimeView?.setTime(from: self.startingTime, to: self.endingTime, position: eventTimePostionToShow.1, eventAvailableCount: otherUserEvents)
            userEventAvailable.count > 0 ? self.userResizableView.setRedBgColorForView() : self.userResizableView.setGreenBgColorForView()

        }
    
    func getUniqueOtherUserEvent(otherUserEvents: [OtherUserEventTimeView]) -> Int {
        var ids: [String] = []
        otherUserEvents.forEach { (otherUserEventTimeView) in
            if !ids.contains(where: {$0 == otherUserEventTimeView.userId}) {
                ids.append(otherUserEventTimeView.userId)
            }
        }
        return ids.count
    }
    
    func findEventTimePostionToShow() -> (CGRect, EventTimeViewPosition) {
        if self.userResizableView.frame.height > 40.0 {
            return (CGRect(x: self.userResizableView.frame.minX, y: self.userResizableView.frame.minY+12, width: self.userResizableView.frame.width, height: 50), .inside)
        }
        else {
            if self.userResizableView.frame.minY < self.scrollView.contentOffset.y+40 {
                return (CGRect(x: self.userResizableView.frame.minX, y: self.userResizableView.frame.maxY, width: self.userResizableView.frame.width, height: 50), .outside)
            }
            else {
                return (CGRect(x: self.userResizableView.frame.minX, y: self.userResizableView.frame.minY-40, width: self.userResizableView.frame.width, height: 50), .outside)
            }
        }
    }
    
    @objc func findTime(rect: CGRect, onEnd: Bool = false) {
        let date = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: self.startingTime)!
        
        
        let startingTime = date.adding(seconds: Int((Double(Int(rect.minY))*53.738))-500).rounded(minutes: 15, rounding: .ceil)
        let startingDayLightInterval = Int(TimeZone.current.daylightSavingTimeOffset(for: date)) - Int(TimeZone.current.daylightSavingTimeOffset(for: startingTime))
        let actualStartingTime = startingTime.adding(seconds: startingDayLightInterval)
        
        let endingTime = date.adding(seconds: Int((Double(Int(rect.maxY))*53.738))-1200).rounded(minutes: 15, rounding: .ceil)
        let endingDayLightInterval = Int(TimeZone.current.daylightSavingTimeOffset(for: date)) - Int(TimeZone.current.daylightSavingTimeOffset(for: endingTime))
        var actualEndingTime = endingTime.adding(seconds: endingDayLightInterval)
        
        actualEndingTime = actualEndingTime.initialHour() == self.viewFSCalendar.selectedDate?.initialHour().adding(days: 1) ? actualEndingTime.initialHour().adding(seconds: -1) : actualEndingTime
        guard self.viewFSCalendar.selectedDate?.initialHour() == actualStartingTime.initialHour() &&  self.viewFSCalendar.selectedDate?.initialHour() == actualEndingTime.initialHour() else {return}
        if startingDayLightInterval != endingDayLightInterval && actualStartingTime >= actualEndingTime, let dstDate = TimeZone.current.nextDaylightSavingTimeTransition(after: self.startingTime) {
            let offsetInterval = TimeZone.current.daylightSavingTimeOffset(for: self.startingTime)
            self.startingTime = dstDate.adding(hour: -1)
            self.endingTime = dstDate.adding(seconds: Int(offsetInterval))
            self.setResizableViewFrame(initially: true)
            self.scrollView.isScrollEnabled = true
        }
        else if onEnd && self.withinDayLightRange(actualStartingTime: actualStartingTime, actualEndingTime: actualEndingTime), let dstDate = TimeZone.current.nextDaylightSavingTimeTransition(after: self.startingTime) {
            let offsetInterval = TimeZone.current.daylightSavingTimeOffset(for: self.startingTime)
            self.startingTime = dstDate.adding(hour: -1)
            self.endingTime = dstDate.adding(seconds: Int(offsetInterval))
            self.setResizableViewFrame(initially: true)
            self.scrollView.isScrollEnabled = true
        }
        else {
            self.startingTime = actualStartingTime
            self.endingTime = actualEndingTime
        }
    }
    
    func withinDayLightRange(actualStartingTime: Date, actualEndingTime: Date) -> Bool {
        let dstDate = TimeZone.current.nextDaylightSavingTimeTransition(after: self.startingTime) ?? self.startingTime
        let offsetInterval = TimeZone.current.daylightSavingTimeOffset(for: self.startingTime)
        let fromRange = dstDate.adding(hour: -1)
        let toRange = dstDate.adding(seconds: Int(offsetInterval))
        let interval = Int(TimeZone.current.daylightSavingTimeOffset(for: self.startingTime.adding(hour: 24).adding(minutes: -1))) - Int(TimeZone.current.daylightSavingTimeOffset(for: self.startingTime.initialHour()))
        return interval != 0 && ((actualStartingTime >= fromRange && actualStartingTime < toRange) && (actualEndingTime <= toRange && actualEndingTime >= fromRange))
    }
    
    func secondsToHoursMinutesSeconds (seconds : Int) -> (Int, Int, Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    
    func hoursMinutesToSeconds (time : (Int, Int, Int)) -> Int {
        return time.0*3600 + time.1*60 + time.2
    }
    
    func incrementContentOffset() {
        UIView.animate(withDuration: 0, delay: 0, options: UIView.AnimationOptions.curveLinear, animations: {
          self.scrollView.contentOffset.y = self.scrollView.contentOffset.y + 2
          }, completion: { _ in
            self.userResizableView.offsetChanged()
        })
    }
    
    func decrementContentOffset() {
        UIView.animate(withDuration: 0, delay: 0, options: UIView.AnimationOptions.curveLinear, animations: {
          self.scrollView.contentOffset.y = self.scrollView.contentOffset.y - 2
          }, completion: { _ in
            self.userResizableView.offsetChanged()
        })
    }
    
    func hideEditingHandles() {
        // We only want the gesture recognizer to end the editing session on the last
        // edited view. We wouldn't want to dismiss an editing session in progress.
        lastEditedView?.hideEditingHandles()
    }
    
    func updateInviteeStatus() {
        UserStatusOperator.default.cancelAllOperations()
        UserStatusOperator.default.getUserStatus(of: self.invitees, startDateTime: self.startingTime, endDateTime: self.endingTime, delegate: self)
    }
    
    @objc func updateTimeAndEventView(_ userResizableView: RKUserResizableView, onEnd flag: Bool = false) {
        self.findTime(rect: userResizableView.frame, onEnd: flag)
        self.setEventTimeView()
    }
    // May return otherUserEventTimeViews or PlanItEvent
    func getUserEventAvailableInTimeRaange(range: ClosedRange<Date>) -> [Any] {
        var containingEventUserCount: [Any] = []
        
        containingEventUserCount += self.otherUserEventTimeViews.filter({ (event) in
            return (event.startDateTime > range.lowerBound && event.startDateTime < range.upperBound) || (event.endDateTime > range.lowerBound && event.endDateTime < range.upperBound) || (event.startDateTime < range.lowerBound && event.endDateTime > range.upperBound) || (event.startDateTime == range.lowerBound && event.endDateTime >= range.upperBound) || (event.startDateTime >= range.lowerBound && event.endDateTime == range.upperBound) || (event.startDateTime < range.lowerBound && event.endDateTime == range.upperBound)
        })
        
        containingEventUserCount += self.userTimeSlotEvent.filter({ (event) in
            return (event.startDate > range.lowerBound && event.startDate < range.upperBound) || (event.endDate > range.lowerBound && event.endDate < range.upperBound) || (event.startDate < range.lowerBound && event.endDate > range.upperBound) || (event.startDate == range.lowerBound && event.endDate >= range.upperBound) || (event.startDate >= range.lowerBound && event.endDate == range.upperBound) || (event.startDate < range.lowerBound && event.endDate == range.upperBound)
        })
        
        
        return containingEventUserCount
    }
}
