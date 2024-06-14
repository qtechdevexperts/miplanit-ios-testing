//
//  BaseViewController.swift
//  MiPlanIt
//
//  Created by Arun on 30/09/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

class BaseViewController: SwipeDrawerViewController {
    
    var requestedUsersData = false
    var isViewDidLoaded = false
    var requestedUsersShareLinkData = false
    var requestedUsersTodoData = false
    var requestedUsersGiftData = false
    var requestedUsersCalendarData = false
    var requestedUsersShoppingData = false
    var requestedUsersPurchaseData = false


    override func viewDidLoad() {
        super.viewDidLoad()
        self.isViewDidLoaded = true
        // Do any additional setup after loading the view.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if self.isBeingRemoved() {
            self.denyUserTodoDataNotification()
            self.denyUserGiftDataNotification()
            self.denyUserShoppingDataNotification()
            self.denyUserCalendarDataNotification()
            self.denyUserPurchaseDataNotification()
        }
        super.viewWillDisappear(animated)
    }
    
    //MARK: - Calendar
    private func requestUserCalendarDataNotification() {
        self.requestedUsersCalendarData = true
        NotificationCenter.default.addObserver(self, selector: #selector(usersCalendarUpdatedWithInformation), name: NSNotification.Name(rawValue: Notifications.calendarUsersDataUpdated), object: nil)
    }
    
    private func denyUserCalendarDataNotification() {
        self.requestedUsersCalendarData = false
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Notifications.calendarUsersDataUpdated), object: nil)
    }
    
    func requestUserCalendarDataIfNeeded() -> PlanItUser? {
        guard let user = Session.shared.readUser(), !Session.shared.readUsersCalendarDataFetching() else {
        self.requestUserCalendarDataNotification(); return nil }
        self.denyUserCalendarDataNotification()
        return user
    }
    //MARK: - ShareLink
    private func requestUserShareLinkDataNotification() {
        self.requestedUsersShareLinkData = true
        NotificationCenter.default.addObserver(self, selector: #selector(usersCalendarUpdatedWithInformation), name: NSNotification.Name(rawValue: Notifications.shareLinkUsersDataUpdated), object: nil)
    }
    
    private func denyUserShareLinkDataNotification() {
        self.requestedUsersShareLinkData = false
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Notifications.shareLinkUsersDataUpdated), object: nil)
    }
    
    func requestUserShareLinkDataIfNeeded() -> PlanItUser? {
        guard let user = Session.shared.readUser(), !Session.shared.readUsersShareLinkDataFetching() else {
        self.requestUserShareLinkDataNotification(); return nil }
        self.denyUserShareLinkDataNotification()
        return user
    }
    
    //MARK: - Todo
    private func requestUserTodoDataNotification() {
        self.requestedUsersTodoData = true
        NotificationCenter.default.addObserver(self, selector: #selector(usersCalendarUpdatedWithInformation), name: NSNotification.Name(rawValue: Notifications.todoUsersDataUpdated), object: nil)
    }
    
    private func denyUserTodoDataNotification() {
        self.requestedUsersTodoData = false
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Notifications.todoUsersDataUpdated), object: nil)
    }
    
    func requestUserTodoDataIfNeeded() -> PlanItUser? {
        guard let user = Session.shared.readUser(), !Session.shared.readUsersTodoDataFetching() else {
        self.requestUserTodoDataNotification(); return nil }
        self.denyUserTodoDataNotification()
        return user
    }
    //MARK: - Shopping
    private func requestUserShoppingDataNotification() {
        self.requestedUsersShoppingData = true
        NotificationCenter.default.addObserver(self, selector: #selector(usersCalendarUpdatedWithInformation), name: NSNotification.Name(rawValue: Notifications.shoppingUsersDataUpdated), object: nil)
    }
    
    private func denyUserShoppingDataNotification() {
        self.requestedUsersShoppingData = false
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Notifications.shoppingUsersDataUpdated), object: nil)
    }
    
    func requestUserShoppingDataIfNeeded() -> PlanItUser? {
        guard let user = Session.shared.readUser(), !Session.shared.readUsersShoppingDataFetching() else {
        self.requestUserShoppingDataNotification(); return nil }
        self.denyUserShoppingDataNotification()
        return user
    }
    //MARK: - Purchase
    private func requestUserPurchaseDataNotification() {
        self.requestedUsersPurchaseData = true
        NotificationCenter.default.addObserver(self, selector: #selector(usersCalendarUpdatedWithInformation), name: NSNotification.Name(rawValue: Notifications.purchaseUsersDataUpdated), object: nil)
    }
    
    private func denyUserPurchaseDataNotification() {
        self.requestedUsersPurchaseData = false
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Notifications.purchaseUsersDataUpdated), object: nil)
    }
    
    func requestUserPurchaseDataIfNeeded() -> PlanItUser? {
        guard let user = Session.shared.readUser(), !Session.shared.readUsersPurchaseDataFetching() else {
        self.requestUserPurchaseDataNotification(); return nil }
        self.denyUserPurchaseDataNotification()
        return user
    }
    //MARK: - Gift
    private func requestUserGiftDataNotification() {
        self.requestedUsersGiftData = true
        NotificationCenter.default.addObserver(self, selector: #selector(usersCalendarUpdatedWithInformation), name: NSNotification.Name(rawValue: Notifications.giftUsersDataUpdated), object: nil)
    }
    
    private func denyUserGiftDataNotification() {
        self.requestedUsersGiftData = false
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Notifications.giftUsersDataUpdated), object: nil)
    }
    
    func requestUserGiftDataIfNeeded() -> PlanItUser? {
        guard let user = Session.shared.readUser(), !Session.shared.readUsersGiftDataFetching() else {
        self.requestUserGiftDataNotification(); return nil }
        self.denyUserGiftDataNotification()
        return user
    }
    
    func refreshScreensWithUsersDataResult(_ result: [ServiceDetection]) {
        switch self {
        case is MyCalanderBaseViewController where result.isContainedSpecificServiceData(.calendar) && !self.requestedUsersCalendarData:
            let notify = Notification(name: NSNotification.Name(rawValue: Notifications.calendarUsersDataUpdated), object: result, userInfo: nil)
            self.usersCalendarUpdatedWithInformation(notify)
        case is TodoBaseViewController where result.isContainedSpecificServiceData(.todo) && !self.requestedUsersTodoData:
            let notify = Notification(name: NSNotification.Name(rawValue: Notifications.calendarUsersDataUpdated), object: result, userInfo: nil)
            self.usersCalendarUpdatedWithInformation(notify)
        case is PurchaseViewController where result.isContainedSpecificServiceData(.purchase) && !self.requestedUsersPurchaseData:
            let notify = Notification(name: NSNotification.Name(rawValue: Notifications.calendarUsersDataUpdated), object: result, userInfo: nil)
            self.usersCalendarUpdatedWithInformation(notify)
        case is GiftCouponsViewController where result.isContainedSpecificServiceData(.gift) && !self.requestedUsersGiftData:
            let notify = Notification(name: NSNotification.Name(rawValue: Notifications.calendarUsersDataUpdated), object: result, userInfo: nil)
            self.usersCalendarUpdatedWithInformation(notify)
        case is ShoppingListViewController where result.isContainedSpecificServiceData(.shop) && !self.requestedUsersShoppingData:
            let notify = Notification(name: NSNotification.Name(rawValue: Notifications.calendarUsersDataUpdated), object: result, userInfo: nil)
            self.usersCalendarUpdatedWithInformation(notify)
        case is DashboardBaseViewController where ((result.isContainedSpecificServiceData(.calendar) && !self.requestedUsersCalendarData) || (result.isContainedSpecificServiceData(.todo) && !self.requestedUsersTodoData) || (result.isContainedSpecificServiceData(.purchase) && !self.requestedUsersPurchaseData) || (result.isContainedSpecificServiceData(.gift) && !self.requestedUsersGiftData) || (result.isContainedSpecificServiceData(.shop) && !self.requestedUsersShoppingData)):
            let notify = Notification(name: NSNotification.Name(rawValue: Notifications.calendarUsersDataUpdated), object: result, userInfo: nil)
            self.usersCalendarUpdatedWithInformation(notify)
        default: break
        }
    }
    
    @objc func usersCalendarUpdatedWithInformation(_ notify: Notification) { }
}
