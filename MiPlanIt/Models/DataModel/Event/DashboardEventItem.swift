//
//  DashboardEventItem.swift
//  MiPlanIt
//
//  Created by Febin Paul on 27/11/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation


class DashboardEventItem {
    
    var tags: [String] = []
    var title: String = Strings.empty
    var description: String = Strings.empty
    var start: Date = Date()
    var end: Date = Date()
    var initialDate: Date = Date()
    var isAllDay: Bool = false
    var planItEvent: PlanItEvent?
    var eventId: String = Strings.empty
    var calendarId: String = Strings.empty
    var calendar: PlanItCalendar?
    public var appEventId: String = Strings.empty

    init(with event: PlanItEvent, startDate: Date, converter: DatabasePlanItEvent) {
        self.eventId = event.readValueOfEventId()
        self.isAllDay = event.isAllDay
        self.initialDate = startDate
        self.start = event.readStartDateTimeFromDate(startDate).trimSeconds()
        self.end = event.readEndDateTimeFromDate(startDate).trimSeconds()
        let miplanitCalendar = event.readMainCalendar()
        self.calendar = miplanitCalendar?.calendar
        self.calendarId = miplanitCalendar?.readValueOfCalendarId() ?? Strings.empty
        self.tags = event.readAllTags().map({ $0.readTag() })
        self.title = event.readValueOfEventName()
        self.description = event.readValueOfEventDescription()
        self.appEventId = event.readValueOfAppEventId()
        self.planItEvent = try? converter.mainObjectContext.existingObject(with: event.objectID) as? PlanItEvent
    }
    
    init(with event: PlanItEvent, startDate: Date) {
        self.eventId = event.readValueOfEventId()
        self.isAllDay = event.isAllDay
        self.initialDate = startDate
        self.start = event.readStartDateTimeFromDate(startDate).trimSeconds()
        self.end = event.readEndDateTimeFromDate(startDate).trimSeconds()
        let miplanitCalendar = event.readMainCalendar()
        self.calendar = miplanitCalendar?.calendar
        self.calendarId = miplanitCalendar?.readValueOfCalendarId() ?? Strings.empty
        self.tags = event.readAllTags().map({ $0.readTag() })
        self.title = event.readValueOfEventName()
        self.description = event.readValueOfEventDescription()
        self.appEventId = event.readValueOfAppEventId()
    }
    
    init(with event: Event) {
        self.eventId = event.eventId
        self.isAllDay = event.isAllDay
        self.initialDate = event.initialDate
        self.start = event.start
        self.end = event.end
        self.calendar = event.calendar
        self.calendarId = event.calendarId
        self.title = event.text
        if let planItEvent = event.eventData as? PlanItEvent {
            self.description = planItEvent.readValueOfEventDescription()
            self.tags = planItEvent.readAllTags().map({ $0.readTag() })
            self.planItEvent = planItEvent
        }
    }
    
    func readAllTags() -> [String] {
        return self.tags.compactMap({ $0.lowercased() })
    }
    
    func containsName(_ string: String) -> Bool {
        return self.title.lowercased().contains(string)
    }
    
    func containsTags(_ string: String) -> Bool {
        return !self.tags.filter({ $0.lowercased().contains(string) }).isEmpty
    }
    
    func containsDescription(_ string: String) -> Bool {
        return self.description.lowercased().contains(string)
    }
}
