//
//  File.swift
//  MiPlanIt
//
//  Created by Febin Paul on 27/10/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation


class ShoppingItemOptionList {
    
    var name: String = Strings.empty
    var image: String = "default-category-image"
    var count: Int = 0
    var listOptionType :ShoppingListOptionType?
    var masterCategoryId: Double = 0
    var isBaseList: Bool = true
    var categoryOrderId: Double = 0.0
    var planItShopMainCategory: PlanItShopMainCategory?
    
    init(name: String, image: String, count: Int, listOptionType :ShoppingListOptionType) {
        self.name = name
        self.image = image
        self.count = count
        self.listOptionType = listOptionType
        self.isBaseList = true
    }
    
    init(shopItemMainCategory: PlanItShopMainCategory) {
        self.isBaseList = false
        self.masterCategoryId = !shopItemMainCategory.isCustom ? shopItemMainCategory.readMasterCategoryIdValue() : 0
        self.name = shopItemMainCategory.readCategoryName()
        self.image = shopItemMainCategory.readCategoryImage().isEmpty ? "default-category-image" : shopItemMainCategory.readCategoryImage()
        self.categoryOrderId = shopItemMainCategory.readOrderId()
        self.planItShopMainCategory = shopItemMainCategory
    }
}
