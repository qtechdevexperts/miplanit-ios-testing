//
//  OfflineTriggerShopping.swift
//  MiPlanIt
//
//  Created by Febin Paul on 01/12/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation


extension Session {
    
    func sendShopListToServer(_ finished: @escaping () -> ()) {
        let allPendingShopList = DatabasePlanItShopList().readAllPendingShopList()
        if allPendingShopList.isEmpty {
            self.sendDeleteShopListToServer(finished)
        }
        else {
            self.startShopListSending(allPendingShopList) {
                self.sendDeleteShopListToServer(finished)
            }
        }
    }
    
    private func startShopListSending(_ shopLists: [PlanItShopList], atIndex: Int = 0, finished: @escaping () -> ()) {
        if atIndex < shopLists.count {
            self.sendShopListToServer(shopList: shopLists[atIndex], at: atIndex, result: { index in
                self.startShopListSending(shopLists, atIndex: index + 1, finished: finished)
            })
        }
        else {
            finished()
        }
    }
    
    private func sendShopListToServer(shopList: PlanItShopList, at index: Int, result: @escaping (Int) -> ()) {
        let shopListModel = ShopList(with: shopList)
        ShopService().addShopList(shopListModel) { (response, error) in
            if let _ = response {
                self.sendShopListImageToServer(shopList: shopListModel, at: index, result: result)
            }
            else {
                result(index)
            }
        }
    }
    
    private func sendShopListImageToServer(shopList: ShopList, at index: Int, result: @escaping (Int) -> ()) {
        if let user = Session.shared.readUser(), let planItShopList = shopList.shopListData, let data = planItShopList.shopListImageData, !data.isEmpty {
            let fileName = String(Date().millisecondsSince1970) + Extensions.png
            ShopService().uploadShopListImages(planItShopList, file: data.base64EncodedString(options: .lineLength64Characters), name: fileName, by: user) { (_, _) in
                result(index)
            }
        }
        else {
            result(index)
        }
    }
    
    func sendDeleteShopListToServer(_ finished: @escaping () -> ()) {
        let pendingDeletedShopList = DatabasePlanItShopList().readAllPendingDeletedShopList()
        if pendingDeletedShopList.isEmpty {
            finished()
        }
        else {
            self.startDeletedShopListSending(pendingDeletedShopList) {
                finished()
            }
        }
    }
    
    private func startDeletedShopListSending(_ shopLists: [PlanItShopList], atIdex: Int = 0, finished: @escaping () -> ()) {
        if atIdex < shopLists.count {
            self.sendDeletedShopListToServer(shopList: shopLists[atIdex], at: atIdex, result: { index in
                self.startDeletedShopListSending(shopLists, atIdex: index + 1, finished: finished)
            })
        }
        else {
            finished()
        }
    }
    
    private func sendDeletedShopListToServer(shopList: PlanItShopList, at index: Int, result: @escaping (Int) -> ()) {
        if shopList.readShopListIdValue() != 0.0 {
            ShopService().deleteShopList(shopList) { (shopList, error) in
                result(index)
            }
        }
        else if !shopList.readAppShopListID().isEmpty {
            shopList.deleteItSelf()
            CoreData.default.mainManagedObjectContext.saveContext()
            result(index)
        }
        else {
            result(index)
        }
    }
    
    func sendDeletedShopUserCategoryToServer(_ finished: @escaping () -> ()) {
        let allPendingDeletedShopCategory = DatabasePlanItShopMasterCategory().readAllPendingDeletedShopCategory()
        if allPendingDeletedShopCategory.isEmpty {
            finished()
        }
        else {
            self.sendDeletedShopCategoryToServer(shopCategorys: allPendingDeletedShopCategory) {
                finished()
            }
        }
    }
    
    private func sendDeletedShopCategoryToServer(shopCategorys: [PlanItShopMainCategory], result: @escaping () -> ()) {
        ShopService().removeShopCategory(shopCategorys) { (ids, error) in
            result()
        }
    }
    
    func sendShopUserCategoryToServer(_ finished: @escaping () -> ()) {
        let allPendingShopCategory = DatabasePlanItShopMasterCategory().readAllPendingShopCategory()
        if allPendingShopCategory.isEmpty {
            finished()
        }
        else {
            self.startShopCategorySending(allPendingShopCategory) {
                finished()
            }
        }
    }
    
    private func startShopCategorySending(_ shopCategorys: [PlanItShopMainCategory], atIndex: Int = 0, finished: @escaping () -> ()) {
        if atIndex < shopCategorys.count {
            self.sendShopCategoryToServer(shopCategory: shopCategorys[atIndex], at: atIndex) { (index) in
                self.startShopCategorySending(shopCategorys, atIndex: index + 1, finished: finished)
            }
        }
        else {
            finished()
        }
    }
    
