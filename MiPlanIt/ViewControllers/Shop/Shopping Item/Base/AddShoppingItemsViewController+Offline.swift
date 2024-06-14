//
//  AddShoppingItemsViewController+Offline.swift
//  MiPlanIt
//
//  Created by Febin Paul on 02/12/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

extension AddShoppingItemsViewController {
    
    func saveShoppingDueDateToServerUsingNetwotk(_ shopListItems: [PlanItShopListItems], date: Date) {
        if SocialManager.default.isNetworkReachable() && self.validateOfflineSyncData(shopListItems) {
            self.createWebServiceToUpdateDueDateShopListItems(shopListItems, dueDate: date)
        }
        else {
            for eachShopListItem in shopListItems {
                eachShopListItem.updateDueDateOffline(date)
            }
            self.updateTitleCacelToDone()
            self.resetShopListItemsBasedOnSearchAndSort()
        }
    }
    
    func saveNewCustomShopListItemToServerUsingNetwotk(_ shopListItem: ShopListItemDetailModel) {
        if SocialManager.default.isNetworkReachable() {
            self.createWebServiceToAddNewCustomShopListItem(shopListItem)
        }
        else {
            shopListItem.saveNewShopListItemOffline()
            Session.shared.registerUserShopingListItemLocationNotification()
            self.refreshUpdateItemDetail(shopListItem)
        }
    }

    func saveShopListItemToServerUsingNetwotk(_ shopListItems: [PlanItShopListItems], shopListItemCellModel: ShopListItemCellModel, reloadAfter flag: Bool = true) {
        if SocialManager.default.isNetworkReachable() && self.validateOfflineSyncData(shopListItems) {
            self.createWebServiceToAddShopListItem(shopListItems, shopListItemCellModel: shopListItemCellModel, reloadAfter: flag)
        }
        else {
            DatabasePlanItShopListItem().savePendingStatus(for: shopListItems)
            Session.shared.registerUserShopingListItemLocationNotification()
            self.tableViewToDoItems?.reloadData()
            self.setVisibilityTopStackView()
            self.updateMainCategoryList()
        }
    }
    
    func deleteShopListItemToServerUsingNetwotk(_ shopListItems: [PlanItShopListItems]) {
        if SocialManager.default.isNetworkReachable() && self.validateOfflineSyncData(shopListItems) {
            self.createWebServiceToDeleteShopListItems(shopListItems)
        }
        else {
            let deletedShopingListItems = shopListItems.compactMap({ return LocalNotificationMethod.shopping.rawValue + $0.readValueOfNotificationId() })
            for eachListItem in shopListItems {
                eachListItem.deleteOffline()
            }
            self.allShopListItem.removeAll { (model) -> Bool in
                shopListItems.contains(model.planItShopListItem)
            }
            Session.shared.removeShoppingNotifications(deletedShopingListItems)
            self.resetShopListItemsAfterDelete()
            self.updateCompletedTable(showList: false)
            self.updateTitleCacelToDone()
            self.updateMainCategoryList()
        }
    }
    
    func saveShopListItemCompleteToServerUsingNetwotk(_ shopListItems: [PlanItShopListItems], with status: Bool) {
        for eachShopListItem in shopListItems {
            eachShopListItem.saveOnlyCompleteStatus(status)
        }
        if SocialManager.default.isNetworkReachable() && self.validateOfflineSyncData(shopListItems) {
            self.createWebServiceToCompleteShopListItem(shopListItems, with: status)
        }
        else {
            self.resetShopListItemsAfterComplete()
            status ? self.updateUndoSection(on: shopListItems) : self.updateCompletedTable()
            self.updateTitleCacelToDone()
            self.updateMainCategoryList()
        }
    }
    
    func saveShopListItemFavoriteToServerUsingNetwotk(_ shopListItems: [PlanItShopListItems], with status: Bool) {
        if SocialManager.default.isNetworkReachable() && self.validateOfflineSyncData(shopListItems) {
            self.createWebServiceToFavoriteShopListItem(shopListItems, with: status)
        }
        else {
            for eachShopListItem in shopListItems {
                eachShopListItem.saveFovoriteStatus(status)
            }
            self.updateTitleCacelToDone()
            self.resetShopListItemsAfterFavorite()
        }
    }
    
