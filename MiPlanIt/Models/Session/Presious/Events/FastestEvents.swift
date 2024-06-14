//
//  FastestEvents.swift
//  MiPlanIt
//
//  Created by Arun on 06/09/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

enum FastestEventStatus {
    case `default`, start, force
}

extension Session {
    
    func loadFastestCalendars() {
        DispatchQueue.main.async {
            self.saveFastestCalendars(DatabasePlanItCalendar().readAllPlanitCalendars().map({ return MiPlanItEventCalendar(with: $0) }))
        }
    }
    
    func loadFastestEvents() {
        guard self.fastestEventStatus == .default else {
            self.fastestEventStatus = .force
            return
        }
        self.fastestEventStatus = .start
        let startOfMonth = Date().addDays(-6).initialHour()
        let endOfMonth = Date().addDays(6).initialHour()
        let databasePlanItEvent = DatabasePlanItEvent()
        databasePlanItEvent.readAllEventsUsingQueueFrom(startOfMonth: startOfMonth, endOfMonth: endOfMonth, result: { allUserEvents in
            var dateEvents: [Event] = []
            for event in allUserEvents where self.fastestEventStatus == .start {
                self.manipulateUserEvent(event, start: startOfMonth, end: endOfMonth, converter: databasePlanItEvent, to: &dateEvents)
            }
            DispatchQueue.main.async {
                if self.fastestEventStatus == .start {
                    self.fastestEventStatus = .default
                    self.saveFastestEvents(dateEvents)
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: Notifications.calendarFastestDataProcessFinished), object: nil)
                }
                else if self.fastestEventStatus == .force {
                    self.fastestEventStatus = .default
                    self.loadFastestEvents()
                }
                else {
                    self.fastestEventStatus = .default
                }
            }
        })
    }
    
    func manipulateUserEvent(_ event: PlanItEvent, start: Date, end: Date, converter: DatabasePlanItEvent, to dateEvents: inout [Event]) {
        let availableDates = event.readAllAvailableDates(from: start, to: end)
        availableDates.forEach({ date in
            let modelEvent = Event(with: event, startDate: date, converter: converter)
            if modelEvent.eventData != nil { dateEvents.append(modelEvent) }
        })
    }
}
