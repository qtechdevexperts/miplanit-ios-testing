//
//  OfflineTriggerCalendarEvent.swift
//  MiPlanIt
//
//  Created by Arun Aniyappan on 27/11/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

extension Session {
    
    func sendEventsToServer(_ finished: @escaping () -> ()) {
        let pendingEvents = DatabasePlanItEvent().readAllPendingEvents()
        let pendingCalendars = DatabasePlanItCalendar().readAllPendingCalendars()
        if pendingEvents.isEmpty || !pendingCalendars.isEmpty {
            self.sendDeletedEventsToServer(finished)
        }
        else {
            self.sendAllPendingParentEvents(pendingEvents) {
                self.sendAllPendingChildEvents(pendingEvents) {
                    self.sendDeletedEventsToServer(finished)
                }
            }
        }
    }
    
    private func sendAllPendingParentEvents(_ pendingEvents: [PlanItEvent], finished: @escaping () -> ()) {
        let pendingParentEvents = pendingEvents.filter({ return $0.parent == nil })
        if pendingParentEvents.isEmpty {
            finished()
        }
        else {
            self.sendAllPendingEvents(pendingParentEvents) {
                finished()
            }
        }
    }
    
    private func sendAllPendingChildEvents(_ pendingEvents: [PlanItEvent], finished: @escaping () -> ()) {
        let pendingChildEvents = pendingEvents.filter({ if let parent = $0.parent, !parent.isPending { return true } else { return false } })
        if pendingChildEvents.isEmpty {
            finished()
        }
        else {
            self.sendAllPendingEvents(pendingChildEvents) {
                finished()
            }
        }
    }
    
    private func sendAllPendingEvents(_ events: [PlanItEvent], finished: @escaping () -> ()) {
        var mainParam: [String: Any] = [:]
        var insertEvents: [[String: Any]] = []
        var updatedEvents: [[String: Any]] = []
        events.forEach({
            var requestParam = self.createBasicParamsForEvent($0)
            requestParam["userId"] = Session.shared.readUserId()
            if $0.readValueOfEventId().isEmpty {
                requestParam["appEventId"] = $0.readValueOfAppEventId()
                if let orginalStartDateTime = $0.readOrginalStartDateTime() {
                    if $0.parent?.isAllDay ?? false {
                        requestParam["originalStartTime"] = orginalStartDateTime.stringFromDate(format: DateFormatters.YYYYHMMDDSHHMMSS)
                    }
                    else {
                        requestParam["originalStartTime"] = orginalStartDateTime.stringFromDate(format: DateFormatters.YYYYHMMDDSHHMMSS, timeZone: TimeZone(abbreviation: "UTC")!)
                    }
                }
                insertEvents.append(requestParam)
            }
            else {
                requestParam["eventId"] = $0.readValueOfEventId()
                requestParam["appEventId"] = $0.readValueOfAppEventId()
                updatedEvents.append(requestParam)
            }
        })
        if !insertEvents.isEmpty {
            mainParam["insertEvents"] = insertEvents
        }
        if !updatedEvents.isEmpty {
            mainParam["updateEvents"] = updatedEvents
        }
        CalendarService().offlineAddEditEvents(events: mainParam, callback: { _, _ in
            finished()
        })
    }
    
