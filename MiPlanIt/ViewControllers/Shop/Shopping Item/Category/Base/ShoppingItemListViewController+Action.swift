//
//  ShoppingItemListViewController+Action.swift
//  MiPlanIt
//
//  Created by Febin Paul on 27/10/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

extension ShoppingItemListViewController {
    
    func initializeData() {
        self.readBaseShoppingOptions()        
    }
    
    func hideCategoryAddNewAndSort() {
        self.buttonAddNew.isHidden = true
        self.buttonCategorySort.isHidden = true
    }
    
    func hideListSortingView() {
        self.viewSortAlphabetically.isHidden = true
        self.buttonSortValue.isSelected = false
    }
    
    func showCategoryAddNew() {
        self.buttonAddNew.isHidden = false
        self.buttonCategorySort.isHidden = false
    }
    
    func setCloseButton(toMinimize flag: Bool) {
        self.buttonBack.isSelected = flag
        if flag {
            self.buttonBack.isHidden = false
            self.hideCategoryAddNewAndSort()
            self.hideListSortingView()
            self.buttonBack.setImage(UIImage(named: "icon_close"), for: .normal)
        }
        else {
            guard let lastType = self.shoppingListOptionTypeOrder.last else { return }
            switch lastType {
            case .base:
                self.buttonBack.isHidden = true
                self.buttonCategorySort.isHidden = true
            case .resentItems, .favoritesList:
                self.buttonBack.isHidden = false
                self.hideCategoryAddNewAndSort()
                self.hideListSortingView()
                self.buttonBack.setImage(UIImage(named: "iconbackblack"), for: .normal)
            case .subCategoryItsItems:
                self.buttonBack.isHidden = false
                self.hideCategoryAddNewAndSort()
                self.hideListSortingView()
                self.buttonBack.setImage(UIImage(named: "iconbackblack"), for: .normal)
            default:
                self.buttonBack.isHidden = false
                self.showCategoryAddNew()
                self.buttonBack.setImage(UIImage(named: "iconbackblack"), for: .normal)
            }
        }
    }
    
    func readBaseShoppingOptions() {
        self.buttonBack.isHidden = true
        self.hideCategoryAddNewAndSort()
        self.hideListSortingView()
        self.shoppingItems = [
            ShoppingItemOptionList(name: Strings.categories, image: FileNames.imageCategoriesDropDown, count: 0, listOptionType: .categories),
            ShoppingItemOptionList(name: Strings.recentItems, image: FileNames.imageRecentItemssDropDown, count: 0, listOptionType: .resentItems),
            ShoppingItemOptionList(name: Strings.favorites, image: FileNames.imageFavoritesDropDown, count: 0, listOptionType: .favoritesList),
            
        ]
        self.labelCaption.text = Strings.addItems
    }
    
    func readCategoryShoppingOptions() {
        self.buttonBack.isHidden = false
        self.showCategoryAddNew()
        self.buttonBack.setImage(UIImage(named: "iconbackblack"), for: .normal)
        self.updateListOrder(self.getSortValue())
        self.labelCaption.text = Strings.categorys
    }
    
    func setShoppingItems() {
        self.setOtherCategoryToLast()
        var mainCategoryList: [ShoppingItemOptionList] = []
        for eachCategory in self.arrayAllShopItemCategory {
            mainCategoryList.append(ShoppingItemOptionList(shopItemMainCategory: eachCategory))
        }
        self.shoppingItems = mainCategoryList
    }
    
    func getSortValue() -> ComparisonResult? {
        if !self.viewSortAlphabetically.isHidden {
            return self.buttonSortValue.isSelected ? .orderedDescending : .orderedAscending
        }
        return nil
    }
    
    func updateListOrder(_ comparisonResult: ComparisonResult? = nil) {
        if let orderBy = comparisonResult {
            self.arrayAllShopItemCategory.sort { (list1, list2) -> Bool in
                list1.readCategoryName().localizedCaseInsensitiveCompare(list2.readCategoryName()) == orderBy
            }
        }
        else {
            let nonOrderItems =  self.arrayAllShopItemCategory.filter({ $0.readOrderId() == 0.0 })
            var orderedItems = self.arrayAllShopItemCategory.filter({ $0.readOrderId() != 0.0 })
            orderedItems.sort { (list1, list2) -> Bool in
                list1.readOrderId() < list2.readOrderId()
            }
            orderedItems.append(contentsOf: nonOrderItems)
            self.arrayAllShopItemCategory = orderedItems
            self.buttonSortValue.isSelected = false
        }
        self.setShoppingItems()
    }
    
