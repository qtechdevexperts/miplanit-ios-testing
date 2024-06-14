//
//  OtherUserEventManager.swift
//  MiPlanIt
//
//  Created by Febin Paul on 03/07/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

protocol OtherUserEventManagerDelegate: class {
    func otherUserEventManager(_ manager: OtherUserEventManager, getTimeSlots timeSlots: [TimeSlotEvent])
}

class OtherUserEventManager: Operation {
    
    var startingTime: Date = Date()
    var endingTime: Date = Date()
     var otherUsers: [OtherUser] = []
    weak var delegate: OtherUserEventManagerDelegate?
    
    override func main() {
        let endOfDate = self.endingTime.initialHour().adding(days: 2)
        let startOfDate = self.startingTime.initialHour().adding(days: -2)
        let otherUserEvents = self.otherUsers.flatMap({ $0.readAllOtherEventsFrom(start: startOfDate, end: endOfDate) })
        let timeSlotEvents = self.readAllTimeSlotEvents(otherUserEvents, start: startOfDate, end: endOfDate)
        self.delegate?.otherUserEventManager(self, getTimeSlots: timeSlotEvents)
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
    
    
}

class OtherUserEventOperator {
    
    static let `default` = OtherUserEventOperator()
        
    let otherUserEventOperationQueue = OperationQueue()
    
    init() {
        self.otherUserEventOperationQueue.maxConcurrentOperationCount = 1
    }
    
    func suspendAllOperations() {
        self.otherUserEventOperationQueue.isSuspended = true
    }
    
    func resumeAllOperations() {
        self.otherUserEventOperationQueue.isSuspended = false
    }
    
    func cancelAllOperations() {
        self.otherUserEventOperationQueue.cancelAllOperations()
    }
    
    func getUserEvents(of invitees: [OtherUser], startDateTime: Date, endDateTime: Date, delegate: OtherUserEventManagerDelegate?) {
        let otherUserEventManager = OtherUserEventManager()
        otherUserEventManager.startingTime = startDateTime
        otherUserEventManager.endingTime = endDateTime
        otherUserEventManager.delegate = delegate
        otherUserEventManager.otherUsers = invitees
        self.otherUserEventOperationQueue.addOperation(otherUserEventManager)
    }
}

