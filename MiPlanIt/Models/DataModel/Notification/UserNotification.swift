//
//  UserNotification.swift
//  MiPlanIt
//
//  Created by Arun on 16/04/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

class UserNotification {
    
    let notificationId: Double
    let actvityType: Double
    let activityTypeLabel: String
    let activityTitle: String
    let notificationType: Double
    let notificationAction: Double
    let notificationActionLabel: String
    let receiverStatus: Double
    let receiverStatusLabel: String
    let createdAt: String
    let modifiedAt: String
    var parentNotificationId: Double?
    var creator: UserNotificationCreator?
    var notificationTo: UserNotificationTo?
    var notificationEvent: UserNotificationEvent?
    var parentNotification: UserNotificationParent?
    var activityId: Double
    var createdAtDate: Date?
    var modifiedAtDate: Date?
    var subActivityTitles: [String]?
    var isAutoSync: Bool?
    
    init(with notification: [String: Any]) {
        self.activityId = notification["activityId"] as? Double ?? 0.0
        self.notificationId = notification["notificationId"] as? Double ?? 0.0
        self.actvityType = notification["actvityType"] as? Double ?? 0.0
        self.activityTypeLabel = notification["activityTypeLabel"] as? String ?? Strings.empty
        self.activityTitle = notification["activityTitle"] as? String ?? Strings.empty
        self.notificationType = notification["notificationType"] as? Double ?? 0.0
        self.notificationAction = notification["notificationAction"] as? Double ?? 0.0
        self.notificationActionLabel = notification["notificationActionLabel"] as? String ?? Strings.empty
        self.receiverStatus = notification["receiverStatus"] as? Double ?? 0.0
        self.receiverStatusLabel = notification["receiverStatusLabel"] as? String ?? Strings.empty
        self.createdAt = notification["createdAt"] as? String ?? Strings.empty
        self.modifiedAt = notification["modifiedAt"] as? String ?? Strings.empty
        self.parentNotificationId = notification["parentNotificationId"] as? Double
        if let createdBy = notification["createdBy"] as? [String: Any] {
            self.creator = UserNotificationCreator(with: createdBy)
        }
        if let notificationTo = notification["notificationTo"] as? [String: Any] {
            self.notificationTo = UserNotificationTo(with: notificationTo)
        }
        if let notificationEvent = notification["event"] as? [String: Any] {
            self.notificationEvent = UserNotificationEvent(with: notificationEvent)
        }
        if let notificationEvent = notification["bookingEventDetails"] as? [String: Any] {
            self.notificationEvent = UserNotificationEvent(with: notificationEvent)
        }
        if let participentResponse = notification["parentNotification"] as? [String: Any] {
            self.parentNotification = UserNotificationParent(with: participentResponse)
        }
        if self.actvityType == 7.0, let subActivities = notification["subActivityTitles"] as? [String] {
            self.subActivityTitles = subActivities
        }
        self.isAutoSync = notification["isAutoSync"] as? Bool
    }
    
    init(with planItNotification: PlanItUserNotification) {
        self.activityId = planItNotification.activityId
        self.notificationId = planItNotification.notificationId
        self.actvityType = planItNotification.actvityType
        self.activityTypeLabel = planItNotification.activityTypeLabel ?? Strings.empty
        self.activityTitle = planItNotification.activityTitle ?? Strings.empty
        self.notificationType = planItNotification.notificationType
        self.notificationAction = planItNotification.notificationAction
        self.notificationActionLabel = planItNotification.notificationActionLabel ?? Strings.empty
        self.receiverStatus = planItNotification.receiverStatus
        self.receiverStatusLabel = planItNotification.receiverStatusLabel ?? Strings.empty
        self.createdAtDate = planItNotification.createdAt
        self.modifiedAtDate = planItNotification.modifiedAt
        self.parentNotificationId = planItNotification.parentNotificationId == 0.0 ? nil : planItNotification.parentNotificationId
        self.createdAt = planItNotification.createdAt?.stringFromDate(format: DateFormatters.MMDDYYYYHMMSSA, timeZone: TimeZone(abbreviation: "UTC")!) ?? Strings.empty
        self.modifiedAt = planItNotification.modifiedAt?.stringFromDate(format: DateFormatters.MMDDYYYYHMMSSA, timeZone: TimeZone(abbreviation: "UTC")!) ?? Strings.empty
        if let createdBy = planItNotification.createdBy {
            self.creator = UserNotificationCreator(with: createdBy)
        }
        if let notificationEvent = planItNotification.notificationEvent {
            self.notificationEvent = UserNotificationEvent(with: notificationEvent)
        }
        if let notificationParent = planItNotification.userNotificationparent {
            self.parentNotification = UserNotificationParent(with: notificationParent)
        }
        if let subActivityTitles = planItNotification.subActivityTitles, !subActivityTitles.isEmpty, let splitCharecter  = Strings.subActivityTitlesSeperator.first {
            self.subActivityTitles = subActivityTitles.split(separator: splitCharecter).map { String($0) }
        }
    }
    
    func readStartDateString() -> String {
        return self.createdAt.stringToDate(formatter: DateFormatters.MMDDYYYYHMMSSA, timeZone: TimeZone(abbreviation: "UTC")!)?.stringFromDate(format: DateFormatters.DDSMMMSYYYY) ?? Strings.empty
    }
    
    func readNotificationId() -> Int {
        return Int(self.notificationId)
    }
    
    func readActvityType() -> Int {
        return Int(self.actvityType)
    }
    
    func readActvityId() -> Double {
        return self.activityId
    }
    
    private func isReplyNotification() -> Bool {
        return self.parentNotificationId != nil
    }
    
    func readNotificationAction() -> Int {
        return self.isReplyNotification() ? 101 : Int(self.notificationAction)
    }
    
    func readOrginalNotificationAction() -> Int {
        return Int(self.notificationAction)
    }
    
    func readSubActivityTitles() -> [String] {
        return self.subActivityTitles ?? []
    }
    
    func readNotificationStatus() -> Double {
        if let parentResponse = self.parentNotification, self.isReplyNotification() {
            return parentResponse.receiverStatus
        }
        return self.receiverStatus
    }
    
    func readNotificationUserStatus() -> Double {
        return self.receiverStatus
    }
    
    func readNotificationStatusLabel() -> String {
        if let parentResponse = self.parentNotification, self.isReplyNotification() {
            return parentResponse.receiverStatusLabel
        }
        return self.receiverStatusLabel
    }
    
    func isExpiredEvent() -> Bool {
        return false
//        guard let expireDate = self.notificationEvent?.readEndDateTime(), self.actvityType != 1.0, expireDate.compare(Date()) == .orderedAscending else { return false }
//        return true
    }
    
    func isActionNeeded() -> Bool {
        return self.readNotificationAction() == 1 && self.readNotificationStatus() == 0
    }
    
    func isReadyToShowUserActions() -> Bool {
        return self.isActionNeeded() && !self.isExpiredEvent()
    }
    
    func isPossibleToUpdateMarkAsRead() -> Bool {
        return (self.isActionNeeded() && self.isExpiredEvent()) || (self.readNotificationAction() != 1 && self.readNotificationUserStatus() != 4)
    }
    
    func readIsAutoSync() -> Bool {
        return (self.isAutoSync ?? false)
    }
}
