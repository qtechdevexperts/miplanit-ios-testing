//
//  ShopSubCategoryAndItems.swift
//  MiPlanIt
//
//  Created by Febin Paul on 09/11/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation


class ShopSubCategoryAndItems {
    
    var categoryName: String = Strings.empty
    var planItShopSubCategory: PlanItShopSubCategory?
    var shopItems: [ShopItem] = []
    var isSelected: Bool = false
    var isOther: Bool = false
    var isEditable: Bool = true
    
    init(_ planItShopSubCategory: PlanItShopSubCategory) {
        self.planItShopSubCategory = planItShopSubCategory
        self.categoryName = planItShopSubCategory.readCategoryName()
        self.shopItems = DatabasePlanItShopItems().readAllShopItemOfMasterSubCategory([planItShopSubCategory.readSubCategoryIdValue()]).map({ ShopItem($0) })
    }
    
    init(otherItems: [PlanItShopItems]) {
        self.categoryName = "Others"
        self.isOther = true
        self.shopItems = otherItems.map({ ShopItem($0) })
    }
    
    init(shopItems: [ShopItem]) {
        self.categoryName = "Others"
        self.isEditable = false
        self.shopItems = shopItems
    }
}
