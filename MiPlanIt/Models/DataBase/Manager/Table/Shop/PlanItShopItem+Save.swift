//
//  PlanItShopItem+Save.swift
//  MiPlanIt
//
//  Created by Febin Paul on 10/11/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

extension PlanItShopItems {
    
    func readItemName() -> String { return self.itemName ?? Strings.empty }
    func readMasterItemId() -> String { return self.masterItemId == 0 ? Strings.empty : self.masterItemId.cleanValue() }
    func readMasterItemIdValue() -> Double { return self.masterItemId }
    
    func readMasterCategoryName() -> String { return self.masterCategoryName ??  Strings.empty }
    func readMasterSubCategoryName() -> String { return self.masterSubCategoryName ??  Strings.empty }
    
    func readUserItemId() -> String { return self.userItemId == 0 ? Strings.empty : self.userItemId.cleanValue() }
    func readUserItemIdValue() -> Double { return self.userItemId }
    func isUserCreated() -> Bool { return self.isCustom }
    func readisItemNameUpdated() -> Bool { return self.isItemNameUpdated }
    func readMasterCategoryId() -> String { return self.masterCategoryId == 0 ? Strings.empty : self.masterCategoryId.cleanValue() }
    func readMasterCategoryIdValue() -> Double { return self.masterCategoryId }
    func readMasterCategoryIdLocalValue() -> Double { return self.masterCategoryIdLocal }
    func readMasterSubCategoryId() -> String { return self.masterSubCategoryId == 0 ? Strings.empty : self.masterSubCategoryId.cleanValue() }
    func readMasterSubCategoryIdValue() -> Double { return self.masterSubCategoryId }
    func readMasterSubCategoryLocalIdValue() -> Double { return self.masterSubCategoryIdLocal }
    
    func readUserCategoryId() -> String { return self.userCategoryId == 0 ? Strings.empty : self.userCategoryId.cleanValue() }
    func readUserCategoryIdValue() -> Double { return self.userCategoryId }
    func readUserCategoryIdLocalValue() -> Double { return self.userCategoryIdLocal }
    func readUserCategoryName() -> String { return self.userCategoryName ??  Strings.empty }
    
    func readImageName() -> String { return self.itemImage ??  Strings.empty }
    func readBgColor() -> String { return self.itemColor ??  Strings.empty }
    func readAppShopCategoryId() -> String { return self.appShopCategoryId ??  Strings.empty }
    func readAppShopItemId() -> String { return self.appShopItemId ??  Strings.empty }

    
    func updateMasterCategoryOffline(to category: CategoryData, ofItem item: PlanItShopListItems) {
        item.isPending = true
        self.isPending = true
        self.masterCategoryName = category.categoryName
        self.masterCategoryIdLocal = category.categoryId
        self.userCategoryId = 0
        self.userCategoryIdLocal = 0
        self.masterSubCategoryId = 0
        self.masterSubCategoryIdLocal = 0
        self.appShopCategoryId = Strings.empty
        self.masterSubCategoryName = Strings.empty
        self.userCategoryName = Strings.empty
        try? self.managedObjectContext?.save()
    }
    
    func updateSubCategoryOffline(to category: CategoryData, ofItem item: PlanItShopListItems) {
        item.isPending = true
        self.isPending = true
        self.masterSubCategoryIdLocal = category.categoryId
        self.masterSubCategoryName = category.categoryName
        self.userCategoryId = 0
        self.userCategoryIdLocal = 0
        self.appShopCategoryId = Strings.empty
        self.userCategoryName = Strings.empty
        try? self.managedObjectContext?.save()
    }
    
    func updateUserCategoryOffline(to category: CategoryData, ofItem item: PlanItShopListItems?) {
        item?.isPending = true
        self.isPending = true
        self.userCategoryIdLocal = category.categoryId
        self.userCategoryName = category.categoryName
        self.masterCategoryId = 0
        self.masterCategoryIdLocal = 0
        self.masterSubCategoryId = 0
        self.masterSubCategoryIdLocal = 0
        self.appShopCategoryId = Strings.empty
        self.masterSubCategoryName = category.categoryName
        try? self.managedObjectContext?.save()
    }
    
    func updateAppShopCategoryOffline(to category: CategoryData, ofItem item: PlanItShopListItems) {
        item.isPending = true
        self.isPending = true
        self.userCategoryId = 0
        self.appShopCategoryId = category.categoryAppId
        self.userCategoryName = category.categoryName
        self.masterCategoryId = 0
        self.masterCategoryIdLocal = 0
        self.masterSubCategoryId = 0
        self.masterSubCategoryIdLocal = 0
        self.masterSubCategoryName = category.categoryName
        try? self.managedObjectContext?.save()
    }
    
    func deleteItSelf() {
        self.managedObjectContext?.delete(self)
    }
}
