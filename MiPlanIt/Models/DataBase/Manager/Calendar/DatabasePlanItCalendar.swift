//
//  DatabasePlanItCalendar.swift
//  MiPlanIt
//
//  Created by Arun on 08/04/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation
import CoreData
// import RRuleSwift

class DatabasePlanItCalendar: DataBaseManager {
    
    func insertPlanItCalendars(_ data: [[String: Any]], using context: NSManagedObjectContext? = nil) {
        guard !data.isEmpty else { return }
        let objectContext = context ?? self.mainObjectContext
        let calendarIds = data.compactMap({ return $0["calendarId"] as? Double })
        let appCalendarIds = data.compactMap({ return $0["appCalendarId"] as? String })
        let localCalendars = self.readSpecificCalendars(calendarIds, appCalendarIds: appCalendarIds, using: objectContext)
        for calendar in data {
            let calendarId = calendar["calendarId"] as? Double ?? 0
            let appCalendarId = calendar["appCalendarId"] as? String ?? Strings.empty
            let calenderEntity = localCalendars.filter({ return $0.calendarId == calendarId || ($0.appCalendarId == appCalendarId && !appCalendarId.isEmpty) }).first ?? self.insertNewRecords(Table.planItCalendar, context: objectContext) as! PlanItCalendar
            calenderEntity.isPending = false
            calenderEntity.deleteStatus = false
            calenderEntity.calendarId = calendarId
            calenderEntity.appCalendarId = appCalendarId
            calenderEntity.user = Session.shared.readUserId()
            calenderEntity.parentCalendarId = calendar["parentCalendarId"] as? Double ?? 0
            calenderEntity.calendarName = calendar["calendarName"] as? String
            calenderEntity.calendarColorCode = calendar["calColourCode"] as? String
            calenderEntity.calendarImage = calendar["calImage"] as? String
            calenderEntity.token = calendar["token"] as? String
            calenderEntity.calendarType = calendar["calendarType"] as? Double ?? 0
            calenderEntity.calendarTypeLabel = calendar["calendarTypeLabel"] as? String
            calenderEntity.createdAt = calendar["createdAt"] as? String
            calenderEntity.modifiedAt = calendar["modifiedAt"] as? String
            calenderEntity.accessLevel = calendar["accessLevel"] as? Double ?? 0
            calenderEntity.socialCalendarId = calendar["extCalendarId"] as? String
            calenderEntity.socialAccountEmail = calendar["socialAccountEmail"] as? String
            calenderEntity.socialAccountId = calendar["socialAccountId"] as? String
            calenderEntity.socialAccountName = calendar["socialAccountName"] as? String
            calenderEntity.canEdit = calendar["canEdit"] as? Bool ?? true
            if let createdBy = calendar["createdBy"] as? [String: Any] {
                DatabasePlanItCreator().insertCalendar(calenderEntity, creator: createdBy, using: objectContext)
            }
            if let modifiedBy = calendar["modifiedBy"] as? [String: Any] {
                DatabasePlanItModifier().insertCalendar(calenderEntity, modifier: modifiedBy, using: objectContext)
            }
            if let invitees = calendar["invitees"] as? [[String: Any]] {
                DatabasePlanItInvitees().insertCalendar(calenderEntity, invitees: invitees, using: objectContext)
            }
            if let invitees = calendar["nonRegInvitees"] as? [[String: Any]] {
                DatabasePlanItInvitees().insertCalendar(calenderEntity, other: invitees, using: objectContext)
            }
            if let sharedUsers = calendar["defaultCalendarSharedUsers"] as? [[String: Any]] {
                DatabasePlanItInvitees().insertShareBaseCalendar(calenderEntity, sharedUser: sharedUsers, using: objectContext)
            }
            if let sharedUsers = calendar["defaultCalendarNonRegUsers"] as? [[String: Any]] {
                DatabasePlanItInvitees().insertShareBaseCalendar(calenderEntity, other: sharedUsers, using: objectContext)
            }
        }
    }
    
