//
//  DatabasePlanItShareLink.swift
//  MiPlanIt
//
//  Created by Febin Paul on 27/03/21.
//  Copyright © 2021 Arun. All rights reserved.
//

import Foundation
import CoreData

class DatabasePlanItShareLink: DataBaseManager {
    
    func insertPlanItShareLinks(_ data: [[String: Any]], using context: NSManagedObjectContext? = nil) {
        let objectContext = context ?? self.mainObjectContext
        let shareLinkIds = data.compactMap({ return $0["calBookLinkId"] as? Double })
        let appShareLinkIds = data.compactMap({ return $0["appCalBookLinkId"] as? String })
        let localShareLinks = self.readSpecificShareLink(shareLinkIds, appShareLinkIds: appShareLinkIds, using: objectContext)
        for event in data {
            let shareLinkId = event["calBookLinkId"] as? Double ?? 0
            let appShareLinkId = event["appCalBookLinkId"] as? String ?? Strings.empty
            let shareLinkEntity = localShareLinks.filter({ return $0.shareLinkId == shareLinkId  || ($0.appShareLinkId == appShareLinkId && !appShareLinkId.isEmpty) }).first ?? self.insertNewRecords(Table.planItShareLink, context: objectContext) as! PlanItShareLink
            shareLinkEntity.warningMessage = Strings.empty
            shareLinkEntity.isPending = false
            shareLinkEntity.shareLinkId = shareLinkId
            shareLinkEntity.appShareLinkId = appShareLinkId
            if let date = event["createdAt"] as? String {
                shareLinkEntity.createdAt = date.stringToDate(formatter: DateFormatters.MMDDYYYYHMMSSA, timeZone: TimeZone(abbreviation: "UTC")!)
            }
            if let createdBy = event["createdBy"] as? [String: Any] {
                DatabasePlanItCreator().insertShareLink(shareLinkEntity, creator: createdBy, using: objectContext)
            }
            if let modifiedBy = event["modifiedBy"] as? [String: Any] {
                DatabasePlanItModifier().insertShareLink(shareLinkEntity, modifier: modifiedBy, using: objectContext)
            }
            shareLinkEntity.eventName = event["eventName"] as? String
            shareLinkEntity.duration = event["duration"] as? Double ?? 0.0
            shareLinkEntity.location = event["location"] as? String
            shareLinkEntity.eventDescription = event["description"] as? String
            shareLinkEntity.bookingLink = event["bookingLink"] as? String
            shareLinkEntity.user = Session.shared.readUserId()
            if let date = event["linkExpiry"] as? String {
                shareLinkEntity.linkExpiry = date.stringToDate(formatter: DateFormatters.MMDDYYYYHMMSSA, timeZone: TimeZone(abbreviation: "UTC")!)
            }
            if let date = event["modifiedAt"] as? String {
                shareLinkEntity.modifiedAt = date.stringToDate(formatter: DateFormatters.MMDDYYYYHMMSSA, timeZone: TimeZone(abbreviation: "UTC")!)
            }
            shareLinkEntity.orginalTimeZone = event["orginalTimeZone"] as? String
            if let weekDays = event["excludedWeekDays"] as? [Double], !weekDays.isEmpty {
                shareLinkEntity.excludedWeekDays = weekDays.map({ String($0) }).joined(separator: ", ")
            }
            else {
                shareLinkEntity.excludedWeekDays = nil
            }
            if let invitees = event["invitees"] as? [String: Any] {
                DatabasePlanItInvitees().insertShareLink(shareLinkEntity, invitees: [invitees], using: objectContext)
            }
            if let tags = event["tags"] as? [[String: String]] {
                let arrayTags = tags.compactMap({$0.values.first})
                if arrayTags.count > 0 {
                    DatabasePlanItTags().insertTags(arrayTags, for: shareLinkEntity, using: objectContext)
                }
            }
            if let reminders = event["reminder"] as? [[String: Any]] {
                DataBasePlanItTodoReminders().insertShareLink(shareLinkEntity, reminders: reminders, using: objectContext)
            }
            else { shareLinkEntity.deleteAllReminder() }
            if let date = event["startDate"] as? String, let time = event["startTime"] as? String {
                let startDateTime = (date + Strings.space + time).stringToDate(formatter: DateFormatters.MMDDYYYYHMMSSA, timeZone: TimeZone(abbreviation: "UTC")!)
                shareLinkEntity.startDateTime = startDateTime
            }
            if let date = event["endDate"] as? String, let time = event["endTime"] as? String {
                shareLinkEntity.endDateTime = (date + Strings.space + time).stringToDate(formatter: DateFormatters.MMDDYYYYHMMSSA, timeZone: TimeZone(abbreviation: "UTC")!)
            }
        }
    }
    
