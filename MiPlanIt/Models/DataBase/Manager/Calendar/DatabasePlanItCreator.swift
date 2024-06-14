//
//  DatabasePlanItCreator.swift
//  MiPlanIt
//
//  Created by Arun on 08/04/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation
import CoreData

class DatabasePlanItCreator: DataBaseManager {
    
    func insertCalendar(_ calendar: PlanItCalendar, creator: [String: Any], using context: NSManagedObjectContext? = nil) {
        let objectContext = context ?? self.mainObjectContext
        let creatorEntity = calendar.createdBy ?? self.insertNewRecords(Table.planItCreator, context: objectContext) as! PlanItCreator
        creatorEntity.userId = creator["userId"] as? Double ?? 0
        creatorEntity.userName = creator["userName"] as? String
        creatorEntity.fullName = creator["fullName"] as? String
        creatorEntity.phone = creator["phone"] as? String
        creatorEntity.email = creator["email"] as? String
        creatorEntity.profileImage = creator["profileImage"] as? String
        creatorEntity.origin = Session.shared.readUserId()
        creatorEntity.calendar = calendar
        Session.shared.insertDBUser(creatorEntity)
    }
    
    func insertCalendar(_ calendar: PlanItCalendar, creator: PlanItUser?, using context: NSManagedObjectContext? = nil) {
        let objectContext = context ?? self.mainObjectContext
        let creatorEntity = calendar.createdBy ?? self.insertNewRecords(Table.planItCreator, context: objectContext) as! PlanItCreator
        creatorEntity.userName = creator?.userName
        creatorEntity.fullName = creator?.name
        creatorEntity.phone = creator?.phone
        creatorEntity.email = creator?.email
        creatorEntity.profileImage = creator?.imageUrl
        creatorEntity.origin = Session.shared.readUserId()
        creatorEntity.userId = Double(creator?.readValueOfUserId() ?? Strings.empty) ?? 0.0
        creatorEntity.origin = Session.shared.readUserId()
        creatorEntity.calendar = calendar
        Session.shared.insertDBUser(creatorEntity)
    }
    
    func insertEvent(_ event: PlanItEvent, creator: PlanItCreator, using context: NSManagedObjectContext? = nil) {
        let objectContext = context ?? self.mainObjectContext
        let creatorEntity = event.createdBy ?? self.insertNewRecords(Table.planItCreator, context: objectContext) as! PlanItCreator
        creatorEntity.userId = creator.userId
        creatorEntity.userName = creator.userName
        creatorEntity.fullName = creator.fullName
        creatorEntity.phone = creator.phone
        creatorEntity.email = creator.email
        creatorEntity.profileImage = creator.profileImage
        creatorEntity.origin = Session.shared.readUserId()
        creatorEntity.event = event
        Session.shared.insertDBUser(creatorEntity)
    }
    
    func insertEvent(_ event: PlanItEvent, creator: [String: Any], using context: NSManagedObjectContext? = nil) {
        let objectContext = context ?? self.mainObjectContext
        let creatorEntity = event.createdBy ?? self.insertNewRecords(Table.planItCreator, context: objectContext) as! PlanItCreator
        creatorEntity.userId = creator["userId"] as? Double ?? 0
        creatorEntity.userName = creator["userName"] as? String
        creatorEntity.fullName = creator["fullName"] as? String
        creatorEntity.phone = creator["phone"] as? String
        creatorEntity.email = creator["email"] as? String
        creatorEntity.profileImage = creator["profileImage"] as? String
        creatorEntity.origin = Session.shared.readUserId()
        creatorEntity.event = event
        Session.shared.insertDBUser(creatorEntity)
    }
    
