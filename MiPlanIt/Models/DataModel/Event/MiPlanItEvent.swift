//
//  MiPlanItEvent.swift
//  MiPlanIt
//
//  Created by Febin Paul on 15/04/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation
// import RRuleSwift
import EventKit

class MiPlanItEvent {
    
    var event: PlanItEvent?
    var eventId: String?
    var tags = ["Events"]
    var isAllday = false
    var isTravelling = false
    var isRecurrance = false
    var isOtherUserEvent = false
    var endTime = Strings.empty
    var location = Strings.empty
    var eventName = Strings.empty
    var recurrence = Strings.empty
    var bodyContentType = Strings.empty
    var eventDescription = Strings.empty
    var recurringEventId = Strings.empty
    var calendarName = Strings.unavailable
    var parent: PlanItEvent?
    var dateEvent: DateSpecificEvent?
    var invitees: [OtherUser] = []
    var startDate = Date().nearestHalfHour()
    var endDate = Date().nearestHalfHour().adding(seconds: 1800)
    var editType = RecursiveEditOption.default
    var placeLatitude: Double?
    var placeLongitude: Double?
    var notifycalendars: [UserCalendarVisibility] = []
    var remindValue: ReminderModel?
    var otherLinks = Strings.empty
    var conferenecType = Strings.empty
    var conferenecUrl = Strings.empty
    var fullConferenceData = Strings.empty
    var appEventId = UUID().uuidString

    lazy var calendars: [UserCalendarVisibility] = {
        return DatabasePlanItCalendar().readAllPlanitCalendars().filter({ return $0.parentCalendarId == 0 }).map({ return UserCalendarVisibility(with: $0) })
    }()
    
    func showDateOnChangeAllDay() -> Date {
        let date1 = self.endDate.addDays(-1)
        return self.startDate > date1 ? self.startDate : date1
    }
    
    func readMainCalendar() -> PlanItCalendar? {
        return self.calendars.filter({ return $0.calendar.parentCalendarId != 0 }).first?.calendar ?? self.calendars.first?.calendar
    }
    
    func isPendingCalendars() -> Bool {
        return self.readMainCalendar()?.isPending ?? false
    }
    
    func isPendingParentEvent() -> Bool {
        return self.parent?.isPending ?? false
    }
    
    func isPendingEvent() -> Bool {
        return self.event?.isPending ?? false
    }
    
    func readEventCalendarName() -> String {
        return self.readMainCalendar()?.readValueOfCalendarName() ?? Strings.empty
    }
    
    func removeCalendarFromNotifyCalendars(_ selectedCalendars: [UserCalendarVisibility]) {
        let calendarIds = selectedCalendars.map({ return $0.calendar.calendarId })
        self.notifycalendars.removeAll(where: { return calendarIds.contains($0.calendar.calendarId )})
    }
    
    func isEdit() -> Bool {
        guard let identifier = self.eventId, !identifier.isEmpty else {
            return false
        }
        return true
    }
    
    func readRecurrence() -> String {
        if self.editType != .thisPerticularEvent {
            return self.recurrence
        }
        return Strings.empty
    }
    
    func readOrginalStartDateTime() -> Date {
        if let parentEvent = self.parent, let eventDate = self.dateEvent {
            return parentEvent.readStartDateTimeFromDate(eventDate.startDate)
        }
        else {
            return self.startDate
        }
    }
    
    func createLocationParamValue() -> String {
        var locationParam = self.location
        if let latitude = self.placeLatitude, let longitude = self.placeLongitude  {
            locationParam += String(Strings.locationSeperator)+String(latitude)+String(Strings.locationSeperator)+String(longitude)
        }
        return locationParam
    }
    
    func readLocationName() -> String? {
        let locationData = self.location.split(separator: Strings.locationSeperator)
        guard let locationName = locationData.first else { return Strings.empty }
        return String(locationName)
    }
    
    func createTextForPrediction() -> String {
        var text: String = ""
        let locationName = self.readLocationName() ?? Strings.empty
        text += self.eventName
        text += locationName.isEmpty ? Strings.empty : ", "+locationName
        text += self.eventDescription.isEmpty ? Strings.empty : ", "+self.eventDescription
        return text
    }
    
    func getDefaultTags() -> [String] {
        var defaultTag = ["Events"]
        self.calendars.forEach { (calendar) in
            let calendarName = calendar.calendar.readValueOfParentCalendarId() == "0" ? Strings.miPlaniT : calendar.calendar.readValueOfCalendarName()
            defaultTag.append(calendarName)
        }
        defaultTag = defaultTag.filter({ !$0.isEmpty })
        return defaultTag
    }
    
    func createRequestParameter(isUpdateTagsOnly tagOnly: Bool) -> [String: Any] {
        switch self.editType {
        case .default:
            return self.createDefaultRequestForEvent(isUpdateTagsOnly: tagOnly)
        case .thisPerticularEvent:
            return self.createPerticularEventRequestForEvent()
        case .allEventInTheSeries:
            return self.createEventInTheSeriesRequestForEvent()
        case .allFutureEvent:
            return self.createFutureEventRequestForEvent()
        }
    }
    
