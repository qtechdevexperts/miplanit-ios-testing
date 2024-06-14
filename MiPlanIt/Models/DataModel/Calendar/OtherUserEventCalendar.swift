//
//  OtherUserEventCalendar.swift
//  MiPlanIt
//
//  Created by Arun on 28/07/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

class OtherUserEventCalendar {

    var calendarColorCode: String
    var calendarId: Double
    var calendarImage: String
    var calendarName: String
    var calendarType: Double
    var parentCalendarId: Double
    var accessLevel: Double
    
    init(with data: [String: Any]) {
        self.calendarId = data["calendarId"] as? Double ?? 0
        self.calendarType = data["calendarType"] as? Double ?? 0
        self.parentCalendarId = data["parentCalendarId"] as? Double ?? 0
        self.calendarName = data["calendarName"] as? String ?? Strings.empty
        self.calendarImage = data["calImage"] as? String ?? Strings.empty
        self.calendarColorCode = data["calColourCode"] as? String ?? Strings.empty
        self.accessLevel = data["accessLevel"] as? Double ?? 1
    }
    
    init(with planItCalendar: PlanItCalendar) {
        self.calendarId = planItCalendar.calendarId
        self.calendarType = planItCalendar.calendarType
        self.parentCalendarId = planItCalendar.parentCalendarId
        self.calendarName = planItCalendar.readValueOfCalendarName()
        self.calendarImage = planItCalendar.readValueOfCalendarImage()
        self.calendarColorCode = planItCalendar.readValueOfColorCode()
        self.accessLevel = planItCalendar.accessLevel
    }
    
    func isSocialCalendar() -> Bool {
        return self.calendarType == 1 || self.calendarType == 2 || self.calendarType == 3
    }
}