    func insertEvent(_ event: PlanItEvent, creator: PlanItUser?, using context: NSManagedObjectContext? = nil) {
        let objectContext = context ?? self.mainObjectContext
        let creatorEntity = event.createdBy ?? self.insertNewRecords(Table.planItCreator, context: objectContext) as! PlanItCreator
        creatorEntity.userName = creator?.userName
        creatorEntity.fullName = creator?.name
        creatorEntity.phone = creator?.phone
        creatorEntity.email = creator?.email
        creatorEntity.profileImage = creator?.imageUrl
        creatorEntity.origin = Session.shared.readUserId()
        creatorEntity.userId = Double(creator?.readValueOfUserId() ?? Strings.empty) ?? 0.0
        creatorEntity.event = event
        Session.shared.insertDBUser(creatorEntity)
    }
    
    func insertPurchase(_ purchase: PlanItPurchase, creator: [String: Any], using context: NSManagedObjectContext? = nil) {
        let objectContext = context ?? self.mainObjectContext
        let creatorEntity = purchase.createdBy ?? self.insertNewRecords(Table.planItCreator, context: objectContext) as! PlanItCreator
        creatorEntity.userId = creator["userId"] as? Double ?? 0
        creatorEntity.userName = creator["userName"] as? String
        creatorEntity.fullName = creator["fullName"] as? String
        creatorEntity.phone = creator["phone"] as? String
        creatorEntity.email = creator["email"] as? String
        creatorEntity.profileImage = creator["profileImage"] as? String
        creatorEntity.origin = Session.shared.readUserId()
        creatorEntity.purchase = purchase
        Session.shared.insertDBUser(creatorEntity)
    }
    
    func insertTodoCategory(_ todoCategory: PlanItTodoCategory, creator: [String: Any], using context: NSManagedObjectContext? = nil) {
        let objectContext = context ?? self.mainObjectContext
        let creatorEntity = todoCategory.createdBy ?? self.insertNewRecords(Table.planItCreator, context: objectContext) as! PlanItCreator
        creatorEntity.userId = creator["userId"] as? Double ?? 0
        creatorEntity.userName = creator["userName"] as? String
        creatorEntity.fullName = creator["fullName"] as? String
        creatorEntity.phone = creator["phone"] as? String
        creatorEntity.email = creator["email"] as? String
        creatorEntity.profileImage = creator["profileImage"] as? String
        creatorEntity.origin = Session.shared.readUserId()
        creatorEntity.todoCategory = todoCategory
        Session.shared.insertDBUser(creatorEntity)
    }
    
    func insertTodoCategory(_ todoCategory: PlanItTodoCategory, creator: PlanItUser?, using context: NSManagedObjectContext? = nil) {
        let objectContext = context ?? self.mainObjectContext
        let creatorEntity = todoCategory.createdBy ?? self.insertNewRecords(Table.planItCreator, context: objectContext) as! PlanItCreator
        creatorEntity.userName = creator?.userName
        creatorEntity.fullName = creator?.name
        creatorEntity.phone = creator?.phone
        creatorEntity.email = creator?.email
        creatorEntity.profileImage = creator?.imageUrl
        creatorEntity.origin = Session.shared.readUserId()
        creatorEntity.userId = Double(creator?.readValueOfUserId() ?? Strings.empty) ?? 0.0
        creatorEntity.todoCategory = todoCategory
        Session.shared.insertDBUser(creatorEntity)
    }
        
    func insertTodo(_ todo: PlanItTodo, creator: [String: Any], using context: NSManagedObjectContext? = nil) {
        let objectContext = context ?? self.mainObjectContext
        let creatorEntity = todo.createdBy ?? self.insertNewRecords(Table.planItCreator, context: objectContext) as! PlanItCreator
        creatorEntity.userId = creator["userId"] as? Double ?? 0
        creatorEntity.userName = creator["userName"] as? String
        creatorEntity.fullName = creator["fullName"] as? String
        creatorEntity.phone = creator["phone"] as? String
        creatorEntity.email = creator["email"] as? String
        creatorEntity.profileImage = creator["profileImage"] as? String
        creatorEntity.origin = Session.shared.readUserId()
        todo.isOwner = creatorEntity.readValueOfUserId() == creatorEntity.origin
        creatorEntity.todo = todo
        Session.shared.insertDBUser(creatorEntity)
    }
    
