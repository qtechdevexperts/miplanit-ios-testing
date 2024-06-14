//
//  SocialUserType.swift
//  MiPlanIt
//
//  Created by Arun on 11/09/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

class SocialUserType {
    
    let type: Double
    let users: [PlanItSocialUser]
    
    init(with type: Double, users: [PlanItSocialUser]) {
        self.type = type
        self.users = users
    }
}
