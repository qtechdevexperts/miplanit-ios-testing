//
//  DashBoardViewController+Service.swift
//  MiPlanIt
//
//  Created by Arun Aniyappan on 16/12/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

extension DashBoardViewController {
    
    func fetchAllCustomDashBoard() {
        guard let user = Session.shared.readUser() else { return }
        DashboardService().fetchCustomDashboardData(user) { (result, error) in
            self.updateDashboardProfilesViews()
        }
    }
}
