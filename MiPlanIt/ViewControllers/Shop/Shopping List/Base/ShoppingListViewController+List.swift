//
//  ShoppingListViewController+List.swift
//  MiPlanIt
//
//  Created by Febin Paul on 27/10/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation
import UIKit

extension ShoppingListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.categories.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.categories[section].items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.shoppingListTableViewCell, for: indexPath) as! ShoppingListTableViewCell
        cell.configCell(planItShopList: self.categories[indexPath.section].items[indexPath.row], delegate: self)
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let trailingAction = UIContextualAction(style: .normal, title:  "", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            success(true)
            // delete list
            self.deleteShopList(on: indexPath)
        })
        
//        if let cgImageX = #imageLiteral(resourceName: "deleteswipefull").cgImage {
            trailingAction.image = UIImage(named: "deleteswipefull") //ImageWithoutRender(cgImage: cgImageX, scale: UIScreen.main.nativeScale, orientation: .up)
//        }
        trailingAction.backgroundColor = UIColor(red: 0.0902, green: 0.0980, blue: 0.1647, alpha: 1.0)


//        trailingAction.backgroundColor = UIColor(red: 214/255, green: 101/255, blue: 101/255, alpha: 1.0)
//        trailingAction.backgroundColor = UIColor.init(red: 247/255.0, green: 246/255.0, blue: 251/255.0, alpha: 1.0)
        let swipeAction = UISwipeActionsConfiguration(actions: [trailingAction])
        swipeAction.performsFirstActionWithFullSwipe = false
        return swipeAction
        
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let editAction = UIContextualAction(style: .normal, title:  "", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            success(true)
            //edit list
            self.performSegue(withIdentifier: Segues.toShopListDetail, sender: self.categories[indexPath.section].items[indexPath.row])
        })
//        if let cgImageX = #imageLiteral(resourceName: "editswipefullicon").cgImage {
            editAction.image = UIImage(named: "editswipefullicon")//ImageWithoutRender(cgImage: cgImageX, scale: UIScreen.main.nativeScale, orientation: .up)
//        }
        editAction.backgroundColor = UIColor(red: 0.0902, green: 0.0980, blue: 0.1647, alpha: 1.0)

//        editAction.backgroundColor = UIColor.init(red: 86/255.0, green: 173/255.0, blue: 189/255.0, alpha: 1.0)
//        editAction.backgroundColor = UIColor.init(red: 247/255.0, green: 246/255.0, blue: 251/255.0, alpha: 1.0)
//        editAction.backgroundColor = UIColor.init(patternImage: #imageLiteral(resourceName: "editswipefullicon"))
        
        let shareAction = UIContextualAction(style: .normal, title:  "", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            self.performSegue(withIdentifier: Segues.toShoppingShare, sender: (self.categories[indexPath.section].items[indexPath.row], indexPath))
            success(true)
        })
//        if let cgImageX = #imageLiteral(resourceName: "swipeshareicon").cgImage {
            shareAction.image = UIImage(named: "swipeshareicon")// ImageWithoutRender(cgImage: cgImageX, scale: UIScreen.main.nativeScale, orientation: .up)
//        }
        shareAction.backgroundColor = UIColor(red: 0.0902, green: 0.0980, blue: 0.1647, alpha: 1.0)

//        shareAction.backgroundColor = UIColor.init(red: 247/255.0, green: 246/255.0, blue: 251/255.0, alpha: 1.0)
        
        let printAction = UIContextualAction(style: .normal, title:  "", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            self.printShoppingList(selected: self.categories[indexPath.section].items[indexPath.row])
            success(true)
        })
        if let cgImageX = #imageLiteral(resourceName: "fullswipeprint").cgImage {
            printAction.image = ImageWithoutRender(cgImage: cgImageX, scale: UIScreen.main.nativeScale, orientation: .up)
        }
        printAction.backgroundColor = UIColor(red: 0.0902, green: 0.0980, blue: 0.1647, alpha: 1.0)

//        printAction.backgroundColor = UIColor.init(red: 247/255.0, green: 246/255.0, blue: 251/255.0, alpha: 1.0)
        
        let swipeAction = UISwipeActionsConfiguration(actions: [editAction, shareAction, printAction])
        swipeAction.performsFirstActionWithFullSwipe = false
        return swipeAction
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return section == self.categories.count - 1 ? 75 : 10
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footer = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 75))
        footer.backgroundColor = UIColor.clear
        return footer
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: Segues.toAddShoppingList, sender: self.categories[indexPath.section].items[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.shoppingCategoryListHeaderCell) as! ShoppingHeaderTableViewCell
        cell.configCell(category: self.categories[section].title)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
}
