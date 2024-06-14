//
//  DashboardBaseViewController+Service.swift
//  MiPlanIt
//
//  Created by Arun Aniyappan on 15/12/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

extension DashboardBaseViewController {
    
    func createWebServiceToCheckInApp() {
        guard let user = Session.shared.readUser(), self.isHelpShown() else { return }
        self.startLottieAnimations()
        InAppPurchaseService().verifySubscriptionStatus(user: user) {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: Notifications.updateAdSenceView), object: nil)
            self.saveSubscriptionStatusOfUserAndProceedServiceCall(user)
        }
    }
    
    func saveSubscriptionStatusOfUserAndProceedServiceCall(_ user: PlanItUser) {
        self.createServiceToFetchUsersCalendarData()
    }
    
    func createServiceToFetchUsersCalendarData() {
        guard let user = self.requestUserCalendarDataIfNeeded() else {
            self.createServiceToFetchUsersShareLinkData()
            return }
        CalendarService().fetchUsersCalendarServerData(user, callback: { result, serviceDetection, error in
            if serviceDetection.isContainedSpecificServiceData(.calendar) {
                self.dasboardDidFinishServiceWithType(.event, serviceDetections: serviceDetection)
            }
            self.createServiceToFetchUsersShareLinkData()
        })
    }
    
    func createServiceToFetchUsersShareLinkData() {
        guard let user = self.requestUserShareLinkDataIfNeeded() else {
            self.createServiceToFetchUsersTodoData()
            return }
        CalendarService().fetchUsersShareLinkServerData(user) { (result, serviceDetection, error) in
            self.createServiceToFetchUsersTodoData()
        }
    }
    
    func createServiceToFetchUsersTodoData() {
        guard let user = self.requestUserTodoDataIfNeeded() else {
            self.createServiceToFetchUsersShoppingMasterData()
            return }
        TodoService().fetchUsersToDoServerData(user, callback: { result, serviceDetection, error in
            if serviceDetection.isContainedSpecificServiceData(.todo) {
                self.dasboardDidFinishServiceWithType(.toDo, serviceDetections: serviceDetection)
            }
            self.createServiceToFetchUsersShoppingMasterData()
        })
    }
    
    func createServiceToFetchUsersShoppingMasterData() {
        guard let user = self.requestUserShoppingDataIfNeeded() else {
            self.createServiceToFetchUsersPurchaseData()
            return }
        ShopService().getShopMasterItem(user, callback: { result, serviceDetection, error in
            self.createServiceToFetchUsersShoppingUserData(user, serviceDetection)
        })
    }
    
    func createServiceToFetchUsersShoppingUserData(_ user: PlanItUser, _ masterDataServiceDetection: [ServiceDetection]) {
        ShopService().getUserShopItem(user, callback: { result, serviceDetection, error in
            self.createServiceToFetchUsersShoppingData(user, serviceDetection+masterDataServiceDetection)
        })
    }
    
    func createServiceToFetchUsersShoppingData(_ user: PlanItUser, _ userDataServiceDetection: [ServiceDetection]) {
        ShopService().fetchUsersShoppingServerData(user, callback: { result, serviceDetection, error in
            if serviceDetection.isContainedSpecificServiceData(.shop) {
                self.dasboardDidFinishServiceWithType(.shopping, serviceDetections: serviceDetection+userDataServiceDetection)
            }
            self.createServiceToFetchUsersPurchaseData()
        })
    }
    
    func createServiceToFetchUsersPurchaseData() {
        guard let user = self.requestUserPurchaseDataIfNeeded() else {
            self.createServiceToFetchUsersGiftData()
            return }
        PurchaseService().fetchUsersPurchaseServerData(user, callback: { result, serviceDetection, error in
            if serviceDetection.isContainedSpecificServiceData(.purchase) {
                self.dasboardDidFinishServiceWithType(.purchase, serviceDetections: serviceDetection)
            }
            self.createServiceToFetchUsersGiftData()
        })
    }
    
    func createServiceToFetchUsersGiftData() {
        guard let user = self.requestUserGiftDataIfNeeded() else {
            self.stopLottieAnimations()
            self.dashboardDidFinishServiceFetch()
            return }
        GiftCouponService().fetchUsersGiftServerData(user, callback: { result, serviceDetection, error in
            if serviceDetection.isContainedSpecificServiceData(.gift) {
                self.dasboardDidFinishServiceWithType(.giftCard, serviceDetections: serviceDetection)
            }
            self.stopLottieAnimations()
            self.dashboardDidFinishServiceFetch()
        })
    }
    
    func createServiceToDoPullToRefresh(completion: @escaping ([ServiceDetection]) -> ()) {
        guard let user = self.requestUserTodoDataIfNeeded() else { completion([]); return }
        TodoService().fetchUsersToDoServerData(user, callback: { result, serviceDetection, error in
            if serviceDetection.isContainedSpecificServiceData(.todo) {
                self.dasboardDidFinishServiceWithType(.toDo, serviceDetections: serviceDetection)
            }
            completion(serviceDetection)
        })
    }
}
