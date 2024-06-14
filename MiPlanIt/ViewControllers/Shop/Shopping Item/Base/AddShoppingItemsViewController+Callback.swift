//
//  CustomCategoryToDoViewController+Callback.swift
//  MiPlanIt
//
//  Created by Febin Paul on 08/07/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

extension AddShoppingItemsViewController: CreateNewListViewControllerDelegate {
    
    func createNewListViewController(_ viewController: CreateNewListViewController, createdUpdatedShoppingList list: PlanItShopList?) {
        guard let planItShopList = list else {
            self.navigationController?.popViewController(animated: true)
            return
        }
        self.planItShopList = planItShopList
        self.showShopingListInformationIfExist()
        self.delegate?.addShoppingItemsViewController(self, addedShopList: planItShopList)
    }
}

extension AddShoppingItemsViewController: ShoppingItemListViewControllerDelegate {
    
    func shoppingItemListViewControllerCategoryUpdated(_ shoppingItemListViewController: ShoppingItemListViewController) {
        self.updateSectionIncompleteShopListItem()
    }
    
    func shoppingItemListViewController(_ shoppingItemListViewController: ShoppingItemListViewController, editShopListItem shopItem: PlanItShopListItems, withQuantity quantity: String) {
        if let shopListItem = self.incompletedShopListItems.filter({ $0.planItShopListItem == shopItem }).first {
            var passQuantity = shopListItem.shopListItemQuantity
            if !quantity.isEmpty {
                passQuantity = quantity
            }
            self.performSegue(withIdentifier: Segues.showShopItemDetail, sender: (shopListItem, passQuantity))
        }
    }
    
    func shoppingItemListViewController(_ shoppingItemListViewController: ShoppingItemListViewController, addItemOnDetail: ShopListItemDetailModel) {
        self.confirmationCheckOnAdd(shopItem: addItemOnDetail, toDetailScreen: true)
    }
    
    func shoppingItemListViewController(_ shoppingItemListViewController: ShoppingItemListViewController, addedNewItem: ShopListItemDetailModel) {
        self.minimizeShopListView()
        if self.incompletedShopListItems.filter({ $0.planItShopListItem == addedNewItem.planItShopListItem }).isEmpty {
            self.appendShopItemInList(addedNewItem)
        }
        else {
            self.updateIncompletedShopListData()
        }
        self.shoppingItemListViewController?.updateShopItemsOfCategory()
    }
    
    func shoppingItemListViewController(_ shoppingItemListViewController: ShoppingItemListViewController, addNewItem: ShopListItemDetailModel) {
        self.minimizeShopListView()
        self.addShopItemInList(addNewItem)
    }
    
    // Add shop list item from selected item
    func shoppingItemListViewController(_ shoppingItemListViewController: ShoppingItemListViewController, addItem: ShopListItemDetailModel, onSearch flag: Bool) {
        if flag || addItem.planItShopListItem != nil {
            self.addShopItemInList(addItem)
        }
        else {
            self.confirmationCheckOnAdd(shopItem: addItem)
        }
    }
    
    
    func shoppingItemListViewControllerToggleView(_ shoppingItemListViewController: ShoppingItemListViewController) {
        self.buttonCloseShopList.isHidden ? self.maximizeShopListView() : self.minimizeShopListView()
    }
    
    func shoppingItemListViewControllerCloseButtonClick(_ shoppingItemListViewController: ShoppingItemListViewController) {
        if self.buttonCloseShopList.isHidden {
            self.shoppingItemListViewController?.removeFromParent()
            self.shoppingItemListViewController = nil
            self.constraintBottomContainer.constant = -(self.containerViewHeight.constant + self.getSafeAreaHeightBottom())
        }
    }
    
    func shoppingItemListViewController(_ shoppingItemListViewController: ShoppingItemListViewController, addMultiSelectedItem: [ShopListItemDetailModel]) {
        self.minimizeShopListView()
        self.addMultipleShopItemInList(addMultiSelectedItem)
    }
}


extension AddShoppingItemsViewController: ShopItemListCellDelegate {
    
    func shopItemListCell(_ shopItemListCell: ShopItemListCell, showAttachment indexPath: IndexPath) {
        if !self.sectionedIncompletedShopListItems[indexPath.section].shopListItems[indexPath.row].planItShopListItem.readAttachments().isEmpty {
            self.performSegue(withIdentifier: Segues.showAttachmentPopUp, sender: self.sectionedIncompletedShopListItems[indexPath.section].shopListItems[indexPath.row])
        }
    }
    
