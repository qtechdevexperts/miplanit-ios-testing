//
//  TimeSlotEvent.swift
//  MiPlanIt
//
//  Created by Arun on 25/06/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

class TimeSlotEvent {
    
    var id: String
    var startDate: Date
    var endDate: Date
    var selectedDate: Date
    var event: Any
    var userId: String! = Strings.empty
    var eventId: String
    
    init(with date: Date, event: PlanItEvent) {
        self.event = event
        self.selectedDate = date
        self.endDate = event.readEndDateTimeFromDate(date)
        self.startDate = event.readStartDateTimeFromDate(date)
        self.userId = event.readValueOfUserId()
        self.eventId = event.readValueOfEventId()
        let specificId = event.readValueOfEventId().isEmpty ? event.readValueOfAppEventId() : event.readValueOfEventId()
        self.id = event.readValueOfUserId() + specificId + "\(date)"
    }
    
    init(with date: Date, event: OtherUserEvent) {
        self.event = event
        self.selectedDate = date
        self.endDate = event.readEndDateTimeFromDate(date)
        self.startDate = event.readStartDateTimeFromDate(date)
        self.userId = event.userId
        self.eventId = event.eventId
        self.id = event.userId + event.eventId + "\(date)"
    }
}
