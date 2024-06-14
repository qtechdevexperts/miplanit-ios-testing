//
//  MiPlanitShareLink.swift
//  MiPlanIt
//
//  Created by Febin Paul on 26/03/21.
//  Copyright © 2021 Arun. All rights reserved.
//

import Foundation

class MiPlanitShareLink {
    
    var tags = ["Events"]
    var location = Strings.empty
    var eventName = Strings.empty
    var eventDescription = Strings.empty
    var invitees: [OtherUser] = []
    var startDate = Date()
    var endDate = Date()
    var startRangeTime = Date()
    var endRangeTime = Date()
    var placeLatitude: Double?
    var placeLongitude: Double?
    var remindValue: ReminderModel?
    var appShareLinkId = UUID().uuidString
    var duration: DurationModel = DurationModel(duartion: 15, duartionType: 1)
    var excludeWeekEnds: Bool = true
    var calendarName = Strings.unavailable
    var planItShareLink: PlanItShareLink?
    
    lazy var calendars: [UserCalendarVisibility] = {
        return DatabasePlanItCalendar().readAllPlanitCalendars().filter({ return $0.parentCalendarId == 0 }).map({ return UserCalendarVisibility(with: $0) })
    }()
    
    init() {
        let startingTime = Date().initialHour().adding(hour: 8)
        let startingDayLightInterval = Int(TimeZone.current.daylightSavingTimeOffset(for: Date())) - Int(TimeZone.current.daylightSavingTimeOffset(for: startingTime))
        let actualStartTime = startingTime.adding(seconds: startingDayLightInterval)
        self.setStartEndRange(start: actualStartTime, end: actualStartTime.adding(hour: 9))
    }
    
    init(_ miPlanIt: PlanItShareLink) {
        self.planItShareLink = miPlanIt
        self.tags = miPlanIt.readTags().compactMap({ $0.readTag() })
        self.location = miPlanIt.readLocation()
        self.eventName = miPlanIt.readEventName()
        self.appShareLinkId = miPlanIt.readEventAppShareLinkId()
        self.eventDescription = miPlanIt.readDescription()
        self.invitees = miPlanIt.readAllShareLinkInvitees().map({ OtherUser(invitee: $0) })
        self.startDate = miPlanIt.readStartDateTimeTimeSlot()
        self.startRangeTime = miPlanIt.readStartDateTimeTimeSlot()
        self.endRangeTime = miPlanIt.readEndDateTimeTimeSlot()
        self.endDate = miPlanIt.readEndDateTimeTimeSlot()
        if  let reminder = miPlanIt.readFirstReminder() {
            self.remindValue = ReminderModel(reminder, from: .shareLink)
        }
        if let latLong = miPlanIt.readPlaceLatLong() {
            self.placeLatitude = latLong.0
            self.placeLongitude = latLong.1
        }
        if  miPlanIt.duration != 0.0 {
            self.duration = DurationModel(duartion: miPlanIt.duration, duartionType: miPlanIt.duration > 60 ? 2 : 1)
        }
        self.excludeWeekEnds = miPlanIt.weekEndExcluded()
        let visibilityCalendars = miPlanIt.readAllCalendars()
        self.calendars = miPlanIt.readAllAvailableCalendars(includingParent: true).map({ calendar in return UserCalendarVisibility(with: calendar, visibility: visibilityCalendars.contains( where: { return (($0.calendarId == calendar.calendarId && calendar.calendarId != 0) || ($0.appCalendarId == calendar.appCalendarId && !calendar.readValueOfAppCalendarId().isEmpty)) && $0.accessLevel == 1}) ? 1 : 0) })
    }
    
