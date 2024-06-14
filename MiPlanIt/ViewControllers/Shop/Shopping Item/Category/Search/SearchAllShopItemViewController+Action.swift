//
//  SearchAllShopItemViewController+Action.swift
//  MiPlanIt
//
//  Created by Febin Paul on 05/11/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation
 
extension SearchAllShopItemViewController {
    
    func initilizeUIComponent() {
        self.viewQuantityOption.delegate = self
        self.showItems = self.sortItemAlphebtically(shopItem: self.shopAllItems) 
        self.addNotifications()
    }
    
    func getAllShopListItem() -> [ShopItem] {
        return self.findUniqueItems(DatabasePlanItShopItems().readAllShopItem()).map({ ShopItem($0) })
    }
    
    func filterShopListItemWithText(_ text: String) {
        let filteredItems = self.shopAllItems.filter({ $0.itemName.lowercased().contains(text.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()) })
        let items = filteredItems.isEmpty && text.isEmpty  ? self.shopAllItems : filteredItems
        self.showItems = self.sortItemAlphebtically(shopItem: items)
        self.viewQuantityOption.setVisibilityAddButton(show: !text.isEmpty)
    }
    
    func sortItemAlphebtically(shopItem: [ShopItem]) -> [ShopItem] {
        return shopItem.sorted { (shopItem1, shopItem2) -> Bool in
            guard let item1 = shopItem1.planItShopItem?.readItemName(), let item2 =  shopItem2.planItShopItem?.readItemName() else {
                return false
            }
            let category1 = (self.getCategoryName(item: shopItem1), item1)
            let category2 = (self.getCategoryName(item: shopItem2), item2)
            return category1 < category2
        }
    }
    
    func getCategoryName(item: ShopItem) -> String {
        if let itemstatus = item.planItShopItem, itemstatus.isCustom {
            let mainCategoryName = (item.planItShopItem?.readMasterCategoryName() ?? Strings.empty)
            return !(item.planItShopItem?.readUserCategoryName() ?? Strings.empty).isEmpty ? item.planItShopItem?.readUserCategoryName() ?? Strings.empty : (mainCategoryName.isEmpty ? "Others" : mainCategoryName)
        }
        else {
            let masterCategory = item.planItShopItem?.readMasterCategoryName() ?? Strings.empty
            return !masterCategory.isEmpty ? masterCategory : "Others"
        }
    }
    
    func allShopListItems() -> [PlanItShopListItems] {
        if let shopList = self.currentPlanItShopList, let specificShopList = DatabasePlanItShopList().readSpecificShop([shopList.shopListId]).first {
            return specificShopList.readAllAvailableShopListItems()
        }
        return []
    }
    
    func findUniqueItems(_ allItems: [PlanItShopItems])  -> [PlanItShopItems] {
        var uniqueItems:[PlanItShopItems] = []
        for eachItem in allItems {
            if uniqueItems.contains(where: { ($0.readItemName() == eachItem.readItemName()) }) { continue }
            uniqueItems.append(eachItem)
        }
        return uniqueItems
    }
    
