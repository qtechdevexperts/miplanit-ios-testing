//
//  UserEventManager.swift
//  MiPlanIt
//
//  Created by Febin Paul on 03/07/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

protocol UserEventManagerDelegate: class {
    func userEventManager(_ manager: UserEventManager, getTimeSlots timeSlots: [TimeSlotEvent])
}

class UserEventManager: Operation {
    
    var startingTime: Date = Date()
    var endingTime: Date = Date()
    var userEvent: [PlanItEvent] = []
    weak var delegate: UserEventManagerDelegate?
    
    override func main() {
        let timeSlots = self.readAllTimeSlotEvents(userEvent, start: self.startingTime, end: self.endingTime)
        self.delegate?.userEventManager(self, getTimeSlots: timeSlots)
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

class UserEventOperator {
    
    static let `default` = UserEventOperator()
        
    let userEventOperationQueue = OperationQueue()
    
    init() {
        self.userEventOperationQueue.maxConcurrentOperationCount = 1
    }
    
    func suspendAllOperations() {
        self.userEventOperationQueue.isSuspended = true
    }
    
    func resumeAllOperations() {
        self.userEventOperationQueue.isSuspended = false
    }
    
    func cancelAllOperations() {
        self.userEventOperationQueue.cancelAllOperations()
    }
    
    func getUserEvents(_ events: [PlanItEvent], startDateTime: Date, endDateTime: Date, delegate: UserEventManagerDelegate?) {
        let userEventManager = UserEventManager()
        userEventManager.userEvent = events
        userEventManager.startingTime = startDateTime
        userEventManager.endingTime = endDateTime
        userEventManager.delegate = delegate
        self.userEventOperationQueue.addOperation(userEventManager)
    }
}

