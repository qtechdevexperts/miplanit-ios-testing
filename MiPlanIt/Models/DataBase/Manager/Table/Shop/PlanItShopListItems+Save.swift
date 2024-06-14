//
//  PlanItShopListItem+Save.swift
//  MiPlanIt
//
//  Created by Febin Paul on 10/05/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

extension PlanItShopListItems {
    
    func readQuantity() -> String { return self.quantity ?? Strings.empty }
    func readStoreName() -> String { return self.storeName ?? Strings.empty }
    func readTargetPrice() -> String { return self.targetPrice ?? Strings.empty }
    func readBrand() -> String { return self.brand ?? Strings.empty }
    func readUrl() -> String { return self.url ?? Strings.empty }
    func readNotes() -> String { return self.notes ?? Strings.empty }
    func readShopItemIdValue() -> Double { return self.shopItemId }
    func readShopListIdValue() -> Double { return self.shopList?.readShopListIDValue() ?? 0 }
    func readIsCompleted() -> Bool { return self.isCompleted || self.isCompletedLocal }
    func readShopListItemsIdValue() -> Double { return self.shopListItemId }
    func readCreatedDate() -> Date { return self.createdDate ?? Date() }
    func readDueDate() -> Date? { return self.dueDate }
    func readDueDateString() -> String { return self.dueDate?.stringFromDate(format: DateFormatters.EEEDDMMMYYYY) ?? Strings.empty  }
    func readCompletedDateString() -> String { return self.modifiedAt?.stringFromDate(format: DateFormatters.EEEDDMMMYYYY) ?? Strings.empty  }
    func readMovedFrom() -> String { return self.movedFrom ?? Strings.empty }
    func readappShopListItemId() -> String { return self.appShopListItemId ?? Strings.empty }
    func readAppShopItemId() -> String { return self.appShopItemId ?? Strings.empty }
    func readShopListId() -> String { return self.shopList?.readShopListIdValue().cleanValue() ?? Strings.empty }
    func readReminders() -> PlanItReminder? { return self.reminder }
    func readDeleteStatus() -> Bool { return self.deleteStatus }
    func readValueOfNotificationId() -> String {
        if let bNotificationId = self.notificationId, !bNotificationId.isEmpty {
            return bNotificationId
        }
        else {
            let newNotificationId = self.readShopListItemsIdValue() == 0 ? self.appShopItemId ?? Strings.empty : self.readShopListItemsIdValue().cleanValue()
            self.notificationId = newNotificationId
            return newNotificationId
        }
    }
    func isShopItemPending() -> Bool {
        if let appShopItemId = self.appShopItemId, self.readShopItemIdValue() == 0.0, let shopItem = DatabasePlanItShopItems().readSpecificAppShopItem(appShopItemId).first {
            return shopItem.isPending
        }
        else if self.readShopItemIdValue() != 0.0, self.isShopCustomItem, let shopItem = DatabasePlanItShopItems().readSpecificUserShopItem([self.readShopItemIdValue()]).first {
            return shopItem.isPending
        }
        else if self.readShopItemIdValue() != 0.0, !self.isShopCustomItem, let shopItem = DatabasePlanItShopItems().readSpecificMasterShopItem([self.readShopItemIdValue()]).first {
            return shopItem.isPending
        }
        return false
    }
    
    func isShopItemCategoryPending() -> Bool {
        if let appShopItemId = self.appShopItemId, let shopItem = DatabasePlanItShopItems().readSpecificAppShopItem(appShopItemId).first, let appCategoryId = shopItem.appShopCategoryId, let planItShopMainCategory = DatabasePlanItShopMasterCategory().readSpecificAppShopCategory(appCategoryId).first {
            return shopItem.isPending || planItShopMainCategory.isPending
        }
        return false
    }
        
    func readTags() -> [PlanItTags] {
        if let tags = self.tags, let shopTags = Array(tags) as? [PlanItTags] {
            return shopTags
        }
        return []
    }
    
    func readAttachments() -> [PlanItUserAttachment] {
        if let attachments = self.shopAttachment, let shopAttachment = Array(attachments) as? [PlanItUserAttachment] {
            return shopAttachment
        }
        return []
    }
    
