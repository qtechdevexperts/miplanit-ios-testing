//
//  CustomDashBoardListViewController+Offline.swift
//  MiPlanIt
//
//  Created by Febin Paul on 21/12/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

extension CustomDashBoardListViewController {
    
    func deleteDashboardToServerUsingNetwotk(_ dashboard: CustomDashboardProfile) {
        if SocialManager.default.isNetworkReachable() {
            self.deleteCustomDashboard(dashboard)
        }
        else {
            DatabasePlanItDashboard().deleteCustomDashboard(planItDashboard: dashboard.planItDashboard)
            self.customDashboardProfile.removeAll { (dashboardProfile) -> Bool in
                dashboardProfile.planItDashboard == dashboard.planItDashboard
            }
            self.delegate?.customDashBoardListViewController(self, deleted: dashboard)
        }
    }
}
