//
//  CustomDashBoardViewController+Callback.swift
//  MiPlanIt
//
//  Created by Febin Paul on 24/11/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation


extension CustomDashBoardViewController: CreateDashboardViewControllerDelegate {
    
    func createDashboardViewController(_ createDashboardViewController: CreateDashboardViewController, updatedDashBord: Dashboard) {
        guard let planItDashBoard = updatedDashBord.planItDashBoard  else { return }
        if self.availableDashboardProfiles.first(where: { return $0.planItDashboard == planItDashBoard }) != nil {
            self.delegate?.customDashBoardViewControllerDelegate(self, updateCustomDashboard: updatedDashBord.planItDashBoard)
        }
        else {
            self.delegate?.customDashBoardViewControllerDelegate(self, createCustomDashboard: updatedDashBord.planItDashBoard)
        }
        self.updateDashboardView(planItDashBoard)
    }
}

extension CustomDashBoardViewController: CustomDashBoardListViewControllerDelegate {
    
    func customDashBoardListViewController(_ customDashBoardListViewController: CustomDashBoardListViewController, update profile: CustomDashboardProfile) {
        self.updateExistingDashboardProfile(profile, onUpdate: true)
        self.delegate?.customDashBoardViewControllerDelegate(self, updateCustomDashboard: profile.planItDashboard)
    }
    
    
    func customDashBoardListViewController(_ customDashBoardListViewController: CustomDashBoardListViewController, onCreate dashBoard: CustomDashboardProfile) {
        guard let planItDashBoard = dashBoard.planItDashboard  else { return }
        self.updateDashboardView(planItDashBoard)
        self.delegate?.customDashBoardViewControllerDelegate(self, createCustomDashboard: dashBoard.planItDashboard)
    }
    
    func customDashBoardListViewController(_ customDashBoardListViewController: CustomDashBoardListViewController, onSelect dashBoard: CustomDashboardProfile?) {
        if self.navigationController?.viewControllers.first is Self {
            let storyBoard = UIStoryboard(name: StoryBoards.dashboard, bundle: Bundle.main)
            guard let dashBoardViewController = storyBoard.instantiateViewController(withIdentifier: StoryBoardIdentifier.dashboard) as? DashBoardViewController else { return }
            dashBoardViewController.customDashboard = dashBoard?.planItDashboard
            dashBoardViewController.dashboardEvents = self.dashboardEvents
            dashBoardViewController.currentSearchEventIndex = self.currentSearchEventIndex
            dashBoardViewController.dashboardPurchases = self.dashboardPurchases
            dashBoardViewController.currentSearchPurchaseIndex = self.currentSearchPurchaseIndex
            dashBoardViewController.dashboardGifts = self.dashboardGifts
            dashBoardViewController.currentSearchGiftIndex = self.currentSearchGiftIndex
            dashBoardViewController.dashboardTodos = self.dashboardTodos
            dashBoardViewController.currentSearchToDoIndex = self.currentSearchToDoIndex
            dashBoardViewController.dashboardShopings = self.dashboardShopings
            dashBoardViewController.currentSearchShoppingIndex = self.currentSearchShoppingIndex
            self.navigationController?.setViewControllers([dashBoardViewController], animated: true)
        }
        else {
            self.navigationController?.popViewController(animated: true)
            self.delegate?.customDashBoardViewControllerDelegate(self, selectedCustomDashboard: dashBoard?.planItDashboard)
        }
    }
    
    func customDashBoardListViewController(_ customDashBoardListViewController: CustomDashBoardListViewController, deleted dashBoard: CustomDashboardProfile) {
        self.hideAllUserDataIfNeeded()
        self.availableDashboardProfiles.removeAll { (dashboardProfile) -> Bool in
            dashboardProfile.planItDashboard == dashBoard.planItDashboard
        }
        self.setUsersOnView()
        self.delegate?.customDashBoardViewControllerDelegate(self, deleteCustomDashboard: dashBoard.planItDashboard)
    }
}

extension CustomDashBoardViewController: CustomDashboardViewDelegate {
    
    func customDashboardViewDelegate(_ customDashboardView: CustomDashboardView, profileImageDownload: UIImage?) {
        self.profilesImageDownloadCount += 1
        self.showAllUserDataIfNeeded()
    }
    
    func customDashboardViewDelegate(_ customDashboardView: CustomDashboardView, longPressDashboardProfile: CustomDashboardProfile?) {
        self.performSegue(withIdentifier: Segues.showPopUpDashboardDetail, sender: longPressDashboardProfile)
    }
    
    func customDashboardViewDelegate(_ customDashboardView: CustomDashboardView, dashboardProfile: CustomDashboardProfile?) {
        guard let dashboard = dashboardProfile else { return }
        if self.navigationController?.viewControllers.first is Self {
            let storyBoard = UIStoryboard(name: StoryBoards.dashboard, bundle: Bundle.main)
            guard let dashBoardViewController = storyBoard.instantiateViewController(withIdentifier: StoryBoardIdentifier.dashboard) as? DashBoardViewController else { return }
            dashBoardViewController.customDashboard = dashboard.planItDashboard
            dashBoardViewController.dashboardEvents = self.dashboardEvents
            dashBoardViewController.currentSearchEventIndex = self.currentSearchEventIndex
            dashBoardViewController.dashboardPurchases = self.dashboardPurchases
            dashBoardViewController.currentSearchPurchaseIndex = self.currentSearchPurchaseIndex
            dashBoardViewController.dashboardGifts = self.dashboardGifts
            dashBoardViewController.currentSearchGiftIndex = self.currentSearchGiftIndex
            dashBoardViewController.dashboardTodos = self.dashboardTodos
            dashBoardViewController.currentSearchToDoIndex = self.currentSearchToDoIndex
            dashBoardViewController.dashboardShopings = self.dashboardShopings
            dashBoardViewController.currentSearchShoppingIndex = self.currentSearchShoppingIndex
            self.navigationController?.setViewControllers([dashBoardViewController], animated: true)
        }
        else {
            self.navigationController?.popViewController(animated: true)
            self.delegate?.customDashBoardViewControllerDelegate(self, selectedCustomDashboard: dashboard.planItDashboard)
        }
    }
}
