//
//  DataBasePlanItTodoReminders.swift
//  MiPlanIt
//
//  Created by Febin Paul on 12/08/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation
import CoreData

class DataBasePlanItTodoReminders: DataBaseManager {
    
    func insertTodo(_ todo: PlanItTodo, reminders: [String: Any], using context: NSManagedObjectContext? = nil) {
        let objectContext = context ?? self.mainObjectContext
        let reminderEntity = todo.reminder ?? self.insertNewRecords(Table.planItReminder, context: objectContext) as! PlanItReminder
        reminderEntity.emailNotification = reminders["emailNotification"] as? Bool ?? false
        reminderEntity.emailNotificationBody = reminders["emailNotificationBody"] as? String
        reminderEntity.interval = reminders["intrvl"] as? Double ?? 0
        reminderEntity.intervalType = reminders["intrvlType"] as? Double ?? 0
        reminderEntity.startDate = reminders["startDate"] as? String
        reminderEntity.startTime = reminders["startTime"] as? String
        reminderEntity.reminderId = reminders["reminderId"] as? Double ?? 0
        reminderEntity.todo = todo
    }
    
    func insertTodo(_ todo: PlanItTodo, reminders: ReminderModel, using context: NSManagedObjectContext? = nil) {
        let objectContext = context ?? self.mainObjectContext
        let reminderEntity = todo.reminder ?? self.insertNewRecords(Table.planItReminder, context: objectContext) as! PlanItReminder
        reminderEntity.emailNotification = reminders.emailNotification
        reminderEntity.emailNotificationBody = reminders.emailNotificationBody
        reminderEntity.interval = Double(reminders.readStringInterval()) ?? 0
        reminderEntity.intervalType = Double(reminders.readStringIntervalType()) ?? 0
        reminderEntity.startTime = reminders.reminderTime
        reminderEntity.todo = todo
    }
    
    func insertSilentEvent(_ event: PlanItSilentEvent, reminders: [String: Any], using context: NSManagedObjectContext? = nil) {
        let objectContext = context ?? self.mainObjectContext
        let reminderEntity = event.reminder ?? self.insertNewRecords(Table.planItReminder, context: objectContext) as! PlanItReminder
        reminderEntity.emailNotification = reminders["emailNotification"] as? Bool ?? false
        reminderEntity.emailNotificationBody = reminders["emailNotificationBody"] as? String
        reminderEntity.interval = reminders["intrvl"] as? Double ?? 0
        reminderEntity.intervalType = reminders["intrvlType"] as? Double ?? 0
        reminderEntity.startDate = reminders["startDate"] as? String
        reminderEntity.startTime = reminders["startTime"] as? String
        reminderEntity.reminderId = reminders["reminderId"] as? Double ?? 0
        reminderEntity.silentEvent = event
    }
    
    func insertEvent(_ event: PlanItEvent, reminders: PlanItReminder, using context: NSManagedObjectContext? = nil) {
        let objectContext = context ?? self.mainObjectContext
        let reminderEntity = event.reminder ?? self.insertNewRecords(Table.planItReminder, context: objectContext) as! PlanItReminder
        reminderEntity.emailNotification = reminders.emailNotification
        reminderEntity.emailNotificationBody = reminders.emailNotificationBody
        reminderEntity.interval = reminders.interval
        reminderEntity.intervalType = reminders.intervalType
        reminderEntity.startDate = reminders.startDate
        reminderEntity.startTime = reminders.startTime
        reminderEntity.reminderId = reminders.reminderId
        reminderEntity.event = event
    }
    
    func insertEvent(_ event: PlanItEvent, reminders: [String: Any], using context: NSManagedObjectContext? = nil) {
        let objectContext = context ?? self.mainObjectContext
        let reminderEntity = event.reminder ?? self.insertNewRecords(Table.planItReminder, context: objectContext) as! PlanItReminder
        reminderEntity.emailNotification = reminders["emailNotification"] as? Bool ?? false
        reminderEntity.emailNotificationBody = reminders["emailNotificationBody"] as? String
        reminderEntity.interval = reminders["intrvl"] as? Double ?? 0
        reminderEntity.intervalType = reminders["intrvlType"] as? Double ?? 0
        reminderEntity.startDate = reminders["startDate"] as? String
        reminderEntity.startTime = reminders["startTime"] as? String
        reminderEntity.reminderId = reminders["reminderId"] as? Double ?? 0
        reminderEntity.event = event
    }
    
