//
//  UserCalendarVisibility.swift
//  MiPlanIt
//
//  Created by Arun on 29/07/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

class UserCalendarVisibility: Comparable {
    
    var selected: Bool
    var visibility: Double
    var disabled: Bool = false
    let calendar: PlanItCalendar
    
    init(with calendar: PlanItCalendar, visibility: Double = 0, selected: Bool = false, isDisabled:  Bool = false)  {
        self.calendar = calendar
        self.selected = selected
        self.disabled = isDisabled
        self.visibility = visibility
    }
    
    func readAllShareUserList() -> [CalendarUser] {
        var calendarUser: [CalendarUser] = []
        if let creator = self.calendar.createdBy {
            calendarUser.append(CalendarUser(creator))
        }
        let sharedUsers = self.calendar.isSocialCalendar() ? self.calendar.readAllUserCalendarInvitees() : (self.calendar.readValueOfParentCalendarId() == "0" ? self.calendar.readAllCalendarSharedUser() : self.calendar.readAllUserCalendarInvitees())
        calendarUser.append(contentsOf: sharedUsers.compactMap({ CalendarUser($0) }))
        return calendarUser
    }
    
    static func == (lhs: UserCalendarVisibility, rhs: UserCalendarVisibility) -> Bool {
        return lhs.calendar.readValueOfCalendarId() == rhs.calendar.readValueOfCalendarId()
    }
    
    static func < (lhs: UserCalendarVisibility, rhs: UserCalendarVisibility) -> Bool {
        return lhs.calendar.readValueOfCalendarId() == rhs.calendar.readValueOfCalendarId()
    }
}
