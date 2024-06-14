//
//  DatabasePlanItShopItem.swift
//  MiPlanIt
//
//  Created by Febin Paul on 09/05/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation
import CoreData

class DatabasePlanItShopItems: DataBaseManager {
    
    func inserMasterCategoryItems(_ items: [[String: Any]], using context: NSManagedObjectContext? = nil) {
        let objectContext = context ?? self.mainObjectContext
        let masterItemsIds = items.compactMap({ return $0["itemId"] as? Double })
        let localMasterShopItems = self.readSpecificMasterShopItem(masterItemsIds, using: objectContext)
        for eachItem in items {
            let itemId = eachItem["itemId"] as? Double ?? 0
            let shopItemEntity = localMasterShopItems.filter({ return $0.masterItemId == itemId }).first ?? self.insertNewRecords(Table.planItShopItems, context: objectContext) as! PlanItShopItems
            shopItemEntity.masterItemId = itemId
            shopItemEntity.isCustom = false
            shopItemEntity.userId = Session.shared.readUserId()
            shopItemEntity.itemName = eachItem["itemName"] as? String
            shopItemEntity.isItemNameUpdated = false
            shopItemEntity.masterCategoryIdLocal = eachItem["prodCatId"] as? Double ?? 0
            shopItemEntity.masterSubCategoryIdLocal = eachItem["prodSubCatId"] as? Double ?? 0
            shopItemEntity.userCategoryIdLocal = eachItem["userProdCatId"] as? Double ?? 0
            shopItemEntity.masterCategoryId = eachItem["prodCatId"] as? Double ?? 0
            shopItemEntity.masterCategoryName = eachItem["prodCat"] as? String
            shopItemEntity.masterSubCategoryId = eachItem["prodSubCatId"] as? Double ?? 0
            shopItemEntity.masterSubCategoryName = eachItem["prodSubCatName"] as? String
            shopItemEntity.userCategoryId = eachItem["userProdCatId"] as? Double ?? 0
            shopItemEntity.appShopCategoryId = Strings.empty
            shopItemEntity.userCategoryName = eachItem["userProdCat"] as? String
            shopItemEntity.itemImage = eachItem["itemImage"] as? String
            shopItemEntity.itemColor = eachItem["itemColourCode"] as? String
            shopItemEntity.createdAt = eachItem["createdAt"] as? String
            shopItemEntity.isPending = false
        }
    }
    
    func inserUserCategoryItems(_ items: [[String: Any]], hardSave: Bool, using context: NSManagedObjectContext? = nil) {
        let objectContext = context ?? self.mainObjectContext
        let localUserShopItems = self.readShopItemWithIds(shopItems: items, using: objectContext)
        for eachItem in items {
            let itemId = eachItem["userItemId"] as? Double ?? 0
            let appShopListItemId = eachItem["appUserItemId"] as? String ?? Strings.empty
            let shopItemEntity = localUserShopItems.filter({ return ($0.userItemId == itemId && itemId != 0) || ($0.appShopItemId == appShopListItemId && !appShopListItemId.isEmpty) }).first ?? self.insertNewRecords(Table.planItShopItems, context: objectContext) as! PlanItShopItems
            shopItemEntity.userItemId = itemId
            shopItemEntity.isCustom = true
            shopItemEntity.userId = Session.shared.readUserId()
            shopItemEntity.itemName = eachItem["userItemName"] as? String
            shopItemEntity.isItemNameUpdated = false
            shopItemEntity.masterCategoryIdLocal = eachItem["prodCatId"] as? Double ?? 0
            shopItemEntity.masterSubCategoryIdLocal = eachItem["prodSubCatId"] as? Double ?? 0
            shopItemEntity.userCategoryIdLocal = eachItem["userProdCatId"] as? Double ?? 0
            shopItemEntity.masterCategoryId = eachItem["prodCatId"] as? Double ?? 0
            shopItemEntity.masterCategoryName = eachItem["prodCat"] as? String
            shopItemEntity.masterSubCategoryId = eachItem["prodSubCatId"] as? Double ?? 0
            shopItemEntity.masterSubCategoryName = eachItem["prodSubCatName"] as? String
            shopItemEntity.userCategoryId = eachItem["userProdCatId"] as? Double ?? 0
            shopItemEntity.appShopCategoryId = Strings.empty
            shopItemEntity.userCategoryName = eachItem["userProdCat"] as? String
            shopItemEntity.itemImage = eachItem["userItemImage"] as? String
            shopItemEntity.itemColor = eachItem["userItemColourCode"] as? String
            shopItemEntity.isPending = false
            if let createdBy = eachItem["createdBy"] as? [String: Any] {
                DatabasePlanItCreator().insertShopItem(shopItemEntity, creator: createdBy, using: objectContext)
            }
        }
        if hardSave { objectContext.saveContext() }
    }