    func insertEvent(_ event: PlanItEvent, reminders: ReminderModel, using context: NSManagedObjectContext? = nil) {
        let objectContext = context ?? self.mainObjectContext
        let reminderEntity = event.reminder ?? self.insertNewRecords(Table.planItReminder, context: objectContext) as! PlanItReminder
        reminderEntity.emailNotification = reminders.emailNotification
        reminderEntity.emailNotificationBody = reminders.emailNotificationBody
        reminderEntity.interval = Double(reminders.readStringInterval()) ?? 0
        reminderEntity.intervalType = Double(reminders.readStringIntervalType()) ?? 0
        reminderEntity.event = event
    }
    
    func insertShopListItem(_ shopListItem: PlanItShopListItems, reminders: [String: Any], using context: NSManagedObjectContext? = nil) {
        let objectContext = context ?? self.mainObjectContext
        let reminderEntity = shopListItem.reminder ?? self.insertNewRecords(Table.planItReminder, context: objectContext) as! PlanItReminder
        reminderEntity.emailNotification = reminders["emailNotification"] as? Bool ?? false
        reminderEntity.emailNotificationBody = reminders["emailNotificationBody"] as? String
        reminderEntity.interval = reminders["intrvl"] as? Double ?? 0
        reminderEntity.intervalType = reminders["intrvlType"] as? Double ?? 0
        reminderEntity.startDate = reminders["startDate"] as? String
        reminderEntity.startTime = reminders["startTime"] as? String
        reminderEntity.reminderId = reminders["reminderId"] as? Double ?? 0
        reminderEntity.shopListItem = shopListItem
    }
    
    func insertShopListItem(_ shopListItem: PlanItShopListItems, shopListItemModel: ShopListItemDetailModel, using context: NSManagedObjectContext? = nil) {
        let objectContext = context ?? self.mainObjectContext
        let reminderEntity = shopListItem.reminder ??  self.insertNewRecords(Table.planItReminder, context: objectContext) as! PlanItReminder
        reminderEntity.emailNotification = shopListItemModel.remindValue?.readEmailNotification() ?? false
        reminderEntity.emailNotificationBody = shopListItemModel.remindValue?.readEmailNotificationBody() ?? Strings.empty
        reminderEntity.interval = Double(shopListItemModel.remindValue?.reminderBeforeValue ?? 0)
        reminderEntity.intervalType = Double(shopListItemModel.remindValue?.readStringIntervalType() ?? Strings.empty) ?? 0
        reminderEntity.startTime = shopListItemModel.remindValue?.reminderTime
        reminderEntity.shopListItem = shopListItem
    }
    
    func insertShareLink(_ shareLink: PlanItShareLink, reminders: [[String: Any]], using context: NSManagedObjectContext? = nil) {
        shareLink.deleteAllReminder()
        let objectContext = context ?? self.mainObjectContext
        for remind in reminders {
            let reminderEntity = self.insertNewRecords(Table.planItReminder, context: objectContext) as! PlanItReminder
            reminderEntity.emailNotification = remind["emailNotification"] as? Bool ?? false
            reminderEntity.emailNotificationBody = remind["emailNotificationBody"] as? String
            reminderEntity.interval = remind["intrvl"] as? Double ?? 0
            reminderEntity.intervalType = remind["intrvlType"] as? Double ?? 0
            reminderEntity.startDate = remind["startDate"] as? String
            reminderEntity.startTime = remind["startTime"] as? String
            reminderEntity.reminderId = remind["reminderId"] as? Double ?? 0
            reminderEntity.shareLink = shareLink
        }
    }
    
    func insertShareLink(_ shareLink: PlanItShareLink, reminders: ReminderModel, using context: NSManagedObjectContext? = nil) {
        let objectContext = context ?? self.mainObjectContext
        let reminderEntity = shareLink.readFirstReminder() ?? self.insertNewRecords(Table.planItReminder, context: objectContext) as! PlanItReminder
        reminderEntity.emailNotification = reminders.emailNotification
        reminderEntity.emailNotificationBody = reminders.emailNotificationBody
        reminderEntity.interval = Double(reminders.readStringInterval()) ?? 0
        reminderEntity.intervalType = Double(reminders.readStringIntervalType()) ?? 0
        reminderEntity.shareLink = shareLink
    }
}
