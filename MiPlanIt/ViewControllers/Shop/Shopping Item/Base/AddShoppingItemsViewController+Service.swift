//
//  ToDoListBaseViewController+Service.swift
//  MiPlanIt
//
//  Created by Arun on 14/07/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

extension AddShoppingItemsViewController {
    
    func createWebServiceToAddNewCustomShopListItem(_ details: ShopListItemDetailModel) {
        ShopService().updateShopListDetail(details) { (result, error) in
            if result{
                self.refreshUpdateItemDetail(details)
            }
            else {
                let message = error ?? Message.unknownError
                self.performSegue(withIdentifier: Segues.toMessageScreen, sender: [Message.error, message])
            }
        }
    }

    func createWebServiceToAddShopListItem(_ shopListItems: [PlanItShopListItems], shopListItemCellModel: ShopListItemCellModel, reloadAfter: Bool = true) {
        guard let shopListItem = shopListItems.first else { return }
        self.startLoadingIndicatorForShopListItem(shopListItems)
        ShopService().addShopListItem(shopListItem) { (shopListItem, error) in
            self.stopLoadingIndicatorForTodos(shopListItems)
            if let item = shopListItem {
                shopListItemCellModel.shopListItemId = item.shopListItemId
                if reloadAfter {
                    self.tableViewToDoItems?.reloadData()
                }
                self.setVisibilityTopStackView()
                self.updateMainCategoryList()
            }
            else {
                let message = error ?? Message.unknownError
                self.performSegue(withIdentifier: Segues.toMessageScreen, sender: [Message.error, message])
            }
        }
    }
    
    func createWebServiceToUpdateDueDateShopListItems(_ shopListItems: [PlanItShopListItems], dueDate: Date) {
        guard let shopList = self.planItShopList else { return }
        self.startLoadingIndicatorForShopListItem(shopListItems)
        ShopService().updateDueDateShopListItems(shopListItems, shopList: shopList, dueDate: dueDate) { (status, error) in
            self.stopLoadingIndicatorForTodos(shopListItems)
            self.updateTitleCacelToDone()
            if status {
                self.resetShopListItemsBasedOnSearchAndSort()
            }
            else {
                let message = error ?? Message.unknownError
                self.performSegue(withIdentifier: Segues.toMessageScreen, sender: [Message.error, message])
            }
        }
    }
    
    func createWebServiceToDeleteShopListItems(_ shopListItems: [PlanItShopListItems]) {
        guard let shopList = self.planItShopList else { return }
        self.startLoadingIndicatorForShopListItem(shopListItems)
        ShopService().deleteShopListItems(shopListItems, shop: shopList) { (status, error) in
            self.stopLoadingIndicatorForTodos(shopListItems)
            if status {
                self.allShopListItem.removeAll { (model) -> Bool in
                    shopListItems.contains(model.planItShopListItem)
                }
                self.resetShopListItemsAfterDelete()
                self.updateCompletedTable(showList: false)
                self.updateTitleCacelToDone()
                self.updateMainCategoryList()
            }
            else {
                let message = error ?? Message.unknownError
                self.performSegue(withIdentifier: Segues.toMessageScreen, sender: [Message.error, message])
            }
        }
    }
    
    func createWebServiceToCompleteShopListItem(_ shopListItems: [PlanItShopListItems], with status: Bool) {
        guard let shopList = self.planItShopList else { return }
        self.startLoadingIndicatorForShopListItem(shopListItems)
        ShopService().shopListItemMarkAsComplete(shopListItems, shop: shopList, with: status) { (result, error) in
            self.stopLoadingIndicatorForTodos(shopListItems)
            if result {
                self.resetShopListItemsAfterComplete()
                status ? self.updateUndoSection(on: shopListItems) : self.updateCompletedTable()
                self.updateTitleCacelToDone()
                self.updateMainCategoryList()
            }
            else{
                let message = error ?? Message.unknownError
                self.performSegue(withIdentifier: Segues.toMessageScreen, sender: [Message.error, message])
            }
        }
    }
    
    func createWebServiceToFavoriteShopListItem(_ shopListItems: [PlanItShopListItems], with status: Bool) {
        guard let shopList = self.planItShopList else { return }
        self.startLoadingIndicatorForShopListItem(shopListItems)
        ShopService().shopListItemMarkAsFavorites(shopListItems, shop: shopList, with: status) { (result, error) in
            self.stopLoadingIndicatorForTodos(shopListItems)
            self.updateTitleCacelToDone()
            if result {
                self.resetShopListItemsAfterFavorite()
            }
            else{
                let message = error ?? Message.unknownError
                self.performSegue(withIdentifier: Segues.toMessageScreen, sender: [Message.error, message])
            }
        }
        
    }
    
    func createWebServiceToMoveShopListItem(_ shopListItems: [PlanItShopListItems], toList: PlanItShopList) {
        guard let shopList = self.planItShopList else { return }
        self.startLoadingIndicatorForShopListItem(shopListItems)
        ShopService().moveShopListItem(shopListItems, fromList: shopList, toList: toList) { (shopList, error) in
            self.stopLoadingIndicatorForTodos(shopListItems)
            if shopList != nil {
                if toList != self.planItShopList {
                    self.allShopListItem.removeAll { (shopListItemCellModel) -> Bool in
                        shopListItems.contains(shopListItemCellModel.planItShopListItem)
                    }
                    self.resetShopListItemsAfterMove()
                    self.updateTitleCacelToDone()
                    self.updateMainCategoryList()
                }
            }
            else {
                let message = error ?? Message.unknownError
                self.performSegue(withIdentifier: Segues.toMessageScreen, sender: [Message.error, message])
            }
        }
    }
    
