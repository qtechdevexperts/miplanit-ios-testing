//
//  DatabasePlanItShopList.swift
//  MiPlanIt
//
//  Created by Febin Paul on 10/05/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation
import CoreData

class DatabasePlanItShopList: DataBaseManager {
    
    func insertUserShopData(_ data: [[String: Any]], using context: NSManagedObjectContext? = nil) {
        let objectContext = context ?? self.mainObjectContext
        let localShops = self.readSpecificShopWithData(shops: data, using: objectContext)
        for eachShopList in data {
            let shpListId = eachShopList["shpListId"] as? Double ?? 0
            let appShopListId = eachShopList["appShpListId"] as? String ?? Strings.empty
            let shopListEntity = localShops.filter({ return ($0.shopListId == shpListId && shpListId != 0) || ($0.appShopListId == appShopListId && !appShopListId.isEmpty) }).first ?? self.insertNewRecords(Table.planItShopList, context: objectContext) as! PlanItShopList
            shopListEntity.shopListId = shpListId
            shopListEntity.userId = Session.shared.readUserId()
            shopListEntity.shopListName = eachShopList["shpListName"] as? String
            shopListEntity.shopListColor = eachShopList["shpListColourCode"] as? String
            shopListEntity.shopListImage = eachShopList["shpListImage"] as? String
            shopListEntity.dueDate = eachShopList["dueDate"] as? String
            shopListEntity.isCustom = false
            shopListEntity.isPending = false
            if let isDefaultList = eachShopList["isDefaultList"] as? Bool {
                shopListEntity.isCustom = !isDefaultList
            }
            if let date = eachShopList["createdAt"] as? String {
                shopListEntity.createdDate = date.stringToDate(formatter: DateFormatters.MMDDYYYYHMMSSA, timeZone: TimeZone(abbreviation: "UTC")!)
            }
            if let date = eachShopList["modifiedAt"] as? String {
                shopListEntity.modifiedAt = date.stringToDate(formatter: DateFormatters.MMDDYYYYHMMSSA, timeZone: TimeZone(abbreviation: "UTC")!)
            }
            if let createdBy = eachShopList["createdBy"] as? [String: Any] {
                DatabasePlanItCreator().insertShop(shopListEntity, creator: createdBy, using: objectContext)
            }
            if let modifiedBy = eachShopList["modifiedBy"] as? [String: Any] {
                DatabasePlanItModifier().insertShop(shopListEntity, modifier: modifiedBy, using: objectContext)
            }
            if let invitees = eachShopList["invitees"] as? [[String: Any]] {
                DatabasePlanItInvitees().insertShop(shopListEntity, invitees: invitees, using: objectContext)
            }
            if let nonRegInvitees = eachShopList["nonRegInvitees"] as? [[String: Any]] {
                DatabasePlanItInvitees().insertShop(shopListEntity, other: nonRegInvitees, using: objectContext)
            }
            if let shoppingItem = eachShopList["shoppingItem"] as? [[String: Any]], !shoppingItem.isEmpty {
                DatabasePlanItShopListItem().insertShopListItem(shoppingItem, planItShopList: shopListEntity, using: objectContext)
            }
            if let deletedlistDetailIds = eachShopList["deletedlistDetailIds"] as? [Double] {
                shopListEntity.deleteShopListItems(deletedlistDetailIds)
            }
        }
    }

