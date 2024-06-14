//
//  ShopListItemCellModel.swift
//  MiPlanIt
//
//  Created by Febin Paul on 10/11/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

class ShopListItemCellModel {
    
    var planItShopListItem: PlanItShopListItems!
    var editSelected: Bool = false
    var shopItem: PlanItShopItems?
    var shopListItemId: Double = 0
    var shopListItemQuantity: String = Strings.empty
    var isPending: Bool = false
    
    init(planItShopListItem: PlanItShopListItems) {
        self.planItShopListItem = planItShopListItem
        self.shopListItemId = self.planItShopListItem.shopListItemId
        self.isPending = planItShopListItem.isPending
        if planItShopListItem.shopItemId == 0.0, let appShopItemId = planItShopListItem.appShopItemId, !appShopItemId.isEmpty, let shopItem = DatabasePlanItShopItems().readSpecificAppShopItem(appShopItemId).first {
            self.shopItem = shopItem
        }
        else if let shopItem = self.planItShopListItem.isShopCustomItem ? DatabasePlanItShopItems().readSpecificUserShopItem([planItShopListItem.shopItemId]).first : DatabasePlanItShopItems().readSpecificMasterShopItem([planItShopListItem.shopItemId]).first {
            self.shopItem = shopItem
        }
    }
    
    func readShopItemCategoryName() -> String {
        return (self.shopItem?.readUserCategoryName() ?? Strings.empty).isEmpty ? (self.shopItem?.readMasterCategoryName() ?? Strings.empty) : (self.shopItem?.readUserCategoryName() ?? Strings.empty)
    }
}