    func findUniqueItems(_ allItems: [PlanItShopListItems])  -> [PlanItShopListItems] {
        var uniqueItems:[PlanItShopListItems] = []
        for eachItem in allItems {
            if uniqueItems.contains(where: { ($0.shopItemId == eachItem.shopItemId) }) { continue }
            uniqueItems.append(eachItem)
        }
        return uniqueItems
    }
    
    func getFavoritedShopListItems() -> [PlanItShopListItems] {
        return self.findUniqueItems(DatabasePlanItShopListItem().readFavoritedShopListItem())
    }
    
    func getResendShopListItems() -> [PlanItShopListItems] {
        return self.findUniqueItems(DatabasePlanItShopListItem().readResendShopListItem())
    }
    
    func showCollectionListFavoriteItmes() {
        self.shoppingListOptionTypeOrder.append(.favoritesList)
        if self.shopItemCategoryViewController == nil {
            self.shopItemCategoryViewController = self.getShoppingItemListViewController()
            self.shopItemCategoryViewController?.shopListItems = self.getFavoritedShopListItems()
        }
        self.showShopItemCategoryViewController()
    }
    
    func showCollectionListResendItmes() {
        self.shoppingListOptionTypeOrder.append(.resentItems)
        if self.shopItemCategoryViewController == nil {
            self.shopItemCategoryViewController = self.getShoppingItemListViewController()
            self.shopItemCategoryViewController?.shopListItems = self.getResendShopListItems()
        }
        self.showShopItemCategoryViewController()
    }
    
    func updateShopItemsOfCategory() {
        guard let listOptionType = self.shoppingListOptionTypeOrder.last, listOptionType == .subCategoryItsItems else {
            return
        }
        self.shopItemCategoryViewController?.updateShopSubCategory()
        if let contentVC = self.shopItemCategoryViewController?.pageController.viewControllers?.first as? ContentVC, let vc =  self.shopItemCategoryViewController, !vc.shopSubCategory.isEmpty {
            contentVC.shopMasterItems = vc.shopSubCategory[0].shopItems
            contentVC.showMasterItems = contentVC.shopMasterItems
        }
        self.shopItemCategoryViewController?.orderListWithSortValue()
    }
    
    func updateFavoritedShopListItems() {
        guard let listOptionType = self.shoppingListOptionTypeOrder.last, listOptionType == .favoritesList else {
            return
        }
        self.shopItemCategoryViewController?.shopListItems = self.getFavoritedShopListItems()
        if let contentVC = self.shopItemCategoryViewController?.pageController.viewControllers?.first as? ContentVC, let vc =  self.shopItemCategoryViewController, !vc.shopSubCategory.isEmpty {
            contentVC.shopMasterItems = vc.shopSubCategory[0].shopItems
            contentVC.showMasterItems = contentVC.shopMasterItems
        }
    }
    
    func updateResendShopListItems() {
        self.shopItemCategoryViewController?.shopListItems = self.getResendShopListItems()
    }
    
    func showCollectionListItmes(index: IndexPath) {
        self.shoppingListOptionTypeOrder.append(.subCategoryItsItems)
        if self.shopItemCategoryViewController == nil {
            self.shopItemCategoryViewController = self.getShoppingItemListViewController()
            self.shopItemCategoryViewController?.planItShopCategory = self.arrayAllShopItemCategory[index.row]
        }
        self.showShopItemCategoryViewController(indexPath: index)
    }
    
