//
//  CustomDashBoardViewController+Offline.swift
//  MiPlanIt
//
//  Created by Febin Paul on 01/01/21.
//  Copyright © 2021 Arun. All rights reserved.
//

import Foundation

extension CustomDashBoardViewController {
    
    func fetchAllCustomDashBoardUsingNetwork() {
        if SocialManager.default.isNetworkReachable() {
            self.fetchAllCustomDashBoard()
        }
        else {
            self.hideAllUserDataIfNeeded()
            self.refreshCustomDashboardProfiles()
        }
    }
}
