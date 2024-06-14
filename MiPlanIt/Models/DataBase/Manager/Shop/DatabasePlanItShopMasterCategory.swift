//
//  DatabasePlanItShopMainCategory.swift
//  MiPlanIt
//
//  Created by Febin Paul on 09/11/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation
import CoreData

class DatabasePlanItShopMasterCategory: DataBaseManager {
    
    func insertMasterCategory(_ data: [[String: Any]], using context: NSManagedObjectContext? = nil) {
        let objectContext = context ?? self.mainObjectContext
        let masterCategoryIds = data.compactMap({ return $0["prodCatId"] as? Double })
        let localMasterCategories = self.readSpecificMasterShopCategory(masterCategoryIds, using: objectContext)
        for shopCategory in data {
            let prodCatId = shopCategory["prodCatId"] as? Double ?? 0
            let shopMainCategoryEntity = localMasterCategories.filter({ return $0.masterCategoryId == prodCatId }).first ?? self.insertNewRecords(Table.planItShopMainCategory, context: objectContext) as! PlanItShopMainCategory
            shopMainCategoryEntity.masterCategoryId = prodCatId
            shopMainCategoryEntity.name = shopCategory["prodCat"] as? String
            shopMainCategoryEntity.isCustom = false
            shopMainCategoryEntity.userId = Session.shared.readUserId()
            shopMainCategoryEntity.orderId = Double(shopCategory["orderId"] as? Int ?? 0)
            if let createdBy = shopCategory["createdBy"] as? [String: Any] {
                DatabasePlanItCreator().insertShopCategory(shopMainCategoryEntity, creator: createdBy, using: objectContext)
            }
            if let subCategorys = shopCategory["subCategory"] as? [[String: Any]] {
                DatabasePlanItShopSubCategory().insertOrUpdateShopSubCategory(subCategorys, parentCategory: shopMainCategoryEntity, using: objectContext)
            }
        }
    }
    
    func insertShopUserCategory(_ data: [[String: Any]], using context: NSManagedObjectContext? = nil) {
        let objectContext = context ?? self.mainObjectContext
        let localUserCategoryIds = self.readSpecificShopCategoryWithData(shops: data, using: objectContext)
        for shopCategory in data {
            let userProdCatId = shopCategory["userProdCatId"] as? Double ?? 0
            let appShopCategoryId = shopCategory["appShopCategoryId"] as? String ?? Strings.empty
            let shopMainCategoryEntity = localUserCategoryIds.filter({ return $0.userCategoryId == userProdCatId || (!appShopCategoryId.isEmpty && appShopCategoryId == $0.appShopCategoryId) }).first ?? self.insertNewRecords(Table.planItShopMainCategory, context: objectContext) as! PlanItShopMainCategory
            shopMainCategoryEntity.userCategoryId = userProdCatId
            shopMainCategoryEntity.name = shopCategory["userProdCat"] as? String
            shopMainCategoryEntity.isCustom = true
            shopMainCategoryEntity.userId = Session.shared.readUserId()
            shopMainCategoryEntity.createdAt = shopCategory["createdAt"] as? String
            shopMainCategoryEntity.isPending = false
            shopMainCategoryEntity.appShopCategoryId = appShopCategoryId
            if let createdBy = shopCategory["createdBy"] as? [String: Any] {
                DatabasePlanItCreator().insertShopCategory(shopMainCategoryEntity, creator: createdBy, using: objectContext)
            }
            if let subCategorys = shopCategory["subCategory"] as? [[String: Any]] {
                DatabasePlanItShopSubCategory().insertOrUpdateShopSubCategory(subCategorys, parentCategory: shopMainCategoryEntity, using: objectContext)
            }
        }
    }
    
    func insertOrUpdateShopCategory(_ data: [String: Any]) -> PlanItShopMainCategory {
        let categoryId = data["userProdCatId"] as? Double ?? 0
        let shopMainCategoryEntity = self.readSpecificShopCategoryWithData(shops: [data]).first ?? self.insertNewRecords(Table.planItShopMainCategory, context: self.mainObjectContext) as! PlanItShopMainCategory
        shopMainCategoryEntity.userCategoryId = categoryId
        shopMainCategoryEntity.appShopCategoryId = data["appUserProdCatId"] as? String
        shopMainCategoryEntity.userId = Session.shared.readUserId()
        shopMainCategoryEntity.isCustom = data["isDefaultList"] as? Bool ?? true
        shopMainCategoryEntity.createdAt = data["createdAt"] as? String
        shopMainCategoryEntity.name = data["userProdCat"] as? String
        shopMainCategoryEntity.isPending = false
        if let createdBy = data["createdBy"] as? [String: Any] {
            DatabasePlanItCreator().insertShopCategory(shopMainCategoryEntity, creator: createdBy, using: self.mainObjectContext)
        }
        let shopItems = DatabasePlanItShopItems().readAllShopItemOfUserCategoryData([data])
        shopItems.forEach { (shopItem) in
            shopItem.userCategoryId = categoryId
            shopItem.userCategoryIdLocal = categoryId
            shopItem.userCategoryName = data["userProdCat"] as? String
        }
        self.mainObjectContext.saveContext()
        return shopMainCategoryEntity
    }
    
    func insertOfflineShopCategory(name: String) -> PlanItShopMainCategory {
        let shopMainCategoryEntity = self.insertNewRecords(Table.planItShopMainCategory, context: self.mainObjectContext) as! PlanItShopMainCategory
        shopMainCategoryEntity.isPending = true
        shopMainCategoryEntity.appShopCategoryId = UUID().uuidString
        shopMainCategoryEntity.isCustom = true
        shopMainCategoryEntity.userId = Session.shared.readUserId()
        shopMainCategoryEntity.name = name
        self.mainObjectContext.saveContext()
        return shopMainCategoryEntity
    }
    
