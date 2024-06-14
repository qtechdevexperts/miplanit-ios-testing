//
//  OtherUserEvent.swift
//  MiPlanIt
//
//  Created by Arun on 14/04/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation
// import RRuleSwift

class OtherUserEvent {
    
    let userId: String
    let accessLevel: String
    let createdAt: String
    var eventDescription: String
    var endDate: String
    var endTime: String
    let eventId: String
    var eventName: String
    let extEventId: String
    var isAllDay: Bool
    var isAvailable: Double
    var location: String
    let modifiedAt: String
    var startDate: String
    var startTime: String
    var visibility: Double
    var reminder: OtherUserReminders?
    var reminderId: Double
    var createdBy: OtherUserEventCreator?
    var modifiedBy: OtherUserEventModifier?
    var invitees: [OtherUserEventInvitees] = []
    var tags: [String] = []
    
    var bodyContentType: String
    var creatorEmail: String
    var creatorName: String
    var extCreatedDate: String
    var recurringEventId: String
    var extUpdatedDate: String
    var htmlLink: String
    var organizerEmail: String
    var organizerName: String
    var originalStartTime: String
    var status: Double
    var calendars: [OtherUserEventCalendar] = []
    var notifyCalendars: [OtherUserEventCalendar] = []
    var otherSubEvents: [OtherUserEvent] = []
    var recurranceEvent: OtherUserRecurranceEvent?
    var attendees: [OtherUserEventAttendees] = []
    var attachments: [OtherUserEventAttachment] = []
    var isRecurrence: Bool = false
    var sortedTime: Date?
    var startDateTime: Date?
    var endDateTime: Date?
    var originalStartDateTime: Date?
    var originalStartDate: String?
    var userColor: UIColor?
    var userColorCode: String? = Strings.empty
    var isSocialEvent: Bool = false
    var conferenceType = Strings.empty
    var conferenceUrl = Strings.empty
    var originalStartTimeZone = Strings.empty
    var originalEndTimeZone = Strings.empty
    var responseStatus = Strings.empty
    var fullConferenceData: String = Strings.empty
    
