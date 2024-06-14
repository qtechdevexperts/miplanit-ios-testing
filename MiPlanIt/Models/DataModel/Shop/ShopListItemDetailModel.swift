//
//  ShopListItemDetailModel.swift
//  MiPlanIt
//
//  Created by Febin Paul on 11/11/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

class ShopListItemDetailModel {
    
    var planItShopListItem: PlanItShopListItems? {
        didSet{
            self.planItShopListItemId = planItShopListItem?.shopListItemId ?? 0
        }
    }
    
    var planItShopItem: PlanItShopItems?
    
    var planItShopListItemId: Double = 0
    var shopListId: Double = 0
    var shopListName: String = Strings.empty
    var itemName: String = Strings.empty
    var isfavorite: Bool = false
    var isfavoriteLocal: Bool = false
    var isCompleted: Bool = false
    var quantity: String = "1"
    var store: String = Strings.empty
    var brand: String = Strings.empty
    var targetPrize: String = Strings.empty
    var url: String = Strings.empty
    var notes: String = Strings.empty
    var attachments: [UserAttachment] = []
    var tags: [String] = ["Shopping"]
    var userCategoryId: Double = 0
    var masterCategoryId: Double = 0
    var masterSubCategoryId: Double = 0
    var categoryName: String = Strings.empty
    var dueDate: Date?
    var createdDate: Date = Date()
    var planItShopList: PlanItShopList?
    var appCategoryId: String = Strings.empty
    var remindValue: ReminderModel?
    
    init(shopListItem: PlanItShopListItems, shopItem: PlanItShopItems, quantity: String = Strings.empty) {
        self.isfavorite = shopListItem.isFavorite
        self.isfavoriteLocal = shopListItem.isFavoriteLocal
        self.isCompleted = shopListItem.isCompletedLocal
        self.quantity = quantity.isEmpty ? shopListItem.readQuantity() : quantity
        self.store = shopListItem.readStoreName()
        self.brand = shopListItem.readBrand()
        self.targetPrize = shopListItem.readTargetPrice()
        self.url = shopListItem.readUrl()
        self.notes = shopListItem.readNotes()
        self.planItShopListItem = shopListItem
        self.planItShopListItemId = planItShopListItem?.shopListItemId ?? 0
        self.planItShopItem = shopItem
        self.itemName = shopItem.readItemName()
        self.shopListId = shopListItem.readShopListIdValue()
        self.shopListName = shopListItem.shopList?.readShopListName() ?? Strings.empty
        self.tags = shopListItem.readTags().compactMap({$0.tag})
        let ownerIdValue = shopListItem.shopList?.createdBy?.readValueOfUserId()
        self.attachments = shopListItem.readAllAttachments().compactMap({ return UserAttachment(with: $0, type: .shopping, ownerId: ownerIdValue) })
        self.dueDate = shopListItem.dueDate
        self.createdDate = shopListItem.createdDate ?? Date()
        if let reminder = shopListItem.readReminders() {
            self.remindValue = ReminderModel(reminder, from: .shopping)
        }
        if shopItem.readUserCategoryIdLocalValue() != 0.0 {
            self.categoryName = shopItem.readUserCategoryName()
            self.userCategoryId = shopItem.readUserCategoryIdLocalValue()
        }
        else {
            if shopItem.readMasterCategoryIdLocalValue() != 0.0 {
                self.categoryName = shopItem.readMasterCategoryName()
                self.masterCategoryId = shopItem.readMasterCategoryIdLocalValue()
            }
            if shopItem.readMasterSubCategoryLocalIdValue() != 0.0 {
                self.categoryName = shopItem.readMasterSubCategoryName()
                self.masterCategoryId = shopItem.readMasterSubCategoryLocalIdValue()
            }
        }
        if shopItem.isCustom && !(shopItem.appShopCategoryId ?? Strings.empty).isEmpty && shopItem.readUserCategoryIdLocalValue() == 0.0 && shopItem.readMasterCategoryIdLocalValue() == 0.0 {
            self.appCategoryId = shopItem.appShopCategoryId ?? Strings.empty
            self.categoryName = shopItem.readUserCategoryName()
        }
        self.planItShopList = shopListItem.shopList
    }
    
