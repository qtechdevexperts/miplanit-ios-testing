//
//  DatabasePlanItDashboard.swift
//  MiPlanIt
//
//  Created by Arun on 09/05/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

import CoreData

class DatabasePlanItDashboard: DataBaseManager {
    
    func insertOrUpdateDashboard(_ data: [String: Any], result: @escaping ()->()) {
        self.privateObjectContext.perform {
            guard !data.isEmpty else { result(); return }
            if let userDashboard = data["userDashboard"] as? [[String: Any]] {
                let localDashboards = self.readDashboardItemWithIds(dashboardData: userDashboard, using: self.privateObjectContext)
                for dashboard in userDashboard {
                    let userDashboardId = dashboard["userDashboardId"] as? Double ?? 0
                    let appDashboardId = dashboard["appUserDashboardId"] as? String ?? Strings.empty
                    let dashboardEntity = localDashboards.filter({ return ($0.userDashboardId == userDashboardId && userDashboardId != 0) || ($0.appDashboardId == appDashboardId && !appDashboardId.isEmpty) }).first ?? self.insertNewRecords(Table.planItDashboard, context: self.privateObjectContext) as! PlanItDashboard
                    dashboardEntity.userId = Session.shared.readUser()?.readValueOfUserId()
                    dashboardEntity.userDashboardId = dashboard["userDashboardId"] as? Double ?? 0
                    dashboardEntity.name = dashboard["name"] as? String
                    dashboardEntity.userDashboardImage = dashboard["userDashboardImage"] as? String
                    dashboardEntity.isPending = false
                    if let date = dashboard["createdAt"] as? String {
                        dashboardEntity.createdAt = date.stringToDate(formatter: DateFormatters.MMDDYYYYHMMSSA, timeZone: TimeZone(abbreviation: "UTC")!)
                    }
                    if let date = dashboard["modifiedAt"] as? String {
                        dashboardEntity.modifiedAt = date.stringToDate(formatter: DateFormatters.MMDDYYYYHMMSSA, timeZone: TimeZone(abbreviation: "UTC")!)
                    }
                    
                    if let createdBy = dashboard["createdBy"] as? [String: Any] {
                        DatabasePlanItCreator().insertDashboard(dashboardEntity, creator: createdBy, using: self.privateObjectContext)
                    }
                    if let modifiedBy = dashboard["modifiedBy"] as? [String: Any] {
                        DatabasePlanItModifier().insertDashboard(dashboardEntity, modifier: modifiedBy, using: self.privateObjectContext)
                    }
                    if let tags = dashboard["tags"] as? [String] {
                        DatabasePlanItTags().insertTags(tags, for: dashboardEntity, using: self.privateObjectContext)
                    }
                    if let excludedSections = dashboard["excludedSections"] as? [String] {
                        DatabasePlanItExcludedSections().insertExcludedSection(excludedSections, for: dashboardEntity, using: self.privateObjectContext)
                    }
                }
            }
            if let removedDashboard = data["removedDashboard"] as? [Double] {
                DatabasePlanItDashboard().removePlanItDashboards(removedDashboard, using: self.privateObjectContext)
            }
            self.privateObjectContext.saveContext()
            DispatchQueue.main.async { result() }
        }
    }
    
    func insertOrUpdateDashboard(_ data: [String: Any]) -> PlanItDashboard {
        let userDashboardId = data["userDashboardId"] as? Double ?? 0
        let dashboardEntity = self.readDashboardItemWithIds(dashboardData: [data], using: self.mainObjectContext).first ?? self.insertNewRecords(Table.planItDashboard, context: self.mainObjectContext) as! PlanItDashboard
        dashboardEntity.userId = Session.shared.readUser()?.readValueOfUserId()
        dashboardEntity.userDashboardId = userDashboardId
        dashboardEntity.name = data["name"] as? String
        dashboardEntity.userDashboardImage = data["userDashboardImage"] as? String
        dashboardEntity.appDashboardId = data["appUserDashboardId"] as? String
        dashboardEntity.isPending = false
        if let date = data["createdAt"] as? String {
            dashboardEntity.createdAt = date.stringToDate(formatter: DateFormatters.MMDDYYYYHMMSSA, timeZone: TimeZone(abbreviation: "UTC")!)
        }
        if let date = data["modifiedAt"] as? String {
            dashboardEntity.modifiedAt = date.stringToDate(formatter: DateFormatters.MMDDYYYYHMMSSA, timeZone: TimeZone(abbreviation: "UTC")!)
        }
        if let createdBy = data["createdBy"] as? [String: Any] {
            DatabasePlanItCreator().insertDashboard(dashboardEntity, creator: createdBy, using: self.mainObjectContext)
        }
        if let modifiedBy = data["modifiedBy"] as? [String: Any] {
            DatabasePlanItModifier().insertDashboard(dashboardEntity, modifier: modifiedBy, using: self.mainObjectContext)
        }
        if let tags = data["tags"] as? [String] {
            DatabasePlanItTags().insertTags(tags, for: dashboardEntity, using: self.mainObjectContext)
        }
        if let excludedSections = data["excludedSections"] as? [String] {
            DatabasePlanItExcludedSections().insertExcludedSection(excludedSections, for: dashboardEntity, using: self.mainObjectContext)
        }
        self.mainObjectContext.saveContext()
        return dashboardEntity
    }
    