    init(with event: [String: Any], user: String, visibility value: Double = 0, userColor: UIColor? = nil, colorCode: String? = nil) {
        self.userId = user
        self.visibility = value
        self.accessLevel = (event["accessLevel"] as? Double)?.cleanValue() ?? Strings.empty
        self.createdAt = event["createdAt"] as? String ?? Strings.empty
        self.eventDescription = event["description"] as? String ?? Strings.empty
        self.endDate = event["endDate"] as? String ?? Strings.empty
        self.endTime = event["endTime"] as? String ?? Strings.empty
        self.eventId = (event["eventId"] as? Double)?.cleanValue() ?? Strings.empty
        self.eventName = event["eventName"] as? String ?? Strings.empty
        self.extEventId = event["extEventId"] as? String ?? Strings.empty
        self.isAllDay = event["isAllDay"] as? Bool ?? false
        self.isAvailable = event["availabilityFlag"] as? Double ?? 0
        self.location = event["location"] as? String ?? Strings.empty
        self.modifiedAt = event["modifiedAt"] as? String ?? Strings.empty
        self.startDate = event["startDate"] as? String ?? Strings.empty
        self.startTime = event["startTime"] as? String ?? Strings.empty
        self.bodyContentType = event["bodyContentType"] as? String ?? Strings.empty
        self.creatorEmail = event["creatorEmail"] as? String ?? Strings.empty
        self.creatorName = event["creatorName"] as? String ?? Strings.empty
        self.extCreatedDate = event["extCreatedDate"] as? String ?? Strings.empty
        self.recurringEventId = event["recurringEventId"] as? String ?? Strings.empty
        self.extUpdatedDate = event["extUpdatedDate"] as? String ?? Strings.empty
        self.htmlLink = event["htmlLink"] as? String ?? Strings.empty
        self.organizerEmail = event["organizerEmail"] as? String ?? Strings.empty
        self.organizerName = event["organizerName"] as? String ?? Strings.empty
        self.originalStartTime = event["originalStartTime"] as? String ?? Strings.empty
        self.originalStartTimeZone = event["originalStartTimeZone"] as? String ?? Strings.empty
        self.originalEndTimeZone = event["originalEndTimeZone"] as? String ?? Strings.empty
        self.responseStatus = event["responseStatus"] as? String ?? Strings.empty
        self.status = event["eventStatus"] as? Double ?? 0
        self.reminderId = event["reminderId"] as? Double ?? 0
        self.originalStartDate = event["originalStartDate"] as? String ?? Strings.empty
        self.isSocialEvent = event["isSocialEvent"] as? Bool ?? false
        if let conferenceData = event["conferenceData"] as? [String: Any] {
            self.conferenceType = conferenceData["conferenceType"] as? String ?? Strings.empty
            self.conferenceUrl = conferenceData["url"] as? String ?? Strings.empty
            self.conferenceUrl = conferenceData["fullConferenceData"] as? String ?? Strings.empty
        }
        if let date = event["originalStartDate"] as? String, let time = event["originalStartTime"] as? String {
            self.originalStartDateTime = (date + Strings.space + time).stringToDate(formatter: DateFormatters.MMDDYYYYHMMSSA, timeZone: TimeZone(abbreviation: "UTC")!)
        }
        if let date = event["startDate"] as? String, let time = event["startTime"] as? String {
            if let allDay = event["isAllDay"] as? Bool, allDay {
                let serverStartDateTime = (date + Strings.space + time).stringToDate(formatter: DateFormatters.MMDDYYYYHMMSSA)
                self.startDateTime = serverStartDateTime
                self.sortedTime = serverStartDateTime?.stringFromDate(format:  DateFormatters.HHCMMCSSSA).stringToDate(formatter:  DateFormatters.HHCMMCSSSA)
            }
            else {
                let serverStartDateTime = (date + Strings.space + time).stringToDate(formatter: DateFormatters.MMDDYYYYHMMSSA, timeZone: TimeZone(abbreviation: "UTC")!)
                self.startDateTime = serverStartDateTime
                self.sortedTime = serverStartDateTime?.stringFromDate(format:  DateFormatters.HHCMMCSSSA).stringToDate(formatter:  DateFormatters.HHCMMCSSSA)
            }
        }
        if let date = event["endDate"] as? String, let time = event["endTime"] as? String {
            if let allDay = event["isAllDay"] as? Bool, allDay {
                self.endDateTime = (date + Strings.space + time).stringToDate(formatter: DateFormatters.MMDDYYYYHMMSSA)
            }
            else {
                self.endDateTime = (date + Strings.space + time).stringToDate(formatter: DateFormatters.MMDDYYYYHMMSSA, timeZone: TimeZone(abbreviation: "UTC")!)
            }
        }
        
        if let subEvents = event["child"] as? [[String: Any]] {
            self.otherSubEvents = subEvents.compactMap({ return OtherUserEvent(withsubEvent: $0, user: user, visibility: self.visibility, userColor: userColor, colorCode: self.userColorCode) })
        }
        if let eventCalendars = event["calendar"] as? [[String: Any]] {
            self.calendars = eventCalendars.map({ return OtherUserEventCalendar(with: $0) })
        }
        if let eventCalendars = event["notifyCalendar"] as? [[String: Any]] {
            self.notifyCalendars = eventCalendars.map({ return OtherUserEventCalendar(with: $0) })
        }
        if let creator = event["createdBy"] as? [String: Any] {
            self.createdBy = OtherUserEventCreator(with: creator)
        }
        if let modifier = event["modifiedBy"] as? [String: Any] {
            self.modifiedBy = OtherUserEventModifier(with: modifier)
        }
        if let inviters = event["invitees"] as? [[String: Any]] {
            self.invitees = inviters.map({ return OtherUserEventInvitees(with: $0) })
        }
        if let tags = event["tags"] as? [[String: String]] {
            let arrayTags = tags.compactMap({$0.values.first})
            self.tags = arrayTags
        }
        if let recurrence = event["recurrence"] as? [String], let rule = recurrence.filter({ $0.hasPrefix("RRULE") }).first {
            self.isRecurrence = true
            self.recurranceEvent = OtherUserRecurranceEvent(with: rule)
        }
        if let recurrence = event["recurrence"] as? [String: Any] {
            self.isRecurrence = true
            self.recurranceEvent = OtherUserRecurranceEvent(with: recurrence)
        }
        if let attendees = event["attendees"] as? [[String: Any]] {
            self.attendees = attendees.compactMap({ return OtherUserEventAttendees(with: $0) })
        }
        if let attachments = event["attachments"] as? [[String: Any]] {
            self.attachments = attachments.compactMap({ return OtherUserEventAttachment(with: $0) })
        }
        if let reminders = event["reminders"] as? [String: Any] {
            self.reminder = OtherUserReminders(with: reminders)
        }
        self.userColor = userColor
        self.userColorCode = colorCode
    }
    