    init(shopItem: PlanItShopItems, quantity: String, onShopList: PlanItShopList) {
        self.planItShopItem = shopItem
        self.planItShopListItemId = planItShopListItem?.shopListItemId ?? 0
        self.quantity = quantity
        self.itemName = shopItem.readItemName()
        self.shopListId = onShopList.readShopListIDValue()
        self.shopListName = onShopList.readShopListName()
        if shopItem.isCustom && !(shopItem.readAppShopCategoryId()).isEmpty && shopItem.readUserCategoryIdLocalValue() == 0.0 {
            self.appCategoryId = shopItem.readAppShopCategoryId()
            self.categoryName = shopItem.readUserCategoryName()
        }
        else if shopItem.isCustom {
            self.userCategoryId = shopItem.readUserCategoryIdLocalValue()
            self.categoryName = shopItem.readUserCategoryName()
        }
        else if shopItem.masterSubCategoryId != 0 {
            self.masterSubCategoryId = shopItem.readMasterSubCategoryLocalIdValue()
            self.categoryName = shopItem.readMasterSubCategoryName()
        }
        if shopItem.masterCategoryId != 0 {
            self.masterCategoryId = shopItem.readMasterCategoryIdLocalValue()
            self.categoryName = shopItem.readMasterCategoryName()
        }
        self.planItShopList = onShopList
    }
    
    init(newItem: String, onShopList: PlanItShopList, withCategory category: PlanItShopMainCategory? = nil) {
        self.itemName = newItem.trimmingCharacters(in: .whitespacesAndNewlines)
        self.shopListId = onShopList.readShopListIDValue()
        self.shopListName = onShopList.readShopListName()
        if let planItCategory = category {
            if planItCategory.isCustom && !(planItCategory.appShopCategoryId ?? Strings.empty).isEmpty && planItCategory.readUserCategoryIdValue() == 0.0 {
                self.appCategoryId = planItCategory.appShopCategoryId ?? Strings.empty
                self.categoryName = planItCategory.readCategoryName()
            }
            else if planItCategory.isCustom {
                self.userCategoryId = planItCategory.readUserCategoryIdValue()
                self.categoryName = planItCategory.readCategoryName()
            }
            else if planItCategory.readMasterCategoryIdValue() != 0 {
                self.masterCategoryId = planItCategory.readMasterCategoryIdValue()
                self.categoryName = planItCategory.readCategoryName()
            }
        }
        else {
            self.masterCategoryId = 1
            self.categoryName = Strings.shopOtherCategoryName
        }
        self.planItShopList = onShopList
    }
    
    func addAttachement(_ attachment: UserAttachment) {
        self.attachments.append(attachment)
    }
    
    func createInfoParams() -> [String: Any] {
        var params:[String: Any] = [:]
        params["quantity"] = self.quantity
        params["store"] = self.store
        params["brand"] = self.brand
        params["targetPrice"] = self.targetPrize
        params["url"] = self.url
        params["notes"] = self.notes
        params["tags"] = self.tags
        params["attachments"] = self.attachments.compactMap({ return $0.identifier.isEmpty ? nil : Int($0.identifier) })
        params["shoppingListId"] = self.shopListId
        params["dueDate"] = self.dueDate == nil ? Strings.empty : self.dueDate?.stringFromDate(format: DateFormatters.YYYYHMMMHDD)
        return params
    }
    