    func shopItemListCell(_ shopItemListCell: ShopItemListCell, completion flag: Bool, indexPath: IndexPath) {
        self.saveShopListItemCompleteToServerUsingNetwotk([shopItemListCell.planItShopListItem], with: flag)
    }
    
    func shopItemListCell(_ shopItemListCell: ShopItemListCell, didSelect indexPath: IndexPath) {
        self.performSegue(withIdentifier: Segues.showShopItemDetail, sender: (self.sectionedIncompletedShopListItems[indexPath.section].shopListItems[indexPath.row], self.sectionedIncompletedShopListItems[indexPath.section].shopListItems[indexPath.row].shopListItemQuantity))
    }
    
    func shopItemListCell(_ shopItemListCell: ShopItemListCell, checkBoxSelect indexPath: IndexPath) {
        self.sectionedIncompletedShopListItems[indexPath.section].shopListItems[indexPath.row].editSelected = !self.sectionedIncompletedShopListItems[indexPath.section].shopListItems[indexPath.row].editSelected
        self.checkForAllCellSelected()
        self.tableViewToDoItems?.reloadData()
        self.updateSelectionLabelCount(self.incompletedShopListItems.filter({ $0.editSelected }).count)
    }
    
    func shopItemListCell(_ shopItemListCell: ShopItemListCell, shopListOn indexPath: IndexPath, quantity: String) {
        self.sectionedIncompletedShopListItems[indexPath.section].shopListItems[indexPath.row].planItShopListItem.quantity = quantity
        self.saveShopListItemToServerUsingNetwotk([self.sectionedIncompletedShopListItems[indexPath.section].shopListItems[indexPath.row].planItShopListItem], shopListItemCellModel: self.sectionedIncompletedShopListItems[indexPath.section].shopListItems[indexPath.row], reloadAfter: false)
    }
    
    func shopItemListCell(_ shopItemListCell: ShopItemListCell, ShouldBeginEditing indexPath: IndexPath) {
        self.currentEditingCellIndex = indexPath
    }
    
    
}


extension AddShoppingItemsViewController: MoreActionShopListDropDownControllerDelegate {
    
    func moreActionShopListDropDownController(_ controller: MoreActionShopListDropDownController, selectedOption: DropDownItem) {
        switch selectedOption.dropDownType {
        case .eShare:
            self.performSegue(withIdentifier: Segues.toShoppingShare, sender: nil)
        case .ePrint:
            self.printShoppingList()
        case .eAlphabetically, .eFavourite, .eDueDate, .eCreatedDate:
            self.selectedSortValue = selectedOption
            self.incompletedShopListItems = self.sortShopListItemsBy(selectedOption.dropDownType, ascending: self.buttonSortArrow?.isSelected ?? true, items: self.incompletedShopListItems)
        case .eCategories:
            self.selectedSortValue = selectedOption
            self.sortByShopItemCategory(ascending: self.buttonSortArrow?.isSelected ?? true)
        case .eDelete:
            self.showAlertWithAction(message: Message.deleteShoppingListMessage, title: Message.deleteShoppingList, items: [Message.yes, Message.cancel], callback: { index in
                if index == 0 {
                    guard let shopList = self.planItShopList else { return }
                    if shopList.createdBy?.readValueOfUserId() != Session.shared.readUserId() {
                        self.removeShopListToServerUsingNetwotk()
                    }
                    else {
                        self.deleteShopListToServerUsingNetwotk()
                    }
                }
            })
        default:
            break
        }
    }
}


extension AddShoppingItemsViewController: EditAndCompleteShopItemStackViewDelegate {
    
    func editAndCompleteShopItemStackViewMoveAll(_ completedShopItemStackView: EditAndCompleteShopItemStackView) {
        if !self.viewCompletedPopUp.isHidden { return }
        let allCompletedItems = self.allShopListItem.filter({ $0.planItShopListItem.isCompletedLocal }).compactMap({ $0.planItShopListItem })
        if allCompletedItems.count > 0 {
            self.performSegue(withIdentifier: Segues.showShopListSelection, sender: allCompletedItems)
        }
        else {
            self.performSegue(withIdentifier: Segues.toMessageScreen, sender: [Message.warning, Message.noShoppingItemsSelectedMove])
        }
    }
    
    func editAndCompleteShopItemStackViewOnChangeDueDate(_ completedShopItemStackView: EditAndCompleteShopItemStackView) {
        let selectedShopListItem = self.incompletedShopListItems.filter({ $0.editSelected })
        if selectedShopListItem.count > 0 {
            self.performSegue(withIdentifier: Segues.toToDoDueDate, sender: nil)
        }
        else {
            self.performSegue(withIdentifier: Segues.toMessageScreen, sender: [Message.warning, Message.noShoppingItemsSelectedDueDate])
        }
    }
    