    init(withsubEvent event: [String: Any], user: String, visibility value: Double = 0, userColor: UIColor? = nil, colorCode: String? = nil) {
        self.userId = user
        self.visibility = value
        self.accessLevel = (event["accessLevel"] as? Double)?.cleanValue() ?? Strings.empty
        self.createdAt = event["createdAt"] as? String ?? Strings.empty
        self.eventDescription = event["description"] as? String ?? Strings.empty
        self.endDate = event["endDate"] as? String ?? Strings.empty
        self.endTime = event["endTime"] as? String ?? Strings.empty
        self.eventId = (event["eventId"] as? Double)?.cleanValue() ?? Strings.empty
        self.eventName = event["eventName"] as? String ?? Strings.empty
        self.extEventId = event["extEventId"] as? String ?? Strings.empty
        self.isAllDay = event["isAllDay"] as? Bool ?? false
        self.isAvailable = event["availabilityFlag"] as? Double ?? 0
        self.location = event["location"] as? String ?? Strings.empty
        self.modifiedAt = event["modifiedAt"] as? String ?? Strings.empty
        self.startDate = event["startDate"] as? String ?? Strings.empty
        self.startTime = event["startTime"] as? String ?? Strings.empty
        self.bodyContentType = event["bodyContentType"] as? String ?? Strings.empty
        self.creatorEmail = event["creatorEmail"] as? String ?? Strings.empty
        self.creatorName = event["creatorName"] as? String ?? Strings.empty
        self.extCreatedDate = event["extCreatedDate"] as? String ?? Strings.empty
        self.recurringEventId = event["recurringEventId"] as? String ?? Strings.empty
        self.extUpdatedDate = event["extUpdatedDate"] as? String ?? Strings.empty
        self.htmlLink = event["htmlLink"] as? String ?? Strings.empty
        self.organizerEmail = event["organizerEmail"] as? String ?? Strings.empty
        self.organizerName = event["organizerName"] as? String ?? Strings.empty
        self.originalStartTime = event["originalStartTime"] as? String ?? Strings.empty
        self.status = event["eventStatus"] as? Double ?? 0
        self.originalStartDate = event["originalStartDate"] as? String ?? Strings.empty
        self.originalStartTimeZone = event["originalStartTimeZone"] as? String ?? Strings.empty
        self.originalEndTimeZone = event["originalEndTimeZone"] as? String ?? Strings.empty
        self.responseStatus = event["responseStatus"] as? String ?? Strings.empty
        self.reminderId = event["reminderId"] as? Double ?? 0
        self.isSocialEvent = event["isSocialEvent"] as? Bool ?? false
        if let conferenceData = event["conferenceData"] as? [String: Any] {
            self.conferenceType = conferenceData["conferenceType"] as? String ?? Strings.empty
            self.conferenceUrl = conferenceData["url"] as? String ?? Strings.empty
            self.conferenceUrl = conferenceData["fullConferenceData"] as? String ?? Strings.empty
        }
        if let date = event["originalStartDate"] as? String, let time = event["originalStartTime"] as? String {
            if let originalAllDay = event["isOriginalAllDay"] as? Bool, originalAllDay {
                self.originalStartDateTime = (date + Strings.space + time).stringToDate(formatter: DateFormatters.MMDDYYYYHMMSSA)
            }
            else {
                self.originalStartDateTime = (date + Strings.space + time).stringToDate(formatter: DateFormatters.MMDDYYYYHMMSSA, timeZone: TimeZone(abbreviation: "UTC")!)
            }
        }
        if let date = event["startDate"] as? String, let time = event["startTime"] as? String {
            if let allDay = event["isAllDay"] as? Bool, allDay {
                let serverStartDateTime = (date + Strings.space + time).stringToDate(formatter: DateFormatters.MMDDYYYYHMMSSA)
                self.startDateTime = serverStartDateTime
                self.sortedTime = serverStartDateTime?.stringFromDate(format:  DateFormatters.HHCMMCSSSA).stringToDate(formatter:  DateFormatters.HHCMMCSSSA)
            }
            else {
                let serverStartDateTime = (date + Strings.space + time).stringToDate(formatter: DateFormatters.MMDDYYYYHMMSSA, timeZone: TimeZone(abbreviation: "UTC")!)
                self.startDateTime = serverStartDateTime
                self.sortedTime = serverStartDateTime?.stringFromDate(format:  DateFormatters.HHCMMCSSSA).stringToDate(formatter:  DateFormatters.HHCMMCSSSA)
            }
        }
        if let date = event["endDate"] as? String, let time = event["endTime"] as? String {
            if let allDay = event["isAllDay"] as? Bool, allDay {
                self.endDateTime = (date + Strings.space + time).stringToDate(formatter: DateFormatters.MMDDYYYYHMMSSA)
            }
            else {
                self.endDateTime = (date + Strings.space + time).stringToDate(formatter: DateFormatters.MMDDYYYYHMMSSA, timeZone: TimeZone(abbreviation: "UTC")!)
            }
        }
        if let eventCalendars = event["calendar"] as? [[String: Any]] {
            self.calendars = eventCalendars.map({ return OtherUserEventCalendar(with: $0) })
        }
        if let eventCalendars = event["notifyCalendar"] as? [[String: Any]] {
            self.notifyCalendars = eventCalendars.map({ return OtherUserEventCalendar(with: $0) })
        }
        if let creator = event["createdBy"] as? [String: Any] {
            self.createdBy = OtherUserEventCreator(with: creator)
        }
        if let modifier = event["modifiedBy"] as? [String: Any] {
            self.modifiedBy = OtherUserEventModifier(with: modifier)
        }
        if let inviters = event["invitees"] as? [[String: Any]] {
            self.invitees = inviters.map({ return OtherUserEventInvitees(with: $0) })
        }
        if let tags = event["tags"] as? [[String: String]] {
            let arrayTags = tags.compactMap({$0.values.first})
            self.tags = arrayTags
        }
        if let attendees = event["attendees"] as? [[String: Any]] {
            self.attendees = attendees.compactMap({ return OtherUserEventAttendees(with: $0) })
        }
        if let attachments = event["attachments"] as? [[String: Any]] {
            self.attachments = attachments.compactMap({ return OtherUserEventAttachment(with: $0) })
        }
        if let reminders = event["reminders"] as? [String: Any] {
            self.reminder = OtherUserReminders(with: reminders)
        }
        self.userColor = userColor
        self.userColorCode = colorCode
    }
    
