//
//  CustomDashBoardListViewController+Service.swift
//  MiPlanIt
//
//  Created by Febin Paul on 24/11/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation


extension CustomDashBoardListViewController {
    
    func deleteCustomDashboard(_ dashboard: CustomDashboardProfile) {
        self.startLoadingIndicatorForShopListItem([dashboard])
        DashboardService().deletedashboard(dashboard.planItDashboard) { (response, error) in
            self.stopLoadingIndicatorForTodos([dashboard])
            if response {
                self.customDashboardProfile.removeAll { (dashboardProfile) -> Bool in
                    dashboardProfile.planItDashboard == dashboard.planItDashboard
                }
                self.delegate?.customDashBoardListViewController(self, deleted: dashboard)
            }
            else {
                let message = error ?? Message.unknownError
                self.performSegue(withIdentifier: Segues.toMessageScreen, sender: [Message.error, message])
            }
        }
    }
}
