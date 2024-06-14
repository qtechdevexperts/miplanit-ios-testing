//
//  CustomDashboardProfile.swift
//  MiPlanIt
//
//  Created by Febin Paul on 24/11/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

class CustomDashboardProfile: Equatable {
    
    var notificationCount: Int = 0
    var totalEventsCount: Int = 0
    var totalTodosCount: Int = 0
    var totalShopingCount: Int = 0
    var totalGiftsCount: Int = 0
    var totalPurchasesCount: Int = 0
    var planItDashboard: PlanItDashboard!
    var planItDashboardName: String!
    
    init(with dashboard: PlanItDashboard) {
        self.planItDashboard = dashboard
        self.planItDashboardName = self.planItDashboard.readDashboardName()
    }
    
    func findIncludedSectionType() -> [DashboardSectionType] {
        var allSections: [DashboardSectionType] = [.event, .gift, .purchase, .shopping, .todo]
        self.planItDashboard.readAllExcludedSections().map({ $0.readSectionName() }).forEach { (section) in
            if let index = allSections.firstIndex(where: { (type) -> Bool in
                type.rawValue == section
            }) {
                allSections.remove(at: index)
            }
        }
        return allSections
    }
    
    func findIncludedTags() -> [String] {
        return self.planItDashboard.readTags().map({ $0.readTag().lowercased() })
    }
    
    static func == (lhs: CustomDashboardProfile, rhs: CustomDashboardProfile) -> Bool {
        return lhs.planItDashboard == rhs.planItDashboard
    }
    
    @discardableResult func updateCustomeDashboardViewCount(events: [DashboardEventItem], todos: [DashboardToDoItem], purchases: [DashboardPurchaseItem], gifts: [DashboardGiftItem], shoppings: [DashboardShopListItem]) -> Int {
        var includedDataType: [Any] = []
        self.totalEventsCount = 0; self.totalShopingCount = 0; self.totalTodosCount = 0; self.totalGiftsCount = 0; self.totalPurchasesCount = 0
        self.findIncludedSectionType().forEach { (section) in
            switch section {
            case .event:
                includedDataType.append(contentsOf: events)
            case .shopping:
                includedDataType.append(contentsOf: shoppings)
            case .todo:
                includedDataType.append(contentsOf: todos)
            case .gift:
                includedDataType.append(contentsOf: gifts)
            case .purchase:
                includedDataType.append(contentsOf: purchases)
            }
        }
        let allAddedTags = self.findIncludedTags()
        self.totalEventsCount = 0; self.totalShopingCount = 0; self.totalTodosCount = 0; self.totalGiftsCount = 0; self.totalPurchasesCount = 0
        for eachItems in includedDataType {
            if let eventItem = eachItems as? DashboardEventItem, let calendar = eventItem.calendar, ( eventItem.readAllTags().contains(where: { allAddedTags.contains($0) }) || allAddedTags.contains(calendar.readValueOfCalendarName().lowercased()) ){
                self.totalEventsCount += 1
            }
            else if let todoItem = eachItems as? DashboardToDoItem, ( todoItem.readAllTags().contains(where: { allAddedTags.contains($0) }) ) {
                self.totalTodosCount += 1
            }
            else if let giftItem = eachItems as? DashboardPurchaseItem, ( giftItem.readAllTags().contains(where: { allAddedTags.contains($0) }) ) {
                self.totalPurchasesCount += 1
            }
            else if let purchaseItem = eachItems as? DashboardGiftItem, ( purchaseItem.readAllTags().contains(where: { allAddedTags.contains($0) }) ) {
                self.totalGiftsCount += 1
            }
            else if let shopListItem = eachItems as? DashboardShopListItem, ( shopListItem.readAllTags().contains(where: { allAddedTags.contains($0) }) ) {
                self.totalShopingCount += 1
            }
        }
        self.notificationCount = self.totalEventsCount + self.totalTodosCount + self.totalShopingCount + self.totalGiftsCount + self.totalPurchasesCount
        return self.notificationCount
    }
    