    func updateShopItemOfDeletedShopCategory(category: PlanItShopMainCategory, isHard: Bool = true) {
        var shopItems: [PlanItShopItems] = []
        if category.readUserCategoryIdValue() != 0 {
            shopItems = DatabasePlanItShopItems().readAllShopItemOfUserCategory([category.readUserCategoryIdValue()])
        }
        else {
            shopItems = DatabasePlanItShopItems().readAllShopItemOfAppUserCategory([category.readUserAppCategoryId()])
        }
        DatabasePlanItShopItems().updateCategoryToOthers(shopItems: shopItems, forceSave: false)
    }
    
    func deleteShopCategorys(_ categorys: [PlanItShopMainCategory]) {
        categorys.forEach { (category) in
            self.updateShopItemOfDeletedShopCategory(category: category, isHard: false)
            self.mainObjectContext.delete(category)
        }
        self.mainObjectContext.saveContext()
    }
    
    func deleteShopCategorysOffline(_ categorys: [PlanItShopMainCategory]) {
        categorys.forEach { (category) in
            self.updateShopItemOfDeletedShopCategory(category: category, isHard: false)
            category.isPending = true
            category.deletedStatus = true
        }
        self.mainObjectContext.saveContext()
    }
    
    func updateOfflineShopCategory(category: PlanItShopMainCategory, name: String) {
        category.isPending = true
        category.name = name
        self.mainObjectContext.saveContext()
    }
    
    func readSpecificMasterShopCategory(_ categoryIds: [Double], using context: NSManagedObjectContext? = nil) -> [PlanItShopMainCategory] {
        let objectContext = context ?? self.mainObjectContext
        let predicate = NSPredicate(format: "userId == %@ AND masterCategoryId IN %@", Session.shared.readUserId(), categoryIds)
        return self.readRecords(fromCoreData: Table.planItShopMainCategory, predicate: predicate, context: objectContext) as! [PlanItShopMainCategory]
    }
    
    func readSpecificShopCategoryWithData(shops: [[String: Any]], using context: NSManagedObjectContext? = nil) -> [PlanItShopMainCategory] {
        let objectContext = context ?? self.mainObjectContext
        let shopCategoryIds = shops.compactMap({ return $0["userProdCatId"] as? Double })
        let appShopCategoryIds: [String] = shops.compactMap({ if let appShopCategoryId = $0["appUserProdCatId"] as? String, !appShopCategoryId.isEmpty { return appShopCategoryId } else { return nil } })
        let predicate = NSPredicate(format: "userId == %@ AND (userCategoryId IN %@ OR appShopCategoryId IN %@)", Session.shared.readUserId(), shopCategoryIds, appShopCategoryIds)
        return self.readRecords(fromCoreData: Table.planItShopMainCategory, predicate: predicate, context: objectContext) as! [PlanItShopMainCategory]
    }
    
    func readSpecificUserShopCategory(_ categoryIds: [Double], using context: NSManagedObjectContext? = nil) -> [PlanItShopMainCategory] {
        let objectContext = context ?? self.mainObjectContext
        let predicate = NSPredicate(format: "userId == %@ AND userCategoryId IN %@", Session.shared.readUserId(), categoryIds)
        return self.readRecords(fromCoreData: Table.planItShopMainCategory, predicate: predicate, context: objectContext) as! [PlanItShopMainCategory]
    }
    
    func readSpecificAppShopCategory(_ categoryId: String, using context: NSManagedObjectContext? = nil) -> [PlanItShopMainCategory] {
        let objectContext = context ?? self.mainObjectContext
        let predicate = NSPredicate(format: "userId == %@ AND appShopCategoryId == %@", Session.shared.readUserId(), categoryId)
        return self.readRecords(fromCoreData: Table.planItShopMainCategory, predicate: predicate, context: objectContext) as! [PlanItShopMainCategory]
    }
    
    func readAllShopCategory(using context: NSManagedObjectContext? = nil) -> [PlanItShopMainCategory] {
        let objectContext = context ?? self.mainObjectContext
        let predicate = NSPredicate(format: "userId == %@ AND deletedStatus == NO", Session.shared.readUserId())
        return self.readRecords(fromCoreData: Table.planItShopMainCategory, predicate: predicate, sortDescriptor: ["orderId"], ascending: true, context: objectContext) as! [PlanItShopMainCategory]
    }
    
    func readAllPendingShopCategory(using context: NSManagedObjectContext? = nil) -> [PlanItShopMainCategory] {
        let objectContext = context ?? self.mainObjectContext
        let predicate = NSPredicate(format: "userId == %@ AND isPending == YES AND isCustom == YES", Session.shared.readUserId())
        return self.readRecords(fromCoreData: Table.planItShopMainCategory, predicate: predicate, context: objectContext) as! [PlanItShopMainCategory]
    }
    
    func readAllPendingDeletedShopCategory(using context: NSManagedObjectContext? = nil) -> [PlanItShopMainCategory] {
        let objectContext = context ?? self.mainObjectContext
        let predicate = NSPredicate(format: "userId == %@ AND isPending == YES AND deletedStatus == YES", Session.shared.readUserId())
        return self.readRecords(fromCoreData: Table.planItShopMainCategory, predicate: predicate, context: objectContext) as! [PlanItShopMainCategory]
    }
    
}