    func createBasicParamsForParentEvent() -> [String: Any] {
        guard let parent = self.parent else { return [:] }
        var requestParameter: [String: Any] = ["description": parent.readValueOfEventDescription(), "location": parent.readLocation(), "startDate": parent.readStartDate(), "endDate": parent.readEndDate(), "availabilityFlag": parent.isUserTravelling() ? 1 : 0, "isAllDay": parent.isAllDay, "eventName": parent.readValueOfEventName(), "createdAt": Date().stringFromDate(format: DateFormatters.YYYYHMMDDSHHMMSS, timeZone: TimeZone(abbreviation: "UTC")!), "tags": parent.createTags(), "invitees": parent.createInvitees(), "recurringEventId": parent.readRecurringEventId(), "eventId": parent.readValueOfEventId(), "appEventId": parent.readValueOfAppEventId()]
        if let recurrence = parent.readPlanItRecurrance(), var recurrenceRule = RecurrenceRule(rruleString: recurrence.readRule()) {
            recurrenceRule.recurrenceEnd = EKRecurrenceEnd(end: self.readOrginalStartDateTime().initialHour().adding(minutes: -1))
            recurrenceRule.startDate = parent.readStartDateTime()
            requestParameter["recurrence"] = [recurrenceRule.toRRuleString()]
        }
        if let reminderParam = parent.reminder?.readReminderNumericValueParameter() {
            requestParameter["reminders"] =  reminderParam
        }
        if self.isAllday {
            requestParameter["startDate"] = parent.readStartDateTime().stringFromDate(format: DateFormatters.YYYYHMMMHDD)
           requestParameter["endDate"] = parent.readEndDateTime().stringFromDate(format: DateFormatters.YYYYHMMMHDD)
        }
        else {
            requestParameter["startDate"] = parent.readStartDateTime().stringFromDate(format: DateFormatters.YYYYHMMDDSHHMMSS, timeZone: TimeZone(abbreviation: "UTC")!)
            requestParameter["endDate"] = parent.readEndDateTime().stringFromDate(format: DateFormatters.YYYYHMMDDSHHMMSS, timeZone: TimeZone(abbreviation: "UTC")!)
        }
        requestParameter["originalStartTimeZone"] = TimeZone.current.identifier
        requestParameter["originalEndTimeZone"] = TimeZone.current.identifier
        
        requestParameter["calendar"] = self.calendars.map({ return ["calendarId": $0.calendar.readValueOfCalendarId(), "accessLevel": $0.visibility.cleanValue() ]})
        requestParameter["notifyCalendar"] = self.notifycalendars.map({ return ["calendarId": $0.calendar.readValueOfCalendarId(), "accessLevel": $0.visibility.cleanValue() ]})
        if !parent.readconferenceURL().isEmpty || !parent.readconferenceType().isEmpty {
            var conferenceData: [String: Any] = [:]
            conferenceData["conferenceType"] = parent.readconferenceType()
            conferenceData["url"] = parent.readconferenceURL()
            conferenceData["fullConferenceData"] = parent.readFullConferenceData()
            requestParameter["conferenceData"] = conferenceData
        }
        return requestParameter
    }
    
    func createBasicParamsForEvent(isUpdateTagsOnly: Bool = false) -> [String: Any] {
        var requestParameter: [String: Any] = ["description": self.eventDescription, "location": self.createLocationParamValue(), "availabilityFlag": self.isTravelling ? 1 : 0, "isAllDay": self.isAllday, "eventName": self.eventName, "recurrence": self.readRecurrence().isEmpty ? "" : [self.readRecurrence()] , "createdAt": Date().stringFromDate(format: DateFormatters.YYYYHMMDDSHHMMSS, timeZone: TimeZone(abbreviation: "UTC")!), "tags": self.tags, "invitees": self.createInvitees(), "recurringEventId": self.recurringEventId]
        
        if self.isAllday {
            requestParameter["startDate"] = self.startDate.stringFromDate(format: DateFormatters.YYYYHMMMHDD)
            requestParameter["endDate"] = self.endDate.stringFromDate(format: DateFormatters.YYYYHMMMHDD)
        }
        else {
            requestParameter["startDate"] = self.startDate.trimSeconds().stringFromDate(format: DateFormatters.YYYYHMMDDSHHMMSS, timeZone: TimeZone(abbreviation: "UTC")!)
            requestParameter["endDate"] = self.endDate.trimSeconds().stringFromDate(format: DateFormatters.YYYYHMMDDSHHMMSS, timeZone: TimeZone(abbreviation: "UTC")!)
        }
        if let reminderParam = self.remindValue?.readReminderNumericValueParameter() {
            requestParameter["reminders"] =  reminderParam
        }
        else {
            requestParameter["reminders"] =  nil
        }
        requestParameter["originalStartTimeZone"] = TimeZone.current.identifier
        requestParameter["originalEndTimeZone"] = TimeZone.current.identifier
        
        requestParameter["calendar"] = self.calendars.map({ return ["calendarId": $0.calendar.readValueOfCalendarId(), "accessLevel": $0.visibility.cleanValue() ]})
        requestParameter["notifyCalendar"] = self.notifycalendars.map({ return ["calendarId": $0.calendar.readValueOfCalendarId(), "accessLevel": $0.visibility.cleanValue() ]})
        if !self.conferenecUrl.isEmpty || !self.conferenecType.isEmpty {
            var conferenceData: [String: Any] = [:]
            conferenceData["conferenceType"] = self.conferenecType
            conferenceData["url"] = self.conferenecUrl
            conferenceData["fullConferenceData"] = self.fullConferenceData
            requestParameter["conferenceData"] = conferenceData
        }
        if isUpdateTagsOnly {
            requestParameter["isUpdateTagsOnly"] = true
        }
        return requestParameter
    }
    
