//
//  SocialCalendarEvent.swift
//  MiPlanIt
//
//  Created by Arun on 23/03/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation
import EventKit

class SocialCalendarEvent {
    
    var eventId = Strings.empty
    var eventName = Strings.empty
    var eventDescription = Strings.empty
    var allday: Bool = false
    var isOriginalAllDay: Bool = false
    var outlookBodyContent = Strings.empty
    var outlookBodyContentType = Strings.empty
    var createdDate = Strings.empty
    var updatedDate = Strings.empty
    var location = Strings.empty
    var startDate = Strings.empty
    var endDate = Strings.empty
    var organizerEmail = Strings.empty
    var organizerName = Strings.empty
    var creatorName = Strings.empty
    var creatorEmail = Strings.empty
    var htmlLink = Strings.empty
    var status = Strings.empty
    var recurrenceRule: Any = Strings.empty
    var originalStartTime = Strings.empty
    var recurringEventId = Strings.empty
    var excludedDates: [String] = []
    var attendees: [[String: Any]] = []
    var attachments: [[String: Any]] = []
    var remindMeBeforeMinutes: Int?
    var responseStatus = Strings.empty
    var originalStartTimeZone = Strings.empty
    var originalEndTimeZone = Strings.empty
    var conferenceData: [String: Any] = [:]

    init(withGoogleEvent data: [String: Any]) {
        self.eventId = data["id"] as? String ?? Strings.empty
        self.eventName = data["summary"] as? String ?? Strings.empty
        self.eventDescription = data["description"] as? String ?? Strings.empty
        if let convertedDate = data["created"] as? String {
            self.createdDate = convertedDate
        }
        if let convertedDate = data["updated"] as? String {
            self.updatedDate = convertedDate
        }
        self.location = data["location"] as? String ?? Strings.empty
        if let start = data["start"] as? [String: String], let date = start["date"] {
            self.allday = true
            self.startDate = date
        }
        if let end = data["end"] as? [String: String], let date = end["date"] {
            self.allday = true
            self.endDate = date
        }
        if let start = data["start"] as? [String: String], let date = start["dateTime"] {
            self.startDate = date
            self.originalStartTimeZone = start["timeZone"] ?? Strings.empty
        }
        if let end = data["end"] as? [String: String], let date = end["dateTime"] {
            self.endDate = date
            self.originalEndTimeZone = end["timeZone"] ?? Strings.empty
        }
        if let startTime = data["originalStartTime"] as? [String: String], let date = startTime["dateTime"] {
            self.isOriginalAllDay = false
            self.originalStartTime = date
        }
        if let startTime = data["originalStartTime"] as? [String: String], let date = startTime["date"] {
            self.isOriginalAllDay = true
            self.originalStartTime = date
        }
        if let organizer = data["organizer"] as? [String: Any] {
            var containOrganizer = true
            if let selfEvent = organizer["self"] as? Int {
                containOrganizer = selfEvent == 0
            }
            if containOrganizer, let email = organizer["email"] as? String, !email.contains("@group.calendar.google.com") {
                self.organizerName = organizer["displayName"] as? String ?? Strings.empty
                self.organizerEmail = organizer["email"] as? String ?? Strings.empty
            }
        }
        if let creators = data["creator"] as? [String: Any], let email = creators["email"] as? String, !email.contains("@group.v.calendar.google.com") {
            self.creatorEmail = email
        }
        self.htmlLink = data["hangoutLink"] as? String ?? Strings.empty // adding hangoutLink instead htmlLink
        self.status = data["status"] as? String ?? Strings.empty
        if let recurrence = data["recurrence"] as? [String] {
            self.recurrenceRule = recurrence
        }
        self.recurringEventId = data["recurringEventId"] as? String ?? Strings.empty
        
        if let attendees = data["attendees"] as? [[String: Any]] {
            for eachAttendees in attendees {
                if let emailAddress = eachAttendees["email"] as? String {
                    self.attendees.append(["email": emailAddress, "name": eachAttendees["displayName"] as? String ?? Strings.empty, "status": eachAttendees["responseStatus"] as? String ?? Strings.empty])
                }
            }
        }
        if let googleAttachments = data["attachments"] as? [[String: Any]] {
            for eachAttachments in googleAttachments {
                self.attachments.append(["fileUrl": eachAttachments["fileUrl"] as? String ?? Strings.empty, "title": eachAttachments["title"] as? String ?? Strings.empty, "iconLink": eachAttachments["iconLink"] as? String ?? Strings.empty])
            }
        }
        if let reminders = data["reminders"] as? [String: Any], let useDefault = reminders["useDefault"] as? Int {
            if useDefault == 1 {
                self.remindMeBeforeMinutes = 30
            }
            else if let overrides = reminders["overrides"] as? [[String: Any]], useDefault == 0 {
                if let popupOverride = overrides.filter({ (data) -> Bool in
                    if let popUp = data["method"] as? String, popUp == "popup" {
                        return true
                    }
                    return false
                    }).first, let minutes = popupOverride["minutes"] as? Int {
                    self.remindMeBeforeMinutes = minutes
                }
            }
        }
        if let conferenceData = data["conferenceData"] as? [String: Any] {
            var typeString = Strings.empty
            var urlString = Strings.empty
            if let conferenceSolution = conferenceData["conferenceSolution"] as? [String: Any], let key = conferenceSolution["key"] as? [String: Any], let type = key["type"] as? String {
                typeString = type
            }
            if let entryPoints = conferenceData["entryPoints"] as? [[String: Any]], let entryPoint = entryPoints.first, let url = entryPoint["uri"] as? String {
                urlString = url
            }
            self.conferenceData = ["conferenceType": typeString, "url": urlString]
            if let conferenceJsonString = self.dictionaryToJsonString(json: conferenceData) {
                self.conferenceData["fullConferenceData"] = conferenceJsonString
            }
        }
    }
    
