//
//  DatabasePlanItTags.swift
//  MiPlanIt
//
//  Created by Febin Paul on 28/04/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation
import CoreData

class DatabasePlanItTags: DataBaseManager {
    
    func insertTags(_ tags: [PlanItTags], for event: PlanItEvent, using context: NSManagedObjectContext? = nil) {
        event.deleteAllTags()
        let objectContext = context ?? self.mainObjectContext
        for eachTag in tags {
            let tagEntity = self.insertNewRecords(Table.planItTags, context: objectContext) as! PlanItTags
            tagEntity.tag = eachTag.tag
            tagEntity.userId = Session.shared.readUserId()
            tagEntity.event = event
        }
    }

    func insertTags(_ tags: [String], for event: PlanItEvent, using context: NSManagedObjectContext? = nil) {
        event.deleteAllTags()
        let objectContext = context ?? self.mainObjectContext
        for eachTag in tags {
            let tagEntity = self.insertNewRecords(Table.planItTags, context: objectContext) as! PlanItTags
            tagEntity.tag = eachTag
            tagEntity.userId = Session.shared.readUserId()
            tagEntity.event = event
        }
    }
    
    func insertTags(_ tags: [String], for purchase: PlanItPurchase, using context: NSManagedObjectContext? = nil) {
        purchase.deleteAllTags()
        let objectContext = context ?? self.mainObjectContext
        for eachTag in tags {
            let tagEntity = self.insertNewRecords(Table.planItTags, context: objectContext) as! PlanItTags
            tagEntity.tag = eachTag
            tagEntity.userId = Session.shared.readUserId()
            tagEntity.purchase = purchase
        }
    }
    
    func insertTags(_ tags: [String], for todo: PlanItTodo, using context: NSManagedObjectContext? = nil) {
        todo.deleteAllTags()
        let objectContext = context ?? self.mainObjectContext
        for eachTag in tags {
            let tagEntity = self.insertNewRecords(Table.planItTags, context: objectContext) as! PlanItTags
            tagEntity.tag = eachTag
            tagEntity.userId = Session.shared.readUserId()
            tagEntity.todo = todo
        }
    }
    
    func insertTags(_ tags: [String], for giftCoupon: PlanItGiftCoupon, using context: NSManagedObjectContext? = nil) {
        giftCoupon.deleteAllTags()
        let objectContext = context ?? self.mainObjectContext
        for eachTag in tags {
            let tagEntity = self.insertNewRecords(Table.planItTags, context: objectContext) as! PlanItTags
            tagEntity.tag = eachTag
            tagEntity.userId = Session.shared.readUserId()
            tagEntity.giftCoupon = giftCoupon
        }
    }
    
    func insertTags(_ tags: [String], for shopListItem: PlanItShopListItems, using context: NSManagedObjectContext? = nil) {
        shopListItem.deleteAllTags()
        let objectContext = context ?? self.mainObjectContext
        for eachTag in tags {
            let tagEntity = self.insertNewRecords(Table.planItTags, context: objectContext) as! PlanItTags
            tagEntity.tag = eachTag
            tagEntity.userId = Session.shared.readUserId()
            tagEntity.shopListItems = shopListItem
        }
    }
    
    func insertTags(_ tags: [String], for dashboard: PlanItDashboard, using context: NSManagedObjectContext? = nil) {
        dashboard.deleteAllTags()
        let objectContext = context ?? self.mainObjectContext
        for eachTag in tags {
            let tagEntity = self.insertNewRecords(Table.planItTags, context: objectContext) as! PlanItTags
            tagEntity.tag = eachTag
            tagEntity.userId = Session.shared.readUserId()
            tagEntity.dashboard = dashboard
        }
    }
    
    func insertTags(_ tags: [String], for shareLink: PlanItShareLink, using context: NSManagedObjectContext? = nil) {
        shareLink.deleteAllTags()
        let objectContext = context ?? self.mainObjectContext
        for eachTag in tags {
            let tagEntity = self.insertNewRecords(Table.planItTags, context: objectContext) as! PlanItTags
            tagEntity.tag = eachTag
            tagEntity.userId = Session.shared.readUserId()
            tagEntity.shareLink = shareLink
        }
    }
    
    func readAllTags(using context: NSManagedObjectContext? = nil) -> [PlanItTags] {
        let objectContext = context ?? self.mainObjectContext
        let predicate = NSPredicate(format: "userId == %@", Session.shared.readUserId())
        return self.readRecords(fromCoreData: Table.planItTags, predicate: predicate, context: objectContext) as! [PlanItTags]
    }
}