    func insertShopItem(_ item: [String: Any], using context: NSManagedObjectContext? = nil) -> PlanItShopItems {
        let objectContext = context ?? self.mainObjectContext
        let masterItem = item["itemId"] as? Double ?? 0
        let localMasterShopItems = self.readSpecificMasterShopItem([masterItem], using: objectContext)
        let shopItemEntity = localMasterShopItems.filter({ return $0.masterItemId == masterItem }).first ?? self.insertNewRecords(Table.planItShopItems, context: objectContext) as! PlanItShopItems
        shopItemEntity.masterItemId = masterItem
        shopItemEntity.isCustom = false
        shopItemEntity.userId = Session.shared.readUserId()
        shopItemEntity.itemName = item["itemName"] as? String
        shopItemEntity.isItemNameUpdated = false
        shopItemEntity.masterCategoryIdLocal = item["prodCatId"] as? Double ?? 0
        shopItemEntity.masterSubCategoryIdLocal = item["prodSubCatId"] as? Double ?? 0
        shopItemEntity.userCategoryIdLocal = item["userProdCatId"] as? Double ?? 0
        shopItemEntity.masterCategoryId = item["prodCatId"] as? Double ?? 0
        shopItemEntity.masterCategoryName = item["prodCat"] as? String
        shopItemEntity.masterSubCategoryId = item["prodSubCatId"] as? Double ?? 0
        shopItemEntity.masterSubCategoryName = item["prodSubCatName"] as? String
        shopItemEntity.userCategoryId = item["userProdCatId"] as? Double ?? 0
        shopItemEntity.appShopCategoryId = Strings.empty
        shopItemEntity.userCategoryName = item["userProdCat"] as? String
        shopItemEntity.itemImage = item["itemImage"] as? String
        shopItemEntity.itemColor = item["itemColourCode"] as? String
        shopItemEntity.createdAt = item["createdAt"] as? String
        shopItemEntity.isPending = false
        return shopItemEntity
    }
    
    func insertUserShopItem(_ item: [String: Any], using context: NSManagedObjectContext? = nil) -> PlanItShopItems {
        let objectContext = context ?? self.mainObjectContext
        let itemId = item["userItemId"] as? Double ?? 0
        let appShopListItemId = item["appUserItemId"] as? String ?? Strings.empty
        let localUserShopItems = self.readShopItemWithIds(shopItems: [item], using: objectContext)
        let shopItemEntity = localUserShopItems.filter({ return ($0.userItemId == itemId && itemId != 0) || ($0.appShopItemId == appShopListItemId && !appShopListItemId.isEmpty) }).first ?? self.insertNewRecords(Table.planItShopItems, context: objectContext) as! PlanItShopItems
        shopItemEntity.userItemId = itemId
        shopItemEntity.isCustom = true
        shopItemEntity.userId = Session.shared.readUserId()
        shopItemEntity.itemName = item["userItemName"] as? String
        shopItemEntity.isItemNameUpdated = false
        shopItemEntity.masterCategoryIdLocal = item["prodCatId"] as? Double ?? 0
        shopItemEntity.masterSubCategoryIdLocal = item["prodSubCatId"] as? Double ?? 0
        shopItemEntity.userCategoryIdLocal = item["userProdCatId"] as? Double ?? 0
        shopItemEntity.masterCategoryId = item["prodCatId"] as? Double ?? 0
        shopItemEntity.masterCategoryName = item["prodCat"] as? String
        shopItemEntity.masterSubCategoryId = item["prodSubCatId"] as? Double ?? 0
        shopItemEntity.masterSubCategoryName = item["prodSubCatName"] as? String
        shopItemEntity.userCategoryId = item["userProdCatId"] as? Double ?? 0
        shopItemEntity.appShopCategoryId = Strings.empty
        shopItemEntity.userCategoryName = item["userProdCat"] as? String
        shopItemEntity.itemImage = item["userItemImage"] as? String
        shopItemEntity.itemColor = item["userItemColourCode"] as? String
        shopItemEntity.isPending = false
        if let createdBy = item["createdBy"] as? [String: Any] {
            DatabasePlanItCreator().insertShopItem(shopItemEntity, creator: createdBy, using: objectContext)
        }
        return shopItemEntity
    }
    
