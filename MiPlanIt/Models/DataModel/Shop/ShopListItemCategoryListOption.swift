//
//  ShopListItemCategoryListOption.swift
//  MiPlanIt
//
//  Created by Febin Paul on 13/11/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

class ShopListItemCategoryListOption {
    
    var shopMainCategory: PlanItShopMainCategory!
    var shopSubCategory: [ShopListItemSubCategoryListOption] = []
    var isExpanded: Bool = true
    var isSelected: Bool = false
    var orderId: Double = 0.0
    
    init(mainCategory: PlanItShopMainCategory, selectedMainCategoryId: Double?, selectedSubCategoryId: Double?, selectedUserCategoryId: Double?, selectedAppCategoryID: String?) {
        self.shopMainCategory = mainCategory
        self.orderId = mainCategory.orderId
        if let userCategoryId = selectedUserCategoryId, userCategoryId != 0 {
            self.isSelected = mainCategory.readUserCategoryIdValue() == userCategoryId
        }
        else if let mainCategoryId = selectedMainCategoryId, mainCategoryId != 0 && (selectedSubCategoryId == nil || selectedSubCategoryId == 0) {
            self.isSelected = mainCategory.readMasterCategoryIdValue() == mainCategoryId
        }
        else if let appCatId = selectedAppCategoryID, !appCatId.isEmpty && (selectedSubCategoryId == 0 || selectedSubCategoryId == nil) {
            self.isSelected = mainCategory.appShopCategoryId == selectedAppCategoryID
        }
        self.shopSubCategory = mainCategory.readAllShopSubCategory().map({ ShopListItemSubCategoryListOption(subCategory: $0, selectedSubCategoryId: selectedSubCategoryId) })
    }
}

class ShopListItemSubCategoryListOption {
    
    var subCategory: PlanItShopSubCategory!
    var isSelected: Bool = false
    
    init(subCategory: PlanItShopSubCategory, selectedSubCategoryId: Double? = nil) {
        self.subCategory = subCategory
        if let categoryId = selectedSubCategoryId, categoryId != 0 {
            self.isSelected = subCategory.readSubCategoryIdValue() == selectedSubCategoryId
        }
    }
}
