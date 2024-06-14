//
//  DatabasePlanItSilentEvent.swift
//  MiPlanIt
//
//  Created by Arun on 08/04/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation
import CoreData
// import RRuleSwift
import EventKit

class DatabasePlanItSilentEvent: DataBaseManager {
    
    func insertNewChildEventFromNotification(_ event: [String: Any], using objectContext: NSManagedObjectContext) {
        let eventId = event["eventId"] as? Double ?? 0
        let appEventId = event["appEventId"] as? String ?? Strings.empty
        let localEvents = self.readSpecificEvent(eventId, appEventId: appEventId, using: objectContext)
        let eventEntity = localEvents.first ?? self.insertNewRecords(Table.planItSilentEvent, context: objectContext) as! PlanItSilentEvent
        eventEntity.notifiedDate = nil
        eventEntity.isPending = false
        eventEntity.isRecurrence = false
        eventEntity.eventId = eventId
        eventEntity.appEventId = appEventId
        eventEntity.endDate = event["endDate"] as? String
        eventEntity.endTime = event["endTime"] as? String
        eventEntity.eventName = event["eventName"] as? String
        eventEntity.extEventId = event["extEventId"] as? String
        eventEntity.recurringEventId = event["recurringEventId"] as? String
        eventEntity.isAllDay = event["isAllDay"] as? Bool ?? false
        eventEntity.location = event["location"] as? String
        eventEntity.originalStartDate = event["originalStartDate"] as? String
        eventEntity.originalStartTime = event["originalStartTime"] as? String
        eventEntity.originalStartTimeZone = event["originalStartTimeZone"] as? String
        eventEntity.originalEndTimeZone = event["originalEndTimeZone"] as? String
        eventEntity.reminderId = event["reminderId"] as? Double ?? 0
        eventEntity.startDate = event["startDate"] as? String
        eventEntity.startTime = event["startTime"] as? String
        eventEntity.status = event["eventStatus"] as? Double ?? 0
        eventEntity.user = Session.shared.readUserId()
        if let date = event["originalStartDate"] as? String, let time = event["originalStartTime"] as? String {
            eventEntity.originalStartDateTime = (date + Strings.space + time).stringToDate(formatter: DateFormatters.MMDDYYYYHMMSSA, timeZone: TimeZone(abbreviation: "UTC")!)
        }
        if let date = event["startDate"] as? String, let time = event["startTime"] as? String {
            if let allDay = event["isAllDay"] as? Bool, allDay {
                let startDateTime = (date + Strings.space + time).stringToDate(formatter: DateFormatters.MMDDYYYYHMMSSA)
                eventEntity.startDateTime = startDateTime
            }
            else {
                let startDateTime = (date + Strings.space + time).stringToDate(formatter: DateFormatters.MMDDYYYYHMMSSA, timeZone: TimeZone(abbreviation: "UTC")!)
                eventEntity.startDateTime = startDateTime
            }
        }
        if let date = event["endDate"] as? String, let time = event["endTime"] as? String {
            if let allDay = event["isAllDay"] as? Bool, allDay {
                eventEntity.endDateTime = (date + Strings.space + time).stringToDate(formatter: DateFormatters.MMDDYYYYHMMSSA)
            }
            else {
                eventEntity.endDateTime = (date + Strings.space + time).stringToDate(formatter: DateFormatters.MMDDYYYYHMMSSA, timeZone: TimeZone(abbreviation: "UTC")!)
            }
        }
        if let recurrence = event["recurrence"] as? [String], let rule = recurrence.filter({ $0.hasPrefix("RRULE") }).first {
            DatabasePlanItEventRecurrence().insertSilentEvent(eventEntity, recurrence: rule, using: objectContext)
        }
        if let recurrence = event["recurrence"] as? [String: Any] {
            DatabasePlanItEventRecurrence().insertSilentEvent(eventEntity, recurrence: recurrence, using: objectContext)
        }
        if let reminders = event["reminders"] as? [[String: Any]], let remindMe = reminders.first {
            DataBasePlanItTodoReminders().insertSilentEvent(eventEntity, reminders: remindMe, using: objectContext)
        }
        else {
            eventEntity.deleteReminder(withHardSave: false)
        }
    }
    
    private func readSpecificEvent(_ eventId: Double, appEventId: String, using context: NSManagedObjectContext) -> [PlanItSilentEvent] {
        let predicate = NSPredicate(format: "user == %@ AND ((eventId == %f AND eventId <> '') OR (appEventId == %@ AND appEventId <> ''))", Session.shared.readUserId(), eventId, appEventId)
        return self.readRecords(fromCoreData: Table.planItSilentEvent, predicate: predicate, context: context) as! [PlanItSilentEvent]
    }
    
    func readSilentChildEventsUsingEventId(_ eventId: String, socialId: String, using context: NSManagedObjectContext? = nil) -> [PlanItSilentEvent] {
        let objectContext = context ?? self.mainObjectContext
        let predicate = NSPredicate(format: "user == %@ AND (recurringEventId == %@ OR recurringEventId == %@)", Session.shared.readUserId(), eventId, socialId)
        return self.readRecords(fromCoreData: Table.planItSilentEvent, predicate: predicate, context: objectContext) as! [PlanItSilentEvent]
    }
}
