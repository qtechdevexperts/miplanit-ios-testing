//
//  SocialCalendar.swift
//  MiPlanIt
//
//  Created by Arun on 23/03/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation
import EventKit

class SocialCalendar {
    
    let socialUser: SocialUser!
    var canEdit = true
    var appleCalendar: EKCalendar?
    var accessRole = Strings.empty
    var calendarId = Strings.empty
    var calendarName = Strings.empty
    var timeZone = Strings.empty
    var calendarEvents: [SocialCalendarEvent] = []
    var deletedEvents: [String] = []
    var calendarProgress = 0.0
    var calendarStatus = SocialCalendarEventStatus.pending
    
    init(withGoogleData data: [String: Any], of user: SocialUser) {
        self.socialUser = user
        self.accessRole = data["accessRole"] as? String ?? Strings.empty
        self.calendarId = data["id"] as? String ?? Strings.empty
        self.calendarName = data["summary"] as? String ?? Strings.empty
        self.timeZone = data["timeZone"] as? String ?? Strings.empty
        self.canEdit = self.accessRole == "owner"
    }
    
    func readGoogleEvents(callback: @escaping (Bool) -> ()){
        guard self.calendarStatus == .pending else { return }
        self.calendarStatus = .started
        var googleEvents: [SocialCalendarEvent] = []
        GoogleService().readEventsFromCalendar(self, callback: { response, finished, error in
            guard let result = response else { self.calendarStatus = .pending;  callback(false); return }
            googleEvents += result
            if finished {
                self.calendarEvents = googleEvents
                self.calendarStatus = .completed; callback(true)
            }
        })
    }
    
    init(withOutlookData data: [String: Any], of user: SocialUser) {
        self.socialUser = user
        self.canEdit = data["canEdit"] as? Bool ?? true
        self.calendarId = data["id"] as? String ?? Strings.empty
        self.calendarName = data["name"] as? String ?? Strings.empty
    }
    
    init(withOutlookData data: PlanItCalendar, of user: SocialUser) {
        self.socialUser = user
        self.canEdit = data.canEdit
        self.calendarId = data.readValueOfSocialCalendarId()
        self.calendarName = data.readValueOfCalendarName()
    }
    //TODO: Read Outlook
    func readOutlookEvents(callback: @escaping (Bool) -> ()) {
        guard self.calendarStatus == .pending else { return }
        self.calendarStatus = .started
        var outlookEvents: [[String: Any]] = []
        OutlookService().readEventsOfCalendar(self) { (response, finished, error) in
            guard let result = response else { self.calendarStatus = .pending; callback(false); return }
            outlookEvents += result
            if finished {
                let commonEvents = outlookEvents.filter({ if let type = $0["type"] as? String { return type != "occurrence" } else { return true } })
                let recurrenceEvents = outlookEvents.filter({ if let type = $0["type"] as? String { return type == "occurrence" || type == "exception" } else { return false } })
                let groupedRecurrenceEvents = Dictionary(grouping: recurrenceEvents, by: { $0["seriesMasterId"] as? String ?? Strings.empty })
                for event in commonEvents {
                    let eventId = event["id"] as? String ?? Strings.empty
                    let minDate = Date().initialHour().addMonth(n: -1)
                    let maxDate = Date().initialHour().addMonth(n: 6)
                    let availableDates: [String] = groupedRecurrenceEvents[eventId]?.compactMap({ if let start = $0["start"] as? [String: Any] { return start["dateTime"] as? String } else { return nil } }) ?? []
                    self.calendarEvents.append(SocialCalendarEvent(withOutlookEvent: event, availableDates: availableDates, from: minDate, to: maxDate))
                }
                self.calendarStatus = .completed; callback(true) }
        }
    }
    
    init(with data: EKCalendar) {
        self.socialUser = nil
        self.appleCalendar = data
        self.calendarName = data.title
        self.calendarId = data.calendarIdentifier
        self.canEdit = data.source.sourceType == .local
    }
    
    func readAppleEventsUsingEventStore(_ eventStore: EKEventStore, callback: @escaping (Bool) -> ()) {
        self.calendarStatus = .started
        guard let calendar = self.appleCalendar else { self.calendarStatus = .pending; callback(false); return }
        DispatchQueue.global(qos: .userInitiated).async {
            let startDate = Date().initialHour().addMonth(n: -1)
            let endDate = Date().initialHour().addMonth(n: 6)
            let eventsPredicate = eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: [calendar])
            let allEvents = eventStore.events(matching: eventsPredicate)
            let groupedEvents = Dictionary.init(grouping: allEvents, by: { $0.eventIdentifier })
            for (_, events) in groupedEvents {
                if let singleEvent = events.first, events.count == 1 {
                    let availableDates = allEvents.filter({ return $0.eventIdentifier.hasPrefix(singleEvent.eventIdentifier)}).compactMap({ return $0.startDate.initialHour() })
                    self.calendarEvents.append(SocialCalendarEvent(withAppleEvent: singleEvent, availableDates: availableDates, from: startDate, to: endDate))
                }
                else {
                    if let singleEvent = events.sorted(by: { return $0.startDate.compare($1.startDate) == .orderedAscending }).first {
                        let availableDates = allEvents.filter({ return $0.eventIdentifier.hasPrefix(singleEvent.eventIdentifier)}).compactMap({ return $0.startDate.initialHour() })
                        self.calendarEvents.append(SocialCalendarEvent(withAppleEvent: singleEvent, availableDates: availableDates, from: startDate, to: endDate))
                    }
                }
            }
            DispatchQueue.main.async {
                self.readDeletedCalendarEventsOfCalendar(calendar, from: startDate, to: endDate, result: { deletedIds in
                    self.deletedEvents = deletedIds
                    self.calendarStatus = .completed
                    callback(true)
                })
            }
        }
    }
    
    func readDeletedCalendarEventsOfCalendar(_ calendar: EKCalendar, from: Date, to: Date, result: @escaping ([String]) -> ()) {
        let databasePlanItEvent = DatabasePlanItEvent()
        let eventIds = self.calendarEvents.map({ return $0.eventId })
        databasePlanItEvent.readSpecificEventsFromCalendarUsingQueue(calendar.calendarIdentifier, startOfMonth: from, endOfMonth: to, eventIds: eventIds, result: { events in
            let deletedIds = events.map({ return $0.readValueOfSocialEventId()})
            DispatchQueue.main.async { result(deletedIds) }
        })
    }
    
    func readAllParentChildEvents() -> (parent: [SocialCalendarEvent], child: [String: [SocialCalendarEvent]]) {
            let parentEvents = self.calendarEvents.filter({ event in return event.recurringEventId.isEmpty || (self.socialUser.userType == .eGoogleUser && !self.calendarEvents.contains(where: { return $0.eventId == event.recurringEventId})) })
            let childEvents = self.calendarEvents.filter({ event in return !event.recurringEventId.isEmpty && !parentEvents.contains(where: { return $0.eventId == event.eventId}) })
            let groupedChildEvents = Dictionary(grouping: childEvents, by: { $0.recurringEventId })
            return (parent: parentEvents, child: groupedChildEvents)
        }
}