    func showShopItemCategoryViewController(indexPath: IndexPath? = nil) {
        guard let shoppingVC = self.shopItemCategoryViewController else { return }
        self.addChild(shoppingVC)
        shoppingVC.view.frame = CGRect(x: 0, y: 0, width: self.viewContainerCollectionList.frame.size.width, height: self.viewContainerCollectionList.frame.size.height);
        self.viewContainerCollectionList.addSubview(shoppingVC.view)
        shoppingVC.didMove(toParent: self)
        self.viewContainerCollectionList.isHidden = false
        self.hideCategoryAddNewAndSort()
        if let listType = self.shoppingListOptionTypeOrder.last {
            switch listType {
            case .resentItems:
                self.labelCaption.text = Strings.recentItems
            case .favoritesList:
                self.labelCaption.text = Strings.favoriteItems
            default:
                if let index = indexPath {
                    self.labelCaption.text = self.arrayAllShopItemCategory[index.row].readCategoryName()
                }
            }
        }
        
    }
    
    func hideCollectionListItmes() {
        //self.buttonBack.isHidden = true
        self.shopItemCategoryViewController?.deinitObject()
        self.shopItemCategoryViewController?.willMove(toParent: nil)
        self.shopItemCategoryViewController?.view.removeFromSuperview()
        self.shopItemCategoryViewController?.removeFromParent()
        self.shopItemCategoryViewController = nil
        self.viewContainerCollectionList.isHidden = true
    }
    
    func getShoppingItemListViewController() -> ShopItemCategoryViewController {
        let storyboard = UIStoryboard(name: "ShoppingList", bundle: Bundle.main)
        let viewController = storyboard.instantiateViewController(withIdentifier: "ShopItemCategoryViewController") as! ShopItemCategoryViewController
        viewController.shoppingListOptionType = self.shoppingListOptionTypeOrder.last
        viewController.delegate = self
        viewController.currentShopList = self.currentPlanItShopList
        return viewController
    }
    
    func setOtherCategoryToLast() {
        if let otherCategoryIndex = self.arrayAllShopItemCategory.firstIndex(where: { return $0.masterCategoryId == 1 && !$0.isCustom }) {
            let otherCategoryList = self.arrayAllShopItemCategory.remove(at: otherCategoryIndex)
            self.arrayAllShopItemCategory.append(otherCategoryList)
        }
    }
    
    func resetShopItemCategoryCollectionScroll() {
        self.shopItemCategoryViewController?.resetScrollOffsetOfCollection()
    }
    
    func startLoadingIndicatorForShoppingItemOption(_ options: [ShoppingItemOptionList]) {
        for option in options {
            if let index = self.shoppingItems.firstIndex(where: { $0.planItShopMainCategory == option.planItShopMainCategory }) {
              let indexPath = IndexPath(row: index, section: 0)
                if let cell = self.tableView.cellForRow(at: indexPath) as? ShoppingItemTableViewCell {
                    cell.startGradientAnimation()
                }
            }
        }
    }
    
    func stopLoadingIndicatorForShoppingItemOption(_ options: [ShoppingItemOptionList]) {
        for option in options {
            if let index = self.shoppingItems.firstIndex(where: { $0.planItShopMainCategory == option.planItShopMainCategory }) {
                let indexPath = IndexPath(row: index, section: 0)
                if let cell = self.tableView.cellForRow(at: indexPath) as? ShoppingItemTableViewCell {
                    cell.stopGradientAnimation()
                }
            }
        }
    }
    
    func removeDeletedShopCategory(_ removeCategoryIds: [Any]) {
        removeCategoryIds.forEach { (idValue) in
            self.arrayAllShopItemCategory.removeAll { (category) -> Bool in
                if let plaItCategory = idValue as? PlanItShopMainCategory {
                    return plaItCategory == category
                }
                return false
            }
        }
        self.delegate?.shoppingItemListViewControllerCategoryUpdated(self)
        self.setShoppingItems()
    }
    
    func updateWithAddedCategory(_ category: CategoryData) {
        guard let planItShopMainCategory = !category.categoryAppId.isEmpty ?  DatabasePlanItShopMasterCategory().readSpecificAppShopCategory(category.categoryAppId).first : DatabasePlanItShopMasterCategory().readSpecificUserShopCategory([category.categoryId]).first else { return }
        self.arrayAllShopItemCategory.append(planItShopMainCategory)
        if let listType = self.shoppingListOptionTypeOrder.last {
            switch listType {
            case .categories:
                if !self.viewSortAlphabetically.isHidden {
                    self.updateListOrder(self.buttonSortValue.isSelected ? .orderedDescending : .orderedAscending)
                }
                else {
                    self.setShoppingItems()
                }
            default:
                break
            }
        }
    }
}
