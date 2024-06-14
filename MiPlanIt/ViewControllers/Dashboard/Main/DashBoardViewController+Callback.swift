//
//  DashBoardViewController+Callback.swift
//  MiPlanIt
//
//  Created by Aneesh Asokan on 19/05/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation


extension DashBoardViewController: DashBoardListMainViewControllerDelegate {
    
    func dashBoardListMainViewController(_ dashBoardListMainViewController: DashBoardListMainViewController, selectedItem: Any) {
        if let dashboardEventItem = selectedItem as? DashboardEventItem {
            self.performSegue(withIdentifier: Segues.toShowEvent, sender: dashboardEventItem)
        }
        else if let todo = selectedItem as? DashboardToDoItem, let planItToDo = todo.todoData as? PlanItTodo {
            self.performSegue(withIdentifier: Segues.segueToDoDetail, sender: (planItToDo, todo.actualDate))
        }
        else if let dashboardPurchaseItem = selectedItem as? DashboardPurchaseItem {
            self.performSegue(withIdentifier: Segues.toPurchaseDetails, sender: dashboardPurchaseItem)
        }
        else if let dashboardGiftItem = selectedItem as? DashboardGiftItem {
            self.performSegue(withIdentifier: Segues.toGiftCouponDetails, sender: dashboardGiftItem)
        }
        else if let dashboardShopListItem = selectedItem as? DashboardShopListItem {
            self.performSegue(withIdentifier: Segues.shoppingListItemDetail, sender: dashboardShopListItem)
        }
    }
    
    func dashBoardListMainViewController(_ dashBoardListMainViewController: DashBoardListMainViewController, toDoToday: Any) {
        if let toDoItems = toDoToday as? [DashboardToDoItem] {
            self.performSegue(withIdentifier: Segues.toMainCategoryToDoListView, sender: (toDoItems.compactMap({$0.todoData}), ToDoMainCategory.today))
        }
    }
    
    func dashBoardListMainViewController(_ dashBoardListMainViewController: DashBoardListMainViewController, toDoOverdue: [PlanItTodo]) {
        self.performSegue(withIdentifier: Segues.toMainCategoryToDoListView, sender: (toDoOverdue, ToDoMainCategory.overdue))
    }
}

extension DashBoardViewController: DashboardItemCardListDelegate {
    func dashboardItemCardList(_ dashboardItemDetailList: DashboardItemCardList, openOverDue card: CardView) {
        self.performSegue(withIdentifier: Segues.toMainCategoryToDoListView, sender: (card.overDueData, ToDoMainCategory.overdue))
    }
    
    func dashboardItemCardList(_ dashboardItemDetailList: DashboardItemCardList, expandCard card: CardView) {
        switch card.dashboardCard.dashBoardTitle {
        case .event:
            self.performSegue(withIdentifier: Segues.toListDetail, sender: (self.dashboardItems, 0))
        case .toDo:
            self.performSegue(withIdentifier: Segues.toListDetail, sender: (self.dashboardItems, 1))
        case .purchase:
            self.performSegue(withIdentifier: Segues.toListDetail, sender: (self.dashboardItems, 4))
        case .giftCard:
            self.performSegue(withIdentifier: Segues.toListDetail, sender: (self.dashboardItems, 3))
        case .shopping:
             self.performSegue(withIdentifier: Segues.toListDetail, sender: (self.dashboardItems, 2))
        case .none:
            break
        }
    }
    
    func dashboardItemCardList(_ dashboardItemDetailList: DashboardItemCardList, selectedItem: Any) {
        if let dashboardEventItem = selectedItem as? DashboardEventItem {
            self.performSegue(withIdentifier: Segues.toShowEvent, sender: dashboardEventItem)
        }
        else if let toDoItem = selectedItem as? DashboardToDoItem, let planItToDo = toDoItem.todoData as? PlanItTodo {
            self.performSegue(withIdentifier: Segues.segueToDoDetail, sender: (planItToDo, toDoItem.actualDate))
        }
        else if let dashboardPurchaseItem = selectedItem as? DashboardPurchaseItem {
            self.performSegue(withIdentifier: Segues.toPurchaseDetails, sender: dashboardPurchaseItem)
        }
        else if let dashboardGiftItem = selectedItem as? DashboardGiftItem {
            self.performSegue(withIdentifier: Segues.toGiftCouponDetails, sender: dashboardGiftItem)
        }
        else if let dashboardShopListItem = selectedItem as? DashboardShopListItem {
            self.performSegue(withIdentifier: Segues.shoppingListItemDetail, sender: dashboardShopListItem)
        }
    }
}

extension DashBoardViewController: CustomDashboardSelectionViewDelegate {
    
