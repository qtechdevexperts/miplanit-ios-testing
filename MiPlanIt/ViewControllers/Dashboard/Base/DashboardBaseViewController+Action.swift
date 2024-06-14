//
//  DashboardBaseViewController+Action.swift
//  MiPlanIt
//
//  Created by Arun Aniyappan on 15/12/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

extension DashboardBaseViewController {
    
    
    func readAllDashboardUsersData(_ forceRefresh: Bool = false) {
        if self.dashboardEvents.isEmpty || forceRefresh {
            self.detectEventUpdate()
        }
        else {
            self.dashboardHaveExistingData(.event)
        }
        if self.dashboardTodos.isEmpty || forceRefresh {
            self.detectTodoUpdate()
        }
        else {
            self.dashboardHaveExistingData(.toDo)
        }
        if self.dashboardShopings.isEmpty || forceRefresh {
            self.detectShopingUpdate()
        }
        else {
            self.dashboardHaveExistingData(.shopping)
        }
        if self.dashboardGifts.isEmpty || forceRefresh {
            self.detectGiftCardUpdate()
        }
        else {
            self.dashboardHaveExistingData(.giftCard)
        }
        if self.dashboardPurchases.isEmpty || forceRefresh {
            self.detectPurchaseUpdate()
        }
        else {
            self.dashboardHaveExistingData(.purchase)
        }
    }
    
    func refreshNextDataWith(_ type: DashBoardTitle) {
        switch type {
        case .event:
            self.checkAndCallNextIndexEventUpdate()
        case .toDo:
            self.checkAndCallNextIndexToDoUpdate()
        case .purchase:
            self.checkAndCallNextIndexPurchaseUpdate()
        case .giftCard:
            self.checkAndCallNextIndexGiftUpdate()
        case .shopping:
            self.checkAndCallNextIndexShoppingUpdate()
        }
    }
    
    func checkPushNotificationPayload() {
        if let jsonObject = Session.shared.pushNotificationPayload as? NSDictionary, let notificationTo = jsonObject["notificationTo"] as? [String: Any], let reciever = notificationTo["userId"] as? Double, let user = Session.shared.readUser(), reciever.cleanValue() == user.readValueOfUserId() {
            if let count = jsonObject["count"] as? Double { user.saveNotificationCount(count) }
            if let jsonDict =  jsonObject as? [String : Any] {
                Session.shared.notificationRedirectToSpecificController(jsonDict)
            }
        }
        else if let jsonObject = Session.shared.pushNotificationPayload as? [String : AnyObject] {
            Session.shared.localNotificationRedirectToSpecificController(jsonObject)
        }
        else { Session.shared.resetPayload() }
    }
    
    func readServerDataFetchStatus() -> Bool {
        guard let settings = Session.shared.readUser()?.readUserSettings() else { return false }        
        return settings.readLastCalendarFetchDataTime().isEmpty || settings.readLastTodoFetchDataTime().isEmpty || settings.readLastFetchShopDataTime().isEmpty || settings.readLastFetchUserShopDataTime().isEmpty || settings.readLastPurchaseFetchDataTime().isEmpty || settings.readLastGiftFetchDataTime().isEmpty
    }
    
