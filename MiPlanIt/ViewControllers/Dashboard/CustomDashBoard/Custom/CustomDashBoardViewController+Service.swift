//
//  CustomDashBoardViewController+Service.swift
//  MiPlanIt
//
//  Created by Febin Paul on 24/11/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

extension CustomDashBoardViewController {
    
    func fetchAllCustomDashBoard() {
        guard let user = Session.shared.readUser() else { return }
        self.hideAllUserDataIfNeeded()
        DashboardService().fetchCustomDashboardData(user) { (result, error) in
            self.refreshCustomDashboardProfiles()
        }
    }
}