    @discardableResult func insertNewPlanItCalendars(_ data: [[String: Any]], using context: NSManagedObjectContext? = nil) -> [PlanItCalendar] {
        guard !data.isEmpty else { return [] }
        let objectContext = context ?? self.mainObjectContext
        var addedCalendars: [PlanItCalendar] = []
        let calendarIds = data.compactMap({ return $0["calendarId"] as? Double })
        let appCalendarIds = data.compactMap({ return $0["appCalendarId"] as? String })
        let localCalendars = self.readSpecificCalendars(calendarIds, appCalendarIds: appCalendarIds, using: objectContext)
        for calendar in data {
            let calendarId = calendar["calendarId"] as? Double ?? 0
            let appCalendarId = calendar["appCalendarId"] as? String ?? Strings.empty
            let calenderEntity = localCalendars.filter({ return $0.calendarId == calendarId || ($0.appCalendarId == appCalendarId && !appCalendarId.isEmpty) }).first ?? self.insertNewRecords(Table.planItCalendar, context: objectContext) as! PlanItCalendar
            calenderEntity.isPending = false
            calenderEntity.deleteStatus = false
            calenderEntity.calendarId = calendarId
            calenderEntity.appCalendarId = appCalendarId
            calenderEntity.user = Session.shared.readUserId()
            calenderEntity.parentCalendarId = calendar["parentCalendarId"] as? Double ?? 0
            calenderEntity.calendarName = calendar["calendarName"] as? String
            calenderEntity.calendarColorCode = calendar["calColourCode"] as? String
            calenderEntity.calendarImage = calendar["calImage"] as? String
            calenderEntity.token = calendar["token"] as? String
            calenderEntity.calendarType = calendar["calendarType"] as? Double ?? 0
            calenderEntity.calendarTypeLabel = calendar["calendarTypeLabel"] as? String
            calenderEntity.createdAt = calendar["createdAt"] as? String
            calenderEntity.modifiedAt = calendar["modifiedAt"] as? String
            calenderEntity.accessLevel = calendar["accessLevel"] as? Double ?? 0
            calenderEntity.socialCalendarId = calendar["extCalendarId"] as? String
            calenderEntity.socialAccountEmail = calendar["socialAccountEmail"] as? String
            calenderEntity.socialAccountId = calendar["socialAccountId"] as? String
            calenderEntity.socialAccountName = calendar["socialAccountName"] as? String
            calenderEntity.canEdit = calendar["canEdit"] as? Bool ?? true
            if let createdBy = calendar["createdBy"] as? [String: Any] {
                DatabasePlanItCreator().insertCalendar(calenderEntity, creator: createdBy, using: objectContext)
            }
            if let modifiedBy = calendar["modifiedBy"] as? [String: Any] {
                DatabasePlanItModifier().insertCalendar(calenderEntity, modifier: modifiedBy, using: objectContext)
            }
            if let invitees = calendar["invitees"] as? [[String: Any]] {
                DatabasePlanItInvitees().insertCalendar(calenderEntity, invitees: invitees, using: objectContext)
            }
            if let invitees = calendar["nonRegInvitees"] as? [[String: Any]] {
                DatabasePlanItInvitees().insertCalendar(calenderEntity, other: invitees, using: objectContext)
            }
            if let sharedUsers = calendar["defaultCalendarSharedUsers"] as? [[String: Any]] {
                DatabasePlanItInvitees().insertShareBaseCalendar(calenderEntity, sharedUser: sharedUsers, using: objectContext)
            }
            if let sharedUsers = calendar["defaultCalendarNonRegUsers"] as? [[String: Any]] {
                DatabasePlanItInvitees().insertShareBaseCalendar(calenderEntity, other: sharedUsers, using: objectContext)
            }
            addedCalendars.append(calenderEntity)
        }
        objectContext.saveContext()
        return addedCalendars
    }
    
