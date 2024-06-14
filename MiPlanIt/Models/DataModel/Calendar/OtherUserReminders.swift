//
//  OtherUserReminders.swift
//  MiPlanIt
//
//  Created by Febin Paul on 13/08/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

class OtherUserReminders {
    
    var startDate: String = Strings.empty
    var startTime: String = Strings.empty
    var interval: Double = 0
    var intervalType: Double = 0
    var emailNotification: Bool = false
    var reminderId: Double = 0
    var emailNotificationBody: String = Strings.empty
    
    init(with data: [String: Any]) {
        self.startDate = data["startDate"] as? String ?? Strings.empty
        self.startTime = data["startTime"] as? String ?? Strings.empty
        self.reminderId = data["reminderId"] as? Double ?? 0
        self.intervalType = data["intrvlType"] as? Double ?? 0
        self.interval = data["intrvl"] as? Double ?? 0
        self.emailNotification = data["emailNotification"] as? Bool ?? false
        self.emailNotificationBody = data["emailNotificationBody"] as? String ?? Strings.empty
    }
    
    func readUnit() -> String {
        switch self.intervalType  {
        case 1:
            return Strings.minUnit
        case 2:
            return Strings.hourUnit
        case 3:
            return Strings.dayUnit
        case 4:
            return Strings.weekUnit
        case 5:
            return Strings.monthUnit
        case 6:
            return Strings.yearUnit
        default:
            return Strings.empty
        }
    }
}