    func readEventCalendarName() -> String {
        if self.readMainCalendar()?.parentCalendarId == 0.0,  let creator = self.createdBy {
            return creator.fullName + " " + (self.readMainCalendar()?.calendarName ?? Strings.empty)
        }
        return self.readMainCalendar()?.calendarName ?? Strings.empty
    }
    
    func readReminder() -> OtherUserReminders? {
        guard  self.reminderId != 0, let reminder = self.reminder else {
            return nil
        }
        return reminder
    }
    
    func readMainCalendar() -> OtherUserEventCalendar? {
        return self.calendars.filter({ return $0.parentCalendarId != 0 }).first ?? self.calendars.first
    }
        
    func readSortedTime() -> Date {
        return self.sortedTime ?? self.readStartDateTime()
    }
    
    func isEventAccepted()->Bool {
        if let invitees = self.invitees.filter({ return $0.userId == Session.shared.readUserId() }).first {
            return invitees.sharedStatus == 1
        }
        else if self.isSocialEvent {
            if let email = Session.shared.readUser()?.email, !email.isEmpty, let attendee = self.attendees.filter({ $0.email == email }).first {
                return attendee.readSharedStatus == 1
            }
            else {
                return false
            }
        }
        return true
    }
    
    func readOrginalUserStartDateTime() -> Date {
        if let timeZone = self.readTimeZone(), !self.isAllDay {
            return self.readStartDateTime().convertTimeZone(timeZone, to: TimeZone.current)
        }
        return self.readStartDateTime()
    }
    
