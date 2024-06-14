//
//  ToDoListBaseViewController+Override.swift
//  MiPlanIt
//
//  Created by Arun on 14/07/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

extension AddShoppingItemsViewController {
    
    @objc func configureShoppingItemCell(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.shopListItemViewCell, for: indexPath) as! ShopItemListCell
        cell.configCell(indexPath, shopListItem: self.sectionedIncompletedShopListItems[indexPath.section].shopListItems[indexPath.row], editMode: self.shopListMode, delegate: self)
        return cell
    }
    
    @objc func setVisibilityBGImage() {
        self.viewBGImageContainer?.isHidden = !self.allShopListItem.isEmpty;
    }
    
    @objc func setVisibilityTopStackView() {
        if self.shopListMode != .edit {
            if let viewSearch = self.viewSearch, !viewSearch.isHidden {
                return
            }
            self.stackViewTop?.isHidden = self.planItShopList == nil
            self.buttonSearch?.isHidden = self.incompletedShopListItems.isEmpty
            self.buttonHeaderEdit?.isHidden = self.incompletedShopListItems.isEmpty
            self.buttonList.isHidden = self.incompletedShopListItems.isEmpty
            self.viewListCount?.isHidden = self.incompletedShopListItems.isEmpty
            self.buttonMore?.isHidden = self.planItShopList == nil
        }
    }
    
    @objc func deleteItemClicked(on index: IndexPath) {
        self.showAlertWithAction(message: Message.deleteShoppingItemMessage, title: Message.deleteShoppingItem, items: [Message.yes, Message.cancel], callback: { buttonindex in
            if buttonindex == 0 {
                self.deleteShopListItemToServerUsingNetwotk([self.sectionedIncompletedShopListItems[index.section].shopListItems[index.row].planItShopListItem])
            }
        })
    }
    
    @objc func moveItemClicked(on index: IndexPath) {
        self.performSegue(withIdentifier: Segues.showShopListSelection, sender: [self.sectionedIncompletedShopListItems[index.section].shopListItems[index.row]])
    }
    
    @objc func showCategoryListClicked(on index: IndexPath) {
        self.performSegue(withIdentifier: Segues.showCategoryList, sender: self.sectionedIncompletedShopListItems[index.section].shopListItems[index.row])
    }
    
    @objc func favoriteItemClicked(on index: IndexPath) {
        self.saveShopListItemFavoriteToServerUsingNetwotk([self.sectionedIncompletedShopListItems[index.section].shopListItems[index.row].planItShopListItem], with: !self.sectionedIncompletedShopListItems[index.section].shopListItems[index.row].planItShopListItem.isFavoriteLocal)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            self.tableViewToDoItems?.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: self.stackViewEditAndCompleteShopItem.tableViewShopListItems.isHidden ? keyboardRectangle.height : 0, right: 0)
            self.tableViewToDoItems?.scrollIndicatorInsets = self.tableViewToDoItems?.contentInset ?? .zero
            if let indexPath = self.currentEditingCellIndex {
                DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
                    self.tableViewToDoItems?.scrollToRow(at: indexPath, at: UITableView.ScrollPosition.middle, animated: false)
                }
            }
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        self.constraintTableViewBottom.constant = 0
        self.currentEditingCellIndex = nil
        self.tableViewToDoItems?.contentInset = .zero
    }
    
    func toggleAllCellSelection(by flag: Bool) {
        self.incompletedShopListItems.forEach { (itemCellModel) in
            itemCellModel.editSelected = flag
        }
        self.tableViewToDoItems?.reloadData()
        self.updateSelectionLabelCount(self.incompletedShopListItems.filter({ $0.editSelected }).count)
    }
    
    func startLoadingIndicatorForShopListItem(_ shopListItems: [PlanItShopListItems]) {
        for eachItem in shopListItems {
            UIApplication.shared.beginIgnoringInteractionEvents()
            for (sectionIndex, eachSection) in self.sectionedIncompletedShopListItems.enumerated() {
                if let rowIndex = eachSection.shopListItems.firstIndex(where: { $0.planItShopListItem == eachItem }) {
                    let indexPath = IndexPath(row: rowIndex, section: sectionIndex)
                    if let cell = self.tableViewToDoItems?.cellForRow(at: indexPath) as? ShopItemListCell {
                        cell.startGradientAnimation()
                        break
                    }
                }
            }
            for (sectionIndex, eachSection) in self.stackViewEditAndCompleteShopItem.sectionedCompletedShopListItems.enumerated() {
                if let rowIndex = eachSection.shopListItems.firstIndex(where: { $0.planItShopListItem == eachItem }) {
                    let indexPath = IndexPath(row: rowIndex, section: sectionIndex)
                    if let cell = self.stackViewEditAndCompleteShopItem.tableViewShopListItems.cellForRow(at: indexPath) as? ShopItemListCell {
                        cell.startGradientAnimation()
                        break
                    }
                }
            }
        }
    }
    
    func stopLoadingIndicatorForTodos(_ shopListItems: [PlanItShopListItems]) {
        for eachItem in shopListItems {
            UIApplication.shared.endIgnoringInteractionEvents()
            for (sectionIndex, eachSection) in self.sectionedIncompletedShopListItems.enumerated() {
                if let rowIndex = eachSection.shopListItems.firstIndex(where: { $0.planItShopListItem == eachItem }) {
                    let indexPath = IndexPath(row: rowIndex, section: sectionIndex)
                    if let cell = self.tableViewToDoItems?.cellForRow(at: indexPath) as? ShopItemListCell {
                        cell.stopGradientAnimation()
                        break
                    }
                }
            }
            for (sectionIndex, eachSection) in self.stackViewEditAndCompleteShopItem.sectionedCompletedShopListItems.enumerated() {
                if let rowIndex = eachSection.shopListItems.firstIndex(where: { $0.planItShopListItem == eachItem }) {
                    let indexPath = IndexPath(row: rowIndex, section: sectionIndex)
                    if let cell = self.stackViewEditAndCompleteShopItem.tableViewShopListItems.cellForRow(at: indexPath) as? ShopItemListCell {
                        cell.stopGradientAnimation()
                        break
                    }
                }
            }
        }
    }
}
