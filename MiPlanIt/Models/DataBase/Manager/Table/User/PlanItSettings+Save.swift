//
//  PlanItSettings+Save.swift
//  MiPlanIt
//
//  Created by Arun on 08/04/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

extension PlanItSettings {
    
    func readLastFetchDataTime() -> String {
        return self.lastDataFetchTime ?? Strings.empty
    }
    
    func saveLastFetchDataTime(_ value: String) {
        self.lastDataFetchTime = value
    }
    
    func readLastFetchShopDataTime() -> String {
        return self.lastShopdataFetchTime ?? Strings.empty
    }
    
    func readLastFetchUserShopDataTime() -> String {
        return self.lastUserShopdataFetchTime ?? Strings.empty
    }
    
    func readLastFetchUserShopListDataTime() -> String {
        return self.lastUserShopListdataFetchTime ?? Strings.empty
    }
    
    func readLastFetchUserDashboardDataTime() -> String {
        return self.lastUserCustomDashboardFetchTime ?? Strings.empty
    }
    
    func readLastCalendarFetchDataTime() -> String {
        return self.lastCalendarFetchTime ?? Strings.empty
    }
    
    func readLastShareListFetchDataTime() -> String {
        return self.lastEventShareLinkFetchTime ?? Strings.empty
    }
    
    func readLastTodoFetchDataTime() -> String {
        return self.lastTodoFetchTime ?? Strings.empty
    }
    
    func readLastGiftFetchDataTime() -> String {
        return self.lastGiftFetchTime ?? Strings.empty
    }
    
    func readLastPurchaseFetchDataTime() -> String {
        return self.lastPurchaseFetchTime ?? Strings.empty
    }
    
    func saveLastFetchShopDataTime(_ value: String) {
        self.lastShopdataFetchTime = value
        try? self.managedObjectContext?.save()
    }
    
    func saveLastFetchUserShopDataTime(_ value: String) {
        self.lastUserShopdataFetchTime = value
        try? self.managedObjectContext?.save()
    }
    
    func saveLastFetchUserShopListDataTime(_ value: String) {
        self.lastUserShopListdataFetchTime = value
        try? self.managedObjectContext?.save()
    }
    
    func saveLastFetchUserDashboardDataTime(_ value: String) {
        self.lastUserCustomDashboardFetchTime = value
        try? self.managedObjectContext?.save()
    }
    
    func saveLastCalendarFetchDataTime(_ value: String) {
        self.lastCalendarFetchTime = value
        try? self.managedObjectContext?.save()
    }
    
    func saveLastEventShareLinkFetchDataTime(_ value: String) {
        self.lastEventShareLinkFetchTime = value
        try? self.managedObjectContext?.save()
    }
    
    func saveLastTodoFetchDataTime(_ value: String) {
        self.lastTodoFetchTime = value
        try? self.managedObjectContext?.save()
    }
    
    func saveLastGiftFetchDataTime(_ value: String) {
        self.lastGiftFetchTime = value
        try? self.managedObjectContext?.save()
    }
    
    func saveLastPurchaseFetchDataTime(_ value: String) {
        self.lastPurchaseFetchTime = value
        try? self.managedObjectContext?.save()
    }
    
    func saveCustomDashboard(_ value: Bool) {
        self.isCustomDashboard = value
        try? self.managedObjectContext?.save()
    }
}
