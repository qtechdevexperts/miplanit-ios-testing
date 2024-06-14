//
//  AppVersionModel.swift
//  MiPlanIt
//
//  Created by Febin Paul on 25/02/21.
//  Copyright © 2021 Arun. All rights reserved.
//

import Foundation

class AppVersionModel {
    
    var appVersion: String?
    var appVersionDetails: String?
    var isOptional: Bool?
    
    init(data: [String: Any]) {
        self.appVersion = data["app_version"] as? String
        self.appVersionDetails = data["appVersionDetails"] as? String
        self.isOptional = data["isOptional"] as? Bool
    }
    
    func readOptional() -> Bool {
        return self.isOptional ?? false
    }
}
