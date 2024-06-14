//
//  NewCalendar.swift
//  MiPlanIt
//
//  Created by Nikhil RajG on 11/04/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

class NewCalendar {
    
    var planItCalendar: PlanItCalendar?
    var name: String = Strings.empty
    var calendarImage: String = Strings.empty
    var calendarImageData: Data?
    var calendarColorCode: String = Strings.empty
    var fullAccesUsers: [CalendarUser] = []
    var partailAccesUsers: [CalendarUser] = []
    var notifyUsers: [CalendarUser] = []
    var appCalendarId = UUID().uuidString
    init() {
        
    }
    
    init(planItCalendar : PlanItCalendar) {
        self.planItCalendar = planItCalendar
        self.name = planItCalendar.readValueOfCalendarName()
        self.calendarColorCode = planItCalendar.readValueOfColorCode()
        self.calendarImage = planItCalendar.readValueOfCalendarImage()
        self.calendarImageData = planItCalendar.readValueOfCalendarImageData()
        self.appCalendarId = planItCalendar.readValueOfAppCalendarId()
        if self.isNotifyCalendar() {
            let allInvitees = planItCalendar.readAllNotifyCalendarInvitees()
            self.notifyUsers = allInvitees.map({return CalendarUser($0)})
        }
        else {
            let allInvitees = planItCalendar.readAllCalendarInvitees()
            self.fullAccesUsers = allInvitees.filter({ return $0.accessLevel == 2 }).map({return CalendarUser($0)})
            self.partailAccesUsers = allInvitees.filter({ return $0.accessLevel == 1 }).map({return CalendarUser($0)})
            self.fullAccesUsers.forEach({ $0.accessLevel = 2 })
            self.partailAccesUsers.forEach({ $0.accessLevel = 1 })
        }
    }
    
    init(calenderData : [String: Any]) {
        self.appCalendarId = calenderData["appCalendarId"] as? String ?? Strings.empty
        self.name = calenderData["calendarName"] as? String ?? Strings.empty
        self.calendarColorCode = calenderData["calColourCode"] as? String ?? Strings.empty
        self.calendarImage = calenderData["calImage"] as? String ?? Strings.empty
        let calenderType = calenderData["calendarType"] as? Double ?? 0
        if calenderType != 1 && calenderType != 2 {
            if let invitees = calenderData["invitees"] as? [[String: Any]] {
                self.fullAccesUsers = invitees.filter { (items) -> Bool in
                    if let accessLevel = items["accessLevel"] as? Double {
                      return accessLevel == 2
                    }
                    return false
                }.map({ return CalendarUser($0) })
                self.partailAccesUsers = invitees.filter { (items) -> Bool in
                    if let accessLevel = items["accessLevel"] as? Double {
                      return accessLevel == 1
                    }
                    return false
                }.map({ return CalendarUser($0) })
                self.fullAccesUsers.forEach({ $0.accessLevel = 2 })
                self.partailAccesUsers.forEach({ $0.accessLevel = 1 })
            }
        }
    }
    
    func isSocialCalendar() -> Bool {
        guard let calendar = self.planItCalendar else {
            return false
        }
        return calendar.isSocialCalendar()
    }
    
    func isNotifyCalendar() -> Bool {
        guard let calendar = self.planItCalendar else {
            return false
        }
        return (calendar.calendarType == 1 || calendar.calendarType == 2) && calendar.canEdit
    }
    
    func readValueOfCalendarTypeNewCalendar() -> String? {
        guard let calendar = self.planItCalendar else {
            return nil
        }
        switch calendar.readValueOfCalendarType() {
        case "1":
            return "1"
        case "2":
            return "2"
        case "3":
            return "3"
        default:
            return nil
        }
    }
}