    func setLocationFromMap(locationName: String, latitude: Double?, longitude: Double?) -> String {
        self.location = locationName
        self.placeLatitude = latitude
        self.placeLongitude = longitude
        return self.location
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
    
    func setStartEndRange(start: Date, end: Date) {
        self.startRangeTime = start
        self.endRangeTime = end
    }
    
    func resetLocation() {
        self.location = Strings.empty
        self.placeLatitude = nil
        self.placeLongitude = nil
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
    
    func createTextForPrediction() -> String {
        var text: String = ""
        let locationName = self.readLocationName() ?? Strings.empty
        text += self.eventName
        text += locationName.isEmpty ? Strings.empty : ", "+locationName
        text += self.eventDescription.isEmpty ? Strings.empty : ", "+self.eventDescription
        return text
    }
    
    func readLocationName() -> String? {
        let locationData = self.location.split(separator: Strings.locationSeperator)
        guard let locationName = locationData.first else { return Strings.empty }
        return String(locationName)
    }
    
    func createLocationParamValue() -> String {
        var locationParam = self.location
        if let latitude = self.placeLatitude, let longitude = self.placeLongitude  {
            locationParam += String(Strings.locationSeperator)+String(latitude)+String(Strings.locationSeperator)+String(longitude)
        }
        return locationParam
    }
    
    func readMainCalendar() -> PlanItCalendar? {
        return self.calendars.filter({ return $0.calendar.parentCalendarId != 0 }).first?.calendar ?? self.calendars.first?.calendar
    }
    
    func showDateOnChangeStartDate() -> Date {
        let date1 = self.endDate
        return self.startDate > date1 ? self.startDate : date1
    }
    
    func createInvitees() -> [[String: Any]] {
        let emails = self.invitees.filter({ return $0.userId.isEmpty && !$0.email.isEmpty }).map({ return ["email": $0.email] })
        return emails
    }
    
    func createRequestParameter() -> [String: Any] {
        var requestParameter: [String: Any] = ["description": self.eventDescription, "location": self.createLocationParamValue(), "eventName": self.eventName, "tags": self.tags, "invitees": self.createInvitees()]
        let startDuration = self.startRangeTime.timeIntervalSince1970 - self.startRangeTime.initialHour().timeIntervalSince1970
        let finalStartDate = self.startDate.initialHour().addingTimeInterval(startDuration)
        let endDuration = self.endRangeTime.timeIntervalSince1970 - self.endRangeTime.initialHour().timeIntervalSince1970
        let finalEndDate = self.endDate.initialHour().addingTimeInterval(endDuration)
        
        requestParameter["startDate"] = finalStartDate.stringFromDate(format: DateFormatters.YYYYHMMMHDD, timeZone: TimeZone(abbreviation: "UTC")!)
        requestParameter["endDate"] = finalEndDate.stringFromDate(format: DateFormatters.YYYYHMMMHDD, timeZone: TimeZone(abbreviation: "UTC")!)
        requestParameter["startTime"] = finalStartDate.stringFromDate(format: DateFormatters.HHCMMCSS, timeZone: TimeZone(abbreviation: "UTC")!)
        requestParameter["endTime"] = finalEndDate.stringFromDate(format: DateFormatters.HHCMMCSS, timeZone: TimeZone(abbreviation: "UTC")!)
        requestParameter["duration"] = self.duration.readDurationValue()
        requestParameter["durationType"] = self.duration.readDurationTypeInt()
        requestParameter["excludedWeekDays"] = self.excludeWeekEnds ? [1,7] : []
        requestParameter["orginalTimeZone"] = TimeZone.current.identifier
        requestParameter["appCalBookLinkId"] = self.appShareLinkId
        if let calendar = self.calendars.first {
            requestParameter["calendarId"] = calendar.calendar.readValueOfCalendarId()
            requestParameter["calAccessLevel"] = calendar.visibility.cleanValue()
        }
        if let reminderParam = self.remindValue?.readReminderNumericValueParameter() {
            requestParameter["reminders"] =  reminderParam
        }
        else {
            requestParameter["reminders"] =  nil
        }
        requestParameter["userId"] = Session.shared.readUserId()
        if let planItShareLink = self.planItShareLink,  planItShareLink.readEventShareLinkId() != 0.0 {
            requestParameter["calBookLinkId"] = planItShareLink.readEventShareLinkId()
        }
        return requestParameter
    }
    
    func readStartEndRangeDiffrenceInSeconds() -> Int {
        return self.endRangeTime.getTimeSeconds() - self.startRangeTime.getTimeSeconds()
    }
}
