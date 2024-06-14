//
//  ShopItemCategoryViewController+Action.swift
//  MiPlanIt
//
//  Created by Febin Paul on 10/11/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation


extension ShopItemCategoryViewController {
    
    func initializeUI() {
        self.viewQuantityOption.delegate = self
        self.viewQuantityOption.buttonRecord.isHidden = true
        self.addNotifications()
        self.menuBarView.isHidden = self.shopSubCategory.count == 1
        var showSort: Bool = false
        self.shopSubCategory.forEach { (shopSubCategoryAndItems) in
            showSort = !shopSubCategoryAndItems.shopItems.isEmpty
        }
        self.viewSortAlphabetically.isHidden = !showSort
    }
    
    func deinitObject() {
        self.removeNotifications()
        self.currentSelectedShopItem = nil
        self.currentShopList = nil
        self.planItShopCategory = nil
        self.shoppingListOptionType = nil
        self.delegate = nil
        self.menuBarView.menuDelegate = nil
        self.menuBarView = nil
        self.viewQuantityOption.deinitQuantityOption()
        self.pageController.removeFromParent()
        self.pageController = nil
        self.shopListItems.removeAll()
        self.shopSubCategory.removeAll()
    }
    
    func updateShopSubCategory() {
        guard let planItShopCategory = self.planItShopCategory else { return }
        self.shopSubCategory = planItShopCategory.readAllShopSubCategory().map({ return ShopSubCategoryAndItems($0) })
        var categoryItems: [PlanItShopItems] = []
        if planItShopCategory.isCustom {
            if planItShopCategory.isPending && planItShopCategory.userCategoryId == 0 {
                categoryItems = []
            }
            else {
                categoryItems = DatabasePlanItShopItems().readAllShopItemOfUserCategory([planItShopCategory.userCategoryId])
            }
        }
        else {
            categoryItems = DatabasePlanItShopItems().readAllShopItemOfMasterCategory([planItShopCategory.masterCategoryId])
        }
        self.shopSubCategory.append(ShopSubCategoryAndItems(otherItems: categoryItems))
    }
    
    func orderListWithSortValue() {
        self.updateListOrder(self.buttonSortValue.isSelected ? .orderedDescending : .orderedAscending)
    }
    
    func enableSearchtextField() {
        self.buttonSearchField.isHidden = true
        self.viewQuantityOption.enableTextField()
    }
    
    func enableItemQuantity() {
        self.buttonSearchField.isHidden = true
        self.viewQuantityOption.enablQuantityOption(shopItem: self.currentSelectedShopItem)
    }
    
    func disableItemQuantity() {
        self.buttonSearchField.isHidden = false
        self.viewQuantityOption.closeQuantityOption()
    }
    
    func presentPageVCOnView() {
        
        self.pageController = storyboard?.instantiateViewController(withIdentifier: "PageControllerVC") as! PageControllerVC
        self.pageController.view.frame = self.viewPageViewContainer.bounds
        self.viewPageViewContainer.addSubview(self.pageController.view)
        self.addChild(self.pageController)
    }
    
    func updateItemsOnAdding() {
        if let controllers = self.pageController.viewControllers, !controllers.isEmpty {
            
        }
    }
    
    func viewController(At index: Int) -> UIViewController? {
        
        if((self.menuBarView.dataArray.count == 0) || (index >= self.menuBarView.dataArray.count)) {
            return nil
        }
        
        let contentVC = storyboard?.instantiateViewController(withIdentifier: "ContentVC") as! ContentVC
        contentVC.strTitle = self.shopSubCategory[index].categoryName
        contentVC.shoppingListOptionType = self.shoppingListOptionType
        switch self.shoppingListOptionType {
        case .favoritesList:
            contentVC.shopMasterItems = self.shopSubCategory[index].shopItems
        case .resentItems:
            contentVC.shopMasterItems = self.shopSubCategory[index].shopItems
        default:
            contentVC.planItShopItems = self.shopSubCategory[index].shopItems.compactMap({ $0.planItShopItem })
        }
        contentVC.pageIndex = index
        contentVC.searchText = self.searchTextValue
        contentVC.delegate = self
        return contentVC
        
    }
    
    func addNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil )
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil )
    }
    
    func removeNotifications() {
        NotificationCenter.default.removeObserver(self, name:  UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name:  UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func updateListOrder(_ comparisonResult: ComparisonResult) {
        self.pageController.viewControllers?.forEach({ (vc) in
            if let contentVC = vc as? ContentVC {
                contentVC.updateListOrder(comparisonResult)
            }
        })
    }
    
    func updateItemWithSearchData(searchData: String) {
        self.searchTextValue = searchData
        self.pageController.viewControllers?.forEach({ (vc) in
            if let contentVC = vc as? ContentVC {
                contentVC.searchText = searchData
            }
        })
        if self.pageController.viewControllers?.isEmpty ?? true {
            // new category
            self.viewQuantityOption.setVisibilityAddButton(show: true)
        }
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            self.constraintQuantityBottom.constant = keyboardRectangle.height
            if #available(iOS 11.0, *) {
                let bottomInset = UIApplication.shared.windows[0].safeAreaInsets.bottom
                self.constraintQuantityBottom.constant -= bottomInset
                self.viewQuantityOption.updateConstraints()
            }
            self.viewQuantityOption.isHidden = false
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        self.constraintQuantityBottom.constant = 0
        self.buttonSearchField.isHidden = false
    }
    
    func resetScrollOffsetOfCollection() {
        self.pageController.viewControllers?.forEach({ (vc) in
            if let contentVC = vc as? ContentVC {
                contentVC.resetScrollOffset()
            }
        })
    }
}
