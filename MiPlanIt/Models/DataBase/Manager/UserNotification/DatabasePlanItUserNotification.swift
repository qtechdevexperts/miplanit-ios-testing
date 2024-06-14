//
//  DatabasePlanItUserNotification.swift
//  MiPlanIt
//
//  Created by Febin Paul on 11/01/21.
//  Copyright © 2021 Arun. All rights reserved.
//

import Foundation
import CoreData

class DatabasePlanItUserNotification: DataBaseManager {

    @discardableResult func insertOrUpdateUserNotification(_ data: [[String: Any]], using context: NSManagedObjectContext? = nil) -> [PlanItUserNotification] {
        guard !data.isEmpty else { return [] }
        let objectContext = context ?? self.mainObjectContext
        let notificationId = data.compactMap({ return $0["notificationId"] as? Double })
        var updatedPlanItUserNotification: [PlanItUserNotification] = []
        let localUserNotification = self.readSpecificUserNotification(notificationId, using: objectContext)
        for notification in data {
            let notificationId = notification["notificationId"] as? Double ?? 0
            let userNotificationEntity = localUserNotification.filter({ return $0.notificationId == notificationId}).first ?? self.insertNewRecords(Table.planItUserNotification, context: objectContext) as! PlanItUserNotification
            userNotificationEntity.notificationId = notificationId
            userNotificationEntity.activityId = notification["activityId"] as? Double ?? 0.0
            userNotificationEntity.activityTitle = notification["activityTitle"] as? String ?? Strings.empty
            userNotificationEntity.activityTypeLabel = notification["activityTypeLabel"] as? String ?? Strings.empty
            userNotificationEntity.actvityType = notification["actvityType"] as? Double ?? 0.0
            if let date = notification["createdAt"] as? String {
                userNotificationEntity.createdAt = date.stringToDate(formatter: DateFormatters.MMDDYYYYHMMSSA, timeZone: TimeZone(abbreviation: "UTC")!)
            }
            if let date = notification["modifiedAt"] as? String {
                userNotificationEntity.modifiedAt = date.stringToDate(formatter: DateFormatters.MMDDYYYYHMMSSA, timeZone: TimeZone(abbreviation: "UTC")!)
            }
            if let createdBy = notification["createdBy"] as? [String: Any] {
                DatabasePlanItCreator().insertUserNotification(userNotificationEntity, creator: createdBy)
            }
            if let event = notification["event"] as? [String: Any] {
                DatabasePlanItUserNotificationEvent().insertUserNotificationEvent(userNotificationEntity, notificationEvent: event)
            }
            if let event = notification["bookingEventDetails"] as? [String: Any] {
                DatabasePlanItUserNotificationEvent().insertUserNotificationEvent(userNotificationEntity, notificationEvent: event)
            }
            if let parent = notification["parentNotification"] as? [String: Any] {
                DatabasePlanItUserNotificationParent().insertUserNotificationParent(userNotificationEntity, notificationParent: parent)
            }
            if let subActivityTitles = notification["subActivityTitles"] as? [String] {
                userNotificationEntity.subActivityTitles = subActivityTitles.joined(separator: Strings.subActivityTitlesSeperator)
            }
            userNotificationEntity.notificationAction = notification["notificationAction"] as? Double ?? 0.0
            userNotificationEntity.notificationActionLabel = notification["notificationActionLabel"] as? String ?? Strings.empty
            userNotificationEntity.notificationType = notification["notificationType"] as? Double ?? 0.0
            userNotificationEntity.parentNotificationId = notification["parentNotificationId"] as? Double ?? 0.0
            userNotificationEntity.receiverStatus = notification["receiverStatus"] as? Double ?? 0.0
            userNotificationEntity.receiverStatusLabel = notification["receiverStatusLabel"] as? String ?? Strings.empty
            userNotificationEntity.userId = Session.shared.readUserId()
            if !updatedPlanItUserNotification.contains(where: { (planItUserNotification) -> Bool in
                planItUserNotification.notificationId == notificationId
            }) {
                updatedPlanItUserNotification.append(userNotificationEntity)
            }
        }
        self.mainObjectContext.saveContext()
        return updatedPlanItUserNotification
    }
    
    func deleteNotifications(_ notificationIds: [Double], type: NotificationDelete, activityType: [Int]) {
        let allUserNotification = self.readAllUserNotification()
        switch type {
        case .all:
            allUserNotification.filter({ !$0.isActionNeeded() }).forEach { (notification) in
                self.mainObjectContext.delete(notification)
            }
        case .activityType:
            allUserNotification.filter { (notification) -> Bool in
                !notification.isActionNeeded() && activityType.contains(notification.readActvityType())
            }.forEach { (notification) in
                self.mainObjectContext.delete(notification)
            }
        default:
            allUserNotification.filter{ (notification) -> Bool in
                notificationIds.contains(where: { return $0 == notification.notificationId })
            }.forEach { (notification) in
                self.mainObjectContext.delete(notification)
            }
        }
        self.mainObjectContext.saveContext()
    }
    
    func deleteAllNotifications() {
        self.readAllUserNotification().forEach { (notification) in
            self.mainObjectContext.delete(notification)
        }
    }
    
    private func readSpecificUserNotification(_ notificationIds: [Double], using context: NSManagedObjectContext? = nil) -> [PlanItUserNotification] {
        let objectContext = context ?? self.mainObjectContext
        let predicate = NSPredicate(format: "userId == %@ AND notificationId IN %@", Session.shared.readUserId(), notificationIds)
        return self.readRecords(fromCoreData: Table.planItUserNotification, predicate: predicate, context: objectContext) as! [PlanItUserNotification]
    }
    
    func readAllUserNotification() -> [PlanItUserNotification] {
        let predicate = NSPredicate(format: "userId == %@", Session.shared.readUserId())
        return self.readRecords(fromCoreData: Table.planItUserNotification, predicate: predicate, sortDescriptor: ["modifiedAt"], ascending: false, context: self.mainObjectContext) as! [PlanItUserNotification]
    }

}
