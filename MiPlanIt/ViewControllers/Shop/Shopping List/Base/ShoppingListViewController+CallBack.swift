//
//  ShoppingListViewController+CallBack.swift
//  MiPlanIt
//
//  Created by Febin Paul on 10/05/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

extension ShoppingListViewController: AddShoppingItemsViewControllerDelegate {
    
    func addShoppingItemsViewController(_ addShoppingItemsViewController: AddShoppingItemsViewController, onUpdate: PlanItShopList) {
        self.tableView.reloadData()
    }
    
    func addShoppingItemsViewController(_ addShoppingItemsViewController: AddShoppingItemsViewController, addedShopList: PlanItShopList) {
        self.allShoppingList.insert(addedShopList, at: 0)
    }
    
    func addShoppingItemsViewController(_ addShoppingItemsViewController: AddShoppingItemsViewController, deletedShopList: PlanItShopList) {
        self.removeShoppingList(deletedShopList)
    }
    
}


extension ShoppingListViewController: CreateNewListViewControllerDelegate {
    
    func createNewListViewController(_ viewController: CreateNewListViewController, createdUpdatedShoppingList list: PlanItShopList?) {
        self.tableView.reloadData()
    }
}


extension ShoppingListViewController: ShoppingListTableViewCellDelegate {
    
    func ShoppingListTableViewCell(_ shoppingListTableViewCell: ShoppingListTableViewCell, shopList: PlanItShopList) {
        self.performSegue(withIdentifier: Segues.toSharedUsers, sender: shopList)
    }
}

extension ShoppingListViewController: ShareShoppingViewControllerDelegate {
    
    func shareShoppingViewController(_ viewController: ShareShoppingViewController, selected users: [OtherUser]) {
        self.saveShopListItemInviteesToServerUsingNetwotk(users)
    }
}


extension ShoppingListViewController: TabViewControllerDelegate {
    
    func tabViewController(_ tabViewController: TabViewController, updateHeightWithAd: Bool) {
        self.constraintTabHeight?.constant = updateHeightWithAd ? 147 : 77
    }
}