    func createDefaultRequestForEvent(isUpdateTagsOnly tagsOnly: Bool) -> [String: Any] {
        var mainParam: [String: Any] = [:]
        var requestParam = self.createBasicParamsForEvent(isUpdateTagsOnly: tagsOnly)
        requestParam["userId"] = Session.shared.readUserId()
        if self.isEdit(), let identifier = self.eventId {
            requestParam["eventId"] = identifier
            mainParam["updateEvents"] = [requestParam]
        }
        else {
            mainParam["appEventId"] = self.appEventId
            mainParam["insertEvents"] = [requestParam]
        }
        return mainParam
    }
    
    func createPerticularEventRequestForEvent() -> [String: Any] {
        var mainParam: [String: Any] = [:]
        var requestParam = self.createBasicParamsForEvent()
        requestParam["userId"] = Session.shared.readUserId()
        if let parent = self.parent, let parentEventId = self.parent?.readValueOfEventId() {
            requestParam["recurringEventId"] = parentEventId
            requestParam["isOriginalAllDay"] = parent.isAllDay
            if parent.isAllDay {
                requestParam["originalStartTime"] = self.readOrginalStartDateTime().stringFromDate(format: DateFormatters.YYYYHMMDDSHHMMSS)
            }
            else {
                requestParam["originalStartTime"] = self.readOrginalStartDateTime().stringFromDate(format: DateFormatters.YYYYHMMDDSHHMMSS, timeZone: TimeZone(abbreviation: "UTC")!)
            }
        }
        mainParam["insertEvents"] = [requestParam]
        return mainParam
    }
    
    func resetLocation() {
        self.location = Strings.empty
        self.placeLatitude = nil
        self.placeLongitude = nil
    }
    
    func setLocation(_ location: String) -> String {
        if location.isEmpty { self.location = Strings.empty }
        let locatinData = location.split(separator: Strings.locationSeperator)
        if let locationName = locatinData.first {
            self.location = String(locationName)
        }
        if locatinData.count > 2 {
            self.placeLatitude = Double(locatinData[1])
            self.placeLongitude = Double(locatinData[2])
        }
        return self.location
    }
    
    func setLocationFromMap(locationName: String, latitude: Double?, longitude: Double?) -> String {
        self.location = locationName
        self.placeLatitude = latitude
        self.placeLongitude = longitude
        return self.location
    }
    
    func createEventInTheSeriesRequestForEvent() -> [String: Any] {
        var mainParam: [String: Any] = [:]
        var requestParam = self.createBasicParamsForEvent()
        requestParam["userId"] = Session.shared.readUserId()
        if self.isEdit(), let identifier = self.eventId {
            requestParam["removeChild"] = true
            requestParam["eventId"] = identifier
            mainParam["updateEvents"] = [requestParam]
        }
        else {
            mainParam["appEventId"] = self.appEventId
            mainParam["insertEvents"] = [requestParam]
        }
        return mainParam
    }
    
    func createFutureEventRequestForEvent() -> [String: Any] {
        var mainParam: [String: Any] = [:]
        var requestParentParam = self.createBasicParamsForParentEvent()
        requestParentParam["removeFutureChild"] = true
        var requestParam = self.createBasicParamsForEvent()
        if !self.readRecurrence().isEmpty, var recurrenceRule = RecurrenceRule(rruleString: self.readRecurrence()) {
            recurrenceRule.startDate = self.startDate
            requestParam["recurrence"] = [recurrenceRule.toRRuleString()]
        }
        requestParam["userId"] = Session.shared.readUserId()
        requestParentParam["userId"] = Session.shared.readUserId()
        mainParam["updateEvents"] = [requestParentParam]
        mainParam["insertEvents"] = [requestParam]
        return mainParam
    }

    func createInvitees() -> [[String: Any]] {
        let userIds = self.invitees.filter({ return !$0.userId.isEmpty }).map({ return ["userId": $0.userId] })
        let emails = self.invitees.filter({ return $0.userId.isEmpty && !$0.email.isEmpty }).map({ return ["email": $0.email] })
        let phones = self.invitees.filter({ return $0.userId.isEmpty && !$0.phone.isEmpty }).map({ return ["phone": $0.phone, "countryCode": $0.countryCode] })
        var users = userIds + emails + phones
        guard let event = self.event, event.isSocialEvent else {
            users.append(["userId": Session.shared.readUserId()])
            return users
        }
        return users
    }
}
