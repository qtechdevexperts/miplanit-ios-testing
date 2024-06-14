//
//  ShoppingItemListViewController+List.swift
//  MiPlanIt
//
//  Created by Febin Paul on 27/10/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation
import UIKit

extension ShoppingItemListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.shoppingItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "itemListCell", for: indexPath) as! ShoppingItemTableViewCell
        cell.configCell(optionType: self.shoppingItems[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard let lastType = self.shoppingListOptionTypeOrder.last else { return UISwipeActionsConfiguration() }
        switch lastType {
        case .categories:
            if let shopCategory = self.shoppingItems[indexPath.row].planItShopMainCategory, shopCategory.isCustom {
                let trailingAction = UIContextualAction(style: .normal, title:  "", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
                    success(true)
                    self.deleteShopCategoryUsingNetwotk(self.shoppingItems[indexPath.row])
                })
                trailingAction.image = #imageLiteral(resourceName: "icon-cell-swipe-delete")
                trailingAction.backgroundColor = UIColor(red: 214/255, green: 101/255, blue: 101/255, alpha: 1.0)
                let swipeAction = UISwipeActionsConfiguration(actions: [trailingAction])
                swipeAction.performsFirstActionWithFullSwipe = false
                return swipeAction
            }
            else {
                return UISwipeActionsConfiguration()
            }
        default:
            break
        }
        return UISwipeActionsConfiguration()
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard let lastType = self.shoppingListOptionTypeOrder.last else { return UISwipeActionsConfiguration() }
        switch lastType {
        case .categories:
            if let shopCategory = self.shoppingItems[indexPath.row].planItShopMainCategory, shopCategory.isCustom {
                let trailingAction = UIContextualAction(style: .normal, title:  "", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
                    success(true)
                    self.performSegue(withIdentifier: Segues.segueAddShopCategory, sender: shopCategory)
                })
                trailingAction.image = #imageLiteral(resourceName: "icon-cell-swipe-edit")
                trailingAction.backgroundColor = UIColor.init(red: 85/255.0, green: 111/255.0, blue: 210/255.0, alpha: 1.0)
                let swipeAction = UISwipeActionsConfiguration(actions: [trailingAction])
                swipeAction.performsFirstActionWithFullSwipe = false
                return swipeAction
            }
            else {
                return UISwipeActionsConfiguration()
            }
        default:
            break
        }
        return UISwipeActionsConfiguration()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let lastType = self.shoppingListOptionTypeOrder.last else { return }
        switch lastType {
        case .base:
            if let type = self.shoppingItems[indexPath.row].listOptionType {
                switch type {
                case .categories:
                    self.shoppingListOptionTypeOrder.append(.categories)
                case .favoritesList:
                    self.showCollectionListFavoriteItmes()
                case .resentItems:
                    self.showCollectionListResendItmes()
                default:
                    break
                }
            }
            
        default:
            self.showCollectionListItmes(index: indexPath)
        }
    }
}
