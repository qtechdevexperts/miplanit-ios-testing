//
//  DatabasePlanItShopData.swift
//  MiPlanIt
//
//  Created by Arun Aniyappan on 19/11/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

class DatabasePlanItShopData: DataBaseManager {
    
    func insertShopMasterCategoryAndItems(_ data: [String: Any], result: @escaping ([ServiceDetection])->()) {
        self.privateObjectContext.perform {
            var serviceDetection: [ServiceDetection] = []
            if let masterItems = data["masterCategories"] as? [[String: Any]], !masterItems.isEmpty {
                serviceDetection.append(.newShopping)
                DatabasePlanItShopMasterCategory().insertMasterCategory(masterItems, using: self.privateObjectContext)
            }
            if let masterItems = data["masterItems"] as? [[String: Any]], !masterItems.isEmpty {
                serviceDetection.append(.newShopping)
                DatabasePlanItShopItems().inserMasterCategoryItems(masterItems, using: self.privateObjectContext)
            }
            if let deletedMasterItemsIds = data["deletedMasterItems"] as? [Double], !deletedMasterItemsIds.isEmpty {
                serviceDetection.append(.shoppingDeleted)
                DatabasePlanItShopItems().deleteShopListMasterItems(deletedMasterItemsIds, using: self.privateObjectContext)
            }
            self.privateObjectContext.saveContext()
            DispatchQueue.main.async { result(serviceDetection) }
        }
    }
    
    func insertShopUserCategoryAndItems(_ data: [String: Any], result: @escaping ([ServiceDetection])->()) {
        self.privateObjectContext.perform {
            var serviceDetection: [ServiceDetection] = []
            if let masterItems = data["userCategories"] as? [[String: Any]], !masterItems.isEmpty {
                serviceDetection.append(.newShopping)
                DatabasePlanItShopMasterCategory().insertShopUserCategory(masterItems, using: self.privateObjectContext)
            }
            if let userItems = data["userItems"] as? [[String: Any]], !userItems.isEmpty {
                serviceDetection.append(.newShopping)
                DatabasePlanItShopItems().inserUserCategoryItems(userItems, hardSave: false, using: self.privateObjectContext)
            }
            self.privateObjectContext.saveContext()
            DispatchQueue.main.async { result(serviceDetection) }
        }
    }
    
    func insertUserShopingList(_ data: [String: Any], result: @escaping ([ServiceDetection])->()) {
        self.privateObjectContext.perform {
            var serviceDetection: [ServiceDetection] = []
            if let userShoppingList = data["userShoppingList"] as? [[String: Any]], !userShoppingList.isEmpty {
                serviceDetection.append(.newShopping)
                DatabasePlanItShopList().insertUserShopData(userShoppingList, using: self.privateObjectContext)
            }
            if let deletedShopList = data["deletedShpListId"] as? [Double], !deletedShopList.isEmpty {
                serviceDetection.append(.shoppingDeleted)
                DatabasePlanItShopList().removePlanItShopingList(deletedShopList, using: self.privateObjectContext)
            }
            self.privateObjectContext.saveContext()
            DispatchQueue.main.async {
                if serviceDetection.isContainedSpecificServiceData(.shop) {
                    Session.shared.registerUserShopingListItemLocationNotification()
                }
                result(serviceDetection)
            }
        }
    }
}
