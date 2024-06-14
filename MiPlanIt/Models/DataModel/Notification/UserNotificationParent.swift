//
//  UserNotificationParent.swift
//  MiPlanIt
//
//  Created by Arun on 22/04/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

class UserNotificationParent {
    
    let notificationId: Double
    let actvityType: Double
    let activityTypeLabel: String
    let activityTitle: String
    let notificationType: Double
    let notificationAction: Double
    let notificationActionLabel: String
    let receiverStatus: Double
    let receiverStatusLabel: String
    
    init(with data: [String: Any]) {
        self.notificationId = data["notificationId"] as? Double ?? 0.0
        self.actvityType = data["actvityType"] as? Double ?? 0.0
        self.activityTypeLabel = data["activityTypeLabel"] as? String ?? Strings.empty
        self.activityTitle = data["activityTitle"] as? String ?? Strings.empty
        self.notificationType = data["notificationType"] as? Double ?? 0.0
        self.notificationAction = data["notificationAction"] as? Double ?? 0.0
        self.notificationActionLabel = data["notificationActionLabel"] as? String ?? Strings.empty
        self.receiverStatus = data["receiverStatus"] as? Double ?? 0.0
        self.receiverStatusLabel = data["receiverStatusLabel"] as? String ?? Strings.empty
    }
    
    
    init(with planItNotificationParent: PlanItUserNotificationParent) {
        self.notificationId = planItNotificationParent.notificationId
        self.actvityType = planItNotificationParent.activityType
        self.activityTypeLabel = planItNotificationParent.activityTypeLabel ?? Strings.empty
        self.activityTitle = planItNotificationParent.activityTitle ?? Strings.empty
        self.notificationType = planItNotificationParent.notificationType
        self.notificationAction = planItNotificationParent.notificationAction
        self.notificationActionLabel = planItNotificationParent.notificationActionLabel ?? Strings.empty
        self.receiverStatus = planItNotificationParent.receiverStatus
        self.receiverStatusLabel = planItNotificationParent.receiverStatusLabel ?? Strings.empty
    }
}
