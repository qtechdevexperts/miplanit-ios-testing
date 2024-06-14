//
//  UserNotificationEvent.swift
//  MiPlanIt
//
//  Created by Arun on 21/04/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

class UserNotificationEvent {
    
    let location: String
    let startDate: String
    let endDate: String
    let startTime: String
    let endTime: String
    let isAllDay: Bool
    let isRegisteredUser: Bool?
    let sharedEmail: String
    
    init(with data: [String: Any]) {
        self.location = data["location"] as? String ?? Strings.empty
        self.startDate = data["startDate"] as? String ?? Strings.empty
        self.endDate = data["endDate"] as? String ?? Strings.empty
        self.startTime = data["startTime"] as? String ?? Strings.empty
        self.endTime = data["endTime"] as? String ?? Strings.empty
        self.isAllDay = data["isAllDay"] as? Bool ?? false
        self.isRegisteredUser = data["regUser"] as? Bool ?? false
        self.sharedEmail = data["sharedEmail"] as? String ?? Strings.empty
    }
    
    init(with planItUserNotificationEvent: PlanItUserNotificationEvent) {
        self.location = planItUserNotificationEvent.location ?? Strings.empty
        self.startDate = planItUserNotificationEvent.startDate ?? Strings.empty
        self.endDate = planItUserNotificationEvent.endDate ?? Strings.empty
        self.startTime = planItUserNotificationEvent.startTime ?? Strings.empty
        self.endTime = planItUserNotificationEvent.endTime ?? Strings.empty
        self.isAllDay = planItUserNotificationEvent.isAllDay
        self.isRegisteredUser = planItUserNotificationEvent.isRegUser
        self.sharedEmail = planItUserNotificationEvent.sharedEmail ?? Strings.empty
    }
    
    func readStartDateTimeString() -> String? {
        if self.isAllDay {
            return (self.startDate + Strings.space + self.startTime).stringToDate(formatter: DateFormatters.MMDDYYYYHMMSSA)?.stringFromDate(format: DateFormatters.DDSMMMSYYYY)
        }
        return (self.startDate + Strings.space + self.startTime).stringToDate(formatter: DateFormatters.MMDDYYYYHMMSSA, timeZone: TimeZone(abbreviation: "UTC")!)?.stringFromDate(format: DateFormatters.DDSMMMSYYYYSHHCMMCSSSA)
    }
    
    func readBookingEventStartDateTimeString() -> String? {
        return (self.startDate + Strings.space + self.startTime).stringToDate(formatter: DateFormatters.YYYYHMMDDSHHMMSS, timeZone: TimeZone(abbreviation: "UTC")!)?.stringFromDate(format: DateFormatters.DDSMMMSYYYYSHHCMMCSSSA)
    }
    
    func readBookingEventEndDateTimeString() -> String? {
        return (self.endDate + Strings.space + self.endTime).stringToDate(formatter: DateFormatters.YYYYHMMDDSHHMMSS, timeZone: TimeZone(abbreviation: "UTC")!)?.stringFromDate(format: DateFormatters.DDSMMMSYYYYSHHCMMCSSSA)
    }
    
    
    func readEndDateTime() -> Date? {
        if self.isAllDay {
            return (self.endDate + Strings.space + self.endTime).stringToDate(formatter: DateFormatters.MMDDYYYYHMMSSA)
        }
        return (self.endDate + Strings.space + self.endTime).stringToDate(formatter: DateFormatters.MMDDYYYYHMMSSA, timeZone: TimeZone(abbreviation: "UTC")!)
    }
}