    func readStartDateTimeFromDate(_ date: Date) -> Date {
        if self.isAllDay {
            return (date.stringFromDate(format: DateFormatters.MMDDYYYY) + Strings.space + self.startTime).stringToDate(formatter: DateFormatters.MMDDYYYYHMMSSA) ?? self.readStartDateTime()
        }
        let calculatedDate = (date.stringFromDate(format: DateFormatters.MMDDYYYY) + Strings.space + self.startTime).stringToDate(formatter: DateFormatters.MMDDYYYYHMMSSA, timeZone: TimeZone(abbreviation: "UTC")!) ?? self.readStartDateTime()
        if calculatedDate.initialHour() == date || !self.isEventOnSameDayForUser() {
            let timezoneOffset = self.readStartDateDayLightTimeOffSet() - self.readDayLightTimeOffSetForDate(calculatedDate)
            return calculatedDate.adding(seconds: timezoneOffset)
        }
        else {
            let days = calculatedDate.initialHour().daysBetweenDate(toDate: date)
            let orginalDate = calculatedDate.addDays(days)
            let timezoneOffset = self.readStartDateDayLightTimeOffSet() - self.readDayLightTimeOffSetForDate(orginalDate)
            return orginalDate.adding(seconds: timezoneOffset)
        }
    }
    
    func isEventOnSameDayForUser() -> Bool {
        if let timeZone = self.readTimeZone(){
            return self.readStartDateTime().convertTimeZone(timeZone, to: TimeZone.current).initialHour() ==  self.readStartDateTime().initialHour()
        }
        return true
    }
    
    func readEndDateTimeFromDate(_ date: Date) -> Date {
        return self.readStartDateTimeFromDate(date).addingTimeInterval(self.readEndDateTime().timeIntervalSince1970 - self.readStartDateTime().timeIntervalSince1970)
    }
    
    func readTimeZoneOfEvent() -> String? {
        if let recurrenceTimeZone = self.recurranceEvent?.recurrenceTimeZone, !recurrenceTimeZone.isEmpty {
            return recurrenceTimeZone
        }
        return self.originalStartTimeZone
    }
    
    func readTimeZone() -> TimeZone? {
        guard let timezone = self.readTimeZoneOfEvent(), !timezone.isEmpty else { return nil }
        let eventTimeZone = timezone.convertTimeZoneToAppleZone()
        return (eventTimeZone == "GMT" || eventTimeZone.hasPrefix("tzone")) && self.responseStatus != "organizer" ? TimeZone.current : TimeZone(identifier: eventTimeZone)
    }
    
    func readStartDateDayLightTimeOffSet() -> Int {
        guard let eventOrginalTimeZone = self.readTimeZone() else { return 0 }
        return Int(eventOrginalTimeZone.daylightSavingTimeOffset(for: self.readStartDateTime()))
    }
    
    func readDayLightTimeOffSetForDate(_ date: Date) -> Int {
        guard let eventOrginalTimeZone = self.readTimeZone() else { return 0 }
        return Int(eventOrginalTimeZone.daylightSavingTimeOffset(for: date))
    }
    
    func readEndTime() -> String { return self.endTime }
    
    func readStartDateTime() -> Date {
        return self.startDateTime ?? Date()
    }

    func readEndDateTime() -> Date {
        return self.endDateTime ?? Date()
    }
    
    func isHTMLContent() -> Bool { return self.bodyContentType.lowercased() == "html" }
    
    func readOrginalStartDateTime() -> Date? {
        return self.originalStartDateTime
    }
    
    func readAllChildEvents() -> [OtherUserEvent] {
        return self.otherSubEvents
    }
    