    func saveShopListItemMoveToServerUsingNetwotk(_ shopListItems: [PlanItShopListItems], toList: PlanItShopList) {
        guard let shopList = self.planItShopList else { return }
        if SocialManager.default.isNetworkReachable() && self.validateOfflineSyncData(shopListItems) {
            self.createWebServiceToMoveShopListItem(shopListItems, toList: toList)
        }
        else {
            if shopList != toList {
                shopList.removeShopListFromList(shopListItems)
                toList.addShopListItem(shopListItems, fromList: shopList)
                self.allShopListItem.removeAll { (shopListItemCellModel) -> Bool in
                    shopListItems.contains(shopListItemCellModel.planItShopListItem)
                }
            }
            self.resetShopListItemsAfterMove()
            self.updateTitleCacelToDone()
            self.updateMainCategoryList()
        }
    }
    
    func saveShopListItemUpdateCategoryToServerUsingNetwotk(_ userItemId: [PlanItShopItems], shopListItems: [PlanItShopListItems], prodCat: CategoryData?, prodSubCat: CategoryData?, userProdCat: CategoryData?) {
        
        let prodCatId = prodCat?.categoryId ?? 0
        let prodSubCatId = prodSubCat?.categoryId ?? 0
        let userProdCatId = userProdCat?.categoryId ?? 0.0
        
        
        if SocialManager.default.isNetworkReachable() && self.validateOfflineSyncData(shopListItems) {
            self.updateCategoryofShopItem(userItemId, shopListItems: shopListItems, prodCatId: prodCatId, prodSubCatId: prodSubCatId, userProdCatId: userProdCatId)
        }
        else if let shopListItem = shopListItems.first {
            userItemId.forEach { (shopItems) in
                if let prodCat = prodCat {
                    shopItems.updateMasterCategoryOffline(to: prodCat, ofItem: shopListItem)
                }
                else if let prodSubCat = prodSubCat {
                    shopItems.updateSubCategoryOffline(to: prodSubCat, ofItem: shopListItem)
                }
                else if let userProdCat = userProdCat, userProdCat.categoryId != 0.0 {
                    shopItems.updateUserCategoryOffline(to: userProdCat, ofItem: shopListItem)
                }
                else if let userProdCat = userProdCat, !userProdCat.categoryAppId.isEmpty {
                    shopItems.updateAppShopCategoryOffline(to: userProdCat, ofItem: shopListItem)
                }
            }
            self.updateTitleCacelToDone()
            self.updateSectionIncompleteShopListItem()
        }
    }
    
    func saveShopListItemInviteesToServerUsingNetwotk(_ invitees: [OtherUser]) {
        guard let shopList = self.planItShopList else { return }
        if SocialManager.default.isNetworkReachable() && !shopList.isPending {
            self.updateInvitees(invitees)
        }
        else if let user = Session.shared.readUser() {
            var sharedUser: [OtherUser] = invitees
            if !invitees.isEmpty {
                let selfUser = OtherUser(planItUser: user)
                selfUser.sharedStatus = 1.0
                sharedUser.append(selfUser)
            }
            shopList.updateShopListItemInvitees(sharedUser)
            self.delegate?.addShoppingItemsViewController(self, onUpdate: shopList)
        }
    }
    
    func saveShopListItemUpdateNameServerUsingNetwotk(_ name: String) {
        guard let shopList = self.planItShopList else { return }
        if SocialManager.default.isNetworkReachable() && !shopList.isPending {
            self.createWebServiceForUpdateShopListName(name)
        }
        else {
            shopList.updateShopListName(name)
            self.updateMainCategoryList()
        }
    }
    
    func deleteShopListToServerUsingNetwotk() {
        guard let shopList = self.planItShopList else { return }
        if SocialManager.default.isNetworkReachable(), !shopList.isPending {
            self.createWebServiceForDeleteShopList()
        }
        else {
            let deletedShopingListItems = shopList.readAllShopListItems().compactMap({ return LocalNotificationMethod.shopping.rawValue + $0.readValueOfNotificationId() })
            shopList.deleteOffline()
            Session.shared.removeShoppingNotifications(deletedShopingListItems)
            self.navigationController?.popViewController(animated: true)
            self.delegate?.addShoppingItemsViewController(self, deletedShopList: shopList)
        }
    }
    
    func removeShopListToServerUsingNetwotk() {
        guard let shopList = self.planItShopList else { return }
        if SocialManager.default.isNetworkReachable(), !shopList.isPending  {
            self.createWebServiceForRemoveShopList()
        }
        else {
            let deletedShopingListItems = shopList.readAllShopListItems().compactMap({ return LocalNotificationMethod.shopping.rawValue + $0.readValueOfNotificationId() })
            shopList.deleteOffline()
            Session.shared.removeShoppingNotifications(deletedShopingListItems)
            self.navigationController?.popViewController(animated: true)
            self.delegate?.addShoppingItemsViewController(self, deletedShopList: shopList)
        }
    }
}