    @discardableResult func updateCustomeDashboardEvent(_ events: [DashboardEventItem]) -> Int {
        var includedDataType: [Any] = []
        self.totalEventsCount = 0
        self.findIncludedSectionType().forEach { (section) in
            switch section {
            case .event:
                includedDataType.append(contentsOf: events)
            default: break
            }
        }
        let allAddedTags = self.findIncludedTags()
        self.totalEventsCount = 0
        for eachItems in includedDataType {
            if let eventItem = eachItems as? DashboardEventItem, let calendar = eventItem.calendar, ( eventItem.readAllTags().contains(where: { allAddedTags.contains($0) }) || allAddedTags.contains(calendar.readValueOfCalendarName().lowercased()) ){
                self.totalEventsCount += 1
            }
        }
        self.notificationCount = self.totalEventsCount + self.totalTodosCount + self.totalShopingCount + self.totalGiftsCount + self.totalPurchasesCount
        return self.notificationCount
    }
    
    @discardableResult func updateCustomeDashboardTodos(_ todos: [DashboardToDoItem]) -> Int {
        var includedDataType: [Any] = []
        self.totalTodosCount = 0
        self.findIncludedSectionType().forEach { (section) in
            switch section {
            case .todo:
                includedDataType.append(contentsOf: todos)
            default: break
            }
        }
        let allAddedTags = self.findIncludedTags()
        self.totalTodosCount = 0
        for eachItems in includedDataType {
            if let todoItem = eachItems as? DashboardToDoItem, ( todoItem.readAllTags().contains(where: { allAddedTags.contains($0) }) ) {
                self.totalTodosCount += 1
            }
        }
        self.notificationCount = self.totalEventsCount + self.totalTodosCount + self.totalShopingCount + self.totalGiftsCount + self.totalPurchasesCount
        return self.notificationCount
    }
    
    @discardableResult func updateCustomeDashboardShopings(_ shoppings: [DashboardShopListItem]) -> Int {
        var includedDataType: [Any] = []
        self.totalShopingCount = 0
        self.findIncludedSectionType().forEach { (section) in
            switch section {
            case .shopping:
                includedDataType.append(contentsOf: shoppings)
            default: break
            }
        }
        let allAddedTags = self.findIncludedTags()
        self.totalShopingCount = 0
        for eachItems in includedDataType {
            if let shopListItem = eachItems as? DashboardShopListItem, ( shopListItem.readAllTags().contains(where: { allAddedTags.contains($0) }) ) {
                self.totalShopingCount += 1
            }
        }
        self.notificationCount = self.totalEventsCount + self.totalTodosCount + self.totalShopingCount + self.totalGiftsCount + self.totalPurchasesCount
        return self.notificationCount
    }
    
    @discardableResult func updateCustomeDashboardGifts(_ gifts: [DashboardGiftItem]) -> Int {
        var includedDataType: [Any] = []
        self.totalGiftsCount = 0
        self.findIncludedSectionType().forEach { (section) in
            switch section {
            case .gift:
                includedDataType.append(contentsOf: gifts)
            default: break
            }
        }
        let allAddedTags = self.findIncludedTags()
        self.totalGiftsCount = 0
        for eachItems in includedDataType {
            if let purchaseItem = eachItems as? DashboardGiftItem, ( purchaseItem.readAllTags().contains(where: { allAddedTags.contains($0) }) ) {
                self.totalGiftsCount += 1
            }
        }
        self.notificationCount = self.totalEventsCount + self.totalTodosCount + self.totalShopingCount + self.totalGiftsCount + self.totalPurchasesCount
        return self.notificationCount
    }
    
    @discardableResult func updateCustomeDashboardPurchases(_ purchases: [DashboardPurchaseItem]) -> Int {
        self.totalPurchasesCount = 0
        var includedDataType: [Any] = []
        self.findIncludedSectionType().forEach { (section) in
            switch section {
            case .purchase:
                includedDataType.append(contentsOf: purchases)
            default: break
            }
        }
        let allAddedTags = self.findIncludedTags()
        self.totalPurchasesCount = 0
        for eachItems in includedDataType {
            if let giftItem = eachItems as? DashboardPurchaseItem, ( giftItem.readAllTags().contains(where: { allAddedTags.contains($0) }) ) {
                self.totalPurchasesCount += 1
            }
        }
        self.notificationCount = self.totalEventsCount + self.totalTodosCount + self.totalShopingCount + self.totalGiftsCount + self.totalPurchasesCount
        return self.notificationCount
    }
}