    func editAndCompleteShopItemStackViewUncompleteAll(_ completedShopItemStackView: EditAndCompleteShopItemStackView) {
        if !self.viewCompletedPopUp.isHidden { return }
        let allCompletedItems = self.allShopListItem.filter({ $0.planItShopListItem.isCompletedLocal }).compactMap({ $0.planItShopListItem })
        self.saveShopListItemCompleteToServerUsingNetwotk(allCompletedItems, with: false)
    }
    
    func editAndCompleteShopItemStackView(_ completedShopItemStackView: EditAndCompleteShopItemStackView, setOverlay flag: Bool) {
        self.textViewShopListName?.isUserInteractionEnabled = !flag
    }
    
    func editAndCompleteShopItemStackView(_ completedShopItemStackView: EditAndCompleteShopItemStackView, popAttachmentShopItem: ShopListItemCellModel) {
        if !popAttachmentShopItem.planItShopListItem.readAttachments().isEmpty {
            self.performSegue(withIdentifier: Segues.showAttachmentPopUp, sender: popAttachmentShopItem)
        }
    }
     
    func editAndCompleteShopItemStackViewOnMove(_ completedShopItemStackView: EditAndCompleteShopItemStackView) {
        let selectedShopListItem = self.incompletedShopListItems.filter({ $0.editSelected })
        if selectedShopListItem.count > 0 {
            self.performSegue(withIdentifier: Segues.showShopListSelection, sender: selectedShopListItem)
        }
        else {
            self.performSegue(withIdentifier: Segues.toMessageScreen, sender: [Message.warning, Message.noShoppingItemsSelectedMove])
        }
    }
    
    func editAndCompleteShopItemStackViewOnFavorite(_ completedShopItemStackView: EditAndCompleteShopItemStackView) {
        let selectedShopListItem = self.incompletedShopListItems.filter({ $0.editSelected })
        if selectedShopListItem.count > 0 {
            self.saveShopListItemFavoriteToServerUsingNetwotk(selectedShopListItem.compactMap({ $0.planItShopListItem }), with: true)
        }
        else {
            self.performSegue(withIdentifier: Segues.toMessageScreen, sender: [Message.warning, Message.noShoppingItemsSelectedFavorite])
        }
    }
    
    func editAndCompleteShopItemStackViewOnComplete(_ completedShopItemStackView: EditAndCompleteShopItemStackView) {
        let selectedShopListItem = self.incompletedShopListItems.filter({ $0.editSelected })
        if selectedShopListItem.count > 0 {
            self.saveShopListItemCompleteToServerUsingNetwotk(selectedShopListItem.compactMap({ $0.planItShopListItem }), with: true)
        }
        else {
            self.performSegue(withIdentifier: Segues.toMessageScreen, sender: [Message.warning, Message.noShoppingItemsSelectedComplete])
        }
    }
    
    func editAndCompleteShopItemStackViewOnDelete(_ completedShopItemStackView: EditAndCompleteShopItemStackView) {
        let selectedShopListItem = self.incompletedShopListItems.filter({ $0.editSelected })
        if selectedShopListItem.count > 0 {
            self.showAlertWithAction(message: Message.deleteShoppingItemMessage, title: Message.deleteShoppingItem, items: [Message.yes, Message.cancel], callback: { index in
                if index == 0 {
                    self.deleteShopListItemToServerUsingNetwotk(selectedShopListItem.compactMap({ $0.planItShopListItem }))
                }
            })
        }
        else {
            self.performSegue(withIdentifier: Segues.toMessageScreen, sender: [Message.warning, Message.noShoppingItemsSelectedDelete])
        }
    }
    
    func editAndCompleteShopItemStackView(_ completedShopItemStackView: EditAndCompleteShopItemStackView, unCompleteShopItem: PlanItShopListItems) {
        guard self.viewCompletedPopUp.isHidden else { return }
        self.saveShopListItemCompleteToServerUsingNetwotk([unCompleteShopItem], with: false)
    }
    
    func editAndCompleteShopItemStackView(_ completedShopItemStackView: EditAndCompleteShopItemStackView, onFavouriteToDo: ToDoItemCellModel, flag: Bool) {
        
    }
    
    func editAndCompleteShopItemStackView(_ completedShopItemStackView: EditAndCompleteShopItemStackView, onDeleteShopListItem: PlanItShopListItems) {
        self.showAlertWithAction(message: Message.deleteShoppingItemMessage, title: Message.deleteShoppingItem, items: [Message.yes, Message.cancel], callback: { buttonindex in
            if buttonindex == 0 {
                self.deleteShopListItemToServerUsingNetwotk([onDeleteShopListItem])
            }
        })
    }
    
    func editAndCompleteShopItemStackView(_ completedShopItemStackView: EditAndCompleteShopItemStackView, onSelectShopItem: ShopListItemCellModel) {
        guard let shopItem = onSelectShopItem.shopItem else { return }
        self.performSegue(withIdentifier: Segues.showCompletedItemDetail, sender: ShopListItemDetailModel(shopListItem: onSelectShopItem.planItShopListItem, shopItem: shopItem))
    }
}


extension AddShoppingItemsViewController: ShoppingItemDetailViewControllerDelegate {
    
    func shoppingItemDetailViewController(_ shoppingItemDetailViewController: ShoppingItemDetailViewController, onAddUserCategory: CategoryData) {
        self.shoppingItemListViewController?.updateWithAddedCategory(onAddUserCategory)
    }
    
    func shoppingItemDetailViewController(_ shoppingItemDetailViewController: ShoppingItemDetailViewController, addUpdateItemDetail: ShopListItemDetailModel) {
        self.minimizeShopListView()
        self.refreshUpdateItemDetail(addUpdateItemDetail)
    }
    
    func shoppingItemDetailViewController(_ shoppingItemDetailViewController: ShoppingItemDetailViewController, onDeleteShopListItem: ShopListItemDetailModel) {
        self.allShopListItem.removeAll { (shopListItemCellModel) -> Bool in
            shopListItemCellModel.shopListItemId == onDeleteShopListItem.planItShopListItemId
        }
        self.resetShopListItemsAfterDelete()
    }
    
}


extension AddShoppingItemsViewController: CategoryListSectionViewControllerDelegate {
    
    func categoryListSectionViewController(_ categoryListSectionViewController: CategoryListSectionViewController, add userCategory: CategoryData) {
        self.shoppingItemListViewController?.updateWithAddedCategory(userCategory)
    }
    
    func categoryListSectionViewController(_ categoryListSectionViewController: CategoryListSectionViewController, selectedMainCategory: CategoryData?, selectedSubCategory: CategoryData?, userCategory: CategoryData?) {
        self.saveShopListItemUpdateCategoryToServerUsingNetwotk([categoryListSectionViewController.planItShopItem], shopListItems: categoryListSectionViewController.planItShopListItem, prodCat: selectedMainCategory, prodSubCat: selectedSubCategory, userProdCat: userCategory)
    }
}

extension AddShoppingItemsViewController: ShopListSelectionViewControllerDelegate {
    
    func shopListSelectionViewController(_ shopListSelectionViewController: ShopListSelectionViewController, selectedShopList: PlanItShopList) {
        let selectedShopListItem: [PlanItShopListItems] = shopListSelectionViewController.planItShopListItem
        self.saveShopListItemMoveToServerUsingNetwotk(selectedShopListItem, toList: selectedShopList)
    }
}


extension AddShoppingItemsViewController: ShareShoppingViewControllerDelegate {
    
    func shareShoppingViewController(_ viewController: ShareShoppingViewController, selected users: [OtherUser]) {
        self.saveShopListItemInviteesToServerUsingNetwotk(users)
    }
}


extension AddShoppingItemsViewController: DueDateViewControllerDelegate {
    
    func dueDateViewController(_ dueDateViewController: DueDateViewController, dueDate: Date) {
        let selectedShopListItem = self.incompletedShopListItems.filter({ $0.editSelected }).compactMap({ $0.planItShopListItem })
        if !selectedShopListItem.isEmpty {
            self.saveShoppingDueDateToServerUsingNetwotk(selectedShopListItem, date: dueDate)
        }
    }
}


extension AddShoppingItemsViewController: ReOrderCategoryViewControllerDelegate {
    
    func reorderCategoryViewController(_ ReOrderCategoryViewController: ReOrderCategoryViewController, shopListCategorys: [ShopItemListSection]) {
        self.planItShopList?.updateCategoryOrder(categorys: shopListCategorys)
        self.sectionedIncompletedShopListItems.sort { (section1, section2) -> Bool in
            if section1.isDefaultOrderValue() &&  section2.readOrderValue() == section1.readOrderValue() {
                return section1.readSectionName() > section2.readSectionName()
            }
            else {
                return section1.orderValue < section2.orderValue
            }
        }
        self.tableViewToDoItems?.reloadData()
    }
}
