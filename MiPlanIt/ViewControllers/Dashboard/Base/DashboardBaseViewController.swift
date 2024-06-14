//
//  DashboardBaseViewController.swift
//  MiPlanIt
//
//  Created by Arun Aniyappan on 15/12/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

class DashboardBaseViewController: BaseViewController {
    
    var startDateOfMonth: Date = Date().initialHour()
    var endDateOfMonth: Date = Date().initialHour().addMonth(n: 1).adding(seconds: -1)
    
    var dashboardEvents: [Date: [DashboardEventItem]] = [:]
    var dashboardTodos: [Date: [DashboardToDoItem]] = [:]
    var dashboardGifts: [Date: [DashboardGiftItem]] = [:]
    var dashboardShopings: [Date: [DashboardShopListItem]] = [:]
    var dashboardPurchases: [Date: [DashboardPurchaseItem]] = [:]
    var currentSearchEventIndex: Int = 0
    var currentSearchToDoIndex: Int = 0
    var currentSearchGiftIndex: Int = 0
    var currentSearchPurchaseIndex: Int = 0
    var currentSearchShoppingIndex: Int = 0
    var filterDateUpdatedEvent: Bool = false
    var filterDateUpdatedToDo: Bool = false
    var filterDateUpdatedGift: Bool = false
    var filterDateUpdatedPurchase: Bool = false
    var filterDateUpdatedShopping: Bool = false
    
    var visibleEvents: [DashboardEventItem] = [] {
        didSet {
            self.dasboardFindDataForCustomDashboard(.event)
            self.totalItemsCount = self.visibleEvents.count + self.visibleTodos.count + self.visibleShopings.count + self.visibleGifts.count + self.visiblePurchases.count
        }
    }
    
    var visibleTodos: [DashboardToDoItem] = [] {
        didSet {
            self.dasboardFindDataForCustomDashboard(.toDo)
            self.totalItemsCount = self.visibleEvents.count + self.visibleTodos.count + self.visibleShopings.count + self.visibleGifts.count + self.visiblePurchases.count
        }
    }
    
    var visibleShopings: [DashboardShopListItem] = [] {
        didSet {
            self.dasboardFindDataForCustomDashboard(.shopping)
            self.totalItemsCount = self.visibleEvents.count + self.visibleTodos.count + self.visibleShopings.count + self.visibleGifts.count + self.visiblePurchases.count
        }
    }
    
    var visibleGifts: [DashboardGiftItem] = [] {
        didSet {
            self.dasboardFindDataForCustomDashboard(.giftCard)
            self.totalItemsCount = self.visibleEvents.count + self.visibleTodos.count + self.visibleShopings.count + self.visibleGifts.count + self.visiblePurchases.count
        }
    }
    
    var visiblePurchases: [DashboardPurchaseItem] = [] {
        didSet {
            self.dasboardFindDataForCustomDashboard(.purchase)
            self.totalItemsCount = self.visibleEvents.count + self.visibleTodos.count + self.visibleShopings.count + self.visibleGifts.count + self.visiblePurchases.count
        }
    }
    
    var totalItemsCount: Int = 0 {
        didSet {
            self.dashboardTotalItems(self.totalItemsCount)
        }
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.addDataUpdateNotifications()
        self.readAllDashboardUsersData()
        self.createWebServiceToCheckInApp()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.checkPushNotificationPayload()
        self.createServiceToFetchUsersCalendarData()
        super.viewWillAppear(animated)
    }

    override func viewDidDisappear(_ animated: Bool) {
        if self.isBeingRemoved() {
            self.removeDataUpdateNotifications()
        }
        super.viewDidDisappear(animated)
    }
    
    //Mark: - Base
    func isHelpShown() -> Bool { return true }
    
    func startLottieAnimations() { }
    
    func stopLottieAnimations() { }
    
    func dashboardDidFinishServiceFetch() {
        //service finished
    }
    
    func dashboardTotalItems(_ items: Int) { }
    