    @discardableResult func insertNewOfflinePlanItCalendar(_ calendar: NewCalendar, file: Data?) -> PlanItCalendar {
        let parentCalendar = self.readDefaultParentCalendarId(using: self.mainObjectContext).first
        let calenderEntity = calendar.planItCalendar ?? self.insertNewRecords(Table.planItCalendar, context: self.mainObjectContext) as! PlanItCalendar
        calenderEntity.isPending = true
        calenderEntity.deleteStatus = false
        calenderEntity.canEdit = true
        calenderEntity.calendarType = calendar.planItCalendar?.calendarType ?? 0
        calenderEntity.calendarTypeLabel = calendar.planItCalendar?.readValueOfCalendarTypeLabel()
        calenderEntity.user = Session.shared.readUserId()
        if calenderEntity.readValueOfAppCalendarId().isEmpty {
            calenderEntity.appCalendarId = UUID().uuidString
        }
        calenderEntity.calendarImageData = file
        calenderEntity.calendarName = calendar.name
        calenderEntity.calendarColorCode = calendar.calendarColorCode
        calenderEntity.parentCalendarId = parentCalendar?.calendarId ?? -1
        DatabasePlanItInvitees().insertCalendar(calenderEntity, invitees: calendar, using: self.mainObjectContext)
        DatabasePlanItCreator().insertCalendar(calenderEntity, creator: Session.shared.readUser(), using: self.mainObjectContext)
        self.mainObjectContext.saveContext()
        return calenderEntity
    }
    
    func updateCalendar(_ planItCalendar: PlanItCalendar, withNewCalendar calendar: [String: Any]) -> PlanItCalendar {
        planItCalendar.isPending = false
        planItCalendar.deleteStatus = false
        planItCalendar.calendarId = calendar["calendarId"] as? Double ?? 0
        planItCalendar.appCalendarId = calendar["appCalendarId"] as? String
        planItCalendar.user = Session.shared.readUserId()
        planItCalendar.parentCalendarId = calendar["parentCalendarId"] as? Double ?? 0
        planItCalendar.calendarName = calendar["calendarName"] as? String
        planItCalendar.calendarColorCode = calendar["calColourCode"] as? String
        planItCalendar.calendarImage = calendar["calImage"] as? String
        planItCalendar.token = calendar["token"] as? String
        planItCalendar.calendarType = calendar["calendarType"] as? Double ?? 0
        planItCalendar.calendarTypeLabel = calendar["calendarTypeLabel"] as? String
        planItCalendar.createdAt = calendar["createdAt"] as? String
        planItCalendar.modifiedAt = calendar["modifiedAt"] as? String
        planItCalendar.accessLevel = calendar["accessLevel"] as? Double ?? 0
        planItCalendar.socialCalendarId = calendar["extCalendarId"] as? String
        planItCalendar.socialAccountEmail = calendar["socialAccountEmail"] as? String
        planItCalendar.socialAccountId = calendar["socialAccountId"] as? String
        planItCalendar.socialAccountName = calendar["socialAccountName"] as? String
        if let invitees = calendar["invitees"] as? [[String: Any]] {
            DatabasePlanItInvitees().insertCalendar(planItCalendar, invitees: invitees, using: planItCalendar.managedObjectContext)
        }
        if let invitees = calendar["nonRegInvitees"] as? [[String: Any]] {
            DatabasePlanItInvitees().insertCalendar(planItCalendar, other: invitees, using: planItCalendar.managedObjectContext)
        }
        try? planItCalendar.managedObjectContext?.save()
        return planItCalendar
    }
    
    func updateCalendarSharedUser(_ planItCalendar: PlanItCalendar, withInvitees invitees: CalendarInvitees) {
        DatabasePlanItInvitees().insertCalendar(planItCalendar, invitees: invitees)
        try? planItCalendar.managedObjectContext?.save()
    }
    
    func removePlanItCalendars(_ calendars: [Double], using context: NSManagedObjectContext? = nil) {
        let objectContext = context ?? self.mainObjectContext
        let localCalendars = self.readSpecificCalendars(calendars, using: objectContext)
        localCalendars.forEach({ objectContext.delete($0) })
    }
    
    func readSpecificCalendars(_ calendars: [Double], appCalendarIds: [String], using context: NSManagedObjectContext) -> [PlanItCalendar] {
        let predicate = NSPredicate(format: "user == %@ AND deleteStatus == NO AND ((calendarId IN %@ AND calendarId <> '') OR (appCalendarId IN %@ AND appCalendarId <> ''))", Session.shared.readUserId(), calendars, appCalendarIds)
        return self.readRecords(fromCoreData: Table.planItCalendar, predicate: predicate, context: context) as! [PlanItCalendar]
    }
    
