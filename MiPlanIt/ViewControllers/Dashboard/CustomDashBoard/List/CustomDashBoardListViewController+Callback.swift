//
//  CustomDashBoardListViewController+Callback.swift
//  MiPlanIt
//
//  Created by Febin Paul on 25/11/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

extension CustomDashBoardListViewController: CreateDashboardViewControllerDelegate {
    
    
    func createDashboardViewController(_ createDashboardViewController: CreateDashboardViewController, updatedDashBord: Dashboard) {
        guard let planItDashBoard = updatedDashBord.planItDashBoard else { return }
        if let availableDashboard = self.customDashboardProfile.filter({ $0.planItDashboard == updatedDashBord.planItDashBoard }).first {
            availableDashboard.updateCustomeDashboardViewCount(events: self.dashboardEvents, todos: self.dashboardTodos, purchases: self.dashboardPurchase, gifts: self.dashboardGifts, shoppings: self.dashboardShopListItems)
            self.delegate?.customDashBoardListViewController(self, update: availableDashboard)
            self.tableView?.reloadData()
        }
        else {
            let dashboardProfile = CustomDashboardProfile(with: planItDashBoard)
            dashboardProfile.updateCustomeDashboardViewCount(events: self.dashboardEvents, todos: self.dashboardTodos, purchases: self.dashboardPurchase, gifts: self.dashboardGifts, shoppings: self.dashboardShopListItems)
            self.customDashboardProfile.insert(dashboardProfile, at: 0)
            self.delegate?.customDashBoardListViewController(self, onCreate: dashboardProfile)
        }
    }
}


extension CustomDashBoardListViewController: CustomDashboardTableViewCellDelegate {
    
    func customDashboardTableViewCell(_ customDashboardTableViewCell: CustomDashboardTableViewCell, onSelect profile: CustomDashboardProfile?) {
        self.dismiss(animated: true) {
            if customDashboardTableViewCell.index == nil {
                self.delegate?.customDashBoardListViewController(self, onSelect: nil)
            }
            else {
                self.delegate?.customDashBoardListViewController(self, onSelect: profile)
            }
        }
    }
    
    func customDashboardTableViewCell(_ customDashboardTableViewCell: CustomDashboardTableViewCell, onLongPress profile: CustomDashboardProfile?) {
        self.performSegue(withIdentifier: Segues.showPopUpDashboardDetail, sender: profile)
    }

}