    func addNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil )
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil )
    }
    
    func removeNotifications() {
        NotificationCenter.default.removeObserver(self, name:  UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name:  UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            self.constraintQuantityBottom.constant = keyboardRectangle.height
            if #available(iOS 11.0, *) {
                let bottomInset = UIApplication.shared.windows[0].safeAreaInsets.bottom
                self.constraintQuantityBottom.constant -= bottomInset
            }
            self.viewQuantityOption.isHidden = false
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        self.constraintQuantityBottom.constant = 0
        //self.viewQuantityOption.isHidden = true
    }
    
    func setQuantityForItem(_ value: String = Strings.empty, item: ShopItem) {
        item.itemSelected = false
        item.quantity = value.isEmpty ? item.quantity : value
        self.delegate?.searchAllShopItemViewController(self, selectedShopItem: item)
        //self.dismiss(animated: true, completion: nil)
        item.quantity = Strings.empty
        self.collectionView.reloadData()
        self.viewQuantityOption.enableTextField()
    }
    
    func checkIncompletedShopItemAlreadyExist(_ shopItem: ShopItem) -> PlanItShopListItems? {
        let filteredShopListItem = self.allShopListItems().filter { (shopListItem) -> Bool in
            if shopItem.readUserItemId() == 0.0 && !shopItem.readAppUserItemId().isEmpty {
                let itemId = shopItem.readAppUserItemId()
                return shopListItem.appShopItemId == itemId && !shopListItem.isCompletedLocal && shopListItem.isShopCustomItem
            }
            else {
                let itemId = shopItem.planItShopItem?.isCustom ?? false ? shopItem.planItShopItem?.userItemId : shopItem.planItShopItem?.masterItemId
                let isCustomItem = shopItem.planItShopItem?.isCustom ?? false
                return shopListItem.shopItemId == itemId && !shopListItem.isCompletedLocal && (isCustomItem ? shopListItem.isShopCustomItem : !shopListItem.isShopCustomItem)
            }
        }
        if let shopListItem = filteredShopListItem.first {
            return shopListItem
        }
        return nil
    }
    
    func checkCompleteShopItemAlreadyExist(_ shopItem: ShopItem) -> PlanItShopListItems? {
        let filteredShopListItem = self.allShopListItems().filter { (shopListItem) -> Bool in
            if shopItem.readUserItemId() == 0.0 && !shopItem.readAppUserItemId().isEmpty {
                let itemId = shopItem.readAppUserItemId()
                return shopListItem.appShopItemId == itemId && shopListItem.isCompletedLocal && shopListItem.isShopCustomItem
            }
            else {
                let itemId = shopItem.planItShopItem?.isCustom ?? false ? shopItem.planItShopItem?.userItemId : shopItem.planItShopItem?.masterItemId
                let isCustomItem = shopItem.planItShopItem?.isCustom ?? false
                return shopListItem.shopItemId == itemId && shopListItem.isCompletedLocal && (isCustomItem ? shopListItem.isShopCustomItem : !shopListItem.isShopCustomItem)
            }
        }
        if let shopListItem = filteredShopListItem.first {
            return shopListItem
        }
        return nil
    }
    
    func showMessageOnAddedOnCompleteItem(_ shopItem: ShopItem, toDetailScreen flag: Bool) {
        self.showAlertWithAction(message: Message.confirmationAddCompletedShopItem, items: [Message.yes, Message.no], callback: { index in
            if index == 0 {
                self.view.endEditing(true)
                if flag {
                    self.dismiss(animated: true) {
                        self.delegate?.searchAllShopItemViewController(self, showDetail: shopItem)
                    }
                }
                else {
                    self.setQuantityForItem(item: shopItem)
                }
            }
            else {
                // dont add
            }
        })
    }
    
    func showMessageOnAddedOnInCompleteItem(_ shopListItemCellModel: PlanItShopListItems, quantity: String) {
        self.showAlertWithAction(message: Message.confirmationAddInCompletedShopItem, items: [Message.yes, Message.no], callback: { index in
            if index == 0 {
                self.view.endEditing(true)
                // edit already added item
                self.dismiss(animated: true) {
                    self.delegate?.searchAllShopItemViewController(self, editShopListItem: shopListItemCellModel, withQuantity: quantity)
                }
            }
            else {
                // don't edit
            }
        })
    }
    
    func confirmationCheckOnAdd(shopItem: ShopItem, toDetailScreen flag: Bool = false) {
        if let existingItem = self.checkIncompletedShopItemAlreadyExist(shopItem) {
            self.showMessageOnAddedOnInCompleteItem(existingItem, quantity: shopItem.quantity)
        }
        else if self.checkCompleteShopItemAlreadyExist(shopItem) != nil {
            self.showMessageOnAddedOnCompleteItem(shopItem, toDetailScreen: flag)
        }
        else if flag {
            self.dismiss(animated: true) {
                self.delegate?.searchAllShopItemViewController(self, showDetail: shopItem)
            }
        }
        else {
            self.setQuantityForItem(item: shopItem)
        }
    }
}