    func insertPlanItShareLink(_ data: [String: Any], using context: NSManagedObjectContext? = nil) {
        let objectContext = context ?? self.mainObjectContext
        let shareLinkId = data["calBookLinkId"]  as? Double ?? 0.0
        let appShareLinkId = data["appCalBookLinkId"]  as? String ?? Strings.empty
        let localShareLinks = self.readSpecificShareLink([shareLinkId], appShareLinkIds: [appShareLinkId], using: objectContext)
        let shareLinkEntity = localShareLinks.filter({ return $0.shareLinkId == shareLinkId  || ($0.appShareLinkId == appShareLinkId && !appShareLinkId.isEmpty) }).first ?? self.insertNewRecords(Table.planItShareLink, context: objectContext) as! PlanItShareLink
        shareLinkEntity.warningMessage = Strings.empty
        shareLinkEntity.isPending = false
        shareLinkEntity.shareLinkId = shareLinkId
        shareLinkEntity.appShareLinkId = appShareLinkId
        if let date = data["createdAt"] as? String {
            shareLinkEntity.createdAt = date.stringToDate(formatter: DateFormatters.MMDDYYYYHMMSSA, timeZone: TimeZone(abbreviation: "UTC")!)
        }
        if let createdBy = data["createdBy"] as? [String: Any] {
            DatabasePlanItCreator().insertShareLink(shareLinkEntity, creator: createdBy, using: objectContext)
        }
        if let modifiedBy = data["modifiedBy"] as? [String: Any] {
            DatabasePlanItModifier().insertShareLink(shareLinkEntity, modifier: modifiedBy, using: objectContext)
        }
        shareLinkEntity.eventName = data["eventName"] as? String
        shareLinkEntity.duration = data["duration"] as? Double ?? 0.0
        shareLinkEntity.location = data["location"] as? String
        shareLinkEntity.eventDescription = data["description"] as? String
        shareLinkEntity.bookingLink = data["bookingLink"] as? String
        shareLinkEntity.user = Session.shared.readUserId()
        if let date = data["linkExpiry"] as? String {
            shareLinkEntity.linkExpiry = date.stringToDate(formatter: DateFormatters.MMDDYYYYHMMSSA, timeZone: TimeZone(abbreviation: "UTC")!)
        }
        if let date = data["modifiedAt"] as? String {
            shareLinkEntity.modifiedAt = date.stringToDate(formatter: DateFormatters.MMDDYYYYHMMSSA, timeZone: TimeZone(abbreviation: "UTC")!)
        }
        shareLinkEntity.orginalTimeZone = data["orginalTimeZone"] as? String
        if let weekDays = data["excludedWeekDays"] as? [Double], !weekDays.isEmpty {
            shareLinkEntity.excludedWeekDays = weekDays.map({ String($0) }).joined(separator: ", ")
        }
        else {
            shareLinkEntity.excludedWeekDays = nil
        }
        if let invitees = data["invitees"] as? [String: Any] {
            DatabasePlanItInvitees().insertShareLink(shareLinkEntity, invitees: [invitees], using: objectContext)
        }
        if let tags = data["tags"] as? [String] {
            DatabasePlanItTags().insertTags(tags, for: shareLinkEntity, using: objectContext)
        }
        if let reminders = data["reminder"] as? [[String: Any]] {
            DataBasePlanItTodoReminders().insertShareLink(shareLinkEntity, reminders: reminders, using: objectContext)
        }
        else { shareLinkEntity.deleteAllReminder() }
        if let calendars = data["calendar"] as? [String: Any] {
            DatabasePlanItEventShareLinkCalendar().insertCalendarsToShareLink([calendars], shareLink: shareLinkEntity, using: objectContext)
        }
        if let date = data["startDate"] as? String, let time = data["startTime"] as? String {
            let startDateTime = (date + Strings.space + time).stringToDate(formatter: DateFormatters.MMDDYYYYHMMSSA, timeZone: TimeZone(abbreviation: "UTC")!)
            shareLinkEntity.startDateTime = startDateTime
        }
        if let date = data["endDate"] as? String, let time = data["endTime"] as? String {
            shareLinkEntity.endDateTime = (date + Strings.space + time).stringToDate(formatter: DateFormatters.MMDDYYYYHMMSSA, timeZone: TimeZone(abbreviation: "UTC")!)
        }
        self.mainObjectContext.saveContext()
    }
    
