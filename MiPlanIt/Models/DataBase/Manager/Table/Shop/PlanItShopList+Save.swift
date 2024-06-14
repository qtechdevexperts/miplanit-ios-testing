//
//  PlanItShopList+Save.swift
//  MiPlanIt
//
//  Created by Febin Paul on 10/05/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation
import PINRemoteImage

extension PlanItShopList {
    
    func readStartDateTime() -> Date {
//        return (self.readStartDate() + Strings.space + self.readStartTime()).stringToDate(formatter: DateFormatters.MMDDYYYYHMMSSA, timeZone: TimeZone(abbreviation: "UTC")!) ?? Date()
        return Date()
    }
    
    func readShopListColor() -> String {
        return self.shopListColor ?? Strings.empty
    }
    
    func readShopListName() -> String {
        return self.shopListName ?? Strings.empty
    }
    
    func readShopListID() -> String {
        return self.shopListId.cleanValue()
    }
    
    func readOwnerUserId() -> String {
        self.createdBy?.readValueOfUserId() ?? Strings.empty
    }
    
    func readAppShopListID() -> String {
        return self.appShopListId ?? Strings.empty
    }
    
    func readShopListIDValue() -> Double {
        return self.shopListId
    }
    
    func readShopListIdValue() -> Double {
        return self.shopListId 
    }
    
    func readUserID() -> String {
        return self.userId ?? Strings.empty
    }
    
    func readShopListImage() -> String {
        return self.shopListImage ?? Strings.empty
    }
    
    func readCategoryOrder() -> [PlanItShopListCategoryOrder] {
        if let listCategoryOrder = self.listCategoryOrder, let shopListCategoryOrder = Array(listCategoryOrder) as? [PlanItShopListCategoryOrder] {
            return shopListCategoryOrder
        }
        return []
    }
    
    func isCompleted() -> Bool {
//        return !self.readCompletionDate().isEmpty
        return false
    }
    
    func readCreatedDate() -> Date {
        return self.createdDate ?? Date()
    }
    
    func readAllShopListShareInvitees() -> [PlanItInvitees] {
        if let items = self.shareInvitees, let shopListInvitees = Array(items) as? [PlanItInvitees] {
            return shopListInvitees
        }
        return []
    }
    
    func readAllOtherUser() -> [OtherUser] {
        return self.readAllShopListShareInvitees().filter({ $0.readValueOfUserId() != Session.shared.readUserId() }).compactMap({ OtherUser(invitee: $0, deletable: $0.readValueOfUserId() != self.createdBy?.readValueOfUserId() ) })
    }
    
    func readAllShopListItems() -> [PlanItShopListItems] {
        if let items = self.shopListItems, let shopListItems = Array(items) as? [PlanItShopListItems] {
            return shopListItems
        }
        return []
    }
    
    func readAllShopListCategoryOrder() -> [PlanItShopListCategoryOrder] {
        if let listCategoryOrder = self.listCategoryOrder, let shopListCategoryOrder = Array(listCategoryOrder) as? [PlanItShopListCategoryOrder] {
            return shopListCategoryOrder
        }
        return []
    }
    
    func readAllInCompleteShopListItems() -> [PlanItShopListItems] {
        return self.readAllShopListItems().filter({ !$0.isCompletedLocal && !$0.deleteStatus })
    }
    
    func readAllAvailableShopListItems() -> [PlanItShopListItems] {
        return self.readAllShopListItems().filter({ !$0.deleteStatus })
    }
    
    func readDeleteStatus() -> Bool {
        return self.deleteStatus
    }
    
    func updateCategoryOrder(categorys: [ShopItemListSection]) {
        DatabasePlanItShopListCategoryOrder().insertShopListCategoryOrder(self, shopItemListSection: categorys)
    }
    
    func deleteAllExternalInvitees() {
        let deletedInvitees = self.readAllShopListShareInvitees().filter({ return $0.isOther })
        self.removeFromShareInvitees(NSSet(array: deletedInvitees))
        deletedInvitees.forEach({ self.managedObjectContext?.delete($0) })
    }
    
    func deleteAllInvitees() {
        let deletedInvitees = self.readAllShopListShareInvitees().filter({ return !$0.isOther })
        self.removeFromShareInvitees(NSSet(array: deletedInvitees))
        deletedInvitees.forEach({ self.managedObjectContext?.delete($0) })
    }
    
    func deleteShopListItems(_ itemIds: [Double]) {
        let deletedShopListItems = self.readAllShopListItems().filter({ return itemIds.contains($0.shopListItemId) })
        self.removeFromShopListItems(NSSet(array: deletedShopListItems))
        deletedShopListItems.forEach({ self.managedObjectContext?.delete($0) })
    }
    
    func deleteAllCategoryOrder() {
        let allCategoryOrders = self.readCategoryOrder()
        self.removeFromListCategoryOrder(self.listCategoryOrder ?? [])
        allCategoryOrders.forEach({ self.managedObjectContext?.delete($0) })
    }
    
    func deleteOffline() {
        let context = self.managedObjectContext
        self.isPending = true
        self.deleteStatus = true
        try? context?.save()
    }
    
    func deleteUnsyncedShopItem() {
        self.readAllShopListItems().forEach { (shopItem) in
            if shopItem.isShopCustomItem, shopItem.readShopItemIdValue() == 0.0, !shopItem.readAppShopItemId().isEmpty {
                let planItShopItem = DatabasePlanItShopItems().readSpecificAppShopItem(shopItem.readAppShopItemId()).first
                planItShopItem?.deleteItSelf()
            }
        }
    }
    
    func deleteItSelf() {
        self.deleteUnsyncedShopItem()
        self.managedObjectContext?.delete(self)
    }
    
    func removeShopListFromList(_ shopListItem: [PlanItShopListItems]) {
        self.removeFromShopListItems(NSSet(array: shopListItem))
    }
    
    func addShopListItem(_ shopListItem: [PlanItShopListItems], fromList: PlanItShopList) {
        shopListItem.forEach({
            if $0.readMovedFrom().isEmpty, fromList.readShopListIDValue() != 0, $0.readShopListItemsIdValue() != 0.0  {
                $0.movedFrom = fromList.readShopListID()
            }
            else {
                $0.isPending = true
            }
        })
        self.addToShopListItems(NSSet(array: shopListItem))
        try? self.managedObjectContext?.save()
    }
    
    func updateShopListItemInvitees(_ invitees: [OtherUser]) {
        self.deleteAllInvitees()
        self.isPending = true
        DatabasePlanItInvitees().insertShop(self, invitees: invitees)
        try? self.managedObjectContext?.save()
    }
    
    func updateShopListName(_ name: String) {
        self.isPending = true
        self.shopListName = name
        try? self.managedObjectContext?.save()
    }
    
    func saveShopListImage(_ image: String) {
        self.shopListImage = image
        if let profileURL = URL(string:image) {
            let orginal = PINRemoteImageManager.shared().cacheKey(for: profileURL, processorKey: nil)
            PINRemoteImageManager.shared().cache.removeObject(forKey: orginal)
            let rounded = PINRemoteImageManager.shared().cacheKey(for: profileURL, processorKey: "rounded")
            PINRemoteImageManager.shared().cache.removeObject(forKey: rounded)
        }
        try? self.managedObjectContext?.save()
    }
    
    func createRequestParams() -> [String: Any] {
        var parameter: [String: Any] = [:]
        parameter["shpListId"] = self.readShopListIdValue()
        parameter["shpListName"] = self.shopListName
        parameter["shpListColourCode"] = self.readShopListColor()
        return parameter
    }
}
