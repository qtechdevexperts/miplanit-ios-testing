//
//  ShoppingListViewController+Search.swift
//  MiPlanIt
//
//  Created by Arun on 11/05/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

extension ShoppingListViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) ?? Strings.empty
        self.searchShoppingListUsingText(currentText)
        return true
    }
    
    func searchShoppingListUsingText(_ text: String) {
        self.buttonSearch.isSelected = !text.isEmpty
        self.buttonClearSearch.isHidden = text.isEmpty
        self.searchShoppingWithText(text)
    }
    
    func searchShoppingWithText(_ text: String) {
        guard !text.isEmpty else { self.userShoppingList = self.allShoppingList; self.groupCategoriesBasedOnOwnerShare(); return }
        self.userShoppingList = allShoppingList.filter({ return $0.readShopListName().range(of: text, options: .caseInsensitive) != nil })
        self.groupCategoriesBasedOnOwnerShare()
    }
    
    func groupCategoriesBasedOnOwnerShare() {
        self.categories.removeAll()
        let ownerCategories = self.userShoppingList.filter({ return $0.createdBy?.readValueOfUserId() == Session.shared.readUserId() })
        if !ownerCategories.isEmpty {
            self.categories.append(ShoppingListCategory(with: Strings.mylist, items: ownerCategories))
        }
        let sharedCategories = self.userShoppingList.filter({ return $0.createdBy?.readValueOfUserId() != Session.shared.readUserId() })
        if !sharedCategories.isEmpty {
            self.categories.append(ShoppingListCategory(with: Strings.sharedList, items: sharedCategories))
        }
        self.tableView.reloadData()
    }
}
