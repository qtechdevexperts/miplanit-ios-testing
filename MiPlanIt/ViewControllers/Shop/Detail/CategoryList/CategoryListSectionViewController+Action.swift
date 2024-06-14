//
//  CategoryListSectionViewController+Action.swift
//  MiPlanIt
//
//  Created by Febin Paul on 13/11/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

extension CategoryListSectionViewController {
    
    func createdCategoryList() {
        self.categoryItems = self.getAllShopCategory().map({ ShopListItemCategoryListOption(mainCategory: $0, selectedMainCategoryId: self.selectedMainCategory?.categoryId, selectedSubCategoryId: self.selectedSubCategory?.categoryId, selectedUserCategoryId: self.selectedUserCategory?.categoryId, selectedAppCategoryID: self.selectedUserCategory?.categoryAppId) })
    }
    
    func getAllShopCategory() -> [PlanItShopMainCategory] {
        var allCategories = DatabasePlanItShopMasterCategory().readAllShopCategory()
        let allCustomCategory = allCategories.filter({ $0.isCustom })
        if !allCustomCategory.isEmpty {
            allCategories.removeAll { (category) -> Bool in
                allCustomCategory.contains { (customCategory) -> Bool in
                    customCategory == category
                }
            }
            allCategories.append(contentsOf: allCustomCategory)
        }
        if let otherCategoryIndex = allCategories.firstIndex(where: { return $0.masterCategoryId == 1 && !$0.isCustom }) {
            let otherCategoryList = allCategories.remove(at: otherCategoryIndex)
            allCategories.append(otherCategoryList)
        }
        return allCategories
    }
    
    func updateListOrder(_ comparisonResult: ComparisonResult? = nil) {
        if let orderBy = comparisonResult {
            self.categoryItems.sort { (list1, list2) -> Bool in
                list1.shopMainCategory.readCategoryName().localizedCaseInsensitiveCompare(list2.shopMainCategory.readCategoryName()) == orderBy
            }
        }
        else {
            let nonOrderItems =  self.categoryItems.filter({ $0.orderId == 0.0 })
            var orderedItems = self.categoryItems.filter({ $0.orderId != 0.0 })
            orderedItems.sort { (list1, list2) -> Bool in
                list1.orderId < list2.orderId
            }
            orderedItems.append(contentsOf: nonOrderItems)
            self.categoryItems = orderedItems
            self.buttonSortValue.isSelected = false
        }
    }
    
    func removeAllSelectionCategory() {
        self.categoryItems.forEach({ $0.isSelected = false; $0.shopSubCategory.forEach({ $0.isSelected = false }) })
        self.selectedMainCategory = nil
        self.selectedUserCategory = nil
        self.selectedSubCategory = nil
    }
    
    func addSelectionForMainCategory(id: Double) {
        self.categoryItems.filter({ $0.shopMainCategory.readMasterCategoryIdValue() == id }).first?.isSelected = true
    }
    
    func addSelectionForSubCategory(id: Double, inMainId: Double) {
        if let mainCategory = self.categoryItems.filter({ $0.shopMainCategory.readMasterCategoryIdValue() == inMainId }).first {
            mainCategory.shopSubCategory.filter({ $0.subCategory.readSubCategoryIdValue() == id }).first?.isSelected = true
        }
    }
    
    func addSelectionForUserCategory(id: Any) {
        if let doubleId = id as? Double {
            self.categoryItems.filter({ $0.shopMainCategory.readUserCategoryIdValue() == doubleId }).first?.isSelected = true
        }
        else if let appId = id as? String {
            self.categoryItems.filter({ $0.shopMainCategory.readUserAppCategoryId() == appId }).first?.isSelected = true
        }
    }
    
    func updateSelection(userCat: CategoryData? = nil, subCat: CategoryData? = nil, main: CategoryData? = nil) {
        self.removeAllSelectionCategory()
        if let category = userCat {
            self.selectedUserCategory = category
            self.addSelectionForUserCategory(id: category.categoryId == 0 ? category.categoryAppId : category.categoryId )
        }
        else if let subCategory = subCat, let mainCatgory = main {
            self.selectedMainCategory = mainCatgory
            self.selectedSubCategory = subCategory
            self.addSelectionForSubCategory(id: subCategory.categoryId, inMainId: mainCatgory.categoryId)
        }
        else if let mainCatgory = main {
            self.selectedMainCategory = mainCatgory
            self.addSelectionForMainCategory(id: mainCatgory.categoryId)
        }
        self.tableView.reloadData()
    }
    
    func setOtherCategoryToLast() {
        if let otherCategoryIndex = self.categoryItems.firstIndex(where: { return $0.shopMainCategory.masterCategoryId == 1 && !$0.shopMainCategory.isCustom }) {
            let otherCategoryList = self.categoryItems.remove(at: otherCategoryIndex)
            self.categoryItems.append(otherCategoryList)
        }
    }
}
