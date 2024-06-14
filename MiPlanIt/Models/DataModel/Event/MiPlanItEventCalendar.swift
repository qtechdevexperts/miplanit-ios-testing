
//
//  MiPlanItEventCalendar.swift
//  MiPlanIt
//
//  Created by Febin Paul on 18/11/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

class MiPlanItEventCalendar {
    
    var accessLevel: Double
    var calendarId: Double
    var parentCalendarId: Double
    var calendar: PlanItCalendar
    var appCalendarId: String?
    
    init(with calendar: PlanItCalendar) {
        self.calendar = calendar
        self.accessLevel = calendar.accessLevel
        self.calendarId = calendar.calendarId
        self.parentCalendarId = calendar.parentCalendarId
        self.appCalendarId = calendar.appCalendarId
    }
    func readValueOfCalendarId() -> String { return self.calendarId.cleanValue() }
    func readValueOfAppCalendarId() -> String { return self.appCalendarId ?? Strings.empty }
}
