//
//  UserDefaultManager.swift
//  MiPlanIt
//
//  Created by Maaz Tauseef on 14/03/2023.
//  Copyright © 2023 Arun. All rights reserved.
//

import Foundation
import SwiftDefaults
class UserDefaultsManager: SwiftDefaults {
    @objc dynamic var tokenStr: String? = nil
    @objc dynamic var tokenStrDeep: String? = nil

    @objc dynamic var fcmTocken: String? = nil
//    @objc dynamic var user: UserInfo? = nil
    @objc dynamic var defaultCarID: String? = nil
    @objc dynamic var fullName: String? = nil
    @objc dynamic var userEmail: String? = nil
    @objc dynamic var mobileNumber: String? = nil
    @objc dynamic var udid:String? = nil
    @objc dynamic var declineId:String? = nil
    @objc dynamic var isWalkthrough:String? = "true"
   func clear() {
       tokenStr = nil
    }
    
    
    
    
}