    func insertUserShopItemOffline(shopListItemDetailModel: ShopListItemDetailModel) -> PlanItShopItems {
        var shopItemEntity: PlanItShopItems!
        if let appShopItemId = shopListItemDetailModel.planItShopListItem?.appShopItemId, !appShopItemId.isEmpty, let planItShopListItem = shopListItemDetailModel.planItShopListItem, planItShopListItem.readShopItemIdValue() == 0.0 {
             shopItemEntity = self.readSpecificAppShopItem(appShopItemId).first
        }
        else if let appShopItemId = shopListItemDetailModel.planItShopItem?.appShopItemId, !appShopItemId.isEmpty, let planItShopListItem = shopListItemDetailModel.planItShopListItem, planItShopListItem.readShopItemIdValue() == 0.0 {
            shopItemEntity = self.readSpecificAppShopItem(appShopItemId).first
        }
        else if let planItShopListItem = shopListItemDetailModel.planItShopListItem, planItShopListItem.isShopCustomItem {
            shopItemEntity = self.readSpecificUserShopItem([planItShopListItem.shopItemId]).first
        }
        else if let planItShopListItem = shopListItemDetailModel.planItShopListItem, !planItShopListItem.isShopCustomItem {
            shopItemEntity = self.readSpecificMasterShopItem([planItShopListItem.shopItemId]).first
        }
        if shopItemEntity == nil {
            shopItemEntity = self.insertNewRecords(Table.planItShopItems, context: self.mainObjectContext) as? PlanItShopItems
            shopItemEntity.appShopItemId = UUID().uuidString
            shopItemEntity.isCustom = true
            shopItemEntity.isPending = true
        }
        shopItemEntity.userId = Session.shared.readUserId()
        if shopItemEntity.readUserItemIdValue() == 0.0 {
            shopItemEntity.isItemNameUpdated = false
            shopItemEntity.itemName = shopListItemDetailModel.itemName
        }
        else if shopListItemDetailModel.itemName != shopItemEntity.readItemName() {
            shopItemEntity.isItemNameUpdated = true
            shopItemEntity.itemName = shopListItemDetailModel.itemName
        }
        shopItemEntity.masterCategoryIdLocal = shopListItemDetailModel.masterCategoryId
        shopItemEntity.masterSubCategoryIdLocal = shopListItemDetailModel.masterSubCategoryId
        shopItemEntity.userCategoryIdLocal = shopListItemDetailModel.userCategoryId
        shopItemEntity.appShopCategoryId = shopListItemDetailModel.appCategoryId
        shopItemEntity.masterCategoryName = Strings.empty
        shopItemEntity.userCategoryName = Strings.empty
        if shopListItemDetailModel.masterCategoryId != 0 {
            shopItemEntity.masterCategoryName = shopListItemDetailModel.categoryName
        }
        else if shopListItemDetailModel.masterSubCategoryId != 0 {
            shopItemEntity.masterSubCategoryName = shopListItemDetailModel.categoryName
        }
        else if shopListItemDetailModel.userCategoryId != 0 {
            shopItemEntity.userCategoryName = shopListItemDetailModel.categoryName
        }
        else if !shopListItemDetailModel.appCategoryId.isEmpty {
            shopItemEntity.userCategoryName = shopListItemDetailModel.categoryName
        }
        return shopItemEntity
    }
    
