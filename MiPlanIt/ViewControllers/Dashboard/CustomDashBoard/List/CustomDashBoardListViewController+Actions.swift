//
//  CustomDashBoardListViewController+Actions.swift
//  MiPlanIt
//
//  Created by fsadmin on 06/11/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

extension CustomDashBoardListViewController {
    
    func initialiseUIComponents() {
        self.buttonAddDashboard.isHidden = !editable
        var sectionName: String = "Today"
        switch self.activeDashboardSection {
        case .today:
            sectionName = "Today's Count"
        case .tomorrow:
            sectionName = "Tomorrow's Count"
        case .week:
            sectionName = "This Week's Count"
        case .all:
            sectionName = "Upcoming Count"
        }
        self.labelDashboardSection.text = sectionName
    }
    
    func startLoadingIndicatorForShopListItem(_ customDashboardProfile: [CustomDashboardProfile]) {
        for eachItem in customDashboardProfile {
            if let index = self.customDashboardProfile.firstIndex(where: { $0.planItDashboard == eachItem.planItDashboard }) {
              let indexPath = IndexPath(row: 0, section: index+1)
                if let cell = self.tableView?.cellForRow(at: indexPath) as? CustomDashboardTableViewCell {
                    cell.startGradientAnimation()
                }
            }
        }
    }
    
    func stopLoadingIndicatorForTodos(_ customDashboardProfile: [CustomDashboardProfile]) {
        for eachItem in customDashboardProfile {
            if let index = self.customDashboardProfile.firstIndex(where: { $0.planItDashboard == eachItem.planItDashboard }) {
                let indexPath = IndexPath(row: 0, section: index+1)
                if let cell = self.tableView?.cellForRow(at: indexPath) as? CustomDashboardTableViewCell {
                    cell.stopGradientAnimation()
                }
            }
        }
    }
    
    func deleteDashboard(_ dashboard: CustomDashboardProfile) {
        self.showAlertWithAction(message: Message.deleteCustomDashboardMessage, title: Message.deleteDashboard, items: [Message.yes, Message.cancel], callback: { index in
            if index == 0 {
                self.deleteDashboardToServerUsingNetwotk(dashboard)
            }
        })
    }
    
    func markAsDefault(_ dashboard: CustomDashboardProfile?) {
        self.showAlertWithAction(message: Message.defaultCustomDashboardMessage, title: Message.defaultDashboard, items: [Message.yes, Message.cancel], callback: { index in
            if index == 0 {
                self.customDashboardProfile.forEach({ if $0.planItDashboard == dashboard?.planItDashboard { $0.planItDashboard.isDefault = true} else { $0.planItDashboard.isDefault = false  } })
                CoreData.default.mainManagedObjectContext.saveContext()
                self.tableView?.reloadData()
            }
        })
    }
    
    func isHelpShown() -> Bool {
        return Storage().readBool(UserDefault.customDashboardListHelp) ?? false
    }
}