    func readOtherUsers() -> [OtherUser] {
        var otherUsers: [OtherUser] = []
        Dictionary(grouping: self.attendees, by: { $0.email }).forEach({ (email, socialAttendees) in
            if let firstAttendee = socialAttendees.first {
                otherUsers.append(OtherUser(attendees: firstAttendee, deletable: false))
            }
        })
        let emailIds = otherUsers.compactMap({ return $0.email.isEmpty ? nil : $0.email })
        otherUsers += self.invitees.filter({ return !emailIds.contains($0.email) }).map({ return OtherUser(invitee: $0) })
        return otherUsers.filter({ user in
            let createrValue = self.readSocialCalendarEventCreatorEmail()
            if createrValue == user.email || createrValue == user.phone { return false }
            return true
        })
    }
    
    func readRecurrenceEndDate() -> Date? {
        return self.recurranceEvent?.readEndDateOfEvent(self)
    }
    
    func readAllAvailableDates(from: Date, to: Date) -> [Date] {
        if self.isRecurrence {
            guard let availableDate = self.recurranceEvent?.readAllAvailableDates(from: from, to: to, event: self) else { return [] }
            var excludedDates: [Date] = []
            self.otherSubEvents.forEach({ childEvent in
                if let googleDeletedItem = childEvent.readOrginalStartDateTime() { excludedDates.append(googleDeletedItem.initialHour()) }
                else { excludedDates.append(childEvent.readStartDateTime().initialHour()) }
            })
            let availableDates: [Date] = availableDate.compactMap({ let initialDate = $0.initialHour(); if excludedDates.contains(initialDate) { return nil } else { return initialDate } })
            return availableDates
        }
        else {
            let eventDateTime = self.readStartDateTime().initialHour()
            return eventDateTime >= from && eventDateTime <= to ? [eventDateTime] : []
        }
    }
    
    func readCalendarColorCode() -> UIColor {
        return Storage().readCalendarColorFromCode(self.readMainCalendar()?.calendarColorCode)
    }
    
    func readCalendarTextColorCode() -> UIColor {
        return Storage().readTextColorFromCode(self.readMainCalendar()?.calendarColorCode)
    }
    
    func isSocialCalendarEvent() -> Bool {
        return self.readMainCalendar()?.isSocialCalendar() ?? false
    }
    
    func readSocialCalendarEventCreatorName() -> String {
        guard let calendar = self.readMainCalendar() else {
            return Strings.empty
        }
        var socialCreator: String = Strings.empty
        switch calendar.calendarType {
        case 1 where self.isSocialEvent:
            socialCreator = !(self.creatorName).isEmpty ? self.creatorName : self.creatorEmail
        case 2 where self.isSocialEvent:
            socialCreator = !(self.organizerName).isEmpty ? self.organizerName : self.organizerEmail
        case 3 where self.isSocialEvent:
            socialCreator = !(self.organizerName ).isEmpty ? self.organizerName : self.organizerEmail
        default:
            break
        }
        if socialCreator.isEmpty, let creator = self.createdBy {
            if calendar.calendarType == 3 && self.isSocialEvent {
                return self.readMainCalendar()?.calendarName ?? Strings.empty
            }
            return !creator.fullName.isEmpty ? creator.fullName : (!creator.email.isEmpty ? creator.email : creator.phone)
        }
        return socialCreator
    }
    
    func readSocialCalendarEventCreatorEmail() -> String {
        guard let calendar = self.readMainCalendar() else {
            return Strings.empty
        }
        var socialCreator: String = Strings.empty
        switch calendar.calendarType {
        case 1 where self.isSocialEvent:
            socialCreator = self.creatorEmail
        case 2 where self.isSocialEvent:
            socialCreator = self.organizerEmail
        case 3 where self.isSocialEvent:
            socialCreator = self.organizerEmail
        default:
            break
        }
        if socialCreator.isEmpty, let creator = self.createdBy {
            if calendar.calendarType == 3 && self.isSocialEvent {
                return Strings.empty
            }
            return !creator.email.isEmpty ? creator.email : creator.phone
        }
        return socialCreator
    }
    