    func updateCategoryToOthers(shopItems: [PlanItShopItems], forceSave isHard: Bool = true) {
        shopItems.forEach { (shopItem) in
            shopItem.masterCategoryIdLocal = 1
            shopItem.masterCategoryName = Strings.shopOtherCategoryName
            shopItem.userCategoryIdLocal = 0
            shopItem.userCategoryName = Strings.empty
        }
        if isHard { self.mainObjectContext.saveContext() }
    }
    
    func updateShopItemCategorynameWith(category planItCategory: PlanItShopMainCategory) {
        if planItCategory.isPending {
            self.readAllShopItemOfAppUserCategory([planItCategory.readUserAppCategoryId()]).forEach { (shopItem) in
                shopItem.userCategoryName = planItCategory.readCategoryName()
            }
        }
        else {
            self.readAllShopItemOfUserCategory([planItCategory.readUserCategoryIdValue()]).forEach { (shopItem) in
                shopItem.userCategoryName = planItCategory.readCategoryName()
            }
        }
        self.mainObjectContext.saveContext()
    }
    
    func deleteShopListMasterItems(_ ids: [Double], using context: NSManagedObjectContext? = nil) {
        let objectContext = context ?? self.mainObjectContext
        self.readSpecificMasterShopItem(ids, using: objectContext).forEach { (planItShopItem) in
            planItShopItem.deleteItSelf()
        }
    }
    
    func readShopItemWithIds(shopItems: [[String: Any]], using context: NSManagedObjectContext? = nil) -> [PlanItShopItems] {
        let objectContext = context ?? self.mainObjectContext
        let shopItemIds = shopItems.compactMap({ return $0["userItemId"] as? Double })
        let appShopItemIds: [String] = shopItems.compactMap({ if let appUserItemId = $0["appUserItemId"] as? String, !appUserItemId.isEmpty { return appUserItemId } else { return nil } })
        let predicate = NSPredicate(format: "userId == %@ AND (userItemId IN %@ OR appShopItemId IN %@)", Session.shared.readUserId(), shopItemIds, appShopItemIds)
         return self.readRecords(fromCoreData: Table.planItShopItems, predicate: predicate, context: objectContext) as! [PlanItShopItems]
    }
    
    func readSpecificMasterShopItem(_ itemIds: [Double], using context: NSManagedObjectContext? = nil) -> [PlanItShopItems] {
        let objectContext = context ?? self.mainObjectContext
        let predicate = NSPredicate(format: "userId == %@ AND isCustom == NO AND masterItemId IN %@", Session.shared.readUserId(), itemIds)
        return self.readRecords(fromCoreData: Table.planItShopItems, predicate: predicate, context: objectContext) as! [PlanItShopItems]
    }
    
    func readSpecificUserShopItem(_ itemIds: [Double], using context: NSManagedObjectContext? = nil) -> [PlanItShopItems] {
        let objectContext = context ?? self.mainObjectContext
        let predicate = NSPredicate(format: "userId == %@ AND isCustom == YES AND userItemId IN %@", Session.shared.readUserId(), itemIds)
        return self.readRecords(fromCoreData: Table.planItShopItems, predicate: predicate, context: objectContext) as! [PlanItShopItems]
    }
    
    func readSpecificAppShopItem(_ itemId: String, using context: NSManagedObjectContext? = nil) -> [PlanItShopItems] {
        let objectContext = context ?? self.mainObjectContext
        let predicate = NSPredicate(format: "userId == %@ AND isCustom == YES AND appShopItemId == %@", Session.shared.readUserId(), itemId)
        return self.readRecords(fromCoreData: Table.planItShopItems, predicate: predicate, context: objectContext) as! [PlanItShopItems]
    }
    
