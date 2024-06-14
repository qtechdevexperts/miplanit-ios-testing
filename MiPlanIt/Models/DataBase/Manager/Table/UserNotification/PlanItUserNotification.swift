//
//  PlanItUserNotification.swift
//  MiPlanIt
//
//  Created by Febin Paul on 12/01/21.
//  Copyright © 2021 Arun. All rights reserved.
//

import Foundation


extension PlanItUserNotification {
    
    func readActvityType() -> Int {
        return Int(self.actvityType)
    }
    
    private func isReplyNotification() -> Bool {
        return self.parentNotificationId != 0.0
    }
    
    func readNotificationAction() -> Int {
        return self.isReplyNotification() ? 101 : Int(self.notificationAction)
    }
    
    func readNotificationStatus() -> Double {
        if let parentResponse = self.userNotificationparent, self.isReplyNotification() {
            return parentResponse.receiverStatus
        }
        return self.receiverStatus
    }
    
    func isActionNeeded() -> Bool {
        return self.readNotificationAction() == 1 && self.readNotificationStatus() == 0
    }
}