    func readUserColorCode() -> UIColor? {
        guard let color = self.userColor else {
            return self.readCalendarColorCode()
        }
        return color
    }
    
    func readUserTextColorCode() -> UIColor? {
        guard let colorCode = self.userColorCode else {
            return self.readCalendarTextColorCode()
        }
        return Storage().readTextColorFromCode(colorCode)
    }
    
    func readOtherUserColorCode() -> String {
        guard let color = self.userColorCode else {
            return Strings.empty
        }
        return color
    }
    
    func readRepeatDropDownValue() -> RepeatDropDown {
        let repeatDropDown = RepeatDropDown(dropDownItem: DropDownItem(name: Strings.never, type: .eNever), untilDate: self.setUntil(recurrence: self.recurranceEvent?.rule ?? Strings.empty, at: self.readStartDateTime()))
        if let repeatValue = self.recurranceEvent?.rule.slice(from: "FREQ=", to: ";") {
            switch repeatValue {
            case "DAILY":
                repeatDropDown.dropDownItem = DropDownItem(name: Strings.everyDay, type: .eEveryDay)
            case "WEEKLY":
                repeatDropDown.dropDownItem = DropDownItem(name: Strings.everyWeek, type: .eEveryWeek)
            case "MONTHLY":
                repeatDropDown.dropDownItem = DropDownItem(name: Strings.everyMonth, type: .eEveryMonth)
            case "YEARLY":
                 repeatDropDown.dropDownItem = DropDownItem(name: Strings.everyYear, type: .eEveryYear)
            default:
                break
            }
        }
        repeatDropDown.untilDate = self.setUntil(recurrence: self.recurranceEvent?.rule ?? Strings.empty, at: self.readStartDateTime())
        return repeatDropDown
    }
    
    func saveOtherUserTag(_ tags: [String]) {
        self.tags = tags
    }
    
    private func setUntil(recurrence: String, at date: Date) -> Date {
        if let range = recurrence.range(of: "UNTIL=") {
            let untilDate = recurrence[range.upperBound...].trimmingCharacters(in: .whitespaces)
            if let dateUntil = untilDate.toDate(withFormat: DateFormatters.YYYMMDD) {
                return dateUntil
            }
        }
        return Date()
    }
    
    func readRecurrenceStatement() -> String {
        var repeatString = ""
        if self.isRecurrence {
            if let planItEventRecurrence = self.recurranceEvent {
                repeatString += "Repeats "
                switch self.getRepeatValueType(recurrence: planItEventRecurrence.readRuleOfEvent(self)) {
                case .eEveryDay:
                    let interval = planItEventRecurrence.findIntervalInRuleOfEvent(self)
                    let everyYear = "\(interval.isEmpty ? "Yearly " : "every \(interval) \(Strings.years) " )"
                    let everyDay = "\(interval.isEmpty ? "Daily " : "every \(interval) \(Strings.days) " )"
                    repeatString += planItEventRecurrence.readRuleOfEvent(self).contains("BYMONTH=") ? everyYear : everyDay
                case .eEveryWeek:
                    repeatString += planItEventRecurrence.getRepeatWeeklyStringOfEvent(self)
                case .eEveryMonth:
                    repeatString += planItEventRecurrence.getRepeatMonthyStringOfEvent(self)
                case .eEveryYear:
                    let interval = planItEventRecurrence.findIntervalInRuleOfEvent(self)
                    repeatString += "\(interval.isEmpty ? "Yearly " : "every \(interval) Year " )"
                default:
                    repeatString += Strings.empty
                }
                if let repeatUntilDate = self.readRecurrenceEndDate() {
                    repeatString += "until \(repeatUntilDate.stringFromDate(format: DateFormatters.DDHMMMMHYYYY))"
                }
            }
        }
        return repeatString
    }
    
    func getWeekDays(weekDays: [Int]) -> [String] {
        var weekDayItem: [String] = []
        weekDays.forEach { (int) in
            weekDayItem.append(int.getWeekDay())
        }
        return weekDayItem
    }
    
    private func getFrequency(recurrence: String) -> String? {
        if let repeatValue = recurrence.slice(from: "FREQ=", to: ";") {
            return repeatValue
        }
        else if let repeatValue = recurrence.slice(from: "FREQ=") {
            return repeatValue
        }
        return nil
    }
    