    func customDashboardSelectionView(_ view: CustomDashboardSelectionView, withSelectedOption option: CustomDashboard) {
        self.activeDashBoardSection = option.type
        self.manageAllUserTileTabData()
    }
}

extension DashBoardViewController: CustomDashBoardViewControllerDelegate {
    
    func customDashBoardViewControllerDelegate(_ customDashBoardViewController: CustomDashBoardViewController, deleteCustomDashboard: PlanItDashboard?) {
        if self.customDashboard == deleteCustomDashboard {
            self.customDashboard = nil
            self.showDefaultDashboardBasicDetails()
            self.manageAllUserTileTabData()
        }
        self.availableDashboardProfiles.removeAll { (dashboardProfile) -> Bool in
            dashboardProfile.planItDashboard == deleteCustomDashboard
        }
    }
    
    func customDashBoardViewControllerDelegate(_ customDashBoardViewController: CustomDashBoardViewController, selectedCustomDashboard: PlanItDashboard?) {
        self.customDashboard = selectedCustomDashboard
        self.showDefaultDashboardBasicDetails()
        self.manageAllUserTileTabData()
    }
    
    func customDashBoardViewControllerDelegate(_ customDashBoardViewController: CustomDashBoardViewController, updateCustomDashboard: PlanItDashboard?) {
        if self.customDashboard == updateCustomDashboard {
            self.showDefaultDashboardBasicDetails()
            self.manageAllUserTileTabData()
        }
    }
    
    func customDashBoardViewControllerDelegate(_ customDashBoardViewController: CustomDashBoardViewController, createCustomDashboard: PlanItDashboard?) {
        guard let planItDashBoard = createCustomDashboard else { return }
        self.addCustomDashboard(planItDashBoard: planItDashBoard)
    }
}

extension DashBoardViewController: CustomDashBoardListViewControllerDelegate {
    
    func customDashBoardListViewController(_ customDashBoardListViewController: CustomDashBoardListViewController, update profile: CustomDashboardProfile) {
        if self.customDashboard == profile.planItDashboard {
            self.showDefaultDashboardBasicDetails()
            self.manageAllUserTileTabData()
        }
    }
    
    func customDashBoardListViewController(_ customDashBoardListViewController: CustomDashBoardListViewController, onCreate dashBoard: CustomDashboardProfile) {
        guard let planItDashBoard = dashBoard.planItDashboard  else { return }
        self.addCustomDashboard(planItDashBoard: planItDashBoard)
    }
    
    func customDashBoardListViewController(_ customDashBoardListViewController: CustomDashBoardListViewController, onSelect dashBoard: CustomDashboardProfile?) {
        self.customDashboard = dashBoard?.planItDashboard
        self.showDefaultDashboardBasicDetails()
        self.manageAllUserTileTabData()
    }
    
    func customDashBoardListViewController(_ customDashBoardListViewController: CustomDashBoardListViewController, deleted dashBoard: CustomDashboardProfile) {
        if self.customDashboard == dashBoard.planItDashboard {
            self.customDashboard = nil
            self.showDefaultDashboardBasicDetails()
            self.manageAllUserTileTabData()
        }
        self.availableDashboardProfiles.removeAll { (profile) -> Bool in
            profile.planItDashboard == dashBoard.planItDashboard
        }
    }
}

extension DashBoardViewController: CreateDashboardViewControllerDelegate {
    
    func createDashboardViewController(_ createDashboardViewController: CreateDashboardViewController, updatedDashBord: Dashboard) {
        guard let planItDashBoard = updatedDashBord.planItDashBoard  else { return }
        self.addCustomDashboard(planItDashBoard: planItDashBoard)
    }
}

extension DashBoardViewController: DashboardDropDownViewControllerDelegate {
    
    func dashboardDropDownViewController(_ controller: DashboardDropDownViewController, selectedOption: DropDownOptionType) {
        switch selectedOption {
        case .eSwitchDashBoard:
            self.performSegue(withIdentifier: Segues.goToCustomDashboard, sender: self)
        case .eNewDashBoard:
            self.performSegue(withIdentifier: Segues.createDashboard, sender: self)
        default: break
        }
    }
}


extension DashBoardViewController: SelectedDashboardHelpScreenDelegate {
    
    func selectedDashboardHelpScreenOnClose(_ selectedDashboardHelpScreen: SelectedDashboardHelpScreen) {
        self.createWebServiceToCheckInApp()
    }
}

extension DashBoardViewController: TabViewControllerDelegate {
    
    func tabViewController(_ tabViewController: TabViewController, updateHeightWithAd: Bool) {
        self.constraintTabHeight?.constant = updateHeightWithAd ? 147 : 77
    }
}