    func createBasicParamsForEvent(_ event: PlanItEvent) -> [String: Any] {
        let recurringRule = event.readPlanItRecurrance()?.readRule() ?? Strings.empty
        var requestParameter: [String: Any] = ["description": event.readValueOfEventDescription(), "location": self.createLocationParamValueOfEvent(event), "availabilityFlag": event.isUserTravelling() ? 1 : 0, "isAllDay": event.isAllDay, "eventName": event.readValueOfEventName(), "recurrence": recurringRule.isEmpty ? "" : [recurringRule] , "createdAt": Date().stringFromDate(format: DateFormatters.YYYYHMMDDSHHMMSS, timeZone: TimeZone(abbreviation: "UTC")!), "tags": event.readAllTags().compactMap({$0.tag}), "invitees": self.createInviteesOfEvent(event), "recurringEventId": event.readRecurringEventId()]
        if let parent = event.parent, !parent.readValueOfEventId().isEmpty {
            requestParameter["recurringEventId"] = parent.readValueOfEventId()
        }
        if event.isAllDay {
            requestParameter["startDate"] = event.readStartDateTime().stringFromDate(format: DateFormatters.YYYYHMMMHDD)
            requestParameter["endDate"] = event.readEndDateTime().stringFromDate(format: DateFormatters.YYYYHMMMHDD)
        }
        else {
            requestParameter["startDate"] = event.readStartDateTime().stringFromDate(format: DateFormatters.YYYYHMMDDSHHMMSS, timeZone: TimeZone(abbreviation: "UTC")!)
            requestParameter["endDate"] = event.readEndDateTime().stringFromDate(format: DateFormatters.YYYYHMMDDSHHMMSS, timeZone: TimeZone(abbreviation: "UTC")!)
        }
        if event.reminderId != 0.0, let reminder = event.reminder {
            let reminder = ReminderModel(reminder, from: .event)
            requestParameter["reminders"] = reminder.readReminderNumericValueParameter()
        }
        let visibilityCalendars = event.readAllEventCalendars()
        requestParameter["calendar"] = event.readAllAvailableCalendars().map({ calendar in return ["calendarId": calendar.readValueOfCalendarId(), "accessLevel": visibilityCalendars.contains( where: { return (($0.calendarId == calendar.calendarId && calendar.calendarId != 0) || ($0.appCalendarId == calendar.appCalendarId && !calendar.readValueOfAppCalendarId().isEmpty)) && $0.accessLevel == 1}) ? "1" : "0"] })
        let notifyCalendars = event.readAllEventNotifyCalendars()
        requestParameter["notifyCalendar"] = event.readAllAvailableNotifyCalendars().map({ calendar in return ["calendarId": calendar.readValueOfCalendarId(), "accessLevel": notifyCalendars.contains( where: { return (($0.calendarId == calendar.calendarId && calendar.calendarId != 0) || ($0.appCalendarId == calendar.appCalendarId && !calendar.readValueOfAppCalendarId().isEmpty)) && $0.accessLevel == 0}) ? "0" : "1"] })
        if let timezone = event.readTimeZoneOfEvent(), !timezone.isEmpty {
            requestParameter["originalStartTimeZone"] = timezone
        }
        if let timezone = event.readEndTimeZoneOfEvent(), !timezone.isEmpty {
            requestParameter["originalEndTimeZone"] = timezone
        }
        if let parent = event.parent {
            requestParameter["isOriginalAllDay"] = parent.isAllDay
        }
        return requestParameter
    }
    
    func createLocationParamValueOfEvent(_ event: PlanItEvent) -> String {
        var locationParam = event.readLocation()
        if let latLong = event.readPlaceLatLong() {
            locationParam += String(Strings.locationSeperator)+String(latLong.0)+String(Strings.locationSeperator)+String(latLong.1)
        }
        return locationParam
    }
    
    func createInviteesOfEvent(_ event: PlanItEvent) -> [[String: Any]] {
        let invitees = event.readOtherUsers()
        let userIds = invitees.filter({ return !$0.userId.isEmpty }).map({ return ["userId": $0.userId] })
        let emails = invitees.filter({ return $0.userId.isEmpty && !$0.email.isEmpty }).map({ return ["email": $0.email] })
        let phones = invitees.filter({ return $0.userId.isEmpty && !$0.phone.isEmpty }).map({ return ["phone": $0.phone, "countryCode": $0.countryCode] })
        var users = userIds + emails + phones
        guard event.isSocialEvent else {
            users.append(["userId": Session.shared.readUserId()])
            return users
        }
        return users
    }
    