    func insertSubTodo(_ subTodo: PlanItSubTodo, creator: [String: Any], using context: NSManagedObjectContext? = nil) {
        let objectContext = context ?? self.mainObjectContext
        let creatorEntity = subTodo.createdBy ?? self.insertNewRecords(Table.planItCreator, context: objectContext) as! PlanItCreator
        creatorEntity.userId = creator["userId"] as? Double ?? 0
        creatorEntity.userName = creator["userName"] as? String
        creatorEntity.fullName = creator["fullName"] as? String
        creatorEntity.phone = creator["phone"] as? String
        creatorEntity.email = creator["email"] as? String
        creatorEntity.profileImage = creator["profileImage"] as? String
        creatorEntity.origin = Session.shared.readUserId()
        creatorEntity.subTodo = subTodo
        Session.shared.insertDBUser(creatorEntity)
    }
    
    func insertGiftCoupon(_ giftCoupon: PlanItGiftCoupon, creator: [String: Any], using context: NSManagedObjectContext? = nil) {
        let objectContext = context ?? self.mainObjectContext
        let creatorEntity = giftCoupon.createdBy ?? self.insertNewRecords(Table.planItCreator, context: objectContext) as! PlanItCreator
        creatorEntity.userId = creator["userId"] as? Double ?? 0
        creatorEntity.userName = creator["userName"] as? String
        creatorEntity.fullName = creator["fullName"] as? String
        creatorEntity.phone = creator["phone"] as? String
        creatorEntity.email = creator["email"] as? String
        creatorEntity.profileImage = creator["profileImage"] as? String
        creatorEntity.origin = Session.shared.readUserId()
        creatorEntity.giftCoupon = giftCoupon
        Session.shared.insertDBUser(creatorEntity)
    }
    
    func insertShop(_ shopList: PlanItShopList, creator: [String: Any], using context: NSManagedObjectContext? = nil) {
        let objectContext = context ?? self.mainObjectContext
        let creatorEntity = shopList.createdBy ?? self.insertNewRecords(Table.planItCreator, context: objectContext) as! PlanItCreator
        creatorEntity.userId = creator["userId"] as? Double ?? 0
        creatorEntity.userName = creator["userName"] as? String
        creatorEntity.fullName = creator["fullName"] as? String
        creatorEntity.phone = creator["phone"] as? String
        creatorEntity.email = creator["email"] as? String
        creatorEntity.profileImage = creator["profileImage"] as? String
        creatorEntity.origin = Session.shared.readUserId()
        creatorEntity.shop = shopList
        Session.shared.insertDBUser(creatorEntity)
    }
    
    func insertShop(_ shopList: PlanItShopList, creator: PlanItUser?, using context: NSManagedObjectContext? = nil) {
        let objectContext = context ?? self.mainObjectContext
        let creatorEntity = shopList.createdBy ?? self.insertNewRecords(Table.planItCreator, context: objectContext) as! PlanItCreator
        creatorEntity.userName = creator?.userName
        creatorEntity.fullName = creator?.name
        creatorEntity.phone = creator?.phone
        creatorEntity.email = creator?.email
        creatorEntity.profileImage = creator?.imageUrl
        creatorEntity.origin = Session.shared.readUserId()
        creatorEntity.userId = Double(creator?.readValueOfUserId() ?? Strings.empty) ?? 0.0
        creatorEntity.shop = shopList
        Session.shared.insertDBUser(creatorEntity)
    }
    
    func insertShopItem(_ shopItems: PlanItShopItems, creator: [String: Any], using context: NSManagedObjectContext? = nil) {
        let objectContext = context ?? self.mainObjectContext
        let creatorEntity = shopItems.createdBy ?? self.insertNewRecords(Table.planItCreator, context: objectContext) as! PlanItCreator
        creatorEntity.userId = creator["userId"] as? Double ?? 0
        creatorEntity.userName = creator["userName"] as? String
        creatorEntity.fullName = creator["fullName"] as? String
        creatorEntity.phone = creator["phone"] as? String
        creatorEntity.email = creator["email"] as? String
        creatorEntity.profileImage = creator["profileImage"] as? String
        creatorEntity.origin = Session.shared.readUserId()
        creatorEntity.shopItem = shopItems
        Session.shared.insertDBUser(creatorEntity)
    }
    
