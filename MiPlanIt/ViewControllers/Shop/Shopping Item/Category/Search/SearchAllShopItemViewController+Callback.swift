//
//  SearchAllShopItemViewController+Callback.swift
//  MiPlanIt
//
//  Created by Febin Paul on 05/11/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

extension SearchAllShopItemViewController : ShopMasterItemCellDelegate {
    
    func shopMasterItemCell(_ shopMasterItemCell: ShopMasterItemCell, customQuantity: String) {
        self.currentSelectedShopItem?.quantity = customQuantity
    }
    
    func shopMasterItemCell(_ shopMasterItemCell: ShopMasterItemCell, addQuantity: String) {
        self.collectionView.contentOffset = .zero
        guard let shopItem = self.currentSelectedShopItem else { return }
        self.confirmationCheckOnAdd(shopItem: shopItem)
    }
    
    func shopMasterItemCell(_ shopMasterItemCell: ShopMasterItemCell, onEdit: IndexPath) {
        self.collectionView.contentOffset = CGPoint(x: 0, y: shopMasterItemCell.frame.minY)
    }
}


extension SearchAllShopItemViewController: ShopItemQuantityOptionViewDelegate {
    
    func shopItemQuantityOptionView(_ shopItemQuantityOptionView: ShopItemQuantityOptionView, addNew itemName: String) {
        let trimmedname = itemName.trimmingCharacters(in: .whitespacesAndNewlines)
        let filteredItems = self.shopAllItems.filter({ $0.itemName.lowercased() == trimmedname.lowercased() })
        if let shopItem = filteredItems.first {
            self.confirmationCheckOnAdd(shopItem: shopItem, toDetailScreen: true)
        }
        else {
            self.addNewShopListItemUsingNetwork(trimmedname)
        }
    }
    
    func shopItemQuantityOptionViewDismissKeyboard(_ shopItemQuantityOptionView: ShopItemQuantityOptionView) {
        self.showItems = self.sortItemAlphebtically(shopItem: self.shopAllItems)
        self.viewQuantityOption.setVisibilityAddButton(show: false)
    }
    
    func shopItemQuantityOptionView(_ shopItemQuantityOptionView: ShopItemQuantityOptionView, searchText: String) {
        self.filterShopListItemWithText(searchText)
    }
    
    func shopItemQuantityOptionView(_ shopItemQuantityOptionView: ShopItemQuantityOptionView, selectedQuantity: String) {
        guard let shopItem = self.currentSelectedShopItem else { return }
        if selectedQuantity == Strings.details {
            self.confirmationCheckOnAdd(shopItem: shopItem, toDetailScreen: true)
        }
        else if shopItem.planItShopItem != nil {
            shopItem.quantity = selectedQuantity
            self.confirmationCheckOnAdd(shopItem: shopItem, toDetailScreen: false)
        }
    }
}