    private func sendShopCategoryToServer(shopCategory: PlanItShopMainCategory, at index: Int, result: @escaping (Int) -> ()) {
        ShopService().addShopCategory(shopCategory.readCategoryName(), appCategoryId: shopCategory.readUserAppCategoryId()) { (response, error) in
            result(index)
        }
    }
    
    func sendPendingShopListItemAttachmentsToServer(finished: @escaping () -> ()) {
        let pendingAttachments = DatabasePlanItUserAttachment().readAllPendingAttachements().filter({ $0.shopListItem != nil })
        if pendingAttachments.isEmpty {
            finished()
        }
        else {
            self.uploadPendingShopListItemAttachmentsToServer(pendingAttachments, finished: finished)
        }
    }
    
    func uploadPendingShopListItemAttachmentsToServer(_ attachments: [PlanItUserAttachment], at index: Int = 0, finished: @escaping () -> ()) {
        guard index < attachments.count else { finished(); return }
        let ownerIdValue = attachments[index].shopListItem?.createdBy?.readValueOfUserId()
        let convertedAttachment = UserAttachment(with: attachments[index], type: .shopping, ownerId: ownerIdValue)
        UserService().uploadAttachement(convertedAttachment, callback: { attachment, _ in
            if let result = attachment {
                attachments[index].saveShopListAttachmentIdentifier(result.identifier)
            }
            self.uploadPendingShopListItemAttachmentsToServer(attachments, at: index + 1, finished: finished)
        })
    }
    
    
    
    func sendShopListItemToServer(_ finished: @escaping () -> ()) {
        let allPendingShopListItem = DatabasePlanItShopListItem().readAllPendingShopListItem()
        if allPendingShopListItem.isEmpty {
            self.sendDeleteShopListItemToServer(finished)
        }
        else {
            self.startShopListItemSending(allPendingShopListItem) {
                self.sendDeleteShopListItemToServer(finished)
            }
        }
    }
    
    private func startShopListItemSending(_ shopListItems: [PlanItShopListItems], atIndex: Int = 0, finished: @escaping () -> ()) {
        if atIndex < shopListItems.count {
            self.sendShopListItemToServer(shopListItem: shopListItems[atIndex], at: atIndex) { (index) in
                self.startShopListItemSending(shopListItems, atIndex: index + 1, finished: finished)
            }
        }
        else {
            finished()
        }
    }
    
    private func sendShopListItemToServer(shopListItem: PlanItShopListItems, at index: Int, result: @escaping (Int) -> ()) {
        ShopService().addShopListItem(shopListItem) { (response, error) in
            result(index)
        }
    }
    
    func sendDeleteShopListItemToServer(_ finished: @escaping () -> ()) {
        let pendingDeletedShopListItem = DatabasePlanItShopListItem().readAllPendingDeleteShopListItem()
        if pendingDeletedShopListItem.isEmpty {
            finished()
        }
        else {
            self.startDeletedShopListItemSending(pendingDeletedShopListItem) {
                finished()
            }
        }
    }
    
    private func startDeletedShopListItemSending(_ shopListItems: [PlanItShopListItems], atIdex: Int = 0, finished: @escaping () -> ()) {
        if atIdex < shopListItems.count {
            self.sendDeletedShopListItemToServer(shopListItem: shopListItems[atIdex], at: atIdex, result: { index in
                self.startDeletedShopListItemSending(shopListItems, atIdex: index + 1, finished: finished)
            })
        }
        else {
            finished()
        }
    }
    
    private func sendDeletedShopListItemToServer(shopListItem: PlanItShopListItems, at index: Int, result: @escaping (Int) -> ()) {
        if let planItShopList =  shopListItem.shopList, shopListItem.readShopListItemsIdValue() != 0.0 {
            ShopService().deleteShopListItems([shopListItem], shop: planItShopList) { (shopList, error) in
                result(index)
            }
        }
        else {
            shopListItem.deleteShopItem()
            shopListItem.deleteItSelf()
            CoreData.default.mainManagedObjectContext.saveContext()
            result(index)
        }
    }
    
    func sendShopListItemMovesToServer(_ finished: @escaping () -> ()) {
        let pendingMovedShopListItem = DatabasePlanItShopListItem().readAllPendingMovedShopListItems()
        if pendingMovedShopListItem.isEmpty {
            finished()
        }
        else {
            let groupedMovedTo = Dictionary(grouping: pendingMovedShopListItem, by: { $0.readShopListIdValue() })
            self.startShopListItemMoveSending(groupedMovedTo.compactMap({ $0.value })) {
                finished()
            }
        }
    }
    