    func insertShopCategory(_ shopMainCategory: PlanItShopMainCategory, creator: [String: Any], using context: NSManagedObjectContext? = nil) {
        let objectContext = context ?? self.mainObjectContext
        let creatorEntity = shopMainCategory.createdBy ?? self.insertNewRecords(Table.planItCreator, context: objectContext) as! PlanItCreator
        creatorEntity.userId = creator["userId"] as? Double ?? 0
        creatorEntity.userName = creator["userName"] as? String
        creatorEntity.fullName = creator["fullName"] as? String
        creatorEntity.phone = creator["phone"] as? String
        creatorEntity.email = creator["email"] as? String
        creatorEntity.profileImage = creator["profileImage"] as? String
        creatorEntity.origin = Session.shared.readUserId()
        creatorEntity.shopMainCategory = shopMainCategory
        Session.shared.insertDBUser(creatorEntity)
    }
    
    func insertShopListItem(_ shopListItems: PlanItShopListItems, creator: PlanItUser?, using context: NSManagedObjectContext? = nil) {
        let objectContext = context ?? self.mainObjectContext
        let creatorEntity = shopListItems.createdBy ?? self.insertNewRecords(Table.planItCreator, context: objectContext) as! PlanItCreator
        creatorEntity.userName = creator?.userName
        creatorEntity.fullName = creator?.name
        creatorEntity.phone = creator?.phone
        creatorEntity.email = creator?.email
        creatorEntity.profileImage = creator?.imageUrl
        creatorEntity.origin = Session.shared.readUserId()
        creatorEntity.userId = Double(creator?.readValueOfUserId() ?? Strings.empty) ?? 0.0
        creatorEntity.shopListItem = shopListItems
        Session.shared.insertDBUser(creatorEntity)
    }
    
    func insertShopListItem(_ shopListItems: PlanItShopListItems, creator: [String: Any], using context: NSManagedObjectContext? = nil) {
        let objectContext = context ?? self.mainObjectContext
        let creatorEntity = shopListItems.createdBy ?? self.insertNewRecords(Table.planItCreator, context: objectContext) as! PlanItCreator
        creatorEntity.userId = creator["userId"] as? Double ?? 0
        creatorEntity.userName = creator["userName"] as? String
        creatorEntity.fullName = creator["fullName"] as? String
        creatorEntity.phone = creator["phone"] as? String
        creatorEntity.email = creator["email"] as? String
        creatorEntity.profileImage = creator["profileImage"] as? String
        creatorEntity.origin = Session.shared.readUserId()
        creatorEntity.shopListItem = shopListItems
        Session.shared.insertDBUser(creatorEntity)
    }
    
    func insertShopCategory(_ shopSubCategory: PlanItShopSubCategory, creator: [String: Any], using context: NSManagedObjectContext? = nil) {
        let objectContext = context ?? self.mainObjectContext
        let creatorEntity = shopSubCategory.createdBy ?? self.insertNewRecords(Table.planItCreator, context: objectContext) as! PlanItCreator
        creatorEntity.userId = creator["userId"] as? Double ?? 0
        creatorEntity.userName = creator["userName"] as? String
        creatorEntity.fullName = creator["fullName"] as? String
        creatorEntity.phone = creator["phone"] as? String
        creatorEntity.email = creator["email"] as? String
        creatorEntity.profileImage = creator["profileImage"] as? String
        creatorEntity.origin = Session.shared.readUserId()
        creatorEntity.shopSubCategory = shopSubCategory
        Session.shared.insertDBUser(creatorEntity)
    }
    
