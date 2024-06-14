//
//  UserNotificationCreator.swift
//  MiPlanIt
//
//  Created by Arun on 16/04/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

class UserNotificationCreator {
    
    let email: String
    let fullName: String
    let phone: String
    let profileImage: String
    let userId: String
    let userName: String
    
    init(with user: [String: Any]) {
        self.email = user["email"] as? String ?? Strings.empty
        self.fullName = user["fullName"] as? String ?? Strings.empty
        self.phone = user["phone"] as? String ?? Strings.empty
        self.profileImage = user["profileImage"] as? String ?? Strings.empty
        self.userId = (user["userId"] as? Double)?.cleanValue() ?? Strings.empty
        self.userName = user["userName"] as? String ?? Strings.empty
    }
    
    init(with planItCreator: PlanItCreator) {
        self.email = planItCreator.readValueOfEmail()
        self.fullName = planItCreator.readValueOfFullName()
        self.phone = planItCreator.readValueOfPhone()
        self.profileImage = planItCreator.readValueOfProfileImage()
        self.userId = planItCreator.readValueOfUserId()
        self.userName = planItCreator.readValueOfUserName()
    }
}