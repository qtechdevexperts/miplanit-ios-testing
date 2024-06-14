//
//  ShopItemCategoryViewController+Callback.swift
//  MiPlanIt
//
//  Created by Febin Paul on 10/11/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation


extension ShopItemCategoryViewController: MenuBarDelegate {

    func menuBarDidSelectItemAt(menu: MenuTabsView, index: Int) {

        if index != currentIndex {

            if index > currentIndex {
                self.pageController.setViewControllers([viewController(At: index)!], direction: .forward, animated: true, completion: nil)
            }else {
                self.pageController.setViewControllers([viewController(At: index)!], direction: .reverse, animated: true, completion: nil)
            }
            self.currentIndex = index
            self.menuBarView.didSelectCategoryOnIndex(IndexPath.init(item: index, section: 0))

        }

    }

}


extension ShopItemCategoryViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let contentVC = viewController as? ContentVC else { return nil}
        var index = contentVC.pageIndex
        
        if (index == 0) || (index == NSNotFound) {
            return nil
        }
        
        index -= 1
        return self.viewController(At: index)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let contentVC = viewController as? ContentVC else { return nil}
        var index = contentVC.pageIndex
        
        if (index == self.shopSubCategory.count) || (index == NSNotFound) {
            return nil
        }
        
        index += 1
        return self.viewController(At: index)
        
    }
   
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        if finished {
            if completed {
                let cvc = pageViewController.viewControllers!.first as! ContentVC
                cvc.searchText = self.searchTextValue
                let newIndex = cvc.pageIndex
                currentIndex = newIndex
                menuBarView.collView.selectItem(at: IndexPath.init(item: newIndex, section: 0), animated: true, scrollPosition: .centeredVertically)
                menuBarView.didSelectCategoryOnIndex(IndexPath.init(item: newIndex, section: 0))
            }
        }
        
    }
    
}


extension ShopItemCategoryViewController: ShopItemQuantityOptionViewDelegate {
    
    func shopItemQuantityOptionView(_ shopItemQuantityOptionView: ShopItemQuantityOptionView, addNew itemName: String) {
        guard let shopList = self.currentShopList else { return }
        let shopListItemDetailModel = ShopListItemDetailModel(newItem: itemName, onShopList: shopList)
        self.view.endEditing(true)
        self.viewQuantityOption.setVisibilityAddButton(show: false)
        self.updateItemWithSearchData(searchData: Strings.empty)
        self.delegate?.shopItemCategoryViewController(self, addNew: shopListItemDetailModel)
    }
    
    
    func shopItemQuantityOptionViewDismissKeyboard(_ shopItemQuantityOptionView: ShopItemQuantityOptionView) {
        self.updateItemWithSearchData(searchData: Strings.empty)
    }
    
    
    func shopItemQuantityOptionView(_ shopItemQuantityOptionView: ShopItemQuantityOptionView, searchText: String) {
        self.updateItemWithSearchData(searchData: searchText)
    }
    
    func shopItemQuantityOptionView(_ shopItemQuantityOptionView: ShopItemQuantityOptionView, selectedQuantity: String) {
        guard let item = self.currentSelectedShopItem else { return }
        if selectedQuantity == Strings.details, let planItShopItem = item.planItShopItem, let shopList = self.currentShopList{
            self.viewQuantityOption.enableTextField()
            self.delegate?.shopItemCategoryViewController(self, selectedShopItemDetail: ShopListItemDetailModel(shopItem: planItShopItem, quantity: item.quantity, onShopList: shopList))
        }
        else if let planItShopItem = item.planItShopItem, let shopList = self.currentShopList {
            item.quantity = selectedQuantity
            self.delegate?.shopItemCategoryViewController(self, selectedShopItem: ShopListItemDetailModel(shopItem: planItShopItem, quantity: item.quantity, onShopList: shopList), fromSearch: false)
            self.pageController.viewControllers?.forEach({ (vc) in
                if let contentVC = vc as? ContentVC {
                    contentVC.resetCollectionData()
                }
            })
            self.viewQuantityOption.enableTextField()
            self.view.endEditing(true)
        }
    }
}


extension ShopItemCategoryViewController: ContentVCDelegate {
    
    func contentVCDelegate(_ contentVC: ContentVC, noSearchData: Bool) {
        self.viewQuantityOption.setVisibilityAddButton(show: noSearchData)
    }
    
    func contentVCDelegate(_ contentVC: ContentVC, addShopItem: ShopItem) {
        guard let planItShopItem = addShopItem.planItShopItem, let shopList = self.currentShopList  else { return }
//        self.view.endEditing(true)
//        self.viewQuantityOption.closeQuantityOption()
        self.delegate?.shopItemCategoryViewController(self, selectedShopItem: ShopListItemDetailModel(shopItem: planItShopItem, quantity: addShopItem.quantity, onShopList: shopList), fromSearch: false)
    }
    
    func contentVCDelegate(_ contentVC: ContentVC, customQuantity: String) {
        guard let item = self.currentSelectedShopItem else { return }
        item.quantity = customQuantity
    }
    
    func contentVCDelegate(_ contentVC: ContentVC, selectedItem: ShopItem) {
        self.currentSelectedShopItem = selectedItem
        self.enableItemQuantity()
    }
    
    func contentVCDelegate(_ contentVC: ContentVC, multiSelectedShopItem: [ShopItem]) {
        guard let shopList = self.currentShopList  else { return }
        let allSelectedShopItem = multiSelectedShopItem.compactMap { (shopItem) -> ShopListItemDetailModel? in
            guard let planItShopItem = shopItem.planItShopItem else { return nil }
            return ShopListItemDetailModel(shopItem: planItShopItem, quantity: shopItem.quantity, onShopList: shopList)
        }
        self.delegate?.shopItemCategoryViewController(self, multiSelectedShopItem: allSelectedShopItem)
    }
}


extension ShopItemCategoryViewController: ShoppingItemDetailViewControllerDelegate {
    
    func shoppingItemDetailViewController(_ shoppingItemDetailViewController: ShoppingItemDetailViewController, onAddUserCategory: CategoryData) {
        self.delegate?.shopItemCategoryViewController(self, addNewCetegory: onAddUserCategory)
    }
    
    func shoppingItemDetailViewController(_ shoppingItemDetailViewController: ShoppingItemDetailViewController, addUpdateItemDetail: ShopListItemDetailModel) {
        self.delegate?.shopItemCategoryViewController(self, addedNew: addUpdateItemDetail)
    }
    
    func shoppingItemDetailViewController(_ shoppingItemDetailViewController: ShoppingItemDetailViewController, onDeleteShopListItem: ShopListItemDetailModel) {
        
    }
}


extension ShopItemCategoryViewController: SearchAllShopItemViewControllerDelegate {
    // Created New Shop Item from Search VC after API call
    func searchAllShopItemViewController(_ searchAllShopItemViewController: SearchAllShopItemViewController, addedNewItem item: ShopListItemDetailModel) {
        guard currentShopList != nil else { return }
        self.delegate?.shopItemCategoryViewController(self, addedNew: item)
    }
    
    func searchAllShopItemViewController(_ searchAllShopItemViewController: SearchAllShopItemViewController, editShopListItem shopItem: PlanItShopListItems, withQuantity: String) {
        let planItShopItems = shopItem.isShopCustomItem ? DatabasePlanItShopItems().readSpecificUserShopItem([shopItem.shopItemId]) :  DatabasePlanItShopItems().readSpecificMasterShopItem([shopItem.shopItemId])
        if let addedShopItem = planItShopItems.first {
            self.performSegue(withIdentifier: Segues.showShopItemDetail, sender: ShopListItemDetailModel(shopListItem: shopItem, shopItem: addedShopItem))
        }
    }
    
    func searchAllShopItemViewController(_ searchAllShopItemViewController: SearchAllShopItemViewController, selectedShopItem: ShopItem) {
        guard let planItShopItem = selectedShopItem.planItShopItem,  let shopList = currentShopList else { return }
        if planItShopItem.isCustom {
            if let selectedCategory = self.planItShopCategory, planItShopItem.readMasterCategoryIdValue() == 1.0, selectedCategory.readMasterCategoryIdValue() != 1.0 {
                // update selectedShopItem category
                let categoryData = selectedCategory.isCustom  ? CategoryData(id: selectedCategory.readUserCategoryIdValue(), name: selectedCategory.readCategoryName(), appId: selectedCategory.readUserAppCategoryId()) : CategoryData(id: selectedCategory.readMasterCategoryIdValue(), name: selectedCategory.readCategoryName(), appId: selectedCategory.readUserAppCategoryId())
                planItShopItem.updateUserCategoryOffline(to: categoryData, ofItem: nil)
            }
        }
        self.delegate?.shopItemCategoryViewController(self, selectedShopItem: ShopListItemDetailModel(shopItem: planItShopItem, quantity: selectedShopItem.quantity, onShopList: shopList), fromSearch: true)
    }
    
    func searchAllShopItemViewController(_ searchAllShopItemViewController: SearchAllShopItemViewController, addNew itemName: String) {
        guard let shopList = currentShopList else { return }
        self.delegate?.shopItemCategoryViewController(self, addNew: ShopListItemDetailModel(newItem: itemName, onShopList: shopList, withCategory: self.planItShopCategory))
    }
    
    func searchAllShopItemViewController(_ searchAllShopItemViewController: SearchAllShopItemViewController, showDetail shopItem: ShopItem) {
        self.performSegue(withIdentifier: Segues.showShopItemDetail, sender: shopItem)
    }
    
    func searchAllShopItemViewControllerOnClose(_ searchAllShopItemViewController: SearchAllShopItemViewController) {
        self.addNotifications()
    }
}