    private func startShopListItemMoveSending(_ shopListItems: [[PlanItShopListItems]], atIndex: Int = 0, finished: @escaping () -> ()) {
        if atIndex < shopListItems.count {
            self.sendShopListItemMoveToServer(shopListItem: shopListItems[atIndex], at: atIndex) { (index) in
                self.startShopListItemMoveSending(shopListItems, atIndex: index + 1, finished: finished)
            }
        }
        else {
            finished()
        }
    }
    
    private func sendShopListItemMoveToServer(shopListItem: [PlanItShopListItems], at index: Int, result: @escaping (Int) -> ()) {
        guard let item = shopListItem.first, let fromList = item.movedFrom else { result(index); return }
        ShopService().movePendingShopListItem(shopListItem, fromListId: fromList, toListId: item.readShopListId()) { (response, error) in
            result(index)
        }
    }
    
    func sendCompletionStatusShopListItemToServer(_ finished: @escaping () -> ()) {
        let allPendingShopListItem = DatabasePlanItShopListItem().readAllPendingCompletionStatusShopListItem()
        if allPendingShopListItem.isEmpty {
            finished()
        }
        else {
            let groupedByShopList = Dictionary(grouping: allPendingShopListItem, by: { $0.readShopListIdValue() })
            self.startCompletionStatusShopListItemSending(groupedByShopList.compactMap({ $0.value })) {
                finished()
            }
        }
    }
    
    private func startCompletionStatusShopListItemSending(_ shopListItems: [[PlanItShopListItems]], atIndex: Int = 0, finished: @escaping () -> ()) {
        if atIndex < shopListItems.count {
            self.sendCompletionUpdateToServer(shopListItem: shopListItems[atIndex], at: atIndex) { (index) in
                self.startCompletionStatusShopListItemSending(shopListItems, atIndex: index + 1, finished: finished)
            }
        }
        else {
            finished()
        }
    }
    
    private func sendCompletionUpdateToServer(shopListItem: [PlanItShopListItems], at index: Int, result: @escaping (Int) -> ()) {
        guard let shopList = shopListItem.first?.shopList else { result(index); return }
        let inCompletedItems = shopListItem.filter({ !$0.isCompletedLocal })
        let completedItems = shopListItem.filter({ $0.isCompletedLocal })
        self.completionShopListItemToServer(shopListItem: inCompletedItems, shopList: shopList, status: false) {
            self.completionShopListItemToServer(shopListItem: completedItems, shopList: shopList, status: true) {
                result(index)
            }
        }
    }
    
    private func completionShopListItemToServer(shopListItem: [PlanItShopListItems], shopList: PlanItShopList, status: Bool, finished: @escaping () -> ()) {
        if !shopListItem.isEmpty {
            ShopService().shopListItemMarkAsComplete(shopListItem, shop: shopList, with: status) { (response, error) in
                finished()
            }
        }
        else {
            finished()
        }
    }
    
    func sendFavoriteStatusShopListItemToServer(_ finished: @escaping () -> ()) {
        let allPendingShopListItem = DatabasePlanItShopListItem().readAllPendingFavoriteStatusShopListItem()
        if allPendingShopListItem.isEmpty {
            finished()
        }
        else {
            let groupedByShopList = Dictionary(grouping: allPendingShopListItem, by: { $0.readShopListIdValue() })
            self.startFavoriteStatusShopListItemSending(groupedByShopList.compactMap({ $0.value })) {
                finished()
            }
        }
    }
    
    private func startFavoriteStatusShopListItemSending(_ shopListItems: [[PlanItShopListItems]], atIndex: Int = 0, finished: @escaping () -> ()) {
        if atIndex < shopListItems.count {
            self.sendFavoriteUpdateToServer(shopListItem: shopListItems[atIndex], at: atIndex) { (index) in
                self.startFavoriteStatusShopListItemSending(shopListItems, atIndex: index + 1, finished: finished)
            }
        }
        else {
            finished()
        }
    }
    
    private func sendFavoriteUpdateToServer(shopListItem: [PlanItShopListItems], at index: Int, result: @escaping (Int) -> ()) {
        guard let shopList = shopListItem.first?.shopList else { result(index); return }
        let unFavoriteItems = shopListItem.filter({ !$0.isFavoriteLocal })
        let favoriteItems = shopListItem.filter({ $0.isFavoriteLocal })
        self.favoriteShopListItemToServer(shopListItem: unFavoriteItems, shopList: shopList, status: false) {
            self.favoriteShopListItemToServer(shopListItem: favoriteItems, shopList: shopList, status: true) {
                result(index)
            }
        }
    }
    
    private func favoriteShopListItemToServer(shopListItem: [PlanItShopListItems], shopList: PlanItShopList, status: Bool, finished: @escaping () -> ()) {
        if !shopListItem.isEmpty {
            ShopService().shopListItemMarkAsFavorites(shopListItem, shop: shopList, with: status) { (response, error) in
                finished()
            }
        }
        else {
            finished()
        }
    }
}
