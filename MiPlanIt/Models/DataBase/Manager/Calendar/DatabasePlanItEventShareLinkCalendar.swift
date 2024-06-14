//
//  DatabasePlanItEventShareLinkCalendar.swift
//  MiPlanIt
//
//  Created by Febin Paul on 30/03/21.
//  Copyright © 2021 Arun. All rights reserved.
//

import Foundation
import CoreData

class DatabasePlanItEventShareLinkCalendar: DataBaseManager {
    
    func insertCalendarsToShareLink(_ calendars: [[String: Any]], shareLink: PlanItShareLink, using context: NSManagedObjectContext? = nil) {
        shareLink.deleteAllCalendars()
        let objectContext = context ?? self.mainObjectContext
        for calendar in calendars {
            let calendarEntity = self.insertNewRecords(Table.planItEventShareLinkCalendar, context: objectContext) as! PlanItEventShareLinkCalendar
            calendarEntity.calendarName = calendar["calendarName"] as? String
            calendarEntity.calendarId = calendar["calendarId"] as? Double ?? 0
            calendarEntity.accessLevel = calendar["accessLevel"] as? Double ?? 0
            calendarEntity.socialCalendarId = calendar["extCalendarId"] as? String
            calendarEntity.calendarType = calendar["calendarType"] as? Double ?? 0
            calendarEntity.socialAccountEmail = calendar["socialAccountEmail"] as? String
            calendarEntity.socialAccountName = calendar["socialAccountName"] as? String
            calendarEntity.shareLink = shareLink
        }
    }
    
    func insertCalendarsToShareLink(_ calendars: [UserCalendarVisibility], shareLink: PlanItShareLink, using context: NSManagedObjectContext? = nil) {
        shareLink.deleteAllCalendars()
        let objectContext = context ?? self.mainObjectContext
        for calendar in calendars {
            let calendarEntity = self.insertNewRecords(Table.planItEventShareLinkCalendar, context: objectContext) as! PlanItEventShareLinkCalendar
            calendarEntity.calendarName = calendar.calendar.calendarName
            calendarEntity.calendarId = calendar.calendar.calendarId
            calendarEntity.appCalendarId = calendar.calendar.appCalendarId
            calendarEntity.accessLevel = calendar.visibility
            calendarEntity.calendarType = calendar.calendar.calendarType
            calendarEntity.socialAccountName = calendar.calendar.socialAccountName
            calendarEntity.socialCalendarId = calendar.calendar.socialCalendarId
            calendarEntity.socialAccountEmail = calendar.calendar.socialAccountEmail
            calendarEntity.shareLink = shareLink
        }
    }
}



