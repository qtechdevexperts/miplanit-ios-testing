//
//  DatabasePlanItModifier.swift
//  MiPlanIt
//
//  Created by Arun on 08/04/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation
import CoreData

class DatabasePlanItModifier: DataBaseManager {
    
    func insertCalendar(_ calendar: PlanItCalendar, modifier: [String: Any], using context: NSManagedObjectContext? = nil) {
        let objectContext = context ?? self.mainObjectContext
        let modifierEntity = calendar.modifiedBy ?? self.insertNewRecords(Table.planItModifier, context: objectContext) as! PlanItModifier
        modifierEntity.userId = modifier["userId"] as? Double ?? 0
        modifierEntity.userName = modifier["userName"] as? String
        modifierEntity.fullName = modifier["fullName"] as? String
        modifierEntity.phone = modifier["phone"] as? String
        modifierEntity.email = modifier["email"] as? String
        modifierEntity.profileImage = modifier["profileImage"] as? String
        modifierEntity.origin = Session.shared.readUserId()
        modifierEntity.calendar = calendar
        Session.shared.insertDBUser(modifierEntity)
    }
    
    func insertEvent(_ event: PlanItEvent, modifier: PlanItModifier, using context: NSManagedObjectContext? = nil) {
        let objectContext = context ?? self.mainObjectContext
        let modifierEntity = event.modifiedBy ?? self.insertNewRecords(Table.planItModifier, context: objectContext) as! PlanItModifier
        modifierEntity.userId = modifier.userId
        modifierEntity.userName = modifier.userName
        modifierEntity.fullName = modifier.fullName
        modifierEntity.phone = modifier.phone
        modifierEntity.email = modifier.email
        modifierEntity.profileImage = modifier.profileImage
        modifierEntity.origin = Session.shared.readUserId()
        modifierEntity.event = event
        Session.shared.insertDBUser(modifierEntity)
    }
    
    func insertEvent(_ event: PlanItEvent, modifier: [String: Any], using context: NSManagedObjectContext? = nil) {
        let objectContext = context ?? self.mainObjectContext
        let modifierEntity = event.modifiedBy ?? self.insertNewRecords(Table.planItModifier, context: objectContext) as! PlanItModifier
        modifierEntity.userId = modifier["userId"] as? Double ?? 0
        modifierEntity.userName = modifier["userName"] as? String
        modifierEntity.fullName = modifier["fullName"] as? String
        modifierEntity.phone = modifier["phone"] as? String
        modifierEntity.email = modifier["email"] as? String
        modifierEntity.profileImage = modifier["profileImage"] as? String
        modifierEntity.origin = Session.shared.readUserId()
        modifierEntity.event = event
        Session.shared.insertDBUser(modifierEntity)
    }
    
    func insertEvent(_ event: PlanItEvent, modifier: PlanItUser?, using context: NSManagedObjectContext? = nil) {
        let objectContext = context ?? self.mainObjectContext
        let modifierEntity = event.modifiedBy ?? self.insertNewRecords(Table.planItModifier, context: objectContext) as! PlanItModifier
        modifierEntity.userName = modifier?.userName
        modifierEntity.fullName = modifier?.name
        modifierEntity.phone = modifier?.phone
        modifierEntity.email = modifier?.email
        modifierEntity.profileImage = modifier?.imageUrl
        modifierEntity.origin = Session.shared.readUserId()
        modifierEntity.userId = Double(modifier?.readValueOfUserId() ?? Strings.empty) ?? 0.0
        modifierEntity.event = event
        Session.shared.insertDBUser(modifierEntity)
    }
    
    func insertTodo(_ todo: PlanItTodo, modifier: [String: Any], using context: NSManagedObjectContext? = nil) {
        let objectContext = context ?? self.mainObjectContext
        let modifierEntity = todo.modifiedBy ?? self.insertNewRecords(Table.planItModifier, context: objectContext) as! PlanItModifier
        modifierEntity.userId = modifier["userId"] as? Double ?? 0
        modifierEntity.userName = modifier["userName"] as? String
        modifierEntity.fullName = modifier["fullName"] as? String
        modifierEntity.phone = modifier["phone"] as? String
        modifierEntity.email = modifier["email"] as? String
        modifierEntity.profileImage = modifier["profileImage"] as? String
        modifierEntity.origin = Session.shared.readUserId()
        modifierEntity.todo = todo
        Session.shared.insertDBUser(modifierEntity)
    }
    
    func insertSubTodo(_ subTodo: PlanItSubTodo, modifier: [String: Any], using context: NSManagedObjectContext? = nil) {
        let objectContext = context ?? self.mainObjectContext
        let modifierEntity = subTodo.modifiedBy ?? self.insertNewRecords(Table.planItModifier, context: objectContext) as! PlanItModifier
        modifierEntity.userId = modifier["userId"] as? Double ?? 0
        modifierEntity.userName = modifier["userName"] as? String
        modifierEntity.fullName = modifier["fullName"] as? String
        modifierEntity.phone = modifier["phone"] as? String
        modifierEntity.email = modifier["email"] as? String
        modifierEntity.profileImage = modifier["profileImage"] as? String
        modifierEntity.origin = Session.shared.readUserId()
        modifierEntity.subTodo = subTodo
        Session.shared.insertDBUser(modifierEntity)
    }
    