    func sendDeletedEventsToServer(_ finished: @escaping () -> ()) {
        let pendingDeletedEvents = DatabasePlanItEvent().readAllPendingDeletedEvents().filter({ if let parent = $0.parent, parent.isPending { return false } else { return true } })
        if pendingDeletedEvents.isEmpty {
            finished()
        }
        else {
            let deletedEvents = pendingDeletedEvents.filter({ return $0.status == 1 })
            let canceledEvents = pendingDeletedEvents.filter({ return $0.status == 2 })
            let forceDeletedEvents = pendingDeletedEvents.filter({ return $0.status == 3 })
            self.sendAllPendingDeletedEvents(deletedEvents) {
                self.sendAllPendingCanceledEvents(canceledEvents) {
                    self.sendAllPendingForceDeletedEvents(forceDeletedEvents) {
                        finished()
                    }
                }
            }
        }
    }
    
    private func sendAllPendingDeletedEvents(_ events: [PlanItEvent], finished: @escaping () -> ()) {
        if events.isEmpty {
            finished()
        }
        else {
            let deletedEvents = events.map({ return self.makeRequestForDeleteCancelEvent($0) })
            CalendarService().deleteOfflineEvents(request: ["deletedEvents": deletedEvents], callback: { status, error in
                if status { events.filter({ return $0.parent == nil }).forEach({ Session.shared.removeNotification(LocalNotificationMethod.event.rawValue + $0.readValueOfNotificationId()); $0.deleteItSelf() }) }
                finished()
            })
        }
    }
    
    func makeRequestForDeleteCancelEvent(_ event: PlanItEvent) -> [String: Any] {
        var eventParams: [String: Any] = [:]
        eventParams["userId"] = Session.shared.readUserId()
        if !event.readValueOfEventId().isEmpty {
            eventParams["eventId"] = event.readValueOfEventId()
        }
        if !event.readValueOfAppEventId().isEmpty {
            eventParams["appEventId"] = event.readValueOfAppEventId()
        }
        if !event.readRecurringEventId().isEmpty {
            eventParams["recurringEventId"] = event.readRecurringEventId()
        }
        if event.parent != nil {
            eventParams["isOriginalAllDay"] = event.isAllDay
            if let originalStartDateTime = event.readOrginalStartDateTime() {
                if event.isAllDay {
                    eventParams["originalStartTime"] = originalStartDateTime.stringFromDate(format: DateFormatters.YYYYHMMDDSHHMMSS)
                }
                else {
                    eventParams["originalStartTime"] = originalStartDateTime.stringFromDate(format: DateFormatters.YYYYHMMDDSHHMMSS, timeZone: TimeZone(abbreviation: "UTC")!)
                }
            }
        }
        return eventParams
    }
    
    func makeRequestForForceDeleteEvent(_ event: PlanItEvent) -> [String: Any] {
        var eventParams: [String: Any] = [:]
        eventParams["userId"] = Session.shared.readUserId()
        if !event.readValueOfEventId().isEmpty {
            eventParams["eventId"] = event.readValueOfEventId()
        }
        if !event.readValueOfAppEventId().isEmpty {
            eventParams["appEventId"] = event.readValueOfAppEventId()
        }
        return eventParams
    }
    
    private func sendAllPendingCanceledEvents(_ events: [PlanItEvent], finished: @escaping () -> ()) {
        if events.isEmpty {
            finished()
        }
        else {
            let deletedEvents = events.map({ return self.makeRequestForDeleteCancelEvent($0) })
            CalendarService().cancelOfflineEvents(request: ["deletedEvents": deletedEvents], callback: { status, error in
                if status { events.filter({ return $0.parent == nil }).forEach({ Session.shared.removeNotification(LocalNotificationMethod.event.rawValue + $0.readValueOfNotificationId()); $0.deleteItSelf() }) }
                finished()
            })
        }
    }
    
    private func sendAllPendingForceDeletedEvents(_ events: [PlanItEvent], finished: @escaping () -> ()) {
        if events.isEmpty {
            finished()
        }
        else {
            let deletedEvents = events.map({ return self.makeRequestForForceDeleteEvent($0) })
            CalendarService().deleteOfflineEvents(request: ["deletedEvents": deletedEvents], callback: { status, error in
                if status { events.filter({ return $0.parent == nil }).forEach({ Session.shared.removeNotification(LocalNotificationMethod.event.rawValue + $0.readValueOfNotificationId()); $0.deleteItSelf() }) }
                finished()
            })
        }
    }
}