    init(withOutlookEvent data: [String: Any], availableDates: [String], from: Date, to: Date) {
        self.status = "confirmed" //default
        self.eventId = data["id"] as? String ?? Strings.empty
        self.eventName = data["subject"] as? String ?? Strings.empty
        if let body = data["body"] as? [String: Any] {
            self.outlookBodyContent = body["content"] as? String ?? Strings.empty
            self.outlookBodyContentType = body["contentType"] as? String ?? Strings.empty
        }
        self.allday = (data["isAllDay"] as? Int ?? 0) == 1
        if let convertedDate = data["createdDateTime"] as? String {
            self.createdDate = convertedDate
        }
        if let convertedDate = data["lastModifiedDateTime"] as? String {
            self.updatedDate = convertedDate
        }
        if let location = data["location"] as? [String: Any] {
            self.location = location["displayName"] as? String ?? Strings.empty
        }
        if let organiser = data["organizer"] as? [String: Any], let emailAddress = organiser["emailAddress"] as? [String: Any], let email = emailAddress["address"] as? String {
            let name = (emailAddress["name"] as? String) ?? Strings.empty
            self.organizerEmail = !email.contains("@group.calendar.google.com") ? email : ( !name.isEmpty ? name : email )
            self.organizerName = name
        }
        if let start = data["start"] as? [String: Any] {
            self.startDate = start["dateTime"] as? String ?? Strings.empty
        }
        if let end = data["end"] as? [String: Any] {
            self.endDate = end["dateTime"] as? String ?? Strings.empty
        }
        if let eventStatus = data["isCancelled"] as? Bool {
            self.status = eventStatus ? "cancelled" : "confirmed"
        }
        if let webLink = data["webLink"] as? String {
            self.htmlLink = webLink
        }
        self.originalStartTimeZone = data["originalStartTimeZone"] as? String ?? Strings.empty
        self.originalEndTimeZone = data["originalEndTimeZone"] as? String ?? Strings.empty
        if let recurrence = data["recurrence"] as? [String: [String: Any]] {
            self.recurrenceRule = recurrence
            let availableDatesInDate = availableDates.compactMap({ return $0.stringToDate(formatter: DateFormatters.YYYYHMMHDDTHHCMMCSSSDSSS, timeZone: TimeZone(abbreviation: "UTC")!)?.initialHour() })
            let ruleAvailableDates = recurrence.readOccurenceBetween(from: from, to: to, startDate: self.startDate.stringToDate(formatter: DateFormatters.YYYYHMMHDDTHHCMMCSSSDSSS, timeZone: TimeZone(abbreviation: "UTC")!))
            self.excludedDates = ruleAvailableDates?.filter({ return !availableDatesInDate.contains($0.initialHour()) }).map({ return $0.stringFromDate(format: DateFormatters.YYYYHMMHDDSHHCMMCSSSZ, timeZone: TimeZone(abbreviation: "UTC")!) }) ?? []
        }
        self.recurringEventId = data["seriesMasterId"] as? String ?? Strings.empty
        
        if let attendees = data["attendees"] as? [[String: Any]] {
            for eachAttendees in attendees {
                if let emailAddress = eachAttendees["emailAddress"] as? [String: Any], let email = emailAddress["address"] as? String {
                    var response = Strings.empty
                    if let attendeesStatus = eachAttendees["status"] as? [String: Any], let responseStatus = attendeesStatus["response"] as? String {
                        response = responseStatus
                    }
                    self.attendees.append(["email": email, "name": emailAddress["name"] as? String ?? Strings.empty, "status": response])
                }
            }
        }
        
        if let isReminderOn = data["isReminderOn"] as? Int, isReminderOn == 1, let reminderMinutesBeforeStart = data["reminderMinutesBeforeStart"] as? Int {
            self.remindMeBeforeMinutes = reminderMinutesBeforeStart
        }
        if let responseStatus = data["responseStatus"] as? [String: Any] {
            self.responseStatus = responseStatus["response"] as? String ?? Strings.empty
        }
        if let isOnlineMeeting = data["isOnlineMeeting"] as? Bool, isOnlineMeeting {
            var typeString = Strings.empty
            var urlString = Strings.empty
            if let onlineMeetingProvider = data["onlineMeetingProvider"] as? String {
                typeString = onlineMeetingProvider
            }
            if let onlineMeeting = data["onlineMeeting"] as? [String: Any], let joinUrl = onlineMeeting["joinUrl"] as? String {
                urlString = joinUrl
            }
            self.conferenceData = ["conferenceType": typeString, "url": urlString]
        }
    }
    