    func createCategoryParams() -> [String: Any] {
        var params:[String: Any] = [:]
        params["userProdCatId"] = self.userCategoryId != 0 ? self.userCategoryId : Strings.empty
        params["prodSubCatId"] = self.masterSubCategoryId != 0 ? self.masterSubCategoryId : Strings.empty
        params["prodCatId"] = self.masterCategoryId != 0 ? self.masterCategoryId : Strings.empty
        if self.userCategoryId == 0 && self.masterSubCategoryId == 0 && self.masterCategoryId == 0 {
            params["prodCatId"] = 1
        }
        return params
    }
    
    
    func createRequestParams(onUpdate: Bool = false) -> [String: Any] {
        var params:[String: Any] = [:]
        params = self.createInfoParams()
        if let planItShopListItem = self.planItShopListItem {
            if onUpdate && planItShopListItem.shopListItemId != 0 {
                params["listDetailId"] = planItShopListItem.shopListItemId
            }
            if planItShopListItem.shopItemId == 0 && !self.itemName.isEmpty {
                var newItem: [String: Any] = [:]
                newItem["userItemName"] = self.itemName
                newItem["appUserItemId"] = self.planItShopItem?.readAppShopItemId()
                params["newItem"] = newItem
            }
            else {
                params["itemId"] =  planItShopListItem.shopItemId
            }
            params["custom"] = planItShopListItem.isShopCustomItem
            if planItShopListItem.isShopCustomItem && self.itemName != self.planItShopItem?.readItemName() {
                var updateItem: [String: Any] = [:]
                updateItem["userItemName"] = self.itemName
                params["updateItem"] = updateItem
            }
        }
        if let shopItem = self.planItShopItem {
            params.merge(self.createCategoryParams(), uniquingKeysWith: { (first, _) in first })
            params["itemId"] = shopItem.isCustom ? shopItem.userItemId : shopItem.masterItemId
            params["custom"] = shopItem.isCustom
            if shopItem.isCustom && self.itemName != self.planItShopItem?.readItemName() {
                var updateItem: [String: Any] = [:]
                updateItem["userItemName"] = self.itemName
                params["updateItem"] = updateItem
            }
        }
        if self.planItShopListItem  == nil && !self.itemName.isEmpty && self.planItShopItem == nil {
            var newItem: [String: Any] = [:]
            newItem["userItemName"] = self.itemName
            newItem["appUserItemId"] = self.planItShopItem?.readAppShopItemId()
            params["newItem"] = newItem
            params["custom"] = true
            params.merge(self.createCategoryParams(), uniquingKeysWith: { (first, _) in first })
        }
        if self.masterSubCategoryId != 0 && self.planItShopItem?.readMasterSubCategoryIdValue() != self.masterSubCategoryId {
            params["isCategoryUpdated"] = true
        }
        if self.masterCategoryId != 0 && self.planItShopItem?.readMasterCategoryIdValue() != self.masterCategoryId {
            params["isCategoryUpdated"] = true
        }
        if self.planItShopItem?.readUserCategoryIdValue() != self.userCategoryId {
            params["isCategoryUpdated"] = true
        }
        if let reminderParam = self.remindValue?.readReminderNumericValueParameter() {
            params["reminders"] =  reminderParam
        }
        else {
            params["reminders"] =  nil
        }
        return params
    }
    
    func createTextForPrediction() -> String {
        var text: String = ""
        text += self.itemName
        text += self.brand.isEmpty ? Strings.empty : ", "+self.brand
        text += self.store.isEmpty ? Strings.empty : ", "+self.store
        text += self.categoryName.isEmpty ? Strings.empty : ", "+self.categoryName
        return text
    }
    
    func saveNewShopListItemOffline() {
        if let planItShopListItem = self.planItShopListItem {
            planItShopListItem.saveShopItemDetailDetails(self, completeStatus: self.isCompleted)
        }
        else {
            guard let planItShopList = self.planItShopList else { return }
            var shopItem = self.planItShopItem
            if !self.itemName.isEmpty {
                shopItem = DatabasePlanItShopItems().insertUserShopItemOffline(shopListItemDetailModel: self)
                self.planItShopItem = shopItem
            }
            let planItShopListItem = DatabasePlanItShopListItem().insertShopListItem(self, planItShopList: planItShopList, planItShopItem: shopItem)
            self.planItShopListItem = planItShopListItem
        }
    }
    
    func isCategoryPending() -> Bool {
        if !self.appCategoryId.isEmpty, let shopCat = DatabasePlanItShopMasterCategory().readSpecificAppShopCategory(self.appCategoryId).first {
            return shopCat.isPending
        }
        return false
    }
    
}
