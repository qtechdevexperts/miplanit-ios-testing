//
//  DashboardSettingViewController+Action.swift
//  MiPlanIt
//
//  Created by Aneesh Asokan on 10/12/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

extension DashboardSettingViewController {
    
    func initialiseUIComponents() {
        if let settings = Session.shared.readUser()?.readUserSettings() {
            self.buttonCustom.isSelected = settings.isCustomDashboard
            self.buttonStandard.isSelected = !settings.isCustomDashboard
        }
    }
}