    func insertShop(_ shopList: PlanItShopList, modifier: [String: Any], using context: NSManagedObjectContext? = nil) {
        let objectContext = context ?? self.mainObjectContext
        let creatorEntity = shopList.modifiedBy ?? self.insertNewRecords(Table.planItModifier, context: objectContext) as! PlanItModifier
        creatorEntity.userId = modifier["userId"] as? Double ?? 0
        creatorEntity.userName = modifier["userName"] as? String
        creatorEntity.fullName = modifier["fullName"] as? String
        creatorEntity.phone = modifier["phone"] as? String
        creatorEntity.email = modifier["email"] as? String
        creatorEntity.profileImage = modifier["profileImage"] as? String
        creatorEntity.origin = Session.shared.readUserId()
        creatorEntity.shopList = shopList
        Session.shared.insertDBUser(creatorEntity)
    }
    
    func insertShopListItem(_ shopListItem: PlanItShopListItems, modifier: PlanItUser?, using context: NSManagedObjectContext? = nil) {
        let objectContext = context ?? self.mainObjectContext
        let modifierEntity = shopListItem.modifiedBy ?? self.insertNewRecords(Table.planItModifier, context: objectContext) as! PlanItModifier
        modifierEntity.userName = modifier?.userName
        modifierEntity.fullName = modifier?.name
        modifierEntity.phone = modifier?.phone
        modifierEntity.email = modifier?.email
        modifierEntity.profileImage = modifier?.imageUrl
        modifierEntity.origin = Session.shared.readUserId()
        modifierEntity.userId = Double(modifier?.readValueOfUserId() ?? Strings.empty) ?? 0.0
        modifierEntity.shopListItem = shopListItem
        Session.shared.insertDBUser(modifierEntity)
    }
    
    func insertShopListItem(_ shopListItem: PlanItShopListItems, modifier: [String: Any], using context: NSManagedObjectContext? = nil) {
        let objectContext = context ?? self.mainObjectContext
        let creatorEntity = shopListItem.modifiedBy ?? self.insertNewRecords(Table.planItModifier, context: objectContext) as! PlanItModifier
        creatorEntity.userId = modifier["userId"] as? Double ?? 0
        creatorEntity.userName = modifier["userName"] as? String
        creatorEntity.fullName = modifier["fullName"] as? String
        creatorEntity.phone = modifier["phone"] as? String
        creatorEntity.email = modifier["email"] as? String
        creatorEntity.profileImage = modifier["profileImage"] as? String
        creatorEntity.origin = Session.shared.readUserId()
        creatorEntity.shopListItem = shopListItem
        Session.shared.insertDBUser(creatorEntity)
    }
    
    func insertDashboard(_ dashboard: PlanItDashboard, modifier: [String: Any], using context: NSManagedObjectContext? = nil) {
        let objectContext = context ?? self.mainObjectContext
        let creatorEntity = dashboard.modifiedBy ?? self.insertNewRecords(Table.planItModifier, context: objectContext) as! PlanItModifier
        creatorEntity.userId = modifier["userId"] as? Double ?? 0
        creatorEntity.userName = modifier["userName"] as? String
        creatorEntity.fullName = modifier["fullName"] as? String
        creatorEntity.phone = modifier["phone"] as? String
        creatorEntity.email = modifier["email"] as? String
        creatorEntity.profileImage = modifier["profileImage"] as? String
        creatorEntity.origin = Session.shared.readUserId()
        creatorEntity.dashboard = dashboard
        Session.shared.insertDBUser(creatorEntity)
    }
    
    func insertShareLink(_ shareLink: PlanItShareLink, modifier: [String: Any], using context: NSManagedObjectContext? = nil) {
        let objectContext = context ?? self.mainObjectContext
        let modifierEntity = shareLink.modifiedBy ?? self.insertNewRecords(Table.planItModifier, context: objectContext) as! PlanItModifier
        modifierEntity.userId = modifier["userId"] as? Double ?? 0
        modifierEntity.userName = modifier["userName"] as? String
        modifierEntity.fullName = modifier["fullName"] as? String
        modifierEntity.phone = modifier["phone"] as? String
        modifierEntity.email = modifier["email"] as? String
        modifierEntity.profileImage = modifier["profileImage"] as? String
        modifierEntity.origin = Session.shared.readUserId()
        modifierEntity.shareLink = shareLink
        Session.shared.insertDBUser(modifierEntity)
    }
    
    func insertShareLink(_ shareLink: PlanItShareLink, modifier: PlanItUser?, using context: NSManagedObjectContext? = nil) {
        let objectContext = context ?? self.mainObjectContext
        let modifierEntity = shareLink.modifiedBy ?? self.insertNewRecords(Table.planItModifier, context: objectContext) as! PlanItModifier
        modifierEntity.userName = modifier?.userName
        modifierEntity.fullName = modifier?.name
        modifierEntity.phone = modifier?.phone
        modifierEntity.email = modifier?.email
        modifierEntity.profileImage = modifier?.imageUrl
        modifierEntity.origin = Session.shared.readUserId()
        modifierEntity.userId = Double(modifier?.readValueOfUserId() ?? Strings.empty) ?? 0.0
        modifierEntity.shareLink = shareLink
        Session.shared.insertDBUser(modifierEntity)
    }
    
    func readAllUserModifier(using context: NSManagedObjectContext? = nil) -> [PlanItModifier] {
        let objectContext = context ?? self.mainObjectContext
        let predicate = NSPredicate(format: "origin == %@ AND userId <> %@", Session.shared.readUserId(), Session.shared.readUserId())
        return self.readRecords(fromCoreData: Table.planItModifier, predicate: predicate, context: objectContext) as! [PlanItModifier]
    }
}