    func readContainShopItemOfName(_ text: String, planItShopItem: PlanItShopItems?, context: NSManagedObjectContext? = nil) -> Bool {
        let objectContext = context ?? self.mainObjectContext
        let predicate: NSPredicate = NSPredicate(format: "userId == %@ AND itemName == [c] %@", Session.shared.readUserId(), text)
        let planItShopItems = self.readRecords(fromCoreData: Table.planItShopItems, predicate: predicate, context: objectContext) as! [PlanItShopItems]
        if let shopItem = planItShopItem {
            return !planItShopItems.filter({ if shopItem.isPending { return $0.appShopItemId != shopItem.appShopItemId } else { return shopItem.isCustom ? ($0.userItemId != shopItem.userItemId) : ($0.masterItemId != shopItem.masterItemId) }   }).isEmpty
        }
        return !planItShopItems.isEmpty
    }
    
    func readAllShopItem(_ context: NSManagedObjectContext? = nil) -> [PlanItShopItems] {
        let objectContext = context ?? self.mainObjectContext
        let predicate = NSPredicate(format: "userId == %@", Session.shared.readUserId())
        return self.readRecords(fromCoreData: Table.planItShopItems, predicate: predicate, context: objectContext) as! [PlanItShopItems]
    }
    
    func readAllShopItemOfMasterCategory(_ categoryIds: [Double], using context: NSManagedObjectContext? = nil) -> [PlanItShopItems] {
        let objectContext = context ?? self.mainObjectContext
        let predicate = NSPredicate(format: "userId == %@ AND masterCategoryIdLocal IN %@ AND masterSubCategoryIdLocal == 0", Session.shared.readUserId(), categoryIds)
        return self.readRecords(fromCoreData: Table.planItShopItems, predicate: predicate, sortDescriptor: ["itemName"], ascending: true, context: objectContext) as! [PlanItShopItems]
    }
    
    func readAllShopItemOfMasterSubCategory(_ categoryIds: [Double], using context: NSManagedObjectContext? = nil) -> [PlanItShopItems] {
        let objectContext = context ?? self.mainObjectContext
        let predicate = NSPredicate(format: "userId == %@ AND masterSubCategoryIdLocal IN %@", Session.shared.readUserId(), categoryIds)
        return self.readRecords(fromCoreData: Table.planItShopItems, predicate: predicate, sortDescriptor: ["itemName"], ascending: true, context: objectContext) as! [PlanItShopItems]
    }
    
    func readAllShopItemOfUserCategory(_ categoryIds: [Double], using context: NSManagedObjectContext? = nil) -> [PlanItShopItems] {
        let objectContext = context ?? self.mainObjectContext
        let predicate = NSPredicate(format: "userId == %@ AND (userCategoryId IN %@ OR userCategoryIdLocal IN %@)", Session.shared.readUserId(), categoryIds, categoryIds)
        return self.readRecords(fromCoreData: Table.planItShopItems, predicate: predicate, context: objectContext) as! [PlanItShopItems]
    }
    
    func readAllShopItemOfUserCategoryData(_ categoryDatas: [[String: Any]], using context: NSManagedObjectContext? = nil) -> [PlanItShopItems] {
        let objectContext = context ?? self.mainObjectContext
        let userProdCatIds = categoryDatas.compactMap({ return $0["userProdCat"] as? Double })
        let appUserProdCatIds: [String] = categoryDatas.compactMap({ if let appUserProdCatId = $0["appUserProdCatId"] as? String, !appUserProdCatId.isEmpty { return appUserProdCatId } else { return nil } })
        let predicate = NSPredicate(format: "userId == %@ AND (userCategoryId IN %@ OR appShopCategoryId IN %@)", Session.shared.readUserId(), userProdCatIds, appUserProdCatIds)
        return self.readRecords(fromCoreData: Table.planItShopItems, predicate: predicate, context: objectContext) as! [PlanItShopItems]
    }
    
    func readAllShopItemOfAppUserCategory(_ appCategoryIds: [String], using context: NSManagedObjectContext? = nil) -> [PlanItShopItems] {
        let objectContext = context ?? self.mainObjectContext
        let predicate = NSPredicate(format: "userId == %@ AND appShopCategoryId IN %@", Session.shared.readUserId(), appCategoryIds)
        return self.readRecords(fromCoreData: Table.planItShopItems, predicate: predicate, context: objectContext) as! [PlanItShopItems]
    }
}
