//
//  ToDoListBaseViewController+Table.swift
//  MiPlanIt
//
//  Created by Febin Paul on 08/07/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation


extension AddShoppingItemsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.sectionedIncompletedShopListItems.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.sectionedIncompletedShopListItems[section].shopListItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return self.configureShoppingItemCell(tableView: tableView, indexPath: indexPath)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
        
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let trailingAction = UIContextualAction(style: .normal, title:  "", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            success(true)
            self.deleteItemClicked(on: indexPath)
        })
        trailingAction.image = #imageLiteral(resourceName: "icon-cell-swipe-delete") 
        trailingAction.backgroundColor = UIColor(red: 214/255, green: 101/255, blue: 101/255, alpha: 1.0)
        let swipeAction = UISwipeActionsConfiguration(actions: [trailingAction])
        swipeAction.performsFirstActionWithFullSwipe = false
        return swipeAction
        
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        var uiSwipeActionConfiguration: [UIContextualAction] = []
        let categoryAction = UIContextualAction(style: .normal, title:  "", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            success(true)
            self.showCategoryListClicked(on: indexPath)
        })
        categoryAction.image = #imageLiteral(resourceName: "cell-swipe-category-icon")
        categoryAction.backgroundColor = UIColor(red: 85/255, green: 111/255, blue: 210/255, alpha: 1.0)
        
        let favAction = UIContextualAction(style: .normal, title:  "", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            success(true)
            self.favoriteItemClicked(on: indexPath)
        })
        let favStatus = self.sectionedIncompletedShopListItems[indexPath.section].shopListItems[indexPath.row].planItShopListItem.isFavoriteLocal
        favAction.image = !favStatus ? #imageLiteral(resourceName: "cell-swipe-favorite-icon") : #imageLiteral(resourceName: "unfavoriteswipecell")
        favAction.backgroundColor = favStatus ? UIColor(red: 248/255.0, green: 150/255.0, blue: 50/255.0, alpha: 1.0) : UIColor(red: 255/255.0, green: 103/255.0, blue: 137/255.0, alpha: 1.0)
        
        let moveAction = UIContextualAction(style: .normal, title:  "", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            success(true)
            self.moveItemClicked(on: indexPath)
        })
        moveAction.image = #imageLiteral(resourceName: "icon-cell-swipe-move")
        moveAction.backgroundColor = UIColor(red: 156/255, green: 85/255, blue: 180/255, alpha: 1.0)
        if self.sectionedIncompletedShopListItems[indexPath.section].shopListItems[indexPath.row].shopItem?.isCustom ?? false {
            uiSwipeActionConfiguration.append(categoryAction)
        }
        uiSwipeActionConfiguration.append(favAction)
        if self.sectionedIncompletedShopListItems[indexPath.section].shopListItems[indexPath.row].shopItem?.isCustom ?? false {
            uiSwipeActionConfiguration.append(moveAction)
        }
        
        let swipeAction = UISwipeActionsConfiguration(actions: uiSwipeActionConfiguration)
        swipeAction.performsFirstActionWithFullSwipe = false
        return swipeAction
        
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return section == self.sectionedIncompletedShopListItems.count-1 ? 75 : 10
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footer = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: section == self.sectionedIncompletedShopListItems.count-1 ? 75 : 10))
        footer.backgroundColor = UIColor.clear
        return footer
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.shoppingListItemHeaderTableViewCell) as! ShoppingListItemHeaderTableViewCell
        cell.configCell(categoryName: self.sectionedIncompletedShopListItems[section].sectionName)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
}