    func addDataUpdateNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(detectEventUpdate), name: NSNotification.Name(rawValue: Notifications.dashboardEventUpdate), object: nil )
        NotificationCenter.default.addObserver(self, selector: #selector(detectTodoUpdate), name: NSNotification.Name(rawValue: Notifications.dashboardToDoUpdate), object: nil )
        NotificationCenter.default.addObserver(self, selector: #selector(detectShopingUpdate), name: NSNotification.Name(rawValue: Notifications.dashboardShoppingUpdate), object: nil )
        NotificationCenter.default.addObserver(self, selector: #selector(detectPurchaseUpdate), name: NSNotification.Name(rawValue: Notifications.dashboardPurchaseUpdate), object: nil )
        NotificationCenter.default.addObserver(self, selector: #selector(detectGiftCardUpdate), name: NSNotification.Name(rawValue: Notifications.dashboardGiftUpdate), object: nil )
    }
    
    func removeDataUpdateNotifications() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Notifications.dashboardEventUpdate), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Notifications.dashboardToDoUpdate), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Notifications.dashboardShoppingUpdate), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Notifications.dashboardPurchaseUpdate), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Notifications.dashboardGiftUpdate), object: nil)
    }
    
    @objc func detectEventUpdate() {
        self.currentSearchEventIndex = 0
        self.filterDateUpdatedEvent = true
        self.dashboardEvents.removeAll()
        self.readAllDashboardEventsFromDB()
    }
    
    @objc func detectTodoUpdate() {
        self.currentSearchToDoIndex = 0
        self.filterDateUpdatedToDo = true
        self.dashboardTodos.removeAll()
        self.readAllDashboardTodosFromDB()
        
    }
    
    @objc func detectShopingUpdate() {
        self.currentSearchShoppingIndex = 0
        self.filterDateUpdatedShopping = true
        self.dashboardShopings.removeAll()
        self.readAllDashboardShoppingsFromDB()
    }
    
    @objc func detectPurchaseUpdate() {
        self.currentSearchPurchaseIndex = 0
        self.filterDateUpdatedPurchase = true
        self.dashboardPurchases.removeAll()
        self.readAllDashboardPurchasesFromDB()
    }
    
    @objc func detectGiftCardUpdate() {
         self.currentSearchGiftIndex = 0
        self.filterDateUpdatedGift = true
        self.dashboardGifts.removeAll()
        self.readAllDashboardGiftCardsFromDB()
    }
    
    func resetAllMasterSearchData() {
        self.dashboardEvents.removeAll()
        self.dashboardTodos.removeAll()
        self.dashboardShopings.removeAll()
        self.dashboardGifts.removeAll()
        self.dashboardPurchases.removeAll()
    }
    
    func updateDateBy(startDate: Date, endDate: Date) {
        self.resetAllMasterSearchData()
        self.startDateOfMonth = startDate
        self.endDateOfMonth = endDate
        self.readAllDashboardUsersData(true)
    }
    
    func checkAndCallNextIndexEventUpdate() {
        if !self.isReachedMaximumEventLimit() {
            self.currentSearchEventIndex += 1
            let startOfMonth = self.startDateOfMonth.addMonth(n: self.currentSearchEventIndex)
            self.readAllDashboardEventsFromDB(startOfMonth: startOfMonth)
        }
        else {
            self.dashboardDidEndDataManipulation(.event)
        }
    }
    
    func isReachedEventLimitUserType(_ type: DashBoardSection) -> Bool {
        return type == .all ? self.isReachedMaximumEventLimit() : self.isReachedMinimumEventLimit()
    }
    
    func isReachedMaximumEventLimit() -> Bool {
        return self.startDateOfMonth.addMonth(n: self.currentSearchEventIndex + 1) >= self.endDateOfMonth
    }
    
    func isReachedMinimumEventLimit() -> Bool {
        return self.currentSearchEventIndex > 1
    }
    
    func readAllDashboardEventsFromDB(startOfMonth: Date? = nil) {
        self.dashboardWillStartDataManipulation(.event)
        let eventStartOfMonth = startOfMonth ?? self.startDateOfMonth
        var eventEndOfMonth = eventStartOfMonth.addMonth(n: 1).adding(seconds: -1)
        eventEndOfMonth = eventEndOfMonth < self.endDateOfMonth ? eventEndOfMonth : self.endDateOfMonth
        self.manipulateEvents(eventStartOfMonth, to: eventEndOfMonth, result: { [weak self] events in
            guard let self = self else { return }
            if self.filterDateUpdatedEvent && self.currentSearchEventIndex > 0 {
                self.filterDateUpdatedEvent = false; return
            }
            self.filterDateUpdatedEvent = false
            self.dashboardEvents[eventStartOfMonth] = events
            self.dashboardDidFinishDataManipulation(.event)
        })
    }
    
    func manipulateEvents(_ from: Date, to: Date, result: @escaping ([DashboardEventItem]) -> ()) {
        let databasePlanItEvent = DatabasePlanItEvent()
        databasePlanItEvent.readAllEventsUsingQueueFrom(startOfMonth: from, endOfMonth: to, result: { [weak self] allUserEvents in
            guard let self = self else { result([]); return }
            var dateEvents: [DashboardEventItem] = []
            allUserEvents.forEach({ self.manipulateUserEvent($0, start: from, end: to, converter: databasePlanItEvent, to: &dateEvents) })
            result(dateEvents)
        })
    }
    
    func manipulateUserEvent(_ event: PlanItEvent, start: Date, end: Date, converter: DatabasePlanItEvent, to dateEvents: inout [DashboardEventItem]) {
        let availableDates = event.readAllAvailableDates(from: start, to: end)
        availableDates.forEach({ date in
            let modelEvent = DashboardEventItem(with: event, startDate: date, converter: converter)
            if modelEvent.planItEvent != nil { dateEvents.append(modelEvent) }
        })
    }
    
    func checkAndCallNextIndexToDoUpdate() {
        if !self.isReachedMaximumTodoLimit() {
            self.currentSearchToDoIndex += 1
            let startOfMonth = self.startDateOfMonth.addMonth(n: self.currentSearchToDoIndex)
            self.readAllDashboardTodosFromDB(startOfMonth: startOfMonth)
        }
        else {
            self.dashboardDidEndDataManipulation(.toDo)
        }
    }
    
    func isReachedToDoLimitUserType(_ type: DashBoardSection) -> Bool {
        return type == .all ? self.isReachedMaximumTodoLimit() : self.isReachedMinimumTodoLimit()
    }
    
    func isReachedMaximumTodoLimit() -> Bool {
        return self.startDateOfMonth.addMonth(n: self.currentSearchToDoIndex + 1) >= self.endDateOfMonth
    }
    
    func isReachedMinimumTodoLimit() -> Bool {
        return self.currentSearchToDoIndex > 1
    }
    
    func readAllDashboardTodosFromDB(startOfMonth: Date? = nil) {
        self.dashboardWillStartDataManipulation(.toDo)
        let todoStartOfMonth = startOfMonth ?? self.startDateOfMonth
        var todoEndOfMonth = todoStartOfMonth.addMonth(n: 1).adding(seconds: -1)
        todoEndOfMonth = todoEndOfMonth < self.endDateOfMonth ? todoEndOfMonth : self.endDateOfMonth
        self.manipulateTodos(todoStartOfMonth, to: todoEndOfMonth, result: { [weak self] todos in
            guard let self = self else { return }
            if self.filterDateUpdatedToDo && self.currentSearchToDoIndex > 0 { self.filterDateUpdatedToDo = false; return }
            self.filterDateUpdatedToDo = false
            self.dashboardTodos[todoStartOfMonth] = todos
            self.dashboardDidFinishDataManipulation(.toDo)
        })
    }
    
    func manipulateTodos(_ from: Date, to: Date, result: @escaping ([DashboardToDoItem]) -> ()) {
        let databasePlanItTodo = DataBasePlanItTodo()
        databasePlanItTodo.readAllFutureTodosUsingQueue(startOfMonth: from, endOfMonth: to, anyItemsExist: self.itemExistOnType(.todo), result: { [weak self] allUserTodos in
            guard let self = self else { result([]); return }
            var dateTodos: [DashboardToDoItem] = []
            allUserTodos.forEach({ self.manipulateUserTodo($0, start: from, end: to, converter: databasePlanItTodo, to: &dateTodos) })
            result(dateTodos)
        })
    }
    
    func manipulateUserTodo(_ todo: PlanItTodo, start: Date, end: Date, converter: DataBasePlanItTodo, to dateTodos: inout [DashboardToDoItem]) {
        if todo.readExactDueDate() == nil && !todo.readDeleteStatus() && !todo.completed {
            dateTodos.append(DashboardToDoItem(with: todo, converter: converter))
        }
        else if todo.readExactDueDate() != nil && !todo.readDeleteStatus() && !todo.completed {
            let availableDates = todo.readAllAvailableDates(from: start, to: end)
            availableDates.forEach({ date in
                let modelTodo = DashboardToDoItem(with: todo, startDate: date, converter: converter)
                if modelTodo.todoData != nil { dateTodos.append(modelTodo) }
            })
        }
    }
    
    func checkAndCallNextIndexShoppingUpdate() {
        if !self.isReachedMaximumShoppingLimit() {
            self.currentSearchShoppingIndex += 1
            let startOfMonth = self.startDateOfMonth.addMonth(n: self.currentSearchShoppingIndex)
            self.readAllDashboardShoppingsFromDB(startOfMonth: startOfMonth)
        }
        else {
            self.dashboardDidEndDataManipulation(.shopping)
        }
    }
    
    func isReachedShoppingLimitUserType(_ type: DashBoardSection) -> Bool {
        return type == .all ? self.isReachedMaximumShoppingLimit() : self.isReachedMinimumShoppingLimit()
    }
    
    func isReachedMaximumShoppingLimit() -> Bool {
        return self.startDateOfMonth.addMonth(n: self.currentSearchShoppingIndex + 1) >= self.endDateOfMonth
    }
    
    func isReachedMinimumShoppingLimit() -> Bool {
        return self.currentSearchShoppingIndex > 1
    }
    
    func readAllDashboardShoppingsFromDB(startOfMonth: Date? = nil) {
        self.dashboardWillStartDataManipulation(.shopping)
        let shoppingStartOfMonth = startOfMonth ?? self.startDateOfMonth
        var shoppingEndOfMonth = shoppingStartOfMonth.addMonth(n: 1).adding(seconds: -1)
        shoppingEndOfMonth = shoppingEndOfMonth < self.endDateOfMonth ? shoppingEndOfMonth : self.endDateOfMonth
        self.manipulateShopings(shoppingStartOfMonth, to: shoppingEndOfMonth, result: { [weak self] shopings in
            guard let self = self else { return }
            if self.filterDateUpdatedShopping && self.currentSearchShoppingIndex > 0 { self.filterDateUpdatedShopping = false; return }
            self.filterDateUpdatedShopping = false
            self.dashboardShopings[shoppingStartOfMonth] = shopings
            self.dashboardDidFinishDataManipulation(.shopping)
        })
    }
    
    func manipulateShopings(_ from: Date, to: Date, result: @escaping ([DashboardShopListItem]) -> ()) {
        let databasePlanItShopListItem = DatabasePlanItShopListItem()
        databasePlanItShopListItem.readAllFutureShopListItemsUsingQueue(startOfMonth: from, endOfMonth: to, anyItemsExist: self.itemExistOnType(.shopping), result: { [weak self] allUserShopings in
            guard let self = self else { result([]); return }
            var dateShopings: [DashboardShopListItem] = []
            allUserShopings.forEach({ self.manipulateUserShoping($0, start: from, end: to, converter: databasePlanItShopListItem, to: &dateShopings) })
            result(dateShopings)
        })
    }
    
    func manipulateUserShoping(_ shoping: PlanItShopListItems, start: Date, end: Date, converter: DatabasePlanItShopListItem, to dateShopings: inout [DashboardShopListItem]) {
        let modelShoping = DashboardShopListItem(shoping, converter: converter)
        if modelShoping.planItShopListItems != nil { dateShopings.append(modelShoping) }
    }
    
    func checkAndCallNextIndexGiftUpdate() {
        if !self.isReachedMaximumGiftLimit() {
            self.currentSearchGiftIndex += 1
            let startOfMonth = self.startDateOfMonth.addMonth(n: self.currentSearchGiftIndex)
            self.readAllDashboardGiftCardsFromDB(startOfMonth: startOfMonth)
        }
        else {
            self.dashboardDidEndDataManipulation(.giftCard)
        }
    }
    
    func isReachedGiftUserType(_ type: DashBoardSection) -> Bool {
        return type == .all ? self.isReachedMaximumGiftLimit() : self.isReachedMinimumGiftLimit()
    }
    
    func isReachedMaximumGiftLimit() -> Bool {
        return self.startDateOfMonth.addMonth(n: self.currentSearchGiftIndex + 1) >= self.endDateOfMonth
    }
    
    func isReachedMinimumGiftLimit() -> Bool {
        return self.currentSearchGiftIndex > 1
    }
    
    func readAllDashboardGiftCardsFromDB(startOfMonth: Date? = nil) {
        self.dashboardWillStartDataManipulation(.giftCard)
        let giftStartOfMonth = startOfMonth ?? self.startDateOfMonth
        var giftEndOfMonth = giftStartOfMonth.addMonth(n: 1).adding(seconds: -1)
        giftEndOfMonth = giftEndOfMonth < self.endDateOfMonth ? giftEndOfMonth : self.endDateOfMonth
        self.manipulateGiftCards(giftStartOfMonth, to: giftEndOfMonth, result: { [weak self] giftCards in
            guard let self = self else { return }
            if self.filterDateUpdatedGift && self.currentSearchGiftIndex > 0 { self.filterDateUpdatedGift = false; return }
            self.filterDateUpdatedGift = false
            self.dashboardGifts[giftStartOfMonth] = giftCards
            self.dashboardDidFinishDataManipulation(.giftCard)
        })
    }
    
    func manipulateGiftCards(_ from: Date, to: Date, result: @escaping ([DashboardGiftItem]) -> ()) {
        let databasePlanItGiftCoupon = DatabasePlanItGiftCoupon()
        databasePlanItGiftCoupon.readAllFutureGiftCouponsListUsingQueue(startOfMonth: from, endOfMonth: to, anyItemsExist: self.itemExistOnType(.gift), result: { [weak self] allUserGiftCoupons in
            guard let self = self else { result([]); return }
            var dateGiftCoupons: [DashboardGiftItem] = []
            allUserGiftCoupons.forEach({ self.manipulateUserGiftCoupon($0, start: from, end: to, converter: databasePlanItGiftCoupon, to: &dateGiftCoupons) })
            result(dateGiftCoupons)
        })
    }
    
    func manipulateUserGiftCoupon(_ giftCoupon: PlanItGiftCoupon, start: Date, end: Date, converter: DatabasePlanItGiftCoupon, to dateGiftCoupons: inout [DashboardGiftItem]) {
        let modelGiftCoupon = DashboardGiftItem(giftCoupon, converter: converter)
        if modelGiftCoupon.planItGiftCoupon != nil { dateGiftCoupons.append(modelGiftCoupon) }
    }
    
    func checkAndCallNextIndexPurchaseUpdate() {
        if !self.isReachedMaximumPurchaseLimit() {
            self.currentSearchPurchaseIndex += 1
            let startOfMonth = self.startDateOfMonth.addMonth(n: self.currentSearchPurchaseIndex)
            self.readAllDashboardPurchasesFromDB(startOfMonth: startOfMonth)
        }
        else {
            self.dashboardDidEndDataManipulation(.purchase)
        }
    }
    
    func isReachedPurchaseUserType(_ type: DashBoardSection) -> Bool {
        return type == .all ? self.isReachedMaximumPurchaseLimit() : self.isReachedMinimumPurchaseLimit()
    }
    
    func isReachedMaximumPurchaseLimit() -> Bool {
        return self.startDateOfMonth.addMonth(n: self.currentSearchPurchaseIndex + 1) >= self.endDateOfMonth
    }
    
    func isReachedMinimumPurchaseLimit() -> Bool {
        return self.currentSearchPurchaseIndex > 1
    }
    
    func readAllDashboardPurchasesFromDB(startOfMonth: Date? = nil) {
        self.dashboardWillStartDataManipulation(.purchase)
        let purchaseStartOfMonth = startOfMonth ?? self.startDateOfMonth
        var purchaseEndOfMonth = purchaseStartOfMonth.addMonth(n: 1).adding(seconds: -1)
        purchaseEndOfMonth = purchaseEndOfMonth < self.endDateOfMonth ? purchaseEndOfMonth : self.endDateOfMonth
        self.manipulatePurchases(purchaseStartOfMonth, to: purchaseEndOfMonth, result: { [weak self] purchases in
            guard let self = self else { return }
            if self.filterDateUpdatedPurchase && self.currentSearchPurchaseIndex > 0 { self.filterDateUpdatedPurchase = false; return }
            self.filterDateUpdatedPurchase = false
             self.dashboardPurchases[purchaseStartOfMonth] = purchases
            self.dashboardDidFinishDataManipulation(.purchase)
        })
    }
    
    func manipulatePurchases(_ from: Date, to: Date, result: @escaping ([DashboardPurchaseItem]) -> ()) {
        let databasePlanItPurchase = DatabasePlanItPurchase()
        databasePlanItPurchase.readAllFuturePurchasListUsingQueue(startOfMonth: from, endOfMonth: to, result: { [weak self] allUserPurchases in
            guard let self = self else { result([]); return }
            var datePurchases: [DashboardPurchaseItem] = []
            allUserPurchases.forEach({ self.manipulateUserPurchase($0, start: from, end: to, converter: databasePlanItPurchase, to: &datePurchases) })
            result(datePurchases)
        })
    }
    
    func manipulateUserPurchase(_ purchase: PlanItPurchase, start: Date, end: Date, converter: DatabasePlanItPurchase, to datePurchases: inout [DashboardPurchaseItem]) {
        let modelPurchase = DashboardPurchaseItem(purchase, converter: converter)
        if modelPurchase.planItPurchase != nil { datePurchases.append(modelPurchase) }
    }
    
    func dasboardDidFinishServiceWithType(_ type: DashBoardTitle, serviceDetections: [ServiceDetection]) {
        switch type {
        case .event:
            self.detectEventUpdate()
        case .toDo:
            self.detectTodoUpdate()
        case .shopping:
            self.detectShopingUpdate()
        case .giftCard:
            self.detectGiftCardUpdate()
        case .purchase:
            self.detectPurchaseUpdate()
        }
    }
    
    @discardableResult func readEventsOf(_ section: DashBoardSection) -> [DashboardEventItem] {
        let allEventValues = self.dashboardEvents.values.flatMap({ return $0})
        switch section {
        case .all:
            let startOfWeek = self.startDateOfMonth
            let endOfWeek = self.startDateOfMonth.addMonth(n: self.currentSearchEventIndex + 1).adding(seconds: -1)
            let records = allEventValues.filter({ $0.start <= endOfWeek && $0.start >= startOfWeek })
            self.visibleEvents = records
            return records
        case .today:
            let todayDate = Date().initialHour()
            let records = allEventValues.filter({ $0.start.initialHour() == todayDate })
            self.visibleEvents = records
            return records
        case .tomorrow:
            let tomorrowDate = Date().adding(days: 1).initialHour()
            let records = allEventValues.filter({ $0.start.initialHour() == tomorrowDate })
            self.visibleEvents = records
            return records
        case .week:
            let startOfWeek = Date().initialHour()
            let endOfWeek = Date().initialHour().addDays(7).adding(seconds: -1)
            let records = allEventValues.filter({ $0.start <= endOfWeek && $0.start >= startOfWeek })
            self.visibleEvents = records
            return records
        }
    }
    
    @discardableResult func readToDos(_ section: DashBoardSection) -> [DashboardToDoItem] {
        let allToDoValues = self.dashboardTodos.values.flatMap({ return $0 })
        switch section {
        case .all:
            let startDate = self.startDateOfMonth
            let endDate = self.startDateOfMonth.addMonth(n: self.currentSearchToDoIndex + 1).adding(seconds: -1)
            let records = allToDoValues.filter({ if let date = $0.actualDate { return date <= endDate && date >= startDate } else { return true } })
            self.visibleTodos = records
            return records
        case .today:
            let startDate = Date().initialHour()
            let endDate = Date().initialHour().adding(days: 1).adding(seconds: -1)
            let records = allToDoValues.filter({ if let date = $0.actualDate { return date <= endDate && date >= startDate } else { return false } })
            self.visibleTodos = records
            return records
        case .tomorrow:
            let startDate = Date().initialHour().adding(days: 1)
            let endDate = Date().initialHour().adding(days: 2).adding(seconds: -1)
            let records = allToDoValues.filter({ if let date = $0.actualDate { return date <= endDate && date >= startDate } else { return false } })
            self.visibleTodos = records
            return records
        case .week:
            let startOfWeek = Date().initialHour()
            let endOfWeek = Date().initialHour().addDays(7).adding(seconds: -1)
            let records = allToDoValues.filter({ if let date = $0.actualDate { return date <= endOfWeek && date >= startOfWeek } else { return false } })
            self.visibleTodos = records
            return records
        }
    }
    
    @discardableResult func readShopping(_ section: DashBoardSection) -> [DashboardShopListItem] {
        let allShoppingValues = self.dashboardShopings.values.flatMap({ return $0 })
        switch section {
        case .all:
            let startDate = self.startDateOfMonth
            let endDate = self.startDateOfMonth.addMonth(n: self.currentSearchShoppingIndex + 1).adding(seconds: -1)
            let records = allShoppingValues.filter({ if let date = $0.actualDueDate { return date <= endDate && date >= startDate } else { return true } })
            self.visibleShopings = records
            return records
        case .today:
            let startDate = Date().initialHour()
            let endDate = Date().initialHour().adding(days: 1).adding(seconds: -1)
            let records = allShoppingValues.filter({ if let date = $0.actualDueDate { return date <= endDate && date >= startDate } else { return false } })
            self.visibleShopings = records
            return records
        case .tomorrow:
            let startDate = Date().initialHour().adding(days: 1)
            let endDate = Date().initialHour().adding(days: 2).adding(seconds: -1)
            let records = allShoppingValues.filter({ if let date = $0.actualDueDate { return date <= endDate && date >= startDate } else { return false } })
            self.visibleShopings = records
            return records
        case .week:
            let startOfWeek = Date().initialHour()
            let endOfWeek = Date().initialHour().addDays(7).adding(seconds: -1)
            let records = allShoppingValues.filter({ if let date = $0.actualDueDate { return date <= endOfWeek && date >= startOfWeek } else { return false } })
            self.visibleShopings = records
            return records
        }
    }
    
    @discardableResult func readPurchases(_ section: DashBoardSection) -> [DashboardPurchaseItem] {
        let allPurchaseValues = self.dashboardPurchases.values.flatMap({ return $0 })
        switch section {
        case .all:
            let startDate = self.startDateOfMonth
            let endDate = self.startDateOfMonth.addMonth(n: self.currentSearchPurchaseIndex + 1).adding(seconds: -1)
            let records = allPurchaseValues.filter({ return $0.bilDateTime <= endDate && $0.bilDateTime >= startDate })
            self.visiblePurchases = records
            return records
        case .today:
            let startDate = Date().initialHour()
            let endDate = Date().initialHour().adding(days: 1).adding(seconds: -1)
            let records = allPurchaseValues.filter({ return $0.bilDateTime <= endDate && $0.bilDateTime >= startDate })
            self.visiblePurchases = records
            return records
        case .tomorrow:
            let startDate = Date().initialHour().adding(days: 1)
            let endDate = Date().initialHour().adding(days: 2).adding(seconds: -1)
            let records = allPurchaseValues.filter({ return $0.bilDateTime <= endDate && $0.bilDateTime >= startDate })
            self.visiblePurchases = records
            return records
        case .week:
            let startOfWeek = Date().initialHour()
            let endOfWeek = Date().initialHour().addDays(7).adding(seconds: -1)
            let records = allPurchaseValues.filter({ return $0.bilDateTime <= endOfWeek && $0.bilDateTime >= startOfWeek })
            self.visiblePurchases = records
            return records
        }
    }
    
    @discardableResult func readGiftCards(_ section: DashBoardSection) -> [DashboardGiftItem] {
        let allGiftValues = self.dashboardGifts.values.flatMap({ return $0 })
        switch section {
        case .all:
            let startDate = self.startDateOfMonth
            let endDate = self.startDateOfMonth.addMonth(n: self.currentSearchGiftIndex + 1).adding(seconds: -1)
            let records = allGiftValues.filter({ if let date = $0.exipryDate { return date <= endDate && date >= startDate } else { return true } })
            self.visibleGifts = records
            return records
        case .today:
            let startDate = Date().initialHour()
            let endDate = Date().initialHour().adding(days: 1).adding(seconds: -1)
            let records = allGiftValues.filter({ if let date = $0.exipryDate { return date <= endDate && date >= startDate } else { return false } })
            self.visibleGifts = records
            return records
        case .tomorrow:
            let startDate = Date().initialHour().adding(days: 1)
            let endDate = Date().initialHour().adding(days: 2).adding(seconds: -1)
            let records = allGiftValues.filter({ if let date = $0.exipryDate { return date <= endDate && date >= startDate } else { return false } })
            self.visibleGifts = records
            return records
        case .week:
            let startOfWeek = Date().initialHour()
            let endOfWeek = Date().initialHour().addDays(7).adding(seconds: -1)
            let records = allGiftValues.filter({ if let date = $0.exipryDate { return date <= endOfWeek && date >= startOfWeek } else { return false } })
            self.visibleGifts = records
            return records
        }
    }
    
    func filterEventWithDashboardTag(_ eventItems: [DashboardEventItem], on customDashboard: PlanItDashboard?) -> [DashboardEventItem] {
        guard let dashboard =  customDashboard else { return eventItems }
        let allDashboardTagString = dashboard.readTags().compactMap({ return $0.tag?.lowercased() })
        return eventItems.filter({ item in
            let containsTags = item.tags.contains(where: { allDashboardTagString.contains($0.lowercased()) })
            var containsCalendar: Bool = false
            if let calendar = item.calendar {
                containsCalendar = allDashboardTagString.contains(calendar.readValueOfCalendarName().lowercased())
            }
            return containsTags || containsCalendar
        })
    }
    
    func filterToDoWithDashboardTag(_ todoItems: [DashboardToDoItem], on customDashboard: PlanItDashboard?) -> [DashboardToDoItem] {
        guard let dashboard =  customDashboard else { return todoItems }
        let allDashboardTagString = dashboard.readTags().compactMap({ return $0.tag?.lowercased() })
        return todoItems.filter({ item in return item.tags.contains(where: { return allDashboardTagString.contains($0.lowercased()) }) })
    }
    
    func filterGiftWithDashboardTag(_ giftcoupon: [DashboardGiftItem], on customDashboard: PlanItDashboard?) -> [DashboardGiftItem] {
        guard let dashboard =  customDashboard else { return giftcoupon }
        let allDashboardTagString = dashboard.readTags().compactMap({ return $0.tag?.lowercased() })
        return giftcoupon.filter({ item in return item.tags.contains(where: { return allDashboardTagString.contains($0.lowercased()) }) })
    }
    
    func filterPurchaseWithDashboardTag(_ purchase: [DashboardPurchaseItem], on customDashboard: PlanItDashboard?) -> [DashboardPurchaseItem] {
        guard let dashboard =  customDashboard else { return purchase }
        let allDashboardTagString = dashboard.readTags().compactMap({ return $0.tag?.lowercased() })
        return purchase.filter({ item in return item.tags.contains(where: { return allDashboardTagString.contains($0.lowercased()) }) })
    }
    
    func filterShopListItemWithDashboardTag(_ shopping: [DashboardShopListItem], on customDashboard: PlanItDashboard?) -> [DashboardShopListItem] {
        guard let dashboard =  customDashboard else { return shopping }
        let allDashboardTagString = dashboard.readTags().compactMap({ return $0.tag?.lowercased() })
        return shopping.filter({ item in return item.tags.contains(where: { return allDashboardTagString.contains($0.lowercased()) }) })
    }
    
    func itemExistOnType(_ type: DashboardSectionType) -> Bool {
        switch type {
        case .event:
            return !self.dashboardEvents.isEmpty
        case .shopping:
            return !self.dashboardShopings.isEmpty
        case .todo:
            return !self.dashboardTodos.isEmpty
        case .gift:
            return !self.dashboardGifts.isEmpty
        case .purchase:
            return !self.dashboardPurchases.isEmpty
        }
    }
}
