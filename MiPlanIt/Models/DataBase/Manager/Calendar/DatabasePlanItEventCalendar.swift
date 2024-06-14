//
//  DatabasePlanItEventCalendar.swift
//  MiPlanIt
//
//  Created by Arun on 28/07/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation
import CoreData

class DatabasePlanItEventCalendar: DataBaseManager {
    
    func insertCalendarsToEvent(_ planItCalendars: [PlanItEventCalendar], event: PlanItEvent, using context: NSManagedObjectContext? = nil) {
        event.deleteAllEventCalendars()
        let objectContext = context ?? self.mainObjectContext
        for calendar in planItCalendars {
            let calendarEntity = self.insertNewRecords(Table.planItEventCalendar, context: objectContext) as! PlanItEventCalendar
            calendarEntity.calendarName = calendar.calendarName
            calendarEntity.calendarId = calendar.calendarId
            calendarEntity.accessLevel = calendar.accessLevel
            calendarEntity.socialCalendarId = calendar.socialCalendarId
            calendarEntity.calendarType = calendar.calendarType
            calendarEntity.socialAccountEmail = calendar.socialAccountEmail
            calendarEntity.socialAccountName = calendar.socialAccountName
            calendarEntity.event = event
        }
    }
    
    func insertCalendarsToEvent(_ calendars: [[String: Any]], event: PlanItEvent, using context: NSManagedObjectContext? = nil) {
        event.deleteAllEventCalendars()
        let objectContext = context ?? self.mainObjectContext
        for calendar in calendars {
            let calendarEntity = self.insertNewRecords(Table.planItEventCalendar, context: objectContext) as! PlanItEventCalendar
            calendarEntity.calendarName = calendar["calendarName"] as? String
            calendarEntity.calendarId = calendar["calendarId"] as? Double ?? 0
            calendarEntity.accessLevel = calendar["accessLevel"] as? Double ?? 0
            calendarEntity.socialCalendarId = calendar["extCalendarId"] as? String
            calendarEntity.calendarType = calendar["calendarType"] as? Double ?? 0
            calendarEntity.socialAccountEmail = calendar["socialAccountEmail"] as? String
            calendarEntity.socialAccountName = calendar["socialAccountName"] as? String
            calendarEntity.event = event
        }
    }
    
    func insertCalendarsToEvent(_ calendars: [UserCalendarVisibility], event: PlanItEvent, using context: NSManagedObjectContext? = nil) {
        event.deleteAllEventCalendars()
        let objectContext = context ?? self.mainObjectContext
        for calendar in calendars {
            let calendarEntity = self.insertNewRecords(Table.planItEventCalendar, context: objectContext) as! PlanItEventCalendar
            calendarEntity.calendarName = calendar.calendar.calendarName
            calendarEntity.calendarId = calendar.calendar.calendarId
            calendarEntity.appCalendarId = calendar.calendar.appCalendarId
            calendarEntity.accessLevel = calendar.visibility
            calendarEntity.calendarType = calendar.calendar.calendarType
            calendarEntity.socialAccountName = calendar.calendar.socialAccountName
            calendarEntity.socialCalendarId = calendar.calendar.socialCalendarId
            calendarEntity.socialAccountEmail = calendar.calendar.socialAccountEmail
            calendarEntity.event = event
        }
    }
    
    func insertNotifyCalendarsToEvent(_ calendars: [PlanItEventCalendar], event: PlanItEvent, using context: NSManagedObjectContext? = nil) {
        event.deleteAllEventNotifyCalendars()
        let objectContext = context ?? self.mainObjectContext
        for calendar in calendars {
            let calendarEntity = self.insertNewRecords(Table.planItEventCalendar, context: objectContext) as! PlanItEventCalendar
            calendarEntity.calendarName = calendar.calendarName
            calendarEntity.calendarId = calendar.calendarId
            calendarEntity.accessLevel = calendar.accessLevel
            calendarEntity.socialCalendarId = calendar.socialCalendarId
            calendarEntity.calendarType = calendar.calendarType
            calendarEntity.socialAccountEmail = calendar.socialAccountEmail
            calendarEntity.socialAccountName = calendar.socialAccountName
            calendarEntity.mainEvent = event
        }
    }
    
    func insertNotifyCalendarsToEvent(_ calendars: [[String: Any]], event: PlanItEvent, using context: NSManagedObjectContext? = nil) {
        event.deleteAllEventNotifyCalendars()
        let objectContext = context ?? self.mainObjectContext
        for calendar in calendars {
            let calendarEntity = self.insertNewRecords(Table.planItEventCalendar, context: objectContext) as! PlanItEventCalendar
            calendarEntity.calendarName = calendar["calendarName"] as? String
            calendarEntity.calendarId = calendar["calendarId"] as? Double ?? 0
            calendarEntity.accessLevel = calendar["accessLevel"] as? Double ?? 0
            calendarEntity.socialCalendarId = calendar["notifyCalId"] as? String
            calendarEntity.calendarType = calendar["calendarType"] as? Double ?? 0
            calendarEntity.socialAccountEmail = calendar["socialAccountEmail"] as? String
            calendarEntity.socialAccountName = calendar["socialAccountName"] as? String
            calendarEntity.mainEvent = event
        }
    }
    
    func insertNotifyCalendarsToEvent(_ calendars: [UserCalendarVisibility], event: PlanItEvent, using context: NSManagedObjectContext? = nil) {
        event.deleteAllEventNotifyCalendars()
        let objectContext = context ?? self.mainObjectContext
        for calendar in calendars {
            let calendarEntity = self.insertNewRecords(Table.planItEventCalendar, context: objectContext) as! PlanItEventCalendar
            calendarEntity.calendarName = calendar.calendar.calendarName
            calendarEntity.calendarId = calendar.calendar.calendarId
            calendarEntity.appCalendarId = calendar.calendar.appCalendarId
            calendarEntity.accessLevel = calendar.visibility
            calendarEntity.calendarType = calendar.calendar.calendarType
            calendarEntity.socialCalendarId = calendar.calendar.socialCalendarId
            calendarEntity.socialAccountName = calendar.calendar.socialAccountName
            calendarEntity.socialAccountEmail = calendar.calendar.socialAccountEmail
            calendarEntity.mainEvent = event
        }
    }
}