    func createRequestParams() -> [String: Any] {
        var params:[String: Any] = [:]
        if self.shopListItemId != 0 {
            params["listDetailId"] = self.shopListItemId
        }
        if self.shopItemId != 0.0 {
            params["itemId"] = self.shopItemId
        }
        var planItShopItem: PlanItShopItems?
        if self.isShopCustomItem {
            if self.shopItemId == 0.0 && !self.readAppShopItemId().isEmpty {
                planItShopItem = DatabasePlanItShopItems().readSpecificAppShopItem(self.readAppShopItemId()).first
            }
            else {
                planItShopItem = DatabasePlanItShopItems().readSpecificUserShopItem([self.shopItemId]).first
            }
            
            params["custom"] = true
            if planItShopItem?.userItemId == 0 {
                var newItem: [String: Any] = [:]
                newItem["userItemName"] = planItShopItem?.readItemName()
                newItem["appUserItemId"] = planItShopItem?.readAppShopItemId()
                params["newItem"] = newItem
            }
            if (planItShopItem?.readisItemNameUpdated() ?? false), planItShopItem?.readUserItemIdValue() != 0.0 {
                var updateItem: [String: Any] = [:]
                updateItem["userItemName"] = planItShopItem?.readItemName()
                params["updateItem"] = updateItem
            }
        }
        else {
            planItShopItem = DatabasePlanItShopItems().readSpecificMasterShopItem([self.shopItemId]).first
            params["custom"] = false
        }
        if let shopItem = planItShopItem {
            params["userProdCatId"] = shopItem.readUserCategoryIdLocalValue() != 0 ? shopItem.readUserCategoryIdLocalValue() : Strings.empty
            params["prodSubCatId"] = shopItem.readMasterSubCategoryLocalIdValue() != 0 ? shopItem.readMasterSubCategoryLocalIdValue() : Strings.empty
            params["prodCatId"] = shopItem.readMasterCategoryIdLocalValue() != 0 ? shopItem.readMasterCategoryIdLocalValue() : Strings.empty
            if shopItem.readMasterCategoryIdValue() == 0 && shopItem.readUserCategoryIdValue() == 0 && shopItem.readMasterCategoryIdLocalValue() == 0 && shopItem.readUserCategoryIdLocalValue() == 0 {
                params["prodCatId"] = 1
            }
            if shopItem.readMasterSubCategoryLocalIdValue() != 0 && shopItem.readMasterSubCategoryIdValue() != shopItem.readMasterSubCategoryLocalIdValue(), self.readShopListItemsIdValue() != 0 {
                params["isCategoryUpdated"] = true
            }
            if shopItem.readMasterCategoryIdLocalValue() != 0 && shopItem.readMasterCategoryIdValue() != shopItem.readMasterCategoryIdLocalValue(), self.readShopListItemsIdValue() != 0 {
                params["isCategoryUpdated"] = true
            }
            if shopItem.readUserCategoryIdLocalValue() != shopItem.readUserCategoryIdValue() {
                params["isCategoryUpdated"] = true
            }
        }
        if let reminderParam = self.readReminders()?.readReminderNumericValueParameter() {
            params["reminders"] =  reminderParam
        }
        else {
            params["reminders"] =  nil
        }
        params["appListDetailId"] = self.readappShopListItemId()
        params["quantity"] = self.readQuantity()
        params["shoppingListId"] = self.shopList?.readShopListIdValue()
        params["store"] = self.readStoreName()
        params["brand"] = self.readBrand()
        params["targetPrice"] = self.readTargetPrice()
        params["url"] = self.readUrl()
        params["notes"] = self.readNotes()
        params["tags"] = self.readTags().compactMap({ $0.tag })
        params["attachments"] = self.readAttachments().compactMap({ return $0.isPending ? nil : $0.identifier })
        params["dueDate"] = self.dueDate == nil ? Strings.empty : self.dueDate?.stringFromDate(format: DateFormatters.YYYYHMMMHDD)
        return params
    }
    
