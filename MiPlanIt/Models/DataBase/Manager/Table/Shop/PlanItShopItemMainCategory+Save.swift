//
//  PlanItShopItemMainCategory+Save.swift
//  MiPlanIt
//
//  Created by Febin Paul on 09/11/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

extension PlanItShopMainCategory {
    
    func readCategoryName() -> String { return self.name ?? Strings.empty }
    func readCategoryImage() -> String { return self.image ?? Strings.empty }
    func readMasterCategoryIdValue() -> Double { return self.masterCategoryId }
    func readUserCategoryIdValue() -> Double { return self.userCategoryId }
    func readUserAppCategoryId() -> String { return self.appShopCategoryId ?? Strings.empty }
    func readOrderId() -> Double { return self.orderId }
    
    func readAllShopSubCategory() -> [PlanItShopSubCategory] {
        if let subCategorys = self.subCategorys, let categorys = Array(subCategorys) as? [PlanItShopSubCategory] {
            return categorys
        }
        return []
    }
    
    func createRequestParams() -> [String: Any] {
        var params: [String: Any] = [:]
        params["userProdCat"] = self.readCategoryName()
        return params
    }
    
    func deleteShopListOffline() {
        if self.readUserCategoryIdValue() == 0 && self.isPending {
            // not synced to server
            let context = self.managedObjectContext
            context?.delete(self)
            try? context?.save()
        }
        else {
            self.deletedStatus = true
            self.isPending = true
            try? self.managedObjectContext?.save()
        }
    }
    
//    func readAllShopCategoryItems() -> [PlanItShopItems] {
//        if let shopItem = self.shopItem, let items = Array(shopItem) as? [PlanItShopItems] {
//            return items
//        }
//        return []
//    }
}
