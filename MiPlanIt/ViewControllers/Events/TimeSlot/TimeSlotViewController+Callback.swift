//
//  TimeSlotViewController+Callback.swift
//  MiPlanIt
//
//  Created by Febin Paul on 03/07/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation


extension TimeSlotViewController: UserStatusManagerDelegate {
    
    func userStatusManager(_ manager: UserStatusManager, getWithStatus otherUsers: [OtherUser]) {
        DispatchQueue.main.async {
            self.viewUsersList.reloadUsersListWith(otherUsers, enableEventColor: false)
        }
    }
}


extension TimeSlotViewController: UserEventManagerDelegate {
    
    func userEventManager(_ manager: UserEventManager, getTimeSlots timeSlots: [TimeSlotEvent]) {
        self.userTimeSlotEvent = timeSlots
        if let eventId = self.editEventId {
             self.userTimeSlotEvent = self.userTimeSlotEvent.filter { (timeSlot) -> Bool in
                if let event = timeSlot.event as? PlanItEvent, event.readValueOfEventId() == eventId { return false }
                else if let event = timeSlot.event as? OtherUserEvent, event.eventId == eventId { return false }
                else { return timeSlot.startDate.initialHour() == self.startingTime.initialHour() }
            }
        }
        self.userTimeSlotEvent = self.userTimeSlotEvent.filter{ (timeSlot) -> Bool in
            if let event = timeSlot.event as? PlanItEvent, event.isAllDay { return false }
            else if let event = timeSlot.event as? OtherUserEvent, event.isAllDay { return false }
            else { return  timeSlot.startDate.initialHour() == self.startingTime.initialHour() }
        }
        var allDayEvents = timeSlots.filter{ (timeSlot) -> Bool in
            if let event = timeSlot.event as? PlanItEvent, event.isAllDay, timeSlot.startDate.initialHour() == self.startingTime.initialHour() { return true }
            else if let event = timeSlot.event as? OtherUserEvent, event.isAllDay, timeSlot.startDate.initialHour() == self.startingTime.initialHour()  { return true }
            else { return false }
        }
        let multiDayEvent = timeSlots.filter{ (timeSlot) -> Bool in
            if let event = timeSlot.event as? PlanItEvent, !event.isAllDay, timeSlot.startDate.initialHour() < self.startingTime.initialHour() && timeSlot.endDate.initialHour() > self.endingTime.initialHour() { return true }
            else if let event = timeSlot.event as? OtherUserEvent, !event.isAllDay, timeSlot.startDate.initialHour() < self.startingTime.initialHour() && timeSlot.endDate.initialHour() > self.endingTime.initialHour()  { return true }
            else { return false }
        }
        allDayEvents += multiDayEvent
        let sortedEventsByDate = self.userTimeSlotEvent.sorted(by: {
            if $0.startDate.trimSeconds() == $1.startDate.trimSeconds() {
                return $0.endDate.trimSeconds() > $1.endDate.trimSeconds()
            }
            else if $0.endDate.trimSeconds() > $1.endDate.trimSeconds() && $0.startDate.trimSeconds() < $1.endDate.trimSeconds() {
                return true
            }
            else {
                return $0.startDate.trimSeconds() < $1.startDate.trimSeconds()
            }})
        let crossEvents = calculateCrossEvents(sortedEventsByDate)
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.operationCount -= 1
            if let resizeView = self.userResizableView {
                self.updateTimeAndEventView(resizeView)
            }

            //--------------- start new code//
            if !sortedEventsByDate.isEmpty {
                // create event
                var newFrame = CGRect(x: 0, y: 0, width: 0, height: self.scrollView.contentSize.height)
                sortedEventsByDate.forEach { (event) in
                    let yStartPosition: CGFloat = self.getPositionbyTime(time: event.startDate.trimSeconds())
                    let yEndPosition: CGFloat = self.getPositionbyTime(time: event.endDate.trimSeconds())
                    let height = self.scrollView.contentSize.height < yEndPosition ? (self.scrollView.contentSize.height-yStartPosition)-67 : (yEndPosition-yStartPosition)
                    newFrame.origin.y = yStartPosition
                    newFrame.size.height = height - 1
                    // calculate 'width' and position 'x'
                    var newWidth = self.scrollView.frame.width*0.766
                    var newPointX: CGFloat = (self.view.frame.maxX*0.234-2)
                    if let crossEvent = crossEvents[event.id] {
                        newWidth /= CGFloat(crossEvent.count)
                        newFrame.size.width = newWidth - 1
                        if crossEvent.count > 1, !self.currentUserEventTimeViews.isEmpty {
                            for _ in 0..<crossEvent.count {
                                for page in self.currentUserEventTimeViews {
                                    if page.frame.intersects(CGRect(x: newPointX, y: newFrame.origin.y, width: newFrame.size.width, height: newFrame.size.height)) {
                                        newPointX = page.frame.maxX > newPointX ? page.frame.maxX.rounded()+1 : newPointX
                                    }
                                }
                            }
                        }
                    }

                    newFrame.origin.x = newPointX
                    let currentUserFrame = CurrentUserEventTimeView(frame: newFrame)
                    currentUserFrame.setEventName((event.event as AnyObject).eventName ?? Strings.empty)
                    self.viewScrollViewContainer.addSubview(currentUserFrame)
                    self.viewScrollViewContainer.sendSubviewToBack(currentUserFrame)
                    self.currentUserEventTimeViews.append(currentUserFrame)
                }
            }
 //            self.removeAllArrangedSubviews()
            self.labelAllDayCaption.isHidden = allDayEvents.count == 0
            allDayEvents.forEach { (event) in
                let timeSlotAllDayView = TimeSlotAllDayView(frame: CGRect.zero)
                timeSlotAllDayView.setEventName((event.event as AnyObject).eventName ?? Strings.empty, event: event.event)
                self.stackViewAllDayEvent.addArrangedSubview(timeSlotAllDayView)
            }
        }
    }
    
    private func getTimeWithouteSeconds(_ date: Date) -> TimeInterval {
        return date.timeIntervalSince1970
    }
    private func calculateCrossEvents(_ events: [TimeSlotEvent]) -> [String: CrossEvent] {
        var eventsTemp = events
        var crossEvents = [String: CrossEvent]()
        
        while let event = eventsTemp.first {
            let start = self.getTimeWithouteSeconds(event.startDate)
            let end = self.getTimeWithouteSeconds(event.endDate)
            var crossEventNew = CrossEvent(eventTime: EventTime(start: start, end: end), eventId: event.id)
            
            var endCalculated: TimeInterval = crossEventNew.eventTime.end - TimeInterval(1)
            endCalculated = crossEventNew.eventTime.start > endCalculated ? crossEventNew.eventTime.start : endCalculated
            let eventsFiltered = events.filter({ (item) in
                var itemEnd = self.getTimeWithouteSeconds(item.endDate) - TimeInterval(1)
                let itemStart = self.getTimeWithouteSeconds(item.startDate)
                itemEnd = itemEnd < itemStart ? itemStart : itemEnd
                return (itemStart...itemEnd).contains(start) || (itemStart...itemEnd).contains(endCalculated) || (start...endCalculated).contains(itemStart) || (start...endCalculated).contains(itemEnd)
            })
            if !eventsFiltered.isEmpty {
                crossEventNew.count = eventsFiltered.count
            }
            crossEvents[crossEventNew.eventId] = crossEventNew
            eventsTemp.removeFirst()
        }
        
        return crossEvents
    }
    
    
    func removeAllArrangedSubviews() {
        _ = self.stackViewAllDayEvent.arrangedSubviews.reduce([UIView]()) { $0 + [removeArrangedSubViewProperly($1)] }
    }
    
    func removeOtherUsersArrangedSubviews() {
        let otherUserSubViews = self.stackViewAllDayEvent.arrangedSubviews.filter({
            if let timeSlot = $0 as? TimeSlotAllDayView, let event = timeSlot.event {
                return event is OtherUserEvent
            }
            return false
        })
        _ = otherUserSubViews.reduce([UIView]()) { $0 + [self.removeArrangedSubViewProperly($1)] }
    }
    
    func removeArrangedSubViewProperly(_ view: UIView) -> UIView {
        self.stackViewAllDayEvent.removeArrangedSubview(view)
        NSLayoutConstraint.deactivate(view.constraints)
        view.removeFromSuperview()
        return view
    }
}