    func insertDashboardOfflineData(_ dashboard: Dashboard, imageData: Data?) {
        let dashboardEntity = dashboard.planItDashBoard ?? self.insertNewRecords(Table.planItDashboard, context: self.mainObjectContext) as! PlanItDashboard
        dashboardEntity.name = dashboard.name
        dashboardEntity.appDashboardId = UUID().uuidString
        dashboardEntity.userId = Session.shared.readUserId()
        if imageData != nil {
            dashboardEntity.dashboardImageData = imageData
        }
        dashboardEntity.isPending = true
        dashboardEntity.createdAt = Date()
        dashboardEntity.modifiedAt = Date()
        DatabasePlanItExcludedSections().insertExcludedSection(dashboard.excludedSections, for: dashboardEntity, using: self.mainObjectContext)
        DatabasePlanItTags().insertTags(dashboard.tags, for: dashboardEntity, using: self.mainObjectContext)
        dashboard.planItDashBoard = dashboardEntity
        self.mainObjectContext.saveContext()
    }
    
    func readDashboardItemWithIds(dashboardData: [[String: Any]], using context: NSManagedObjectContext? = nil) -> [PlanItDashboard] {
        let objectContext = context ?? self.mainObjectContext
        let dashboardIds = dashboardData.compactMap({ return $0["userDashboardId"] as? Double })
        let appDashboardIds: [String] = dashboardData.compactMap({ if let appId = $0["appUserDashboardId"] as? String, !appId.isEmpty { return appId } else { return nil } })
        let predicate = NSPredicate(format: "userId == %@ AND (userDashboardId IN %@ OR appDashboardId IN %@) AND deleteStatus == NO", Session.shared.readUserId(), dashboardIds, appDashboardIds)
        return self.readRecords(fromCoreData: Table.planItDashboard, predicate: predicate, context: objectContext) as! [PlanItDashboard]
    }
    
    func removePlanItDashboards(_ dashboards: [Double], using context: NSManagedObjectContext? = nil) {
        let objectContext = context ?? self.mainObjectContext
        let localDashboards = self.readSpecificDashboards(dashboards, using: objectContext)
        localDashboards.forEach({ objectContext.delete($0) })
    }
    
    private func readSpecificDashboards(_ dashboards: [Double], using context: NSManagedObjectContext? = nil) -> [PlanItDashboard] {
        let objectContext = context ?? self.mainObjectContext
        let predicate = NSPredicate(format: "userId == %@ AND userDashboardId IN %@", Session.shared.readUserId(), dashboards)
        return self.readRecords(fromCoreData: Table.planItDashboard, predicate: predicate, context: objectContext) as! [PlanItDashboard]
    }
    
    private func readSpecificAppDashboards(_ dashboardAppId: String, using context: NSManagedObjectContext? = nil) -> [PlanItDashboard] {
        if dashboardAppId.isEmpty { return [] }
        let objectContext = context ?? self.mainObjectContext
        let predicate = NSPredicate(format: "userId == %@ AND appDashboardId == %@", Session.shared.readUserId(), dashboardAppId)
        return self.readRecords(fromCoreData: Table.planItDashboard, predicate: predicate, context: objectContext) as! [PlanItDashboard]
    }
    
    func readAllDashboards() -> [PlanItDashboard] {
        let predicate = NSPredicate(format: "userId == %@ AND deleteStatus == NO", Session.shared.readUserId())
        return self.readRecords(fromCoreData: Table.planItDashboard, predicate: predicate, sortDescriptor: ["createdAt"], ascending: false, context: self.mainObjectContext) as! [PlanItDashboard]
    }
    
    func readAllPendingDashboards() -> [PlanItDashboard] {
        let predicate = NSPredicate(format: "userId == %@ AND deleteStatus == NO AND isPending == YES", Session.shared.readUserId())
        return self.readRecords(fromCoreData: Table.planItDashboard, predicate: predicate, sortDescriptor: ["createdAt"], ascending: false, context: self.mainObjectContext) as! [PlanItDashboard]
    }
    
    func readAllPendingDeletedDashboards() -> [PlanItDashboard] {
        let predicate = NSPredicate(format: "userId == %@ AND deleteStatus == YES AND isPending == YES", Session.shared.readUserId())
        return self.readRecords(fromCoreData: Table.planItDashboard, predicate: predicate, sortDescriptor: ["createdAt"], ascending: false, context: self.mainObjectContext) as! [PlanItDashboard]
    }
    
    func readDefaultDashboard() -> PlanItDashboard? {
        let predicate = NSPredicate(format: "userId == %@ AND isDefault == YES", Session.shared.readUserId())
        let defaultDashboards = self.readRecords(fromCoreData: Table.planItDashboard, predicate: predicate, context: self.mainObjectContext) as! [PlanItDashboard]
        return defaultDashboards.first
    }
    
    func deleteCustomDashboard(planItDashboard: PlanItDashboard) {
        planItDashboard.deleteStatus = true
        planItDashboard.isPending = true
        self.mainObjectContext.saveContext()
    }
}