    private func getRepeatValueType(recurrence: String) -> DropDownOptionType {
        if let repeatValue = self.getFrequency(recurrence: recurrence) {
            switch repeatValue.uppercased() {
            case "DAILY":
                return .eEveryDay
            case "WEEKLY":
                return .eEveryWeek
            case "MONTHLY", "RELATIVEMONTHLY", "ABSOLUTEMONTHLY":
                return .eEveryMonth
            case "YEARLY":
                 return .eEveryYear
            default:
                break
            }
        }
        return .eNever
    }
    
    func createStringForWebView() -> String {
        var htmlString = """
        <header><meta name='viewport' content='width=device-width, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, user-scalable=no'></header>
        """
        if self.bodyContentType == "html" {
            htmlString += "\(self.eventDescription)"
        }
        if !self.htmlLink.isEmpty  {
            htmlString += """
            <p style="color: #4485b8;"><span style="text-decoration: underline;"><span style="color: #808080; text-decoration: underline;">Html Link:</span></span></p>
            <ul>
            <li style="color: #4485b8;">
            """
            htmlString += "\(self.htmlLink)"
            htmlString += """
            </li>
            </ul>
            <p></p>
            """
        }
        return htmlString
    }
    
    func readConferenceData() -> String {
        var entryPointsDatas: String = Strings.empty
        if !self.fullConferenceData.isEmpty {
            let conferenceData = self.readConferenceData(self.fullConferenceData)
            if let entryPoints = conferenceData["entryPoints"] as? [[String: Any]] {
                entryPointsDatas += self.setConferenceData(conferenceType: .phone, entryPoints: entryPoints)
                entryPointsDatas += self.setConferenceData(conferenceType: .sip, entryPoints: entryPoints)
                entryPointsDatas += self.setConferenceData(conferenceType: .video, entryPoints: entryPoints)
            }
        }
        else if !self.conferenceUrl.isEmpty {
            entryPointsDatas += "\(self.conferenceUrl)\n\n\n"
        }
        return entryPointsDatas
    }
    
    private func readConferenceData(_ conferenceString: String) -> [String: Any] {
        let data = conferenceString.data(using: .utf8)!
        do {
            if let jsonArray = try JSONSerialization.jsonObject(with: data, options : .allowFragments) as? [String: Any] { return jsonArray }
            else { return [:] }
        } catch _ as NSError { return [:] }
    }
    
    private func setConferenceData(conferenceType: ConferenceType, entryPoints: [[String: Any]]) -> String {
        var conferenceData: String = Strings.empty
        if let phoneEntryPoint = entryPoints.filter({ data in
            if let type = data["entryPointType"] as? String, type == conferenceType.rawValue {
                return true
            }
            return false
        }).first {
            if let label = phoneEntryPoint["label"] as? String {
                conferenceData = label+"\n"
            }
            if conferenceType == .phone, let label = phoneEntryPoint["label"] as? String {
                conferenceData = label+"\n"
            }
            if conferenceType == .video, let label = phoneEntryPoint["uri"] as? String {
                conferenceData = label+"\n"
            }
            if let accessCode = phoneEntryPoint["accessCode"] as? String {
                conferenceData += "ID: "+accessCode+"\n"
            }
            if let passcode = phoneEntryPoint["passcode"] as? String {
                conferenceData += "Passcode: "+passcode+"\n"
            }
        }
        return conferenceData.isEmpty ? conferenceData : conferenceData+"\n\n"
    }
    
    func readLocationString() -> String {
        let locatinData = self.location.split(separator: Strings.locationSeperator)
        if let locationName = locatinData.first {
            return String(locationName)
        }
        return Strings.empty
    }
    
    func createTextForPrediction() -> String {
        var text: String = ""
        text += self.eventName
        text += self.readLocationString().isEmpty ? Strings.empty : ", "+self.readLocationString()
        text += (self.eventDescription.isEmpty || self.eventDescription.filter ({ !$0.isWhitespace }).isHtml()) ? Strings.empty : ", "+self.eventDescription
        return text
    }
}