    func readSpecificCalendars(_ calendars: [Double], using context: NSManagedObjectContext) -> [PlanItCalendar] {
        let predicate = NSPredicate(format: "user == %@ AND deleteStatus == NO AND calendarId IN %@", Session.shared.readUserId(), calendars)
        return self.readRecords(fromCoreData: Table.planItCalendar, predicate: predicate, context: context) as! [PlanItCalendar]
    }
    
    func readAllPlanitCalendars() -> [PlanItCalendar] {
        let predicate = NSPredicate(format: "user == %@ AND deleteStatus == NO", Session.shared.readUserId())
        return self.readRecords(fromCoreData: Table.planItCalendar, predicate: predicate, context: self.mainObjectContext) as! [PlanItCalendar]
    }
    
    func checkCalendarNameExist(_ name: String) -> Bool {
        let predicate = NSPredicate(format: "user == %@ AND deleteStatus == NO AND calendarName == %@",Session.shared.readUserId(), name)
        let arrayRecords = self.readRecords(fromCoreData: Table.planItCalendar, predicate: predicate, sortDescriptor: nil, limit: 0, context: self.mainObjectContext) as! [PlanItCalendar]
        return !arrayRecords.isEmpty
    }
    
    func readCalendersUsingId(_ calendarIds: [Double], appCalendarIds: [String], includingParent parent: Bool = false, using context: NSManagedObjectContext? = nil) -> [PlanItCalendar] {
        let objectContext = context ?? self.mainObjectContext
        let records = self.readSpecificCalendars(calendarIds, appCalendarIds: appCalendarIds, using: objectContext)
        if !records.isEmpty || !parent { return records }
        return self.readDefaultParentCalendarId(using: objectContext)
    }

    func readCalendersUsingId(_ calendarIds: [Double], appCalendarIds: [String], using context: NSManagedObjectContext? = nil) -> [PlanItCalendar] {
        let objectContext = context ?? self.mainObjectContext
        return self.readSpecificCalendars(calendarIds, appCalendarIds: appCalendarIds, using: objectContext)
    }
    
    func readSpecificCalendarsUsingType(_ type: Double) -> [PlanItCalendar] {
        let predicate = NSPredicate(format: "user == %@ AND deleteStatus == NO AND calendarType == %f", Session.shared.readUserId(), type)
        return self.readRecords(fromCoreData: Table.planItCalendar, predicate: predicate, context: self.mainObjectContext) as! [PlanItCalendar]
    }
    
    func readDefaultParentCalendarId(using context: NSManagedObjectContext? = nil) -> [PlanItCalendar] {
        let objectContext = context ?? self.mainObjectContext
        let predicate = NSPredicate(format: "user == %@ AND deleteStatus == NO AND parentCalendarId == 0",Session.shared.readUserId())
        let arrayRecords = self.readRecords(fromCoreData: Table.planItCalendar, predicate: predicate, sortDescriptor: nil, limit: 0, context: objectContext) as! [PlanItCalendar]
        return arrayRecords
    }
    
    func readAllPendingCalendars(using context: NSManagedObjectContext? = nil) -> [PlanItCalendar] {
        let objectContext = context ?? self.mainObjectContext
        let predicate = NSPredicate(format: "user == %@ AND deleteStatus == NO AND (isPending == YES || calendarImageData <> nil)", Session.shared.readUserId())
        return self.readRecords(fromCoreData: Table.planItCalendar, predicate: predicate, context: objectContext) as! [PlanItCalendar]
    }
    
    func readAllPendingDeletedCalendars(using context: NSManagedObjectContext? = nil) -> [PlanItCalendar] {
        let objectContext = context ?? self.mainObjectContext
        let predicate = NSPredicate(format: "user == %@ AND deleteStatus == YES", Session.shared.readUserId())
        return self.readRecords(fromCoreData: Table.planItCalendar, predicate: predicate, context: objectContext) as! [PlanItCalendar]
    }
}