    func insertCreatedInvitees(_ invitees: PlanItInvitees, todo: PlanItTodo, creator: [String: Any], using context: NSManagedObjectContext? = nil) {
        let objectContext = context ?? self.mainObjectContext
        let creatorEntity = invitees.createdBy ?? self.insertNewRecords(Table.planItCreator, context: objectContext) as! PlanItCreator
        creatorEntity.userId = creator["userId"] as? Double ?? 0
        creatorEntity.userName = creator["userName"] as? String
        creatorEntity.fullName = creator["fullName"] as? String
        creatorEntity.phone = creator["phone"] as? String
        creatorEntity.email = creator["email"] as? String
        creatorEntity.profileImage = creator["profileImage"] as? String
        creatorEntity.origin = Session.shared.readUserId()
        creatorEntity.createdInvitee = invitees
        if creatorEntity.readValueOfUserId() == creatorEntity.origin {
            todo.isAssignedByMe = true
        }
        Session.shared.insertDBUser(creatorEntity)
    }
    
    func insertDashboard(_ dashboard: PlanItDashboard, creator: [String: Any], using context: NSManagedObjectContext? = nil) {
        let objectContext = context ?? self.mainObjectContext
        let creatorEntity = dashboard.createdBy ?? self.insertNewRecords(Table.planItCreator, context: objectContext) as! PlanItCreator
        creatorEntity.userId = creator["userId"] as? Double ?? 0
        creatorEntity.userName = creator["userName"] as? String
        creatorEntity.fullName = creator["fullName"] as? String
        creatorEntity.phone = creator["phone"] as? String
        creatorEntity.email = creator["email"] as? String
        creatorEntity.profileImage = creator["profileImage"] as? String
        creatorEntity.origin = Session.shared.readUserId()
        creatorEntity.dashboard = dashboard
        Session.shared.insertDBUser(creatorEntity)
    }
    
    func insertUserNotification(_ notification: PlanItUserNotification, creator: [String: Any], using context: NSManagedObjectContext? = nil) {
        let objectContext = context ?? self.mainObjectContext
        let creatorEntity = notification.createdBy ?? self.insertNewRecords(Table.planItCreator, context: objectContext) as! PlanItCreator
        creatorEntity.userId = creator["userId"] as? Double ?? 0
        creatorEntity.userName = creator["userName"] as? String
        creatorEntity.fullName = creator["fullName"] as? String
        creatorEntity.phone = creator["phone"] as? String
        creatorEntity.email = creator["email"] as? String
        creatorEntity.profileImage = creator["profileImage"] as? String
        creatorEntity.origin = Session.shared.readUserId()
        creatorEntity.userNotification = notification
        Session.shared.insertDBUser(creatorEntity)
    }
    
    func insertShareLink(_ shareLink: PlanItShareLink, creator: [String: Any], using context: NSManagedObjectContext? = nil) {
        let objectContext = context ?? self.mainObjectContext
        let creatorEntity = shareLink.createdBy ?? self.insertNewRecords(Table.planItCreator, context: objectContext) as! PlanItCreator
        creatorEntity.userId = creator["userId"] as? Double ?? 0
        creatorEntity.userName = creator["userName"] as? String
        creatorEntity.fullName = creator["fullName"] as? String
        creatorEntity.phone = creator["phone"] as? String
        creatorEntity.email = creator["email"] as? String
        creatorEntity.profileImage = creator["profileImage"] as? String
        creatorEntity.origin = Session.shared.readUserId()
        creatorEntity.shareLink = shareLink
        Session.shared.insertDBUser(creatorEntity)
    }
    
    func readAllUserCreator(using context: NSManagedObjectContext? = nil) -> [PlanItCreator] {
        let objectContext = context ?? self.mainObjectContext
        let predicate = NSPredicate(format: "origin == %@ AND userId <> %@", Session.shared.readUserId(), Session.shared.readUserId())
        return self.readRecords(fromCoreData: Table.planItCreator, predicate: predicate, context: objectContext) as! [PlanItCreator]
    }
}
