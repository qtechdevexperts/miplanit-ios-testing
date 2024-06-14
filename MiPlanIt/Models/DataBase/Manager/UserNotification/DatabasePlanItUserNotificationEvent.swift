//
//  DatabasePlanItUserNotificationEvent.swift
//  MiPlanIt
//
//  Created by Febin Paul on 12/01/21.
//  Copyright © 2021 Arun. All rights reserved.
//

import Foundation
import CoreData

class DatabasePlanItUserNotificationEvent: DataBaseManager {

    func insertUserNotificationEvent(_ notification: PlanItUserNotification, notificationEvent: [String: Any], using context: NSManagedObjectContext? = nil) {
        let objectContext = context ?? self.mainObjectContext
        guard let _ = notificationEvent["startDate"] as? String else { return }
        let planitNotificationEvent = notification.notificationEvent ?? self.insertNewRecords(Table.planItUserNotificationEvent, context: objectContext) as! PlanItUserNotificationEvent
        planitNotificationEvent.location = notificationEvent["location"] as? String ?? Strings.empty
        planitNotificationEvent.startDate = notificationEvent["startDate"] as? String ?? Strings.empty
        planitNotificationEvent.endDate = notificationEvent["endDate"] as? String ?? Strings.empty
        planitNotificationEvent.startTime = notificationEvent["startTime"] as? String ?? Strings.empty
        planitNotificationEvent.endTime = notificationEvent["endTime"] as? String ?? Strings.empty
        planitNotificationEvent.isAllDay = notificationEvent["isAllDay"] as? Bool ?? false
        planitNotificationEvent.isRegUser = notificationEvent["regUser"] as? Bool ?? false
        planitNotificationEvent.sharedEmail = notificationEvent["sharedEmail"] as? String ?? Strings.empty
        planitNotificationEvent.userNotification = notification
    }

}
