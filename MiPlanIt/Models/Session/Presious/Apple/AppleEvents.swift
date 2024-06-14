//
//  AppleEvents.swift
//  MiPlanIt
//
//  Created by Arun on 23/09/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation
import EventKit

extension Session {
    
    func refreshAppleCalendarsEvents() {
        guard SocialManager.default.isNetworkReachable(), let user = Session.shared.readUser() else { return }
        InAppPurchaseService().verifySubscriptionStatus(user: user) {
            self.triggerAppleCalendarSynchronisationToServer()
        }
    }
    
    func triggerAppleCalendarSynchronisationToServer() {
        let appleCalendars = DatabasePlanItCalendar().readSpecificCalendarsUsingType(3)
        guard !appleCalendars.isEmpty, EKEventStore.authorizationStatus(for: .event) == .authorized else { return }
        self.sendAppleCalendarSynchronisationToServer(appleCalendars)
    }
    
    func sendAppleCalendarSynchronisationToServer(_ calendars: [PlanItCalendar]) {
        let calendarIds = calendars.compactMap({ return $0.socialCalendarId })
        let calendars = self.eventStore.calendars(for: .event).filter({ return calendarIds.contains($0.calendarIdentifier) })
        if !calendars.isEmpty {
            let appleCalanders = calendars.map({ return SocialCalendar(with: $0) })
            self.downloadAppleEventsFromCalendars(appleCalanders)
        }
    }
    
    func downloadAppleEventsFromCalendars(_ calendars: [SocialCalendar], at index: Int = 0) {
        if index < calendars.count {
            calendars[index].readAppleEventsUsingEventStore(Session.shared.eventStore, callback: { _ in
                self.downloadAppleEventsFromCalendars(calendars, at: index + 1)
            })
        }
        else {
            self.createServiceToImportCalendarEvents(calendars)
        }
    }
    
    func createServiceToImportCalendarEvents(_ calendars: [SocialCalendar]) {
        CalendarService().importUser(calendars: calendars, callback: { result, addedColorCodes, error in
            if result {
                self.createServiceToFetchUsersEventData()
            }
            else if let message = error {
                debugPrint(message)
            }
            else {
                debugPrint("unknown")
            }
        })
    }
}