extension TimeSlotViewController: OtherUserEventManagerDelegate {
    
    func otherUserEventManager(_ manager: OtherUserEventManager, getTimeSlots timeSlots: [TimeSlotEvent]) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.operationCount -= 1
            if manager.isCancelled { return }
            var otherUserTimeSlotEvents = timeSlots
            otherUserTimeSlotEvents = otherUserTimeSlotEvents.filter{ (timeSlot) -> Bool in
                if let event = timeSlot.event as? OtherUserEvent, event.isAllDay { return false }
                else { return  timeSlot.startDate.initialHour() == self.startingTime.initialHour() }
            }
            let multiDayEvent = timeSlots.filter{ (timeSlot) -> Bool in
                if let event = timeSlot.event as? PlanItEvent, !event.isAllDay, timeSlot.startDate.initialHour() < self.startingTime.initialHour() && timeSlot.endDate.initialHour() > self.endingTime.initialHour() { return true }
                else if let event = timeSlot.event as? OtherUserEvent, !event.isAllDay, timeSlot.startDate.initialHour() < self.startingTime.initialHour() && timeSlot.endDate.initialHour() > self.endingTime.initialHour()  { return true }
                else { return false }
            }
            otherUserTimeSlotEvents.forEach { (event) in
                if let event = event.event as? OtherUserEvent, event.isAllDay { return }
                let yStartPosition: CGFloat = self.getPositionbyTime(time: event.startDate)
                let yEndPosition: CGFloat = self.getPositionbyTime(time: event.endDate)
                let height = self.scrollView.contentSize.height < (yEndPosition-yStartPosition) ? (self.scrollView.contentSize.height-yStartPosition)-60 : (yEndPosition-yStartPosition)
                let gripFrame = CGRect(x: self.view.frame.maxX*0.234-2, y: yStartPosition, width: (self.scrollView.frame.width*0.766+2), height: height)
                let otherUserFrame = OtherUserEventTimeView(frame: gripFrame)
                otherUserFrame.setDateTime(startDateTime: event.startDate, endDateTime: event.endDate, userId: event.userId)
                self.viewScrollViewContainer.addSubview(otherUserFrame)
                self.otherUserEventTimeViews.append(otherUserFrame)
                self.viewScrollViewContainer.sendSubviewToBack(otherUserFrame)
            }
            self.removeOtherUsersArrangedSubviews()
            self.labelAllDayCaption.isHidden = multiDayEvent.count == 0
            multiDayEvent.forEach { (event) in
                let timeSlotAllDayView = TimeSlotAllDayView(frame: CGRect.zero)
                timeSlotAllDayView.setEventName(Strings.empty, event: event.event)
                self.stackViewAllDayEvent.addArrangedSubview(timeSlotAllDayView)
            }
            if let resizeView = self.userResizableView {
                self.updateTimeAndEventView(resizeView)
            }
        }
    }
}

extension TimeSlotViewController: TimePickerViewControllerDelegate {
    
    func timePickerViewController(_ timePickerViewController: TimePickerViewController, startDate: Date, endDate: Date) {
        self.startingTime = startDate
        self.endingTime = endDate
        self.setResizableViewFrame(initially: true)
    }
}
