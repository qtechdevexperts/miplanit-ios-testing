//
//  CategoryListSectionViewController+Callback.swift
//  MiPlanIt
//
//  Created by Febin Paul on 13/11/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

extension CategoryListSectionViewController: ShopMainCategoryTableViewCellDelegate {
    
    func shopMainCategoryTableViewCell(_ shopMainCategoryTableViewCell: ShopMainCategoryTableViewCell, onExpand flag: Bool) {
        self.categoryItems[shopMainCategoryTableViewCell.section].isExpanded = flag
        self.tableView.reloadData()
    }
    
    func shopMainCategoryTableViewCell(_ shopMainCategoryTableViewCell: ShopMainCategoryTableViewCell, onSelect flag: Bool) {
        self.categoryItems[shopMainCategoryTableViewCell.section].isSelected = flag
        if self.categoryItems[shopMainCategoryTableViewCell.section].shopMainCategory.isCustom {
            let id = self.categoryItems[shopMainCategoryTableViewCell.section].shopMainCategory.readUserCategoryIdValue()
            let name = self.categoryItems[shopMainCategoryTableViewCell.section].shopMainCategory.readCategoryName()
            let appId = self.categoryItems[shopMainCategoryTableViewCell.section].shopMainCategory.readUserAppCategoryId()
            self.updateSelection(userCat: CategoryData(id: id, name: name, appId: appId))
        }
        else {
            let id = self.categoryItems[shopMainCategoryTableViewCell.section].shopMainCategory.readMasterCategoryIdValue()
            let name = self.categoryItems[shopMainCategoryTableViewCell.section].shopMainCategory.readCategoryName()
            let appId = self.categoryItems[shopMainCategoryTableViewCell.section].shopMainCategory.readUserAppCategoryId()
            self.updateSelection(main: CategoryData(id: id, name: name, appId: appId))
        }
    }
}


extension CategoryListSectionViewController: ShopSubCategoryTableViewCellDelegate {
    
    func shopSubCategoryTableViewCell(_ shopSubCategoryTableViewCell: ShopSubCategoryTableViewCell, onSelect flag: Bool) {
        self.categoryItems[shopSubCategoryTableViewCell.index.section].shopSubCategory[shopSubCategoryTableViewCell.index.row].isSelected = flag
        
        let subCatId = self.categoryItems[shopSubCategoryTableViewCell.index.section].shopSubCategory[shopSubCategoryTableViewCell.index.row].subCategory.readSubCategoryIdValue()
        let mainCatId = self.categoryItems[shopSubCategoryTableViewCell.index.section].shopMainCategory.readMasterCategoryIdValue()
        
        let mainCatName = self.categoryItems[shopSubCategoryTableViewCell.index.section].shopMainCategory.readCategoryName()
        let subCatName = self.categoryItems[shopSubCategoryTableViewCell.index.section].shopSubCategory[shopSubCategoryTableViewCell.index.row].subCategory.readCategoryName()
        
        let appId = self.categoryItems[shopSubCategoryTableViewCell.index.section].shopMainCategory.readUserAppCategoryId()
        
        self.updateSelection(subCat: CategoryData(id: subCatId, name: subCatName, appId: appId), main: CategoryData(id: mainCatId, name: mainCatName, appId: appId) )
    }
}

extension CategoryListSectionViewController: AddNewCategoryViewControllerDelegate {
    
    func addNewCategoryViewController(_ addNewCategoryViewController: AddNewCategoryViewController, update category: PlanItShopMainCategory) {
        self.tableView.reloadData()
    }
    
    
    func addNewCategoryViewController(_ addNewCategoryViewController: AddNewCategoryViewController, add category: PlanItShopMainCategory) {
        self.categoryItems.append(ShopListItemCategoryListOption(mainCategory: category, selectedMainCategoryId: nil, selectedSubCategoryId: nil, selectedUserCategoryId: category.readUserCategoryIdValue(), selectedAppCategoryID: category.readUserAppCategoryId()))
        self.setOtherCategoryToLast()
        let categoryData = CategoryData(id: category.readUserCategoryIdValue(), name: category.readCategoryName(), appId: category.readUserAppCategoryId())
        self.updateSelection(userCat: categoryData)
        if !self.viewSortAlphabetically.isHidden {
            self.updateListOrder(self.buttonSortValue.isSelected ? .orderedDescending : .orderedAscending)
        }
        self.delegate?.categoryListSectionViewController(self, add: categoryData)
    }
}