    func updateCategoryofShopItem(_ userItemId: [PlanItShopItems], shopListItems: [PlanItShopListItems], prodCatId: Double, prodSubCatId: Double, userProdCatId: Double) {
        self.startLoadingIndicatorForShopListItem(shopListItems)
        let prodCategoryId = prodCatId != 0 ? "\(prodCatId)" : ""
        let prodSubCategoryId = prodSubCatId != 0 ? "\(prodSubCatId)" : ""
        let userCategoryId = userProdCatId != 0 ? "\(userProdCatId)" : ""
        ShopService().updateCategoryOfShopListItem(userItemId, prodCatId: prodCategoryId, prodSubCatId: prodSubCategoryId, userProdCatId: userCategoryId) { (shopItems, error) in
            self.stopLoadingIndicatorForTodos(shopListItems)
            self.updateTitleCacelToDone()
            if shopItems != nil {
                self.updateSectionIncompleteShopListItem()
            }
            else {
                let message = error ?? Message.unknownError
                self.performSegue(withIdentifier: Segues.toMessageScreen, sender: [Message.error, message])
            }
        }
    }
    
    func createWebServiceForRemoveShopList() {
        guard let shopList = self.planItShopList else { return }
        self.buttonLoader.isHidden = false
        self.buttonLoader.startAnimation()
        ShopService().removeShopList(ShopList(with: shopList)) { (response, error) in
            if let _ = response {
                self.buttonLoader.stopAnimation(animationStyle: .normal, revertAfterDelay: 0) {
                    self.navigationController?.popViewController(animated: true)
                    self.delegate?.addShoppingItemsViewController(self, deletedShopList: shopList)
                }
            }
            else {
                self.buttonLoader.stopAnimation(animationStyle: .shake, revertAfterDelay: 0) {
                    self.buttonLoader.isHidden = true
                    let message = error ?? Message.unknownError
                    self.performSegue(withIdentifier: Segues.toMessageScreen, sender: [Message.error, message])
                }
            }
        }
    }
    
    func createWebServiceForDeleteShopList() {
        guard let shopList = self.planItShopList else { return }
        self.buttonLoader.isHidden = false
        self.buttonLoader.startAnimation()
        ShopService().deleteShopList(shopList) { (response, error) in
            if let _ = response {
                self.buttonLoader.stopAnimation(animationStyle: .normal, revertAfterDelay: 0) {
                    self.navigationController?.popViewController(animated: true)
                    self.delegate?.addShoppingItemsViewController(self, deletedShopList: shopList)
                }
            }
            else {
                self.buttonLoader.stopAnimation(animationStyle: .shake, revertAfterDelay: 0) {
                    self.buttonLoader.isHidden = true
                    let message = error ?? Message.unknownError
                    self.performSegue(withIdentifier: Segues.toMessageScreen, sender: [Message.error, message])
                }
            }
        }
    }
    
    func updateInvitees(_ invitees: [OtherUser]) {
        guard let shopList = self.planItShopList else { return }
        self.buttonLoader.startAnimation()
        ShopService().shareShopInvitees(invitees, shopList: shopList) { (result, error) in
            if result {
                self.buttonLoader.stopAnimation(animationStyle: .normal, revertAfterDelay: 0) {
                    self.delegate?.addShoppingItemsViewController(self, onUpdate: shopList)
                }
            }
            else{
                let message = error ?? Message.unknownError
                self.buttonLoader.stopAnimation(animationStyle: .shake, revertAfterDelay: 0) {
                    self.performSegue(withIdentifier: Segues.toMessageScreen, sender: [Message.error, message])
                }
            }
        }
    }
    
    func createWebServiceForUpdateShopListName(_ name: String) {
        guard let shopList = self.planItShopList else { return }
        self.buttonLoader.startAnimation()
        ShopService().updateNameShopList(withName: name, shopList: shopList) { (result, error) in
            if result {
                self.buttonLoader.stopAnimation(animationStyle: .normal, revertAfterDelay: 0) {
                    self.delegate?.addShoppingItemsViewController(self, onUpdate: shopList)
                }
            }
            else {
                let message = error ?? Message.unknownError
                self.buttonLoader.stopAnimation(animationStyle: .shake, revertAfterDelay: 0) {
                    self.performSegue(withIdentifier: Segues.toMessageScreen, sender: [Message.error, message])
                }
            }
        }
    }
    //MARK: pull to refresh
    func createWebServiceMasterDataInsidePullToRefresh(completion: @escaping ([ServiceDetection])->()) {
        guard let user = Session.shared.readUser() else {
            completion([])
            return
        }
        ShopService().getShopMasterItem(user, callback: { result, masterServiceDetection, error in
            if result {
                self.createWebServiceUsersMasterDataInsidePullToRefresh(user, masterServiceDetection, completion)
            }
            else {
                completion([])
            }
        })
    }
    
    func createWebServiceUsersMasterDataInsidePullToRefresh(_ user: PlanItUser, _ userServiceDetection: [ServiceDetection], _ completion: @escaping ([ServiceDetection])->()) {
        ShopService().getUserShopItem(user, callback: { result, serviceDetection, error in
            if result {
                self.createServiceToUsersShopingListInsidePullToRefresh(user, serviceDetection+userServiceDetection, completion)
            }
            else {
                completion([])
            }
        })
    }
    
    func createServiceToUsersShopingListInsidePullToRefresh(_ user: PlanItUser, _ shopDataServiceDetection: [ServiceDetection], _ completion: @escaping ([ServiceDetection])->()) {
        ShopService().fetchUsersShoppingServerData(user, callback: { result, serviceDetection, error in
            if result {
                completion(serviceDetection+shopDataServiceDetection)
            }
            else {
                completion([])
            }
        })
    }
    
}
