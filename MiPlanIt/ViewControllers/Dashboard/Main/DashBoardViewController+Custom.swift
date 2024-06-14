//
//  DashBoardViewController+Custom.swift
//  MiPlanIt
//
//  Created by Arun Aniyappan on 16/12/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

extension DashBoardViewController {
    
    func updateDashboardProfilesViews() {
        self.availableDashboardProfiles = DatabasePlanItDashboard().readAllDashboards().map({ CustomDashboardProfile(with: $0) })
        self.updateDashboardProfileViewsAllItemsCount()
    }
    
    func updateDashboardProfileViewsAllItemsCount() {
        self.availableDashboardProfiles.forEach { (customDashboardProfile) in
            customDashboardProfile.updateCustomeDashboardViewCount(events: self.visibleEvents, todos: self.visibleTodos, purchases: self.visiblePurchases, gifts: self.visibleGifts, shoppings: self.visibleShopings)
        }
    }
    
    func updateDashboardProfileViewsWithSpecificType(_ type: DashBoardTitle) {
        DispatchQueue.main.async {
            switch type {
            case .event:
                self.availableDashboardProfiles.forEach({ $0.updateCustomeDashboardEvent(self.visibleEvents)})
            case .toDo:
                self.availableDashboardProfiles.forEach({ $0.updateCustomeDashboardTodos(self.visibleTodos)})
            case .purchase:
                self.availableDashboardProfiles.forEach({ $0.updateCustomeDashboardPurchases(self.visiblePurchases) })
            case .giftCard:
                self.availableDashboardProfiles.forEach({ $0.updateCustomeDashboardGifts(self.visibleGifts) })
            case .shopping:
                self.availableDashboardProfiles.forEach({ $0.updateCustomeDashboardShopings(self.visibleShopings) })
            }
        }
    }
    
    func addCustomDashboard(planItDashBoard: PlanItDashboard) {
        let profile = CustomDashboardProfile(with: planItDashBoard)
        self.availableDashboardProfiles.insert(profile, at: 0)
        profile.updateCustomeDashboardViewCount(events: self.visibleEvents, todos: self.visibleTodos, purchases: self.visiblePurchases, gifts: self.visibleGifts, shoppings: self.visibleShopings)
    }
}
