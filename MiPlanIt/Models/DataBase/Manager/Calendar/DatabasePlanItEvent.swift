//
//  DatabasePlanItEvent.swift
//  MiPlanIt
//
//  Created by Arun on 08/04/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation
import CoreData
//import RRuleSwift
import EventKit

class DatabasePlanItEvent: DataBaseManager {
    
    func insertPlanItEvents(_ data: [[String: Any]], using context: NSManagedObjectContext? = nil) {
        let objectContext = context ?? self.mainObjectContext
        let eventIds = data.compactMap({ return $0["eventId"] as? Double })
        let appEventIds = data.compactMap({ return $0["appEventId"] as? String })
        let localEvents = self.readSpecificEvents(eventIds, appEventIds: appEventIds, using: objectContext)
        for event in data {
            let eventId = event["eventId"] as? Double ?? 0
            let appEventId = event["appEventId"] as? String ?? Strings.empty
            let eventEntity = localEvents.filter({ return $0.eventId == eventId  || ($0.appEventId == appEventId && !appEventId.isEmpty) }).first ?? self.insertNewRecords(Table.planItEvent, context: objectContext) as! PlanItEvent
            if eventEntity.isPending, let serverModifiedDate = (event["modifiedAt"] as? String)?.stringToDate(formatter: DateFormatters.MMDDYYYYHMMSSA, timeZone: TimeZone(abbreviation: "UTC")!), let localModifiedDate = eventEntity.modifiedAt?.stringToDate(formatter: DateFormatters.MMDDYYYYHMMSSA, timeZone: TimeZone(abbreviation: "UTC")!), serverModifiedDate < localModifiedDate {
                continue
            }
            eventEntity.eventHidden = false
            eventEntity.notifiedDate = nil
            eventEntity.isPending = false
            eventEntity.isRecurrence = false
            eventEntity.eventId = eventId
            eventEntity.appEventId = appEventId
            eventEntity.remindMe = LocalNotificationType.new.rawValue
            eventEntity.accessLevel = event["accessLevel"] as? Double ?? 0
            eventEntity.bodyContentType = event["bodyContentType"] as? String
            eventEntity.createdAt = event["createdAt"] as? String
            eventEntity.creatorEmail = event["creatorEmail"] as? String
            eventEntity.creatorName = event["creatorName"] as? String
            eventEntity.endDate = event["endDate"] as? String
            eventEntity.endTime = event["endTime"] as? String
            eventEntity.eventDescription = event["description"] as? String
            eventEntity.eventName = event["eventName"] as? String
            eventEntity.extCreatedDate = event["extCreatedDate"] as? String
            eventEntity.extEventId = event["extEventId"] as? String
            eventEntity.recurringEventId = event["recurringEventId"] as? String
            eventEntity.extUpdatedDate = event["extUpdatedDate"] as? String
            eventEntity.htmlLink = event["htmlLink"] as? String
            eventEntity.isAllDay = event["isAllDay"] as? Bool ?? false
            eventEntity.isAvailable = event["availabilityFlag"] as? Double ?? 0
            eventEntity.location = event["location"] as? String
            eventEntity.modifiedAt = event["modifiedAt"] as? String
            eventEntity.organizerEmail = event["organizerEmail"] as? String
            eventEntity.organizerName = event["organizerName"] as? String
            eventEntity.originalStartDate = event["originalStartDate"] as? String
            eventEntity.originalStartTime = event["originalStartTime"] as? String
            eventEntity.originalStartTimeZone = event["originalStartTimeZone"] as? String
            eventEntity.originalEndTimeZone = event["originalEndTimeZone"] as? String
            eventEntity.reminderId = event["reminderId"] as? Double ?? 0
            eventEntity.startDate = event["startDate"] as? String
            eventEntity.startTime = event["startTime"] as? String
            eventEntity.status = event["eventStatus"] as? Double ?? 0
            eventEntity.isSocialEvent = event["isSocialEvent"] as? Bool ?? false
            eventEntity.user = Session.shared.readUserId()
            eventEntity.responseStatus = event["responseStatus"] as? String
            if let conferenceData = event["conferenceData"] as? [String: Any] {
                eventEntity.conferenceType = conferenceData["conferenceType"] as? String
                eventEntity.conferenceUrl = conferenceData["url"] as? String
                eventEntity.fullConferenceData = conferenceData["fullConferenceData"] as? String
            }
            if let date = event["originalStartDate"] as? String, let time = event["originalStartTime"] as? String {
                eventEntity.originalStartDateTime = (date + Strings.space + time).stringToDate(formatter: DateFormatters.MMDDYYYYHMMSSA, timeZone: TimeZone(abbreviation: "UTC")!)
            }
            if let date = event["startDate"] as? String, let time = event["startTime"] as? String {
                if let allDay = event["isAllDay"] as? Bool, allDay {
                    let startDateTime = (date + Strings.space + time).stringToDate(formatter: DateFormatters.MMDDYYYYHMMSSA)
                    eventEntity.startDateTime = startDateTime
                    eventEntity.sortedTime = startDateTime?.stringFromDate(format:  DateFormatters.HHCMMCSSSA).stringToDate(formatter:  DateFormatters.HHCMMCSSSA)
                }
                else {
                    let startDateTime = (date + Strings.space + time).stringToDate(formatter: DateFormatters.MMDDYYYYHMMSSA, timeZone: TimeZone(abbreviation: "UTC")!)
                    eventEntity.startDateTime = startDateTime
                    eventEntity.sortedTime = startDateTime?.stringFromDate(format:  DateFormatters.HHCMMCSSSA).stringToDate(formatter:  DateFormatters.HHCMMCSSSA)
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
            if let subEvents = event["child"] as? [[String: Any]] {
                self.insertPlanItChildEvents(subEvents, to: eventEntity, using: objectContext)
            }
            if let calendars = event["calendar"] as? [[String: Any]] {
                DatabasePlanItEventCalendar().insertCalendarsToEvent(calendars, event: eventEntity, using: objectContext)
            }
            if let calendars = event["notifyCalendars"] as? [[String: Any]] {
                DatabasePlanItEventCalendar().insertNotifyCalendarsToEvent(calendars, event: eventEntity, using: objectContext)
            }
            else { eventEntity.deleteAllEventNotifyCalendars() }
            if let createdBy = event["createdBy"] as? [String: Any] {
                DatabasePlanItCreator().insertEvent(eventEntity, creator: createdBy, using: objectContext)
            }
            if let modifiedBy = event["modifiedBy"] as? [String: Any] {
                DatabasePlanItModifier().insertEvent(eventEntity, modifier: modifiedBy, using: objectContext)
            }
            if let invitees = event["invitees"] as? [[String: Any]] {
                DatabasePlanItInvitees().insertEvent(eventEntity, main: invitees, using: objectContext)
            }
            if let tags = event["tags"] as? [[String: String]] {
                let arrayTags = tags.compactMap({$0.values.first})
                if arrayTags.count > 0 {
                    DatabasePlanItTags().insertTags(arrayTags, for: eventEntity, using: objectContext)
                }
            }
            if let recurrence = event["recurrence"] as? [String], let rule = recurrence.filter({ $0.hasPrefix("RRULE") }).first {
                DatabasePlanItEventRecurrence().insertEvent(eventEntity, recurrence: rule, using: objectContext)
            }
            if let recurrence = event["recurrence"] as? [String: Any] {
                DatabasePlanItEventRecurrence().insertEvent(eventEntity, recurrence: recurrence, using: objectContext)
            }
            if let attendees = event["attendees"] as? [[String: Any]] {
                DatabasePlanItEventAttendees().insertAttendees(attendees, for: eventEntity, using: objectContext)
            }
            if let nonRegInvitees = event["nonRegInvitees"] as? [[String: Any]] {
                DatabasePlanItInvitees().insertEvent(eventEntity, other: nonRegInvitees, using: objectContext)
            }
            if let attachments = event["attachments"] as? [[String: Any]] {
                DatabasePlanItEventAttachment().insertAttachments(attachments, for: eventEntity, using: objectContext)
            }
            if let reminders = event["reminders"] as? [String: Any] {
                DataBasePlanItTodoReminders().insertEvent(eventEntity, reminders: reminders, using: objectContext)
            }
            else {
                eventEntity.deleteReminder(withHardSave: false)
            }
        }
    }
    
    func insertPlanItChildEvents(_ data: [[String: Any]], to parent: PlanItEvent, using context: NSManagedObjectContext? = nil) {
        let objectContext = context ?? self.mainObjectContext
        let localEvents = parent.readAllChildEvents()
        for event in data {
            let eventId = event["eventId"] as? Double ?? 0
            let appEventId = event["appEventId"] as? String ?? Strings.empty
            let eventEntity = localEvents.filter({ return $0.eventId == eventId  || ($0.appEventId == appEventId && !appEventId.isEmpty) }).first ?? self.insertNewRecords(Table.planItEvent, context: objectContext) as! PlanItEvent
            eventEntity.eventHidden = false
            eventEntity.parent = parent
            eventEntity.notifiedDate = nil
            eventEntity.isPending = false
            eventEntity.isRecurrence = false
            eventEntity.eventId = eventId
            eventEntity.appEventId = appEventId
            eventEntity.remindMe = LocalNotificationType.new.rawValue
            eventEntity.accessLevel = event["accessLevel"] as? Double ?? 0
            eventEntity.bodyContentType = event["bodyContentType"] as? String
            eventEntity.createdAt = event["createdAt"] as? String
            eventEntity.creatorEmail = event["creatorEmail"] as? String
            eventEntity.creatorName = event["creatorName"] as? String
            eventEntity.endDate = event["endDate"] as? String
            eventEntity.endTime = event["endTime"] as? String
            eventEntity.eventDescription = event["description"] as? String
            eventEntity.eventName = event["eventName"] as? String
            eventEntity.extCreatedDate = event["extCreatedDate"] as? String
            eventEntity.extEventId = event["extEventId"] as? String
            eventEntity.recurringEventId = event["recurringEventId"] as? String
            eventEntity.extUpdatedDate = event["extCreatedDate"] as? String
            eventEntity.htmlLink = event["htmlLink"] as? String
            eventEntity.isAllDay = event["isAllDay"] as? Bool ?? false
            eventEntity.isAvailable = event["availabilityFlag"] as? Double ?? 0
            eventEntity.location = event["location"] as? String
            eventEntity.modifiedAt = event["modifiedAt"] as? String
            eventEntity.organizerEmail = event["organizerEmail"] as? String
            eventEntity.organizerName = event["organizerName"] as? String
            eventEntity.originalStartDate = event["originalStartDate"] as? String
            eventEntity.originalStartTime = event["originalStartTime"] as? String
            eventEntity.originalStartTimeZone = event["originalStartTimeZone"] as? String
            eventEntity.originalEndTimeZone = event["originalEndTimeZone"] as? String
            eventEntity.reminderId = event["reminderId"] as? Double ?? 0
            eventEntity.startDate = event["startDate"] as? String
            eventEntity.startTime = event["startTime"] as? String
            eventEntity.status = event["eventStatus"] as? Double ?? 0
            eventEntity.isSocialEvent = event["isSocialEvent"] as? Bool ?? false
            eventEntity.user = parent.user ?? Strings.empty
            eventEntity.responseStatus = event["responseStatus"] as? String
            if let conferenceData = event["conferenceData"] as? [String: Any] {
                eventEntity.conferenceType = conferenceData["conferenceType"] as? String
                eventEntity.conferenceUrl = conferenceData["url"] as? String
                eventEntity.fullConferenceData = conferenceData["fullConferenceData"] as? String
            }
            if let date = event["originalStartDate"] as? String, let time = event["originalStartTime"] as? String {
                if let originalAllDay = event["isOriginalAllDay"] as? Bool, originalAllDay {
                    eventEntity.originalStartDateTime = (date + Strings.space + time).stringToDate(formatter: DateFormatters.MMDDYYYYHMMSSA)
                }
                else {
                    eventEntity.originalStartDateTime = (date + Strings.space + time).stringToDate(formatter: DateFormatters.MMDDYYYYHMMSSA, timeZone: TimeZone(abbreviation: "UTC")!)
                }
            }
            if let date = event["startDate"] as? String, let time = event["startTime"] as? String {
                if let allDay = event["isAllDay"] as? Bool, allDay {
                    let startDateTime = (date + Strings.space + time).stringToDate(formatter: DateFormatters.MMDDYYYYHMMSSA)
                    eventEntity.startDateTime = startDateTime
                    eventEntity.sortedTime = startDateTime?.stringFromDate(format:  DateFormatters.HHCMMCSSSA).stringToDate(formatter:  DateFormatters.HHCMMCSSSA)
                }
                else {
                    let startDateTime = (date + Strings.space + time).stringToDate(formatter: DateFormatters.MMDDYYYYHMMSSA, timeZone: TimeZone(abbreviation: "UTC")!)
                    eventEntity.startDateTime = startDateTime
                    eventEntity.sortedTime = startDateTime?.stringFromDate(format:  DateFormatters.HHCMMCSSSA).stringToDate(formatter:  DateFormatters.HHCMMCSSSA)
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
            if let calendars = event["calendar"] as? [[String: Any]] {
                DatabasePlanItEventCalendar().insertCalendarsToEvent(calendars, event: eventEntity, using: objectContext)
            }
            if let calendars = event["notifyCalendars"] as? [[String: Any]] {
                DatabasePlanItEventCalendar().insertNotifyCalendarsToEvent(calendars, event: eventEntity, using: objectContext)
            }
            else { eventEntity.deleteAllEventNotifyCalendars() }
            if let createdBy = event["createdBy"] as? [String: Any] {
                DatabasePlanItCreator().insertEvent(eventEntity, creator: createdBy, using: objectContext)
            }
            if let modifiedBy = event["modifiedBy"] as? [String: Any] {
                DatabasePlanItModifier().insertEvent(eventEntity, modifier: modifiedBy, using: objectContext)
            }
            if let invitees = event["invitees"] as? [[String: Any]] {
                DatabasePlanItInvitees().insertEvent(eventEntity, main: invitees, using: objectContext)
            }
            if let tags = event["tags"] as? [[String: String]] {
                let arrayTags = tags.compactMap({$0.values.first})
                if arrayTags.count > 0 {
                    DatabasePlanItTags().insertTags(arrayTags, for: eventEntity, using: objectContext)
                }
            }
            if let attendees = event["attendees"] as? [[String: Any]] {
                DatabasePlanItEventAttendees().insertAttendees(attendees, for: eventEntity, using: objectContext)
            }
            if let nonRegInvitees = event["nonRegInvitees"] as? [[String: Any]] {
                DatabasePlanItInvitees().insertEvent(eventEntity, other: nonRegInvitees, using: objectContext)
            }
            if let attachments = event["attachments"] as? [[String: Any]] {
                DatabasePlanItEventAttachment().insertAttachments(attachments, for: eventEntity, using: objectContext)
            }
            if let reminders = event["reminders"] as? [String: Any] {
                DataBasePlanItTodoReminders().insertEvent(eventEntity, reminders: reminders, using: objectContext)
            }
            else {
                eventEntity.deleteReminder(withHardSave: false)
            }
            if let masterEventId = event["movedPrEventId"] as? Double, masterEventId != 0 {
                self.removedPlantItEvent(eventId, from: masterEventId, using: objectContext)
            }
        }
    }
    
    @discardableResult func insertNewPlanItEvent(_ data: [[String: Any]], using context: NSManagedObjectContext? = nil, hardSave: Bool = false) -> [PlanItEvent] {
        let objectContext = context ?? self.mainObjectContext
        var addedEvents: [PlanItEvent] = []
        let eventIds = data.compactMap({ return $0["eventId"] as? Double })
        let appEventIds = data.compactMap({ return $0["appEventId"] as? String })
        let localEvents = self.readSpecificEvents(eventIds, appEventIds: appEventIds, using: objectContext)
        for event in data {
            let eventId = event["eventId"] as? Double ?? 0
            let appEventId = event["appEventId"] as? String ?? Strings.empty
            let eventEntity = localEvents.filter({ return $0.eventId == eventId  || ($0.appEventId == appEventId && !appEventId.isEmpty) }).first ?? self.insertNewRecords(Table.planItEvent, context: objectContext) as! PlanItEvent
            if eventEntity.isPending, let serverModifiedDate = (event["modifiedAt"] as? String)?.stringToDate(formatter: DateFormatters.MMDDYYYYHMMSSA, timeZone: TimeZone(abbreviation: "UTC")!), let localModifiedDate = eventEntity.modifiedAt?.stringToDate(formatter: DateFormatters.MMDDYYYYHMMSSA, timeZone: TimeZone(abbreviation: "UTC")!), serverModifiedDate < localModifiedDate {
                continue
            }
            eventEntity.eventHidden = false
            eventEntity.notifiedDate = nil
            eventEntity.isPending = false
            eventEntity.isRecurrence = false
            eventEntity.eventId = eventId
            eventEntity.appEventId = appEventId
            eventEntity.remindMe = LocalNotificationType.new.rawValue
            eventEntity.accessLevel = event["accessLevel"] as? Double ?? 0
            eventEntity.bodyContentType = event["bodyContentType"] as? String
            eventEntity.createdAt = event["createdAt"] as? String
            eventEntity.creatorEmail = event["creatorEmail"] as? String
            eventEntity.creatorName = event["creatorName"] as? String
            eventEntity.endDate = event["endDate"] as? String
            eventEntity.endTime = event["endTime"] as? String
            eventEntity.eventDescription = event["description"] as? String
            eventEntity.eventName = event["eventName"] as? String
            eventEntity.extCreatedDate = event["extCreatedDate"] as? String
            eventEntity.extEventId = event["extEventId"] as? String
            eventEntity.recurringEventId = event["recurringEventId"] as? String
            eventEntity.extUpdatedDate = event["extUpdatedDate"] as? String
            eventEntity.htmlLink = event["htmlLink"] as? String
            eventEntity.isAllDay = event["isAllDay"] as? Bool ?? false
            eventEntity.isAvailable = event["availabilityFlag"] as? Double ?? 0
            eventEntity.location = event["location"] as? String
            eventEntity.modifiedAt = event["modifiedAt"] as? String
            eventEntity.organizerEmail = event["organizerEmail"] as? String
            eventEntity.organizerName = event["organizerName"] as? String
            eventEntity.originalStartDate = event["originalStartDate"] as? String
            eventEntity.originalStartTime = event["originalStartTime"] as? String
            eventEntity.originalStartTimeZone = event["originalStartTimeZone"] as? String
            eventEntity.originalEndTimeZone = event["originalEndTimeZone"] as? String
            eventEntity.reminderId = event["reminderId"] as? Double ?? 0
            eventEntity.startDate = event["startDate"] as? String
            eventEntity.startTime = event["startTime"] as? String
            eventEntity.status = event["eventStatus"] as? Double ?? 0
            eventEntity.isSocialEvent = event["isSocialEvent"] as? Bool ?? false
            if let conferenceData = event["conferenceData"] as? [String: Any] {
                eventEntity.conferenceType = conferenceData["conferenceType"] as? String
                eventEntity.conferenceUrl = conferenceData["url"] as? String
                eventEntity.fullConferenceData = conferenceData["fullConferenceData"] as? String
            }
            eventEntity.user = Session.shared.readUserId()
            if let date = event["originalStartDate"] as? String, let time = event["originalStartTime"] as? String {
                eventEntity.originalStartDateTime = (date + Strings.space + time).stringToDate(formatter: DateFormatters.MMDDYYYYHMMSSA, timeZone: TimeZone(abbreviation: "UTC")!)
            }
            if let date = event["startDate"] as? String, let time = event["startTime"] as? String {
                if let allDay = event["isAllDay"] as? Bool, allDay {
                    let startDateTime = (date + Strings.space + time).stringToDate(formatter: DateFormatters.MMDDYYYYHMMSSA)
                    eventEntity.startDateTime = startDateTime
                    eventEntity.sortedTime = startDateTime?.stringFromDate(format:  DateFormatters.HHCMMCSSSA).stringToDate(formatter:  DateFormatters.HHCMMCSSSA)
                }
                else {
                    let startDateTime = (date + Strings.space + time).stringToDate(formatter: DateFormatters.MMDDYYYYHMMSSA, timeZone: TimeZone(abbreviation: "UTC")!)
                    eventEntity.startDateTime = startDateTime
                    eventEntity.sortedTime = startDateTime?.stringFromDate(format:  DateFormatters.HHCMMCSSSA).stringToDate(formatter:  DateFormatters.HHCMMCSSSA)
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
            if let subEvents = event["child"] as? [[String: Any]] {
                self.insertPlanItChildEvents(subEvents, to: eventEntity, using: objectContext)
            }
            if let calendars = event["calendar"] as? [[String: Any]] {
                DatabasePlanItEventCalendar().insertCalendarsToEvent(calendars, event: eventEntity, using: objectContext)
            }
            if let calendars = event["notifyCalendars"] as? [[String: Any]] {
                DatabasePlanItEventCalendar().insertNotifyCalendarsToEvent(calendars, event: eventEntity, using: objectContext)
            }
            else { eventEntity.deleteAllEventNotifyCalendars() }
            if let createdBy = event["createdBy"] as? [String: Any] {
                DatabasePlanItCreator().insertEvent(eventEntity, creator: createdBy, using: objectContext)
            }
            if let modifiedBy = event["modifiedBy"] as? [String: Any] {
                DatabasePlanItModifier().insertEvent(eventEntity, modifier: modifiedBy, using: objectContext)
            }
            if let invitees = event["invitees"] as? [[String: Any]] {
                DatabasePlanItInvitees().insertEvent(eventEntity, main: invitees, using: objectContext)
            }
            if let attendees = event["attendees"] as? [[String: Any]] {
                DatabasePlanItEventAttendees().insertAttendees(attendees, for: eventEntity, using: objectContext)
            }
            if let nonRegInvitees = event["nonRegInvitees"] as? [[String: Any]] {
                DatabasePlanItInvitees().insertEvent(eventEntity, other: nonRegInvitees, using: objectContext)
            }
            if let recurrence = event["recurrence"] as? [String], let rule = recurrence.filter({ $0.hasPrefix("RRULE") }).first {
                DatabasePlanItEventRecurrence().insertEvent(eventEntity, recurrence: rule, using: objectContext)
            }
            if let recurrence = event["recurrence"] as? [String: Any] {
                DatabasePlanItEventRecurrence().insertEvent(eventEntity, recurrence: recurrence, using: objectContext)
            }
            if let reminders = event["reminders"] as? [String: Any] {
                DataBasePlanItTodoReminders().insertEvent(eventEntity, reminders: reminders, using: objectContext)
            }
            else {
                eventEntity.deleteReminder(withHardSave: false)
            }
            if let tags = event["tags"] as? [[String: String]] {
                let arrayTags = tags.compactMap({$0.values.first})
                DatabasePlanItTags().insertTags(arrayTags, for: eventEntity, using: objectContext)
            }
            addedEvents.append(eventEntity)
        }
        if hardSave { objectContext.saveContext() }
        return addedEvents
    }
    
    func insertPlanItEventsFromNotification(_ data: [[String: Any]], using context: NSManagedObjectContext? = nil) {
        let objectContext = context ?? self.mainObjectContext
        let eventIds = data.compactMap({ return $0["eventId"] as? Double })
        let appEventIds = data.compactMap({ return $0["appEventId"] as? String })
        let localEvents = DatabasePlanItEvent().readSpecificEvents(eventIds, appEventIds: appEventIds, using: objectContext)
        for event in data {
            let eventId = event["eventId"] as? Double ?? 0
            let appEventId = event["appEventId"] as? String ?? Strings.empty
            if let eventEntity = localEvents.filter({ return $0.eventId == eventId  || ($0.appEventId == appEventId && !appEventId.isEmpty) }).first {
                if let masterEventId = event["movedPrEventId"] as? Double, masterEventId != 0, masterEventId == eventEntity.parent?.eventId {
                    self.removedPlantItEvent(eventId, from: masterEventId, using: objectContext)
                    self.insertNewEventFromNotification(event, using: objectContext)
                }
                else {
                    self.updatePlanItEvent(eventEntity, notification: event, using: objectContext)
                }
            }
            else {
                self.insertNewEventFromNotification(event, using: objectContext)
            }
        }
    }
    
    func insertNewEventFromNotification(_ event: [String: Any], using objectContext: NSManagedObjectContext) {
        if let recurringEventId = event["recurringEventId"] as? String, !recurringEventId.isEmpty {
            let eventId = Double(recurringEventId) ?? 0
            if let parentEvent = self.readSpecificEvent(eventId, socialId: recurringEventId, using: objectContext).first {
                self.insertNewChildEventFromNotification(event, to: parentEvent, using: objectContext)
            }
            else {
                DatabasePlanItSilentEvent().insertNewChildEventFromNotification(event, using: objectContext)
            }
        }
        else {
            self.insertNewParentEventFromNotification(event, using: objectContext)
        }
    }
    
    func insertNewParentEventFromNotification(_ event: [String: Any], using objectContext: NSManagedObjectContext) {
        let eventId = event["eventId"] as? Double ?? 0
        let appEventId = event["appEventId"] as? String ?? Strings.empty
        let eventEntity = self.insertNewRecords(Table.planItEvent, context: objectContext) as! PlanItEvent
        eventEntity.eventHidden = true
        eventEntity.notifiedDate = nil
        eventEntity.isPending = false
        eventEntity.isRecurrence = false
        eventEntity.eventId = eventId
        eventEntity.appEventId = appEventId
        eventEntity.remindMe = LocalNotificationType.new.rawValue
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
        eventEntity.responseStatus = event["responseStatus"] as? String
        if let date = event["originalStartDate"] as? String, let time = event["originalStartTime"] as? String {
            eventEntity.originalStartDateTime = (date + Strings.space + time).stringToDate(formatter: DateFormatters.MMDDYYYYHMMSSA, timeZone: TimeZone(abbreviation: "UTC")!)
        }
        if let date = event["startDate"] as? String, let time = event["startTime"] as? String {
            if let allDay = event["isAllDay"] as? Bool, allDay {
                let startDateTime = (date + Strings.space + time).stringToDate(formatter: DateFormatters.MMDDYYYYHMMSSA)
                eventEntity.startDateTime = startDateTime
                eventEntity.sortedTime = startDateTime?.stringFromDate(format:  DateFormatters.HHCMMCSSSA).stringToDate(formatter:  DateFormatters.HHCMMCSSSA)
            }
            else {
                let startDateTime = (date + Strings.space + time).stringToDate(formatter: DateFormatters.MMDDYYYYHMMSSA, timeZone: TimeZone(abbreviation: "UTC")!)
                eventEntity.startDateTime = startDateTime
                eventEntity.sortedTime = startDateTime?.stringFromDate(format:  DateFormatters.HHCMMCSSSA).stringToDate(formatter:  DateFormatters.HHCMMCSSSA)
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
            DatabasePlanItEventRecurrence().insertEvent(eventEntity, recurrence: rule, using: objectContext)
        }
        if let recurrence = event["recurrence"] as? [String: Any] {
            DatabasePlanItEventRecurrence().insertEvent(eventEntity, recurrence: recurrence, using: objectContext)
        }
        if let reminders = event["reminders"] as? [String: Any] {
            DataBasePlanItTodoReminders().insertEvent(eventEntity, reminders: reminders, using: objectContext)
        }
        else {
            eventEntity.deleteReminder(withHardSave: false)
        }
        self.moveSilentChildsEventsToParent(eventEntity, using: objectContext)
    }
    
    func moveSilentChildsEventsToParent(_ parent: PlanItEvent, using objectContext: NSManagedObjectContext) {
        let silentChildEvents = DatabasePlanItSilentEvent().readSilentChildEventsUsingEventId(parent.readValueOfEventId(), socialId: parent.readValueOfSocialEventId(), using: objectContext)
        let localEvents = parent.readAllChildEvents()
        for event in silentChildEvents {
            let appEventId = event.appEventId ?? Strings.empty
            if let _ = localEvents.filter({ return $0.eventId == event.eventId || ($0.appEventId == appEventId && !appEventId.isEmpty) }).first { event.deleteItSelf(withHardSave: false); continue }
            let eventEntity = self.insertNewRecords(Table.planItEvent, context: objectContext) as! PlanItEvent
            eventEntity.eventHidden = true
            eventEntity.parent = parent
            eventEntity.notifiedDate = nil
            eventEntity.isPending = false
            eventEntity.isRecurrence = false
            eventEntity.eventId = event.eventId
            eventEntity.appEventId = event.appEventId
            eventEntity.remindMe = LocalNotificationType.new.rawValue
            eventEntity.creatorName = event.eventName
            eventEntity.endDate = event.endDate
            eventEntity.endTime = event.endTime
            eventEntity.eventName = event.eventName
            eventEntity.extEventId = event.extEventId
            eventEntity.recurringEventId = event.recurringEventId
            eventEntity.isAllDay = event.isAllDay
            eventEntity.location = event.location
            eventEntity.originalStartDate = event.originalStartDate
            eventEntity.originalStartTime = event.originalStartTime
            eventEntity.originalStartTimeZone = event.originalStartTimeZone
            eventEntity.originalEndTimeZone = event.originalEndTimeZone
            eventEntity.reminderId = event.reminderId
            eventEntity.startDate = event.startDate
            eventEntity.startTime = event.startTime
            eventEntity.status = event.status
            eventEntity.user = parent.user ?? Strings.empty
            eventEntity.responseStatus = event.responseStatus
            eventEntity.originalStartDateTime = event.originalStartDateTime
            eventEntity.startDateTime = event.startDateTime
            eventEntity.endDateTime = event.endDateTime
            if let reminders = event.readReminders() {
                DataBasePlanItTodoReminders().insertEvent(eventEntity, reminders: reminders, using: objectContext)
            }
            event.deleteItSelf(withHardSave: false)
        }
    }
    
    func insertNewChildEventFromNotification(_ event: [String: Any], to parent: PlanItEvent, using objectContext: NSManagedObjectContext) {
        let eventId = event["eventId"] as? Double ?? 0
        let appEventId = event["appEventId"] as? String ?? Strings.empty
        let localEvents = parent.readAllChildEvents()
        if let _ = localEvents.filter({ return $0.eventId == eventId  || ($0.appEventId == appEventId && !appEventId.isEmpty) }).first { return }
        let eventEntity = self.insertNewRecords(Table.planItEvent, context: objectContext) as! PlanItEvent
        eventEntity.parent = parent
        eventEntity.eventHidden = true
        eventEntity.notifiedDate = nil
        eventEntity.isPending = false
        eventEntity.isRecurrence = false
        eventEntity.eventId = eventId
        eventEntity.appEventId = appEventId
        eventEntity.remindMe = LocalNotificationType.new.rawValue
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
        eventEntity.user = parent.user ?? Strings.empty
        eventEntity.responseStatus = event["responseStatus"] as? String
        if let date = event["originalStartDate"] as? String, let time = event["originalStartTime"] as? String {
            eventEntity.originalStartDateTime = (date + Strings.space + time).stringToDate(formatter: DateFormatters.MMDDYYYYHMMSSA, timeZone: TimeZone(abbreviation: "UTC")!)
        }
        if let date = event["startDate"] as? String, let time = event["startTime"] as? String {
            if let allDay = event["isAllDay"] as? Bool, allDay {
                let startDateTime = (date + Strings.space + time).stringToDate(formatter: DateFormatters.MMDDYYYYHMMSSA)
                eventEntity.startDateTime = startDateTime
                eventEntity.sortedTime = startDateTime?.stringFromDate(format:  DateFormatters.HHCMMCSSSA).stringToDate(formatter:  DateFormatters.HHCMMCSSSA)
            }
            else {
                let startDateTime = (date + Strings.space + time).stringToDate(formatter: DateFormatters.MMDDYYYYHMMSSA, timeZone: TimeZone(abbreviation: "UTC")!)
                eventEntity.startDateTime = startDateTime
                eventEntity.sortedTime = startDateTime?.stringFromDate(format:  DateFormatters.HHCMMCSSSA).stringToDate(formatter:  DateFormatters.HHCMMCSSSA)
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
            DatabasePlanItEventRecurrence().insertEvent(eventEntity, recurrence: rule, using: objectContext)
        }
        if let recurrence = event["recurrence"] as? [String: Any] {
            DatabasePlanItEventRecurrence().insertEvent(eventEntity, recurrence: recurrence, using: objectContext)
        }
        if let reminders = event["reminders"] as? [String: Any] {
            DataBasePlanItTodoReminders().insertEvent(eventEntity, reminders: reminders, using: objectContext)
        }
        else {
            eventEntity.deleteReminder(withHardSave: false)
        }
    }
    
    func updatePlanItEvent(_ eventEntity: PlanItEvent, notification event: [String: Any], using objectContext: NSManagedObjectContext) {
        eventEntity.notifiedDate = nil
        eventEntity.isPending = false
        eventEntity.isRecurrence = false
        eventEntity.remindMe = LocalNotificationType.new.rawValue
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
        eventEntity.responseStatus = event["responseStatus"] as? String
        if let date = event["originalStartDate"] as? String, let time = event["originalStartTime"] as? String {
            if let originalAllDay = event["isOriginalAllDay"] as? Bool, originalAllDay {
                eventEntity.originalStartDateTime = (date + Strings.space + time).stringToDate(formatter: DateFormatters.MMDDYYYYHMMSSA)
            }
            else {
                eventEntity.originalStartDateTime = (date + Strings.space + time).stringToDate(formatter: DateFormatters.MMDDYYYYHMMSSA, timeZone: TimeZone(abbreviation: "UTC")!)
            }
        }
        if let date = event["startDate"] as? String, let time = event["startTime"] as? String {
            if let allDay = event["isAllDay"] as? Bool, allDay {
                let startDateTime = (date + Strings.space + time).stringToDate(formatter: DateFormatters.MMDDYYYYHMMSSA)
                eventEntity.startDateTime = startDateTime
                eventEntity.sortedTime = startDateTime?.stringFromDate(format:  DateFormatters.HHCMMCSSSA).stringToDate(formatter:  DateFormatters.HHCMMCSSSA)
            }
            else {
                let startDateTime = (date + Strings.space + time).stringToDate(formatter: DateFormatters.MMDDYYYYHMMSSA, timeZone: TimeZone(abbreviation: "UTC")!)
                eventEntity.startDateTime = startDateTime
                eventEntity.sortedTime = startDateTime?.stringFromDate(format:  DateFormatters.HHCMMCSSSA).stringToDate(formatter:  DateFormatters.HHCMMCSSSA)
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
            DatabasePlanItEventRecurrence().insertEvent(eventEntity, recurrence: rule, using: objectContext)
        }
        if let recurrence = event["recurrence"] as? [String: Any] {
            DatabasePlanItEventRecurrence().insertEvent(eventEntity, recurrence: recurrence, using: objectContext)
        }
        if let reminders = event["reminders"] as? [String: Any] {
            DataBasePlanItTodoReminders().insertEvent(eventEntity, reminders: reminders, using: objectContext)
        }
        else {
            eventEntity.deleteReminder(withHardSave: false)
        }
    }
    
    @discardableResult func insertNewOfflinePlanItEvent(_ event: MiPlanItEvent, using context: NSManagedObjectContext? = nil) -> ([PlanItEvent], [String]) {
        let objectContext = context ?? self.mainObjectContext
        defer { objectContext.saveContext() }
        switch event.editType {
        case .default:
            return self.insertNewDefaultOfflinePlanItEvent(event, using: objectContext)
        case .thisPerticularEvent:
            return self.insertNewParticularOfflinePlanItEvent(event, using: objectContext)
        case .allEventInTheSeries:
            return self.insertNewAllOfflinePlanItEvent(event, using: objectContext)
        case .allFutureEvent:
            return self.insertNewFutureOfflinePlanItEvent(event, using: objectContext)
        }
    }
    
    func insertNewDefaultOfflinePlanItEvent(_ event: MiPlanItEvent, using context: NSManagedObjectContext? = nil) -> ([PlanItEvent], [String]) {
        let objectContext = context ?? self.mainObjectContext
        let eventEntity = event.event ?? self.insertNewRecords(Table.planItEvent, context: objectContext) as! PlanItEvent
        eventEntity.notifiedDate = nil
        eventEntity.isPending = true
        eventEntity.isRecurrence = false
        eventEntity.remindMe = LocalNotificationType.new.rawValue
        eventEntity.accessLevel = 1
        eventEntity.createdAt = Date().stringFromDate(format: DateFormatters.MMDDYYYYHMMSSA, timeZone: TimeZone(abbreviation: "UTC")!)
        eventEntity.modifiedAt = Date().stringFromDate(format: DateFormatters.MMDDYYYYHMMSSA, timeZone: TimeZone(abbreviation: "UTC")!)
        eventEntity.creatorEmail = Session.shared.readUser()?.readValueOfEmail()
        eventEntity.creatorName = Session.shared.readUser()?.readValueOfName()
        eventEntity.eventDescription = event.eventDescription
        if eventEntity.readValueOfAppEventId().isEmpty { eventEntity.appEventId = UUID().uuidString }
        eventEntity.eventName = event.eventName
        eventEntity.recurringEventId = event.recurringEventId
        eventEntity.isAllDay = event.isAllday
        eventEntity.location = event.location
        eventEntity.status = 0
        eventEntity.isAvailable = event.isTravelling ? 1 : 0
        eventEntity.user = Session.shared.readUserId()
        eventEntity.originalStartTimeZone = TimeZone.current.identifier
        eventEntity.originalEndTimeZone = TimeZone.current.identifier
        if event.isAllday {
            let initialStartTime = event.startDate.initialHour()
            let initialEndTime = event.endDate.initialHour()
            eventEntity.endDate = initialEndTime.stringFromDate(format: DateFormatters.MMDDYYYY)
            eventEntity.endTime = initialEndTime.stringFromDate(format: DateFormatters.HHCMMCSSSA)
            eventEntity.startDate = initialStartTime.stringFromDate(format: DateFormatters.MMDDYYYY)
            eventEntity.startTime = initialStartTime.stringFromDate(format: DateFormatters.HHCMMCSSSA)
            eventEntity.startDateTime = initialStartTime
            eventEntity.endDateTime = initialEndTime
            eventEntity.sortedTime = initialStartTime.stringFromDate(format:  DateFormatters.HHCMMCSSSA).stringToDate(formatter:  DateFormatters.HHCMMCSSSA)
        }
        else {
            eventEntity.endDate = event.endDate.stringFromDate(format: DateFormatters.MMDDYYYY, timeZone: TimeZone(abbreviation: "UTC")!)
            eventEntity.endTime = event.endDate.stringFromDate(format: DateFormatters.HHCMMCSSSA, timeZone: TimeZone(abbreviation: "UTC")!)
            eventEntity.startDate = event.startDate.stringFromDate(format: DateFormatters.MMDDYYYY, timeZone: TimeZone(abbreviation: "UTC")!)
            eventEntity.startTime = event.startDate.stringFromDate(format: DateFormatters.HHCMMCSSSA, timeZone: TimeZone(abbreviation: "UTC")!)
            eventEntity.startDateTime = event.startDate.stringFromDate(format:  DateFormatters.MMDDYYYYHMMSSA, timeZone: TimeZone(abbreviation: "UTC")!).stringToDate(formatter:  DateFormatters.MMDDYYYYHMMSSA, timeZone: TimeZone(abbreviation: "UTC")!)
            eventEntity.endDateTime = event.endDate.stringFromDate(format:  DateFormatters.MMDDYYYYHMMSSA, timeZone: TimeZone(abbreviation: "UTC")!).stringToDate(formatter:  DateFormatters.MMDDYYYYHMMSSA, timeZone: TimeZone(abbreviation: "UTC")!)
            eventEntity.sortedTime = event.startDate.stringFromDate(format:  DateFormatters.HHCMMCSSSA, timeZone: TimeZone(abbreviation: "UTC")!).stringToDate(formatter:  DateFormatters.HHCMMCSSSA, timeZone: TimeZone(abbreviation: "UTC")!)
        }
        DatabasePlanItEventCalendar().insertCalendarsToEvent(event.calendars, event: eventEntity, using: objectContext)
        if !event.notifycalendars.isEmpty {
            DatabasePlanItEventCalendar().insertNotifyCalendarsToEvent(event.notifycalendars, event: eventEntity, using: objectContext)
        }
        else {
            eventEntity.deleteAllEventNotifyCalendars()
        }
        DatabasePlanItTags().insertTags(event.tags, for: eventEntity, using: objectContext)
        DatabasePlanItCreator().insertEvent(eventEntity, creator: Session.shared.readUser(), using: objectContext)
        DatabasePlanItModifier().insertEvent(eventEntity, modifier: Session.shared.readUser(), using: objectContext)
        DatabasePlanItInvitees().insertEvent(eventEntity, other: event.invitees, using: objectContext)
        if !event.recurrence.isEmpty {
            DatabasePlanItEventRecurrence().insertEvent(eventEntity, recurrence: event.recurrence, using: objectContext)
        }
        if let reminders = event.remindValue {
            DataBasePlanItTodoReminders().insertEvent(eventEntity, reminders: reminders, using: objectContext)
        }
        else {
            eventEntity.deleteReminder(withHardSave: false)
        }
        return ([eventEntity], [])
    }
    
    func insertNewParticularOfflinePlanItEvent(_ event: MiPlanItEvent, using context: NSManagedObjectContext? = nil) -> ([PlanItEvent], [String]) {
        let objectContext = context ?? self.mainObjectContext
        let eventEntity = self.insertNewRecords(Table.planItEvent, context: objectContext) as! PlanItEvent
        eventEntity.parent = event.parent
        eventEntity.notifiedDate = nil
        eventEntity.isPending = true
        eventEntity.isRecurrence = false
        eventEntity.remindMe = LocalNotificationType.new.rawValue
        eventEntity.accessLevel = 1
        eventEntity.createdAt = Date().stringFromDate(format: DateFormatters.MMDDYYYYHMMSSA, timeZone: TimeZone(abbreviation: "UTC")!)
        eventEntity.modifiedAt = Date().stringFromDate(format: DateFormatters.MMDDYYYYHMMSSA, timeZone: TimeZone(abbreviation: "UTC")!)
        eventEntity.creatorEmail = Session.shared.readUser()?.readValueOfEmail()
        eventEntity.creatorName = Session.shared.readUser()?.readValueOfName()
        eventEntity.eventDescription = event.eventDescription
        if eventEntity.readValueOfAppEventId().isEmpty { eventEntity.appEventId = UUID().uuidString }
        eventEntity.eventName = event.eventName
        eventEntity.recurringEventId = event.parent?.readValueOfEventId()
        eventEntity.isAllDay = event.isAllday
        eventEntity.location = event.location
        eventEntity.status = 0
        eventEntity.isAvailable = event.isTravelling ? 1 : 0
        eventEntity.user = Session.shared.readUserId()
        eventEntity.originalStartTimeZone = TimeZone.current.identifier
        eventEntity.originalEndTimeZone = TimeZone.current.identifier
        if event.isAllday {
            let initialStartTime = event.startDate.initialHour()
            let initialEndTime = event.endDate.initialHour()
            eventEntity.endDate = initialEndTime.stringFromDate(format: DateFormatters.MMDDYYYY)
            eventEntity.endTime = initialEndTime.stringFromDate(format: DateFormatters.HHCMMCSSSA)
            eventEntity.startDate = initialStartTime.stringFromDate(format: DateFormatters.MMDDYYYY)
            eventEntity.startTime = initialStartTime.stringFromDate(format: DateFormatters.HHCMMCSSSA)
            eventEntity.startDateTime = initialStartTime
            eventEntity.endDateTime = initialEndTime
            eventEntity.sortedTime = initialStartTime.stringFromDate(format:  DateFormatters.HHCMMCSSSA).stringToDate(formatter:  DateFormatters.HHCMMCSSSA)
        }
        else {
            eventEntity.endDate = event.endDate.stringFromDate(format: DateFormatters.MMDDYYYY, timeZone: TimeZone(abbreviation: "UTC")!)
            eventEntity.endTime = event.endDate.stringFromDate(format: DateFormatters.HHCMMCSSSA, timeZone: TimeZone(abbreviation: "UTC")!)
            eventEntity.startDate = event.startDate.stringFromDate(format: DateFormatters.MMDDYYYY, timeZone: TimeZone(abbreviation: "UTC")!)
            eventEntity.startTime = event.startDate.stringFromDate(format: DateFormatters.HHCMMCSSSA, timeZone: TimeZone(abbreviation: "UTC")!)
            eventEntity.startDateTime = event.startDate.stringFromDate(format:  DateFormatters.MMDDYYYYHMMSSA, timeZone: TimeZone(abbreviation: "UTC")!).stringToDate(formatter:  DateFormatters.MMDDYYYYHMMSSA, timeZone: TimeZone(abbreviation: "UTC")!)
            eventEntity.endDateTime = event.endDate.stringFromDate(format:  DateFormatters.MMDDYYYYHMMSSA, timeZone: TimeZone(abbreviation: "UTC")!).stringToDate(formatter:  DateFormatters.MMDDYYYYHMMSSA, timeZone: TimeZone(abbreviation: "UTC")!)
            eventEntity.sortedTime = event.startDate.stringFromDate(format:  DateFormatters.HHCMMCSSSA, timeZone: TimeZone(abbreviation: "UTC")!).stringToDate(formatter:  DateFormatters.HHCMMCSSSA, timeZone: TimeZone(abbreviation: "UTC")!)
        }
        if let parent = event.parent, parent.isAllDay {
            eventEntity.originalStartDateTime = event.readOrginalStartDateTime()
        }
        else {
            eventEntity.originalStartDateTime = event.readOrginalStartDateTime().stringFromDate(format:  DateFormatters.MMDDYYYYHMMSSA, timeZone: TimeZone(abbreviation: "UTC")!).stringToDate(formatter: DateFormatters.MMDDYYYYHMMSSA, timeZone: TimeZone(abbreviation: "UTC")!)
        }
        DatabasePlanItEventCalendar().insertCalendarsToEvent(event.calendars, event: eventEntity, using: objectContext)
        if !event.notifycalendars.isEmpty {
            DatabasePlanItEventCalendar().insertNotifyCalendarsToEvent(event.notifycalendars, event: eventEntity, using: objectContext)
        }
        else {
            eventEntity.deleteAllEventNotifyCalendars()
        }
        DatabasePlanItTags().insertTags(event.tags, for: eventEntity, using: objectContext)
        DatabasePlanItCreator().insertEvent(eventEntity, creator: Session.shared.readUser(), using: objectContext)
        DatabasePlanItModifier().insertEvent(eventEntity, modifier: Session.shared.readUser(), using: objectContext)
        DatabasePlanItInvitees().insertEvent(eventEntity, other: event.invitees, using: objectContext)
        if !event.recurrence.isEmpty {
            DatabasePlanItEventRecurrence().insertEvent(eventEntity, recurrence: event.recurrence, using: objectContext)
        }
        if let reminders = event.remindValue {
            DataBasePlanItTodoReminders().insertEvent(eventEntity, reminders: reminders, using: objectContext)
        }
        else {
            eventEntity.deleteReminder(withHardSave: false)
        }
        if let parent = eventEntity.parent {
            return ([parent], [])
        }
        return ([], [])
    }
    
    func insertNewAllOfflinePlanItEvent(_ event: MiPlanItEvent, using context: NSManagedObjectContext? = nil) -> ([PlanItEvent], [String]) {
        let objectContext = context ?? self.mainObjectContext
        let deletedEvents = event.event?.deleteAllChildEvents(with: .allEventInTheSeries)
        let eventEntity = event.event ?? self.insertNewRecords(Table.planItEvent, context: objectContext) as! PlanItEvent
        eventEntity.notifiedDate = nil
        eventEntity.isPending = true
        eventEntity.isRecurrence = false
        eventEntity.remindMe = LocalNotificationType.new.rawValue
        eventEntity.accessLevel = 1
        eventEntity.createdAt = Date().stringFromDate(format: DateFormatters.MMDDYYYYHMMSSA, timeZone: TimeZone(abbreviation: "UTC")!)
        eventEntity.modifiedAt = Date().stringFromDate(format: DateFormatters.MMDDYYYYHMMSSA, timeZone: TimeZone(abbreviation: "UTC")!)
        eventEntity.creatorEmail = Session.shared.readUser()?.readValueOfEmail()
        eventEntity.creatorName = Session.shared.readUser()?.readValueOfName()
        eventEntity.eventDescription = event.eventDescription
        if eventEntity.readValueOfAppEventId().isEmpty { eventEntity.appEventId = UUID().uuidString }
        eventEntity.eventName = event.eventName
        eventEntity.recurringEventId = event.recurringEventId
        eventEntity.isAllDay = event.isAllday
        eventEntity.location = event.location
        eventEntity.status = 0
        eventEntity.isAvailable = event.isTravelling ? 1 : 0
        eventEntity.user = Session.shared.readUserId()
        eventEntity.originalStartTimeZone = TimeZone.current.identifier
        eventEntity.originalEndTimeZone = TimeZone.current.identifier
        if event.isAllday {
            let initialStartTime = event.startDate.initialHour()
            let initialEndTime = event.endDate.initialHour()
            eventEntity.endDate = initialEndTime.stringFromDate(format: DateFormatters.MMDDYYYY)
            eventEntity.endTime = initialEndTime.stringFromDate(format: DateFormatters.HHCMMCSSSA)
            eventEntity.startDate = initialStartTime.stringFromDate(format: DateFormatters.MMDDYYYY)
            eventEntity.startTime = initialStartTime.stringFromDate(format: DateFormatters.HHCMMCSSSA)
            eventEntity.startDateTime = initialStartTime
            eventEntity.endDateTime = initialEndTime
            eventEntity.sortedTime = initialStartTime.stringFromDate(format:  DateFormatters.HHCMMCSSSA).stringToDate(formatter:  DateFormatters.HHCMMCSSSA)
        }
        else {
            eventEntity.endDate = event.endDate.stringFromDate(format: DateFormatters.MMDDYYYY, timeZone: TimeZone(abbreviation: "UTC")!)
            eventEntity.endTime = event.endDate.stringFromDate(format: DateFormatters.HHCMMCSSSA, timeZone: TimeZone(abbreviation: "UTC")!)
            eventEntity.startDate = event.startDate.stringFromDate(format: DateFormatters.MMDDYYYY, timeZone: TimeZone(abbreviation: "UTC")!)
            eventEntity.startTime = event.startDate.stringFromDate(format: DateFormatters.HHCMMCSSSA, timeZone: TimeZone(abbreviation: "UTC")!)
            eventEntity.startDateTime = event.startDate.stringFromDate(format:  DateFormatters.MMDDYYYYHMMSSA, timeZone: TimeZone(abbreviation: "UTC")!).stringToDate(formatter:  DateFormatters.MMDDYYYYHMMSSA, timeZone: TimeZone(abbreviation: "UTC")!)
            eventEntity.endDateTime = event.endDate.stringFromDate(format:  DateFormatters.MMDDYYYYHMMSSA, timeZone: TimeZone(abbreviation: "UTC")!).stringToDate(formatter:  DateFormatters.MMDDYYYYHMMSSA, timeZone: TimeZone(abbreviation: "UTC")!)
            eventEntity.sortedTime = event.startDate.stringFromDate(format:  DateFormatters.HHCMMCSSSA, timeZone: TimeZone(abbreviation: "UTC")!).stringToDate(formatter:  DateFormatters.HHCMMCSSSA, timeZone: TimeZone(abbreviation: "UTC")!)
        }
        DatabasePlanItEventCalendar().insertCalendarsToEvent(event.calendars, event: eventEntity, using: objectContext)
        if !event.notifycalendars.isEmpty {
            DatabasePlanItEventCalendar().insertNotifyCalendarsToEvent(event.notifycalendars, event: eventEntity, using: objectContext)
        }
        else {
            eventEntity.deleteAllEventNotifyCalendars()
        }
        DatabasePlanItTags().insertTags(event.tags, for: eventEntity, using: objectContext)
        DatabasePlanItCreator().insertEvent(eventEntity, creator: Session.shared.readUser(), using: objectContext)
        DatabasePlanItModifier().insertEvent(eventEntity, modifier: Session.shared.readUser(), using: objectContext)
        DatabasePlanItInvitees().insertEvent(eventEntity, other: event.invitees, using: objectContext)
        if !event.recurrence.isEmpty {
            DatabasePlanItEventRecurrence().insertEvent(eventEntity, recurrence: event.recurrence, using: objectContext)
        }
        if let reminders = event.remindValue {
            DataBasePlanItTodoReminders().insertEvent(eventEntity, reminders: reminders, using: objectContext)
        }
        else {
            eventEntity.deleteReminder(withHardSave: false)
        }
        return ([eventEntity], deletedEvents ?? [])
    }
    
    func insertNewFutureOfflinePlanItEvent(_ event: MiPlanItEvent, using context: NSManagedObjectContext? = nil) -> ([PlanItEvent], [String]) {
        let objectContext = context ?? self.mainObjectContext
        var allEvents: [PlanItEvent] = []
        var deletedEvents: [String] = []
        if let parent =  event.parent, let recurrence = parent.readPlanItRecurrance(), var recurrenceRule = RecurrenceRule(rruleString: recurrence.readRule()) {
            recurrenceRule.recurrenceEnd = EKRecurrenceEnd(end: event.readOrginalStartDateTime().initialHour().adding(minutes: -1))
            recurrenceRule.startDate = parent.readStartDateTime()
            DatabasePlanItEventRecurrence().insertEvent(parent, recurrence: recurrenceRule.toRRuleString(), using: objectContext)
            deletedEvents = parent.deleteAllChildEvents(with: .allFutureEvent)
            parent.isPending = true
            allEvents.append(parent)
        }
        let eventEntity = self.insertNewRecords(Table.planItEvent, context: objectContext) as! PlanItEvent
        allEvents.append(eventEntity)
        eventEntity.notifiedDate = nil
        eventEntity.isPending = true
        eventEntity.isRecurrence = false
        eventEntity.remindMe = LocalNotificationType.new.rawValue
        eventEntity.accessLevel = 1
        eventEntity.createdAt = Date().stringFromDate(format: DateFormatters.MMDDYYYYHMMSSA, timeZone: TimeZone(abbreviation: "UTC")!)
        eventEntity.modifiedAt = Date().stringFromDate(format: DateFormatters.MMDDYYYYHMMSSA, timeZone: TimeZone(abbreviation: "UTC")!)
        eventEntity.creatorEmail = Session.shared.readUser()?.readValueOfEmail()
        eventEntity.creatorName = Session.shared.readUser()?.readValueOfName()
        eventEntity.eventDescription = event.eventDescription
        if eventEntity.readValueOfAppEventId().isEmpty { eventEntity.appEventId = UUID().uuidString }
        eventEntity.eventName = event.eventName
        eventEntity.recurringEventId = event.recurringEventId
        eventEntity.isAllDay = event.isAllday
        eventEntity.location = event.location
        eventEntity.status = 0
        eventEntity.isAvailable = event.isTravelling ? 1 : 0
        eventEntity.user = Session.shared.readUserId()
        eventEntity.originalStartTimeZone = TimeZone.current.identifier
        eventEntity.originalEndTimeZone = TimeZone.current.identifier
        if event.isAllday {
            let initialStartTime = event.startDate.initialHour()
            let initialEndTime = event.endDate.initialHour()
            eventEntity.endDate = initialEndTime.stringFromDate(format: DateFormatters.MMDDYYYY)
            eventEntity.endTime = initialEndTime.stringFromDate(format: DateFormatters.HHCMMCSSSA)
            eventEntity.startDate = initialStartTime.stringFromDate(format: DateFormatters.MMDDYYYY)
            eventEntity.startTime = initialStartTime.stringFromDate(format: DateFormatters.HHCMMCSSSA)
            eventEntity.startDateTime = initialStartTime
            eventEntity.endDateTime = initialEndTime
            eventEntity.sortedTime = initialStartTime.stringFromDate(format:  DateFormatters.HHCMMCSSSA).stringToDate(formatter:  DateFormatters.HHCMMCSSSA)
        }
        else {
            eventEntity.endDate = event.endDate.stringFromDate(format: DateFormatters.MMDDYYYY, timeZone: TimeZone(abbreviation: "UTC")!)
            eventEntity.endTime = event.endDate.stringFromDate(format: DateFormatters.HHCMMCSSSA, timeZone: TimeZone(abbreviation: "UTC")!)
            eventEntity.startDate = event.startDate.stringFromDate(format: DateFormatters.MMDDYYYY, timeZone: TimeZone(abbreviation: "UTC")!)
            eventEntity.startTime = event.startDate.stringFromDate(format: DateFormatters.HHCMMCSSSA, timeZone: TimeZone(abbreviation: "UTC")!)
            eventEntity.startDateTime = event.startDate.stringFromDate(format:  DateFormatters.MMDDYYYYHMMSSA, timeZone: TimeZone(abbreviation: "UTC")!).stringToDate(formatter:  DateFormatters.MMDDYYYYHMMSSA, timeZone: TimeZone(abbreviation: "UTC")!)
            eventEntity.endDateTime = event.endDate.stringFromDate(format:  DateFormatters.MMDDYYYYHMMSSA, timeZone: TimeZone(abbreviation: "UTC")!).stringToDate(formatter:  DateFormatters.MMDDYYYYHMMSSA, timeZone: TimeZone(abbreviation: "UTC")!)
            eventEntity.sortedTime = event.startDate.stringFromDate(format:  DateFormatters.HHCMMCSSSA, timeZone: TimeZone(abbreviation: "UTC")!).stringToDate(formatter:  DateFormatters.HHCMMCSSSA, timeZone: TimeZone(abbreviation: "UTC")!)
        }
        DatabasePlanItEventCalendar().insertCalendarsToEvent(event.calendars, event: eventEntity, using: objectContext)
        if !event.notifycalendars.isEmpty {
            DatabasePlanItEventCalendar().insertNotifyCalendarsToEvent(event.notifycalendars, event: eventEntity, using: objectContext)
        }
        else {
            eventEntity.deleteAllEventNotifyCalendars()
        }
        DatabasePlanItTags().insertTags(event.tags, for: eventEntity, using: objectContext)
        DatabasePlanItCreator().insertEvent(eventEntity, creator: Session.shared.readUser(), using: objectContext)
        DatabasePlanItModifier().insertEvent(eventEntity, modifier: Session.shared.readUser(), using: objectContext)
        DatabasePlanItInvitees().insertEvent(eventEntity, other: event.invitees, using: objectContext)
        if !event.readRecurrence().isEmpty, var recurrenceRule = RecurrenceRule(rruleString: event.readRecurrence()) {
            recurrenceRule.startDate = event.startDate
            DatabasePlanItEventRecurrence().insertEvent(eventEntity, recurrence: recurrenceRule.toRRuleString(), using: objectContext)
        }
        if let reminders = event.remindValue {
            DataBasePlanItTodoReminders().insertEvent(eventEntity, reminders: reminders, using: objectContext)
        }
        else {
            eventEntity.deleteReminder(withHardSave: false)
        }
        return (allEvents, deletedEvents)
    }
    
    @discardableResult func deleteOfflinePlanItEvent(_ event: PlanItEvent, date: Date, type: RecursiveEditOption, using context: NSManagedObjectContext? = nil) -> ([PlanItEvent], [String]) {
        let objectContext = context ?? self.mainObjectContext
        defer { objectContext.saveContext() }
        switch type {
        case .default:
            return self.deleteDefaultOfflinePlanItEvent(event, using: objectContext)
        case .thisPerticularEvent:
            return self.deleteParticularOfflinePlanItEvent(event, date: date, using: objectContext)
        case .allEventInTheSeries:
            return self.deleteAllOfflinePlanItEvent(event, using: objectContext)
        case .allFutureEvent:
            return self.deleteFutureOfflinePlanItEvent(event, date: date, using: objectContext)
        }
    }
    
    func deleteDefaultOfflinePlanItEvent(_ event: PlanItEvent, using context: NSManagedObjectContext? = nil) -> ([PlanItEvent], [String]) {
        event.saveDeleteStatus(1, hardSave: true)
        return ([event], [])
    }
    
    func deleteParticularOfflinePlanItEvent(_ event: PlanItEvent, date: Date, using context: NSManagedObjectContext? = nil) -> ([PlanItEvent], [String]) {
        let objectContext = context ?? self.mainObjectContext
        let eventEntity = self.insertNewRecords(Table.planItEvent, context: objectContext) as! PlanItEvent
        eventEntity.parent = event
        eventEntity.saveDeleteStatus(1, hardSave: false)
        eventEntity.recurringEventId = event.readValueOfEventId()
        if eventEntity.readValueOfAppEventId().isEmpty { eventEntity.appEventId = UUID().uuidString }
        if event.isAllDay {
            eventEntity.originalStartDateTime = event.readStartDateTimeFromDate(date)
        }
        else {
            eventEntity.originalStartDateTime = event.readStartDateTimeFromDate(date).stringFromDate(format: DateFormatters.MMDDYYYYHMMSSA, timeZone: TimeZone(abbreviation: "UTC")!).stringToDate(formatter: DateFormatters.MMDDYYYYHMMSSA, timeZone: TimeZone(abbreviation: "UTC")!)
        }
        return ([eventEntity], [])
    }
    
    func deleteAllOfflinePlanItEvent(_ event: PlanItEvent, using context: NSManagedObjectContext? = nil) -> ([PlanItEvent], [String]) {
        let deletedEvents = event.deleteAllChildEvents(with: .allEventInTheSeries)
        event.saveDeleteStatus(1, hardSave: true)
        return ([event], deletedEvents)
    }
    
    func deleteFutureOfflinePlanItEvent(_ event: PlanItEvent, date: Date, using context: NSManagedObjectContext? = nil) -> ([PlanItEvent], [String]) {
        var deletedEvents: [String] = []
        if let recurrence = event.recurrence, var recurrenceRule = RecurrenceRule(rruleString: recurrence.readRule()) {
            event.isPending = true
            let recurringEndDate = event.readStartDateTimeFromDate(date).initialHour().adding(seconds: -1)
            recurrenceRule.recurrenceEnd = EKRecurrenceEnd(end: recurringEndDate)
            recurrenceRule.startDate = event.readStartDateTime()
            DatabasePlanItEventRecurrence().insertEvent(event, recurrence: recurrenceRule.toRRuleString())
            deletedEvents = event.deleteAllChildEvents(with: .allFutureEvent)
        }
        return ([event], deletedEvents)
    }
    
    @discardableResult func cancelOfflinePlanItEvent(_ event: PlanItEvent, date: Date, type: RecursiveEditOption, using context: NSManagedObjectContext? = nil) -> ([PlanItEvent], [String]) {
        let objectContext = context ?? self.mainObjectContext
        defer { objectContext.saveContext() }
        switch type {
        case .default:
            return self.cancelDefaultOfflinePlanItEvent(event, using: objectContext)
        case .thisPerticularEvent:
            return self.cancelParticularOfflinePlanItEvent(event, date: date, using: objectContext)
        case .allEventInTheSeries:
            return self.cancelAllOfflinePlanItEvent(event, using: objectContext)
        case .allFutureEvent:
            return self.cancelFutureOfflinePlanItEvent(event, date: date, using: objectContext)
        }
    }
    
    func cancelDefaultOfflinePlanItEvent(_ event: PlanItEvent, using context: NSManagedObjectContext? = nil) -> ([PlanItEvent], [String]) {
        event.saveDeleteStatus(2, hardSave: true)
        return ([event], [])
    }
    
    func cancelParticularOfflinePlanItEvent(_ event: PlanItEvent, date: Date, using context: NSManagedObjectContext? = nil) -> ([PlanItEvent], [String]) {
        let objectContext = context ?? self.mainObjectContext
        let eventEntity = self.insertNewRecords(Table.planItEvent, context: objectContext) as! PlanItEvent
        eventEntity.parent = event
        eventEntity.saveDeleteStatus(1, hardSave: false)
        eventEntity.recurringEventId = event.readValueOfEventId()
        if eventEntity.readValueOfAppEventId().isEmpty { eventEntity.appEventId = UUID().uuidString }
        if event.isAllDay {
            eventEntity.originalStartDateTime = event.readStartDateTimeFromDate(date)
        }
        else {
            eventEntity.originalStartDateTime = event.readStartDateTimeFromDate(date).stringFromDate(format: DateFormatters.MMDDYYYYHMMSSA, timeZone: TimeZone(abbreviation: "UTC")!).stringToDate(formatter: DateFormatters.MMDDYYYYHMMSSA, timeZone: TimeZone(abbreviation: "UTC")!)
        }
        return ([eventEntity], [])
    }
    
    func cancelAllOfflinePlanItEvent(_ event: PlanItEvent, using context: NSManagedObjectContext? = nil) -> ([PlanItEvent], [String]) {
        let deletedEvents = event.deleteAllChildEvents(with: .allEventInTheSeries)
        event.saveDeleteStatus(2, hardSave: true)
        return ([event], deletedEvents)
    }
    
    func cancelFutureOfflinePlanItEvent(_ event: PlanItEvent, date: Date, using context: NSManagedObjectContext? = nil) -> ([PlanItEvent], [String]) {
        var deletedEvents: [String] = []
        if let recurrence = event.recurrence, var recurrenceRule = RecurrenceRule(rruleString: recurrence.readRule()) {
            event.isPending = true
            let recurringEndDate = event.readStartDateTimeFromDate(date).initialHour().adding(seconds: -1)
            recurrenceRule.recurrenceEnd = EKRecurrenceEnd(end: recurringEndDate)
            recurrenceRule.startDate = event.readStartDateTime()
            DatabasePlanItEventRecurrence().insertEvent(event, recurrence: recurrenceRule.toRRuleString())
            deletedEvents = event.deleteAllChildEvents(with: .allFutureEvent)
        }
        return ([event], deletedEvents)
    }
    
    func readSpecificEvent(_ eventId: Double, using context: NSManagedObjectContext? = nil) -> [PlanItEvent] {
        let objectContext = context ?? self.mainObjectContext
        let predicate = NSPredicate(format: "user == %@ AND eventId == %f", Session.shared.readUserId(), eventId)
        return self.readRecords(fromCoreData: Table.planItEvent, predicate: predicate, context: objectContext) as! [PlanItEvent]
    }
    
    private func readSpecificEvent(_ eventId: Double, socialId: String, using context: NSManagedObjectContext? = nil) -> [PlanItEvent] {
        let objectContext = context ?? self.mainObjectContext
        let predicate = NSPredicate(format: "user == %@ AND ((eventId == %f AND eventId <> 0) OR (extEventId == %@ AND extEventId <> ''))", Session.shared.readUserId(), eventId, socialId)
        return self.readRecords(fromCoreData: Table.planItEvent, predicate: predicate, context: objectContext) as! [PlanItEvent]
    }
    
    private func readSpecificEvents(_ eventIds: [Double], appEventIds: [String], using context: NSManagedObjectContext) -> [PlanItEvent] {
        let predicate = NSPredicate(format: "user == %@ AND ((eventId IN %@ AND eventId <> '') OR (appEventId IN %@ AND appEventId <> ''))", Session.shared.readUserId(), eventIds, appEventIds)
        return self.readRecords(fromCoreData: Table.planItEvent, predicate: predicate, context: context) as! [PlanItEvent]
    }
    
    private func readSpecificEvents(_ eventIds: [Double], using context: NSManagedObjectContext) -> [PlanItEvent] {
        let predicate = NSPredicate(format: "user == %@ AND eventId IN %@", Session.shared.readUserId(), eventIds)
        return self.readRecords(fromCoreData: Table.planItEvent, predicate: predicate, context: context) as! [PlanItEvent]
    }
    
    func insertUpdate(_ events: [[String: Any]], deletedEvents: [Double]?) -> [PlanItEvent] {
        if let removedEvents = deletedEvents {
            self.removedPlantItEvents(removedEvents)
        }
        let addedEvents = self.insertNewPlanItEvent(events)
        self.mainObjectContext.saveContext()
        return addedEvents
    }
    
    func removedPlantItEvent(_ eventId: Double, from parent: Double, using context: NSManagedObjectContext? = nil) {
        let objectContext = context ?? self.mainObjectContext
        let predicate = NSPredicate(format: "user == %@ AND eventId == %f AND self.parent.eventId == %f", Session.shared.readUserId(), eventId, parent)
        let records = self.readRecords(fromCoreData: Table.planItEvent, predicate: predicate, context: objectContext) as! [PlanItEvent]
        records.forEach({ objectContext.delete($0) })
    }
    
    func removedPlantItEvents(_ eventIds: [Double], using context: NSManagedObjectContext? = nil) {
        let objectContext = context ?? self.mainObjectContext
        let myPlanItEvents = self.readSpecificEvents(eventIds, using: objectContext)
        myPlanItEvents.forEach({ objectContext.delete($0) })
        context?.saveContext()
    }

    func removedPlantItEventsFromCalendar(_ calendar: PlanItCalendar, using context: NSManagedObjectContext? = nil) {
        let objectContext = context ?? self.mainObjectContext
        let predicate = NSPredicate(format: "user == %@ AND (ANY calendars.calendarId == %f OR ANY parent.calendars.calendarId == %f)", Session.shared.readUserId(), calendar.calendarId, calendar.calendarId)
        let events = self.readRecords(fromCoreData: Table.planItEvent, predicate: predicate, context: objectContext) as! [PlanItEvent]
        events.forEach({ objectContext.delete($0) })
        objectContext.saveContext()
    }
    
    func removedPlantItEventsFromCalendar(_ calendars: [Double], using context: NSManagedObjectContext? = nil) {
        let objectContext = context ?? self.mainObjectContext
        let predicate = NSPredicate(format: "user == %@ AND (ANY calendars.calendarId IN %@ OR ANY parent.calendars.calendarId IN %@)", Session.shared.readUserId(), calendars, calendars)
        let events = self.readRecords(fromCoreData: Table.planItEvent, predicate: predicate, context: objectContext) as! [PlanItEvent]
        events.forEach({ objectContext.delete($0) })
        objectContext.saveContext()
    }
    
    func readUser(_ user: String, allPendingRemindMeEventsUsingType type: [LocalNotificationType], completionHandler: @escaping ([PlanItEvent]) -> ()) {
        self.privateObjectContext.perform {
            let types = type.map({ return $0.rawValue })
            let predicate = NSPredicate(format: "user == %@ AND remindMe IN %@", user, types)
            let events = self.readRecords(fromCoreData: Table.planItEvent, predicate: predicate, context: self.privateObjectContext) as! [PlanItEvent]
            completionHandler(events)
        }
    }
    
    func readPlanItEventsWith(_ eventId: Double, using context: NSManagedObjectContext? = nil) -> PlanItEvent? {
        let objectContext = context ?? self.mainObjectContext
        let events = self.readSpecificEvents([eventId], using: objectContext)
        return events.first
    }
    
    func readSpecificEventsFromCalendarUsingQueue(_ calendar: String, startOfMonth: Date, endOfMonth: Date, eventIds: [String], result: @escaping ([PlanItEvent]) -> ()) {
        self.privateObjectContext.perform {
            let end = endOfMonth as NSDate
            let start = startOfMonth as NSDate
            let predicate = NSPredicate(format: "user == %@ AND (ANY calendars.socialCalendarId == %@ OR ANY parent.calendars.socialCalendarId == %@) AND ((isRecurrence == NO AND ((startDateTime >= %@ AND startDateTime <= %@) OR (endDateTime >= %@ AND endDateTime <= %@) OR (startDateTime < %@ AND endDateTime > %@))) OR (isRecurrence == YES AND ((recurrenceEndDate == nil AND startDateTime <= %@) OR (startDateTime >= %@ AND startDateTime <= %@) OR (recurrenceEndDate >= %@ AND recurrenceEndDate <= %@) OR (startDateTime < %@ AND recurrenceEndDate > %@) ))) AND NOT(extEventId IN %@) AND status == 0 AND eventHidden <> YES", Session.shared.readUserId(), calendar, calendar, start, end, start, end, start, end, end, start, end, start, end, start, end, eventIds)
            let events = self.readRecords(fromCoreData: Table.planItEvent, predicate: predicate, context: self.privateObjectContext) as! [PlanItEvent]
            result(events)
        }
    }
    
    func readSpecificEventsUsingQueue(startOfMonth: Date, endOfMonth: Date, eventIds: [Double], result: @escaping ([PlanItEvent]) -> ()) {
        self.privateObjectContext.perform {
            let end = endOfMonth as NSDate
            let start = startOfMonth as NSDate
            let predicate = NSPredicate(format: "user == %@ AND ((isRecurrence == NO AND ((startDateTime >= %@ AND startDateTime <= %@) OR (endDateTime >= %@ AND endDateTime <= %@) OR (startDateTime < %@ AND endDateTime > %@))) OR (isRecurrence == YES AND ((recurrenceEndDate == nil AND startDateTime <= %@) OR (startDateTime >= %@ AND startDateTime <= %@) OR (recurrenceEndDate >= %@ AND recurrenceEndDate <= %@) OR (startDateTime < %@ AND recurrenceEndDate > %@) ))) AND eventId IN %@ AND status == 0 AND eventHidden <> YES", Session.shared.readUserId(), start, end, start, end, start, end, end, start, end, start, end, start, end, eventIds)
            let events = self.readRecords(fromCoreData: Table.planItEvent, predicate: predicate, context: self.privateObjectContext) as! [PlanItEvent]
            result(events)
        }
    }
    
    func readAllEventsUsingQueueFrom(startOfMonth: Date, endOfMonth: Date, from calendars: [PlanItCalendar] = [], result: @escaping ([PlanItEvent]) -> ()) {
        self.privateObjectContext.perform {
            if calendars.isEmpty || calendars.contains(where: { return $0.parentCalendarId == 0 }) {
                let allEvents = self.readAllEventsFrom(startOfMonth: startOfMonth, endOfMonth: endOfMonth, using: self.privateObjectContext)
                result(allEvents)
            }
            else {
                let end = endOfMonth as NSDate
                let start = startOfMonth as NSDate
                let calendarIds = calendars.map({ return $0.calendarId })
                let predicate = NSPredicate(format: "user == %@ AND (ANY calendars.calendarId IN %@ OR ANY parent.calendars.calendarId IN %@) AND ((isRecurrence == NO AND ((startDateTime >= %@ AND startDateTime <= %@) OR (endDateTime >= %@ AND endDateTime <= %@) OR (startDateTime < %@ AND endDateTime > %@))) OR (isRecurrence == YES AND ((recurrenceEndDate == nil AND startDateTime <= %@) OR (startDateTime >= %@ AND startDateTime <= %@) OR (recurrenceEndDate >= %@ AND recurrenceEndDate <= %@) OR (startDateTime < %@ AND recurrenceEndDate > %@) ))) AND status == 0 AND eventHidden <> YES", Session.shared.readUserId(), calendarIds, calendarIds, start, end, start, end, start, end, end, start, end, start, end, start, end)
                let allEvents = self.readRecords(fromCoreData: Table.planItEvent, predicate: predicate, context: self.privateObjectContext) as! [PlanItEvent]
                result(allEvents)
            }
        }
    }
    func readAllEventsFrom(startOfMonth: Date, endOfMonth: Date, using context: NSManagedObjectContext? = nil) -> [PlanItEvent] {
        let end = endOfMonth as NSDate
        let start = startOfMonth as NSDate
        let objectContext = context ?? self.mainObjectContext
        let predicate = NSPredicate(format: "user == %@ AND ((isRecurrence == NO AND ((startDateTime >= %@ AND startDateTime <= %@) OR (endDateTime >= %@ AND endDateTime <= %@) OR (startDateTime < %@ AND endDateTime > %@))) OR (isRecurrence == YES AND ((recurrenceEndDate == nil AND startDateTime <= %@) OR (startDateTime >= %@ AND startDateTime <= %@) OR (recurrenceEndDate >= %@ AND recurrenceEndDate <= %@) OR (startDateTime < %@ AND recurrenceEndDate > %@) ))) AND status == 0 AND eventHidden <> YES", Session.shared.readUserId(), start, end, start, end, start, end, end, start, end, start, end, start, end)
        let events = self.readRecords(fromCoreData: Table.planItEvent, predicate: predicate, context: objectContext) as! [PlanItEvent]
        return events
    }
    
    func readAllPendingEvents(using context: NSManagedObjectContext? = nil) -> [PlanItEvent] {
        let objectContext = context ?? self.mainObjectContext
        let predicate = NSPredicate(format: "user == %@ AND status == 0 AND isPending == YES", Session.shared.readUserId())
        let events = self.readRecords(fromCoreData: Table.planItEvent, predicate: predicate, context: objectContext) as! [PlanItEvent]
        return events
    }
    
    func readAllPendingDeletedEvents(using context: NSManagedObjectContext? = nil) -> [PlanItEvent] {
        let objectContext = context ?? self.mainObjectContext
        let predicate = NSPredicate(format: "user == %@ AND status <> 0 AND isPending == YES", Session.shared.readUserId())
        let events = self.readRecords(fromCoreData: Table.planItEvent, predicate: predicate, context: objectContext) as! [PlanItEvent]
        return events
    }
}