    func saveShopItemDetailDetails(_ details: ShopListItemDetailModel, completeStatus: Bool) {
        self.isPending = true
        self.saveAttachments(details.attachments)
        self.storeName = details.store
        self.notes = details.notes
        self.quantity = details.quantity
        self.brand = details.brand
        self.url = details.url
        self.targetPrice = details.targetPrize
        self.isCompletedLocal = completeStatus
        self.saveTags(details.tags)
        self.remindMe = LocalNotificationType.new.rawValue
        self.dueDate = details.dueDate
        if let planItShopListItem = details.planItShopListItem {
            if details.remindValue != nil {
                DataBasePlanItTodoReminders().insertShopListItem(planItShopListItem, shopListItemModel: details)
            }
            else {
                self.reminder?.deleteItSelf()
            }
        }
        let shopItem = DatabasePlanItShopItems().insertUserShopItemOffline(shopListItemDetailModel: details)
        details.planItShopItem = shopItem
        try? self.managedObjectContext?.save()
    }
    
    func saveOnlyCompleteStatus(_ status: Bool) {
        self.isCompletedLocal = status
        self.modifiedAt = Date()
        if let modifier = self.modifiedBy {
            self.managedObjectContext?.delete(modifier)
            self.modifiedBy = nil
        }
        DatabasePlanItModifier().insertShopListItem(self, modifier: Session.shared.readUser())
        try? self.managedObjectContext?.save()
    }
    
    func saveFovoriteStatus(_ status: Bool, details: ShopListItemDetailModel) {
        self.isFavoriteLocal = status
        self.saveAttachments(details.attachments)
        self.storeName = details.store
        self.notes = details.notes
        self.saveTags(details.tags)
        try? self.managedObjectContext?.save()
    }
    
    func updateDueDateOffline(_ dueDate: Date) {
        self.dueDate = dueDate
        self.isPending = true
        try? self.managedObjectContext?.save()
    }
    
    func saveFovoriteStatus(_ status: Bool) {
        self.isFavoriteLocal = status
        try? self.managedObjectContext?.save()
    }
    
    func saveTags(_ tags: [String]) {
        DatabasePlanItTags().insertTags(tags, for: self)
    }
    
    func saveAttachments(_ data: [UserAttachment]) {
        DatabasePlanItUserAttachment().insertAttachments(data, for: self)
    }
    
    func saveShopListItemContext() {
        try? self.managedObjectContext?.save()
    }
    
    func readAllAvailableDates(from: Date, to: Date) -> [Date] {
        guard let startDate = self.readDueDate(), startDate >= from, startDate <= to else { return [] }
        return [startDate]
    }
    
    func readReminderIntervalsFromStartDate(_ date: Date) -> Date? {
        if let reminder = self.readReminders() {
            return reminder.readReminderMinutesFromDate(date)
        }
        return nil
    }
    
    func deleteAllShopAttachments(forceRemove: Bool) {
        if forceRemove {
            let allAttachments = self.readAllAttachments()
            self.removeFromShopAttachment(self.shopAttachment ?? [])
            allAttachments.forEach({ self.managedObjectContext?.delete($0) })
        }
        else {
            let allAttachments = self.readAllAttachments().filter({ return !$0.isPending })
            self.removeFromShopAttachment(NSSet(array: allAttachments))
            allAttachments.forEach({ self.managedObjectContext?.delete($0) })
        }
    }
    
    func deleteAllTags() {
        let allTags = self.readTags()
        self.removeFromTags(self.tags ?? [])
        allTags.forEach({ self.managedObjectContext?.delete($0) })
    }
        
    func deleteItSelf() {
        self.managedObjectContext?.delete(self)
    }
    
    func deleteShopItem() {
        if self.shopItemId == 0.0 && !self.readAppShopItemId().isEmpty {
            let planItShopItem = DatabasePlanItShopItems().readSpecificAppShopItem(self.readAppShopItemId()).first
            planItShopItem?.deleteItSelf()
        }
    }
    
    func deleteOffline() {
        let context = self.managedObjectContext
        self.isPending = true
        self.deleteStatus = true
        try? context?.save()
    }
    
    func readAllAttachments() -> [PlanItUserAttachment] {
        if let bAttachments = self.shopAttachment, let todoAttachments = Array(bAttachments) as? [PlanItUserAttachment] {
            return todoAttachments
        }
        return []
    }
}