    @discardableResult func insertOrUpdateShopList(_ data: [String: Any], updatePlanItShopListItem planItShopListItems: PlanItShopListItems? = nil, shopListItemDetailModel: ShopListItemDetailModel? = nil) -> PlanItShopList {
        let shopId = data["shpListId"] as? Double ?? 0
        let shopListEntity = self.readSpecificShopWithData(shops: [data]).first ?? self.insertNewRecords(Table.planItShopList, context: self.mainObjectContext) as! PlanItShopList
        shopListEntity.shopListId = shopId
        shopListEntity.shopListName = data["shpListName"] as? String
        shopListEntity.userId = Session.shared.readUserId()
        shopListEntity.isCustom = data["isDefaultList"] as? Bool ?? false
        shopListEntity.shopListColor = data["shpListColourCode"] as? String
        shopListEntity.dueDate = data["dueDate"] as? String
        shopListEntity.isPending = false
        if let date = data["createdAt"] as? String {
            shopListEntity.createdDate = date.stringToDate(formatter: DateFormatters.MMDDYYYYHMMSSA, timeZone: TimeZone(abbreviation: "UTC")!)
        }
        if let date = data["modifiedAt"] as? String {
            shopListEntity.modifiedAt = date.stringToDate(formatter: DateFormatters.MMDDYYYYHMMSSA, timeZone: TimeZone(abbreviation: "UTC")!)
        }
        if let createdBy = data["createdBy"] as? [String: Any] {
            DatabasePlanItCreator().insertShop(shopListEntity, creator: createdBy, using: self.mainObjectContext)
        }
        if let invitees = data["invitees"] as? [[String: Any]] {
            DatabasePlanItInvitees().insertShop(shopListEntity, invitees: invitees, using: self.mainObjectContext)
        }
        if let nonRegInvitees = data["nonRegInvitees"] as? [[String: Any]] {
            DatabasePlanItInvitees().insertShop(shopListEntity, other: nonRegInvitees, using: self.mainObjectContext)
        }
        if let modifiedBy = data["modifiedBy"] as? [String: Any] {
            DatabasePlanItModifier().insertShop(shopListEntity, modifier: modifiedBy, using: self.mainObjectContext)
        }
        if let shoppingItem = data["shoppingItem"] as? [[String: Any]], !shoppingItem.isEmpty {
            let shoppingListItems = DatabasePlanItShopListItem().insertShopListItem(shoppingItem, planItShopList: shopListEntity, updatePlanItShopListItems: planItShopListItems, using: self.mainObjectContext)
            shopListItemDetailModel?.planItShopListItem = shoppingListItems.first
        }
        if let deletedlistDetailIds = data["deletedlistDetailIds"] as? [Double] {
            shopListEntity.deleteShopListItems(deletedlistDetailIds)
        }
        self.mainObjectContext.saveContext()
        return shopListEntity
    }
    
    func inserShopListItemFromShopData(_ data: [String: Any]) -> PlanItShopListItems? {
        var insertedPlanItShopListItems: PlanItShopListItems?
        let shopId = data["shpListId"] as? Double ?? 0
        let shopListEntity = self.readSpecificShopWithData(shops: [data]).first ?? self.insertNewRecords(Table.planItShopList, context: self.mainObjectContext) as! PlanItShopList
        shopListEntity.shopListId = shopId
        shopListEntity.shopListName = data["shpListName"] as? String
        shopListEntity.userId = Session.shared.readUserId()
        shopListEntity.isCustom = data["isDefaultList"] as? Bool ?? false
        shopListEntity.shopListColor = data["shpListColourCode"] as? String
        shopListEntity.dueDate = data["dueDate"] as? String
        shopListEntity.isPending = false
        if let date = data["createdAt"] as? String {
            shopListEntity.createdDate = date.stringToDate(formatter: DateFormatters.MMDDYYYYHMMSSA, timeZone: TimeZone(abbreviation: "UTC")!)
        }
        if let date = data["modifiedAt"] as? String {
            shopListEntity.modifiedAt = date.stringToDate(formatter: DateFormatters.MMDDYYYYHMMSSA, timeZone: TimeZone(abbreviation: "UTC")!)
        }
        if let createdBy = data["createdBy"] as? [String: Any] {
            DatabasePlanItCreator().insertShop(shopListEntity, creator: createdBy, using: self.mainObjectContext)
        }
        if let invitees = data["invitees"] as? [[String: Any]] {
            DatabasePlanItInvitees().insertShop(shopListEntity, invitees: invitees, using: self.mainObjectContext)
        }
        if let nonRegInvitees = data["nonRegInvitees"] as? [[String: Any]] {
            DatabasePlanItInvitees().insertShop(shopListEntity, other: nonRegInvitees, using: self.mainObjectContext)
        }
        if let modifiedBy = data["modifiedBy"] as? [String: Any] {
            DatabasePlanItModifier().insertShop(shopListEntity, modifier: modifiedBy, using: self.mainObjectContext)
        }
        if let shoppingItem = data["shoppingItem"] as? [[String: Any]], !shoppingItem.isEmpty {
            let shoppingListItems = DatabasePlanItShopListItem().insertShopListItem(shoppingItem, planItShopList: shopListEntity)
            insertedPlanItShopListItems = shoppingListItems.first
        }
        self.mainObjectContext.saveContext()
        return insertedPlanItShopListItems
    }
    
