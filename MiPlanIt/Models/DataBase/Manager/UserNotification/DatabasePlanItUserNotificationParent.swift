//
//  DatabasePlanItUserNotificationParent.swift
//  MiPlanIt
//
//  Created by Febin Paul on 12/01/21.
//  Copyright © 2021 Arun. All rights reserved.
//

import Foundation
import CoreData

class DatabasePlanItUserNotificationParent: DataBaseManager {

    func insertUserNotificationParent(_ notification: PlanItUserNotification, notificationParent: [String: Any], using context: NSManagedObjectContext? = nil) {
        let objectContext = context ?? self.mainObjectContext
        let planitNotificationParent = notification.userNotificationparent ?? self.insertNewRecords(Table.planItUserNotificationParent, context: objectContext) as! PlanItUserNotificationParent
        planitNotificationParent.notificationId = notificationParent["notificationId"] as? Double ?? 0.0
        planitNotificationParent.activityType = notificationParent["actvityType"] as? Double ?? 0.0
        planitNotificationParent.activityTypeLabel = notificationParent["activityTypeLabel"] as? String ?? Strings.empty
        planitNotificationParent.activityTitle = notificationParent["activityTitle"] as? String ?? Strings.empty
        planitNotificationParent.notificationType = notificationParent["notificationType"] as? Double ?? 0.0
        planitNotificationParent.notificationAction = notificationParent["notificationAction"] as? Double ?? 0.0
        planitNotificationParent.notificationActionLabel = notificationParent["notificationActionLabel"] as? String ?? Strings.empty
        planitNotificationParent.receiverStatus = notificationParent["receiverStatus"] as? Double ?? 0.0
        planitNotificationParent.receiverStatusLabel = notificationParent["receiverStatusLabel"] as? String ?? Strings.empty
        planitNotificationParent.userNotification = notification
    }
}
