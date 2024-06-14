//
//  ShoppingItemListViewController+Callback.swift
//  MiPlanIt
//
//  Created by Febin Paul on 09/11/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

extension ShoppingItemListViewController: AddNewCategoryViewControllerDelegate {
    
    func addNewCategoryViewController(_ addNewCategoryViewController: AddNewCategoryViewController, update category: PlanItShopMainCategory) {
        self.delegate?.shoppingItemListViewControllerCategoryUpdated(self)
        self.setShoppingItems()
    }
    
    func addNewCategoryViewController(_ addNewCategoryViewController: AddNewCategoryViewController, add category: PlanItShopMainCategory) {
        self.arrayAllShopItemCategory.append(category)
        self.delegate?.shoppingItemListViewControllerCategoryUpdated(self)
        if !self.viewSortAlphabetically.isHidden {
            self.updateListOrder(self.buttonSortValue.isSelected ? .orderedDescending : .orderedAscending)
        }
        else {
            self.setShoppingItems()
        }
    }
}

extension ShoppingItemListViewController: MoreActionShopListDropDownControllerDelegate {
    
    func moreActionShopListDropDownController(_ controller: MoreActionShopListDropDownController, selectedOption: DropDownItem) {
        switch selectedOption.dropDownType {
        case .eDelete:
            break
        default:
            break
        }
    }
}

extension ShoppingItemListViewController: ShopItemCategoryViewControllerDelegate {
    
    func shopItemCategoryViewController(_ shopItemCategoryViewController: ShopItemCategoryViewController, addNewCetegory category: CategoryData) {
        self.updateWithAddedCategory(category)
    }
    
    func shopItemCategoryViewController(_ shopItemCategoryViewController: ShopItemCategoryViewController, selectedShopItemDetail: ShopListItemDetailModel) {
        self.delegate?.shoppingItemListViewController(self, addItemOnDetail: selectedShopItemDetail)
    }
    
    func shopItemCategoryViewController(_ shopItemCategoryViewController: ShopItemCategoryViewController, multiSelectedShopItem: [ShopListItemDetailModel]) {
        self.multiSelectedShopItem = multiSelectedShopItem
    }
    
    
    func shopItemCategoryViewControllerOnDetail(_ shopItemCategoryViewController: ShopItemCategoryViewController) {
        self.buttonBack.sendActions(for: .touchUpInside)
    }
    
    func shopItemCategoryViewController(_ shopItemCategoryViewController: ShopItemCategoryViewController, addedNew shopItem: ShopListItemDetailModel) {
        self.delegate?.shoppingItemListViewController(self, addedNewItem: shopItem)
    }
    
    func shopItemCategoryViewController(_ shopItemCategoryViewController: ShopItemCategoryViewController, addNew shopItem: ShopListItemDetailModel) {
        self.buttonBack.sendActions(for: .touchUpInside)
        self.delegate?.shoppingItemListViewController(self, addNewItem: shopItem)
    }
    
    // Add shop list item from selected item
    func shopItemCategoryViewController(_ shopItemCategoryViewController: ShopItemCategoryViewController, selectedShopItem: ShopListItemDetailModel, fromSearch flag: Bool) {
        self.delegate?.shoppingItemListViewController(self, addItem: selectedShopItem, onSearch: flag)
    }
}

extension ShoppingItemListViewController: SearchAllShopItemViewControllerDelegate {
    // Created new shop item After API call
    func searchAllShopItemViewController(_ searchAllShopItemViewController: SearchAllShopItemViewController, addedNewItem item: ShopListItemDetailModel) {
        guard currentPlanItShopList != nil else { return }
        self.delegate?.shoppingItemListViewController(self, addedNewItem: item)
    }
    
    func searchAllShopItemViewController(_ searchAllShopItemViewController: SearchAllShopItemViewController, showDetail shopItem: ShopItem) {
        self.performSegue(withIdentifier: Segues.showShopItemDetail, sender: shopItem)
    }
    
    func searchAllShopItemViewController(_ searchAllShopItemViewController: SearchAllShopItemViewController, addNew itemName: String) {
        guard let shopList = currentPlanItShopList else { return }
        self.delegate?.shoppingItemListViewController(self, addNewItem: ShopListItemDetailModel(newItem: itemName, onShopList: shopList))
    }
    
    func searchAllShopItemViewController(_ searchAllShopItemViewController: SearchAllShopItemViewController, selectedShopItem: ShopItem) {
        guard let planItShopItem = selectedShopItem.planItShopItem,  let shopList = currentPlanItShopList else { return }
        self.delegate?.shoppingItemListViewController(self, addItem: ShopListItemDetailModel(shopItem: planItShopItem, quantity: selectedShopItem.quantity, onShopList: shopList), onSearch: true)
    }
    
    func searchAllShopItemViewControllerOnClose(_ searchAllShopItemViewController: SearchAllShopItemViewController) {
        
    }
    
    func searchAllShopItemViewController(_ searchAllShopItemViewController: SearchAllShopItemViewController, editShopListItem shopItem: PlanItShopListItems, withQuantity quantity: String) {
        self.delegate?.shoppingItemListViewController(self, editShopListItem: shopItem, withQuantity: quantity)
    }
}


extension ShoppingItemListViewController: ShoppingItemDetailViewControllerDelegate {
    
    func shoppingItemDetailViewController(_ shoppingItemDetailViewController: ShoppingItemDetailViewController, onAddUserCategory: CategoryData) {
        self.updateWithAddedCategory(onAddUserCategory)
    }
    
    func shoppingItemDetailViewController(_ shoppingItemDetailViewController: ShoppingItemDetailViewController, addUpdateItemDetail: ShopListItemDetailModel) {
        self.delegate?.shoppingItemListViewController(self, addItem: addUpdateItemDetail, onSearch: false)
    }
    
    func shoppingItemDetailViewController(_ shoppingItemDetailViewController: ShoppingItemDetailViewController, onDeleteShopListItem: ShopListItemDetailModel) {
        
    }
}