    init(withAppleEvent data: EKEvent, availableDates: [Date], from: Date, to: Date) {
        self.eventId = data.eventIdentifier
        self.eventName = data.title
        self.allday = data.isAllDay
        self.location = data.location ?? Strings.empty
        self.eventDescription = data.notes ?? Strings.empty
        self.organizerName = data.organizer?.name ?? Strings.empty
        self.status = data.status == .canceled ? "cancelled" : "confirmed"
        if let convertedDate = data.creationDate?.stringFromDate(format: DateFormatters.YYYYHMMHDDSHHCMMCSSSZ, timeZone: TimeZone(abbreviation: "UTC")!) {
            self.createdDate = convertedDate
        }
        if let convertedDate = data.lastModifiedDate?.stringFromDate(format: DateFormatters.YYYYHMMHDDSHHCMMCSSSZ, timeZone: TimeZone(abbreviation: "UTC")!) {
            self.updatedDate = convertedDate
        }
        if data.isAllDay {
            self.startDate = data.startDate.stringFromDate(format: DateFormatters.YYYYHMMHDDSHHCMMCSSSZ)
            self.endDate = data.endDate.stringFromDate(format: DateFormatters.YYYYHMMHDDSHHCMMCSSSZ)
        }
        else {
            self.startDate = data.startDate.stringFromDate(format: DateFormatters.YYYYHMMHDDSHHCMMCSSSZ, timeZone: TimeZone(abbreviation: "UTC")!)
            self.endDate = data.endDate.stringFromDate(format: DateFormatters.YYYYHMMHDDSHHCMMCSSSZ, timeZone: TimeZone(abbreviation: "UTC")!)
        }
        var timeZone: TimeZone?
        if let startTimeZone = data.value(forKey: "startTimeZone") as? TimeZone {
            timeZone = startTimeZone
            self.originalStartTimeZone = startTimeZone.identifier
        }
        if let endTimeZone = data.value(forKey: "endTimeZone") as? TimeZone {
            self.originalEndTimeZone = endTimeZone.identifier
        }
        if let rule = data.recurrenceRules?.map({ return $0.stringForICalendar() }), !rule.isEmpty {
            self.recurrenceRule = rule
            let splittedDeletedEvents = data.eventIdentifier.components(separatedBy: "<!ExceptionDate!>")
            if let parentId = splittedDeletedEvents.first, splittedDeletedEvents.count > 1 {
                self.recurringEventId = parentId
            }
            let splittedEditedEvents = data.eventIdentifier.components(separatedBy: "/RID=")
            if let parentId = splittedEditedEvents.first, splittedEditedEvents.count > 1, data.isDetached {
                self.recurringEventId = parentId
            }
            if let recurrenceRule = rule.filter({ $0.hasPrefix("RRULE") }).first?.replacingOccurrences(of: "RRULE ", with: "RRULE:") {
                let ruleAvailableDates = recurrenceRule.readOccurenceBetween(from: from, to: to, startDate: data.startDate, timeZone: timeZone)
                self.excludedDates = ruleAvailableDates?.filter({ return !availableDates.contains($0.initialHour()) }).map({ return $0.stringFromDate(format: DateFormatters.YYYYHMMHDDSHHCMMCSSSZ, timeZone: TimeZone(abbreviation: "UTC")!) }) ?? []
            }
        }
        if let attendees = data.attendees {
            self.attendees = attendees.map({ return ["email": ($0.url.absoluteString).replacingOccurrences(of: "mailto:", with: Strings.empty), "name": $0.name ?? Strings.empty, "status": $0.participantStatus.rawValue == 2 ? "accepted" : ($0.participantStatus.rawValue == 3 ? "declined" : Strings.empty)]})
        }
        if let reminder = data.alarms?.last {
            self.remindMeBeforeMinutes = Int(abs(reminder.relativeOffset)/60.0)
        }
        if let organizer = data.organizer {
            let organizerEmail = (organizer.url.absoluteString).replacingOccurrences(of: "mailto:", with: Strings.empty)
            self.organizerEmail = organizerEmail
        }
        self.setRespondStatusForApple(withAppleEvent: data)
    }
    
    func setRespondStatusForApple(withAppleEvent data: EKEvent) {
        if data.organizer == nil && data.attendees == nil {
            self.responseStatus = "organizer"
        }
        else if let organizer = data.organizer, organizer.isCurrentUser {
            self.responseStatus = "organizer"
        }
        else if let attendees = data.attendees, let currentUser = attendees.filter({ $0.isCurrentUser }).first {
            self.responseStatus = currentUser.participantStatus.rawValue == 2 ? "accepted" : Strings.empty
        }
    }
    
    func readReminderBeforeMinutesValue() -> String {
        guard let minutes = self.remindMeBeforeMinutes else { return Strings.empty }
        return String(minutes)
    }
    
    func dictionaryToJsonString(json: [String: Any]) -> String? {
        do {
            let data1 =  try JSONSerialization.data(withJSONObject: json, options: JSONSerialization.WritingOptions.prettyPrinted) // first of all convert json to the data
            let convertedString = String(data: data1, encoding: String.Encoding.utf8) // the data will be converted to the string
            return convertedString
        } catch _ {
            return nil
        }

    }
}