    func insertShareLinkOffline(_ shareLink: MiPlanitShareLink, using context: NSManagedObjectContext? = nil) {
        let objectContext = context ?? self.mainObjectContext
        let shareLinkEntity = shareLink.planItShareLink ?? self.insertNewRecords(Table.planItShareLink, context: objectContext) as! PlanItShareLink
        shareLinkEntity.warningMessage = Strings.empty
        shareLinkEntity.isPending = true
        shareLinkEntity.appShareLinkId = shareLink.appShareLinkId
        shareLinkEntity.createdAt = shareLink.planItShareLink?.createdAt ?? Date()
        DatabasePlanItModifier().insertShareLink(shareLinkEntity, modifier: Session.shared.readUser(), using: objectContext)
        shareLinkEntity.eventName = shareLink.eventName
        shareLinkEntity.duration = Double(shareLink.duration.durationValue)
        shareLinkEntity.location = shareLink.readLocationName()
        shareLinkEntity.eventDescription = shareLink.eventDescription
        shareLinkEntity.user = Session.shared.readUserId()
        shareLinkEntity.excludedWeekDays = shareLink.excludeWeekEnds ? [1,7].map({ String($0) }).joined(separator: ", ") : Strings.empty
        DatabasePlanItInvitees().insertShareLink(shareLinkEntity, other: shareLink.invitees, using: objectContext)
        DatabasePlanItTags().insertTags(shareLink.tags, for: shareLinkEntity, using: objectContext)
        if let remindValue = shareLink.remindValue {
            DataBasePlanItTodoReminders().insertShareLink(shareLinkEntity, reminders: remindValue, using: objectContext)
        }
        else {
            shareLinkEntity.deleteAllReminder()
        }
        DatabasePlanItEventShareLinkCalendar().insertCalendarsToShareLink(shareLink.calendars, shareLink: shareLinkEntity, using: objectContext)
        
        let startDuration = shareLink.startRangeTime.timeIntervalSince1970 - shareLink.startRangeTime.initialHour().timeIntervalSince1970
        let finalStartDate = shareLink.startDate.initialHour().addingTimeInterval(startDuration)
        let endDuration = shareLink.endRangeTime.timeIntervalSince1970 - shareLink.endRangeTime.initialHour().timeIntervalSince1970
        let finalEndDate = shareLink.endDate.initialHour().addingTimeInterval(endDuration)
        
        shareLinkEntity.startDateTime = finalStartDate
        shareLinkEntity.endDateTime = finalEndDate
        objectContext.saveContext()
    }
    
    
    func removedPlantItEventShareLink(_ shareLinkIds: [Double], using context: NSManagedObjectContext? = nil) {
        let objectContext = context ?? self.mainObjectContext
        let predicate = NSPredicate(format: "user == %@ AND shareLinkId IN %@", Session.shared.readUserId(), shareLinkIds)
        let myPlanItCategories = self.readRecords(fromCoreData: Table.planItShareLink, predicate: predicate, context: objectContext) as! [PlanItShareLink]
        myPlanItCategories.forEach({ objectContext.delete($0) })
    }
    
    private func readSpecificShareLink(_ shareLinkIds: [Double], appShareLinkIds: [String] = [], using context: NSManagedObjectContext) -> [PlanItShareLink] {
        let predicate = NSPredicate(format: "user == %@ AND ((shareLinkId IN %@ AND shareLinkId <> '') OR (appShareLinkId IN %@ AND appShareLinkId <> ''))", Session.shared.readUserId(), shareLinkIds, appShareLinkIds)
        return self.readRecords(fromCoreData: Table.planItShareLink, predicate: predicate, context: context) as! [PlanItShareLink]
    }
    
    func readAllUserShareLink(using context: NSManagedObjectContext? = nil) -> [PlanItShareLink] {
        let objectContext = context ?? self.mainObjectContext
        let predicate = NSPredicate(format: "user == %@ AND deleteStatus == NO", Session.shared.readUserId())
        return self.readRecords(fromCoreData: Table.planItShareLink, predicate: predicate, sortDescriptor: ["createdAt"], ascending: false, context: objectContext) as! [PlanItShareLink]
    }
    
    func readAllPendingShareLink(using context: NSManagedObjectContext? = nil) -> [PlanItShareLink] {
        let objectContext = context ?? self.mainObjectContext
        let predicate = NSPredicate(format: "user == %@ AND isPending == YES AND deleteStatus == NO AND warningMessage == %@", Session.shared.readUserId(), Strings.empty)
        return self.readRecords(fromCoreData: Table.planItShareLink, predicate: predicate, context: objectContext) as! [PlanItShareLink]
    }
    
    func readAllPendingDeletedShareLink(using context: NSManagedObjectContext? = nil) -> [PlanItShareLink] {
        let objectContext = context ?? self.mainObjectContext
        let predicate = NSPredicate(format: "user == %@ AND isPending == YES AND deleteStatus == YES", Session.shared.readUserId())
        return self.readRecords(fromCoreData: Table.planItShareLink, predicate: predicate, context: objectContext) as! [PlanItShareLink]
    }
    
    @discardableResult func deleteSpecificShareLink(_ shareLink: Double ) -> PlanItShareLink? {
        if let shopData = self.readSpecificShareLink([shareLink], using: self.mainObjectContext).first {
            self.mainObjectContext.delete(shopData)
            self.mainObjectContext.saveContext()
            return shopData
        }
        return nil
    }
}