    func dashboardHaveExistingData(_ type: DashBoardTitle) {
        self.refreshNextDataWith(type)
    }
    
    func dashboardWillStartDataManipulation(_ type: DashBoardTitle) {}
    
    func dashboardDidEndDataManipulation(_ type: DashBoardTitle) {}
    
    func dashboardDidFinishDataManipulation(_ type: DashBoardTitle) {
        DispatchQueue.main.async { self.refreshNextDataWith(type) }
    }
    
    func dasboardFindDataForCustomDashboard(_ type: DashBoardTitle) {}
    //Mark: --------
    
    override func usersCalendarUpdatedWithInformation(_ notify: Notification) {
        guard let serviceDetections = notify.object as? [ServiceDetection] else { return }
        if serviceDetections.isContainedSpecificServiceData(.calendar) {
            self.detectEventUpdate()
        }
        if serviceDetections.isContainedSpecificServiceData(.todo) {
            self.detectTodoUpdate()
        }
        if serviceDetections.isContainedSpecificServiceData(.shop) {
            self.detectShopingUpdate()
        }
        if serviceDetections.isContainedSpecificServiceData(.purchase) {
            self.detectPurchaseUpdate()
        }
        if serviceDetections.isContainedSpecificServiceData(.gift) {
            self.detectGiftCardUpdate()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.destination {
        case is ViewEventViewController:
            let viewEventViewController = segue.destination as! ViewEventViewController
            viewEventViewController.delegate = self
            if let dateEvent = sender as? DashboardEventItem {
                viewEventViewController.eventPlanOtherObject = dateEvent.planItEvent
                viewEventViewController.dateEvent = DateSpecificEvent(with: dateEvent)
            }
        case is TodoDetailViewController:
            let todoDetailViewController = segue.destination as! TodoDetailViewController
            todoDetailViewController.delegate = self
            if let todo = sender as? (PlanItTodo, Date?) {
                todoDetailViewController.categoryType = .all
                todoDetailViewController.dashboardDueDate = todo.1
                todoDetailViewController.mainToDoItem = todo.0
            }
        case is ShoppingItemDetailViewController:
            let shoppingItemDetailViewController = segue.destination as! ShoppingItemDetailViewController
            shoppingItemDetailViewController.delegate = self
            if let dashboardShopListItem = sender as? DashboardShopListItem, let planItShopListItems = dashboardShopListItem.planItShopListItems, let planItShopItem = dashboardShopListItem.planItShopItem {
                shoppingItemDetailViewController.shopItemDetailModel = ShopListItemDetailModel(shopListItem: planItShopListItems, shopItem: planItShopItem)
            }
        case is PurchaseDetailViewController:
            let purchaseDetailViewController = segue .destination as! PurchaseDetailViewController
            purchaseDetailViewController.delegate = self
            if let dashboardPurchaseItem = sender as? DashboardPurchaseItem {
                purchaseDetailViewController.planitPurchase = dashboardPurchaseItem.planItPurchase
            }
        case is GiftCouponDetailViewController:
            let giftCouponDetailViewController = segue.destination as! GiftCouponDetailViewController
            giftCouponDetailViewController.delegate = self
            if let dashboardGiftItem = sender as? DashboardGiftItem {
                giftCouponDetailViewController.planItGiftCoupon = dashboardGiftItem.planItGiftCoupon
            }
        case is MainCategoryToDoViewController:
            let mainCategoryToDoViewController = segue.destination as! MainCategoryToDoViewController
            mainCategoryToDoViewController.delegate = self
            if let info = sender as? ([PlanItTodo], ToDoMainCategory) {
                mainCategoryToDoViewController.categoryType = info.1
                mainCategoryToDoViewController.categorisedTodos = info.0
            }
        case is PricingViewController:
            let pricingViewController = segue.destination as! PricingViewController
            pricingViewController.delegate = self
            pricingViewController.isAlreadySubscribed = sender as? Bool ?? false
        default: break
        }
    }
}