    func insertOfflineShopList(_ shopList: ShopList, imageData: Data?) -> PlanItShopList {
        let shopListEntity = shopList.shopListData ?? self.insertNewRecords(Table.planItShopList, context: self.mainObjectContext) as! PlanItShopList
        shopListEntity.appShopListId = UUID().uuidString
        shopListEntity.shopListName = shopList.shopListName
        shopListEntity.userId = Session.shared.readUserId()
        shopListEntity.isCustom = true
        shopListEntity.isPending = true
        shopListEntity.shopListColor = shopList.shopColorCode
        shopListEntity.createdDate = Date()
        shopListEntity.modifiedAt = Date()
        shopListEntity.shopListImageData = imageData
        DatabasePlanItInvitees().insertShop(shopListEntity, invitees: shopList.shareInvitees, using: self.mainObjectContext)
        DatabasePlanItCreator().insertShop(shopListEntity, creator: Session.shared.readUser(), using: self.mainObjectContext)
        self.mainObjectContext.saveContext()
        return shopListEntity
    }
    
    func readAllUserShopList(using context: NSManagedObjectContext? = nil) -> [PlanItShopList] {
        let objectContext = context ?? self.mainObjectContext
        let predicate = NSPredicate(format: "userId == %@ AND deleteStatus == NO", Session.shared.readUserId())
        return self.readRecords(fromCoreData: Table.planItShopList, predicate: predicate, context: objectContext) as! [PlanItShopList]
    }
    
    func readSpecificShopWithData(shops: [[String: Any]], using context: NSManagedObjectContext? = nil) -> [PlanItShopList] {
        let objectContext = context ?? self.mainObjectContext
        let shopListIds = shops.compactMap({ return $0["shpListId"] as? Double })
        let appShopListIds: [String] = shops.compactMap({ if let appShopListId = $0["appShpListId"] as? String, !appShopListId.isEmpty { return appShopListId } else { return nil } })
        let predicate = NSPredicate(format: "userId == %@ AND (shopListId IN %@ OR appShopListId IN %@) AND deleteStatus == NO", Session.shared.readUserId(), shopListIds, appShopListIds)
        return self.readRecords(fromCoreData: Table.planItShopList, predicate: predicate, context: objectContext) as! [PlanItShopList]
    }
    
    func readSpecificShop(_ shops: [Double], using context: NSManagedObjectContext? = nil) -> [PlanItShopList] {
        let objectContext = context ?? self.mainObjectContext
        let predicate = NSPredicate(format: "userId == %@ AND shopListId IN %@", Session.shared.readUserId(), shops)
        return self.readRecords(fromCoreData: Table.planItShopList, predicate: predicate, context: objectContext) as! [PlanItShopList]
    }
    
    func readSpecificShopByName(_ shopName: String, exceptId: Double, using context: NSManagedObjectContext? = nil) -> [PlanItShopList] {
        let objectContext = context ?? self.mainObjectContext
        let predicate = NSPredicate(format: "userId == %@ AND deleteStatus == NO AND shopListName == %@ AND shopListId != %f", Session.shared.readUserId(), shopName, exceptId)
        return self.readRecords(fromCoreData: Table.planItShopList, predicate: predicate, context: objectContext) as! [PlanItShopList]
    }
    
    func readAllPendingShopList(using context: NSManagedObjectContext? = nil) -> [PlanItShopList] {
        let objectContext = context ?? self.mainObjectContext
        let predicate = NSPredicate(format: "userId == %@ AND isPending == YES AND deleteStatus == NO", Session.shared.readUserId())
        return self.readRecords(fromCoreData: Table.planItShopList, predicate: predicate, context: objectContext) as! [PlanItShopList]
    }
    
    func readAllPendingDeletedShopList(using context: NSManagedObjectContext? = nil) -> [PlanItShopList] {
        let objectContext = context ?? self.mainObjectContext
        let predicate = NSPredicate(format: "userId == %@ AND isPending == YES AND deleteStatus == YES", Session.shared.readUserId())
        return self.readRecords(fromCoreData: Table.planItShopList, predicate: predicate, context: objectContext) as! [PlanItShopList]
    }
    
    func removePlanItShopingList(_ shoppingList: [Double], using context: NSManagedObjectContext? = nil) {
        let objectContext = context ?? self.mainObjectContext
        let localShoppingList = self.readSpecificShop(shoppingList, using: objectContext)
        localShoppingList.forEach({ objectContext.delete($0) })
        objectContext.saveContext()
    }
    
    @discardableResult func deleteSpecificShop(_ shopsId: Double ) -> PlanItShopList? {
        if let shopData = self.readSpecificShop([shopsId]).first {
            self.mainObjectContext.delete(shopData)
            self.mainObjectContext.saveContext()
            return shopData
        }
        return nil
    }
}

