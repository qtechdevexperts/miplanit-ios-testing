//
//  ToDoListBaseViewController+Table.swift
//  MiPlanIt
//
//  Created by Febin Paul on 08/07/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation


extension ToDoListBaseViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.toDoItemCellModels.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return self.configureToDoCell(tableView: tableView, indexPath: indexPath)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteStatus = self.toDoItemCellModels[indexPath.section].planItToDo.readDeleteStatus()
        let trailingAction = UIContextualAction(style: .normal, title:  "", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            success(true)
            !deleteStatus ? self.deleteItemClicked(on: indexPath) : self.restoreItemClicked(on: indexPath)
        })
        trailingAction.image = !deleteStatus ? #imageLiteral(resourceName: "icon-cell-swipe-delete") : #imageLiteral(resourceName: "restoreSwipeIcon")
        trailingAction.backgroundColor = !deleteStatus ? UIColor(red: 214/255, green: 101/255, blue: 101/255, alpha: 1.0) : UIColor(red: 113/255, green: 196/255, blue: 152/255, alpha: 1.0)
        let swipeAction = UISwipeActionsConfiguration(actions: [trailingAction])
        swipeAction.performsFirstActionWithFullSwipe = false
        if let modifiedId =  self.toDoItemCellModels[indexPath.section].planItToDo.modifiedBy, modifiedId.readValueOfUserId() != Session.shared.readUserId(), deleteStatus {
            return UISwipeActionsConfiguration()
        }
        return swipeAction
        
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let shareAction = UIContextualAction(style: .normal, title:  "", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            success(true)
            self.editItemClicked(on: indexPath)
        })
        shareAction.image = #imageLiteral(resourceName: "icon-cell-swipe-edit")
        shareAction.backgroundColor = UIColor.init(red: 85/255.0, green: 111/255.0, blue: 210/255.0, alpha: 1.0)
        let assignAction = UIContextualAction(style: .normal, title:  "", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            success(true)
            self.assignItemClicked(on: indexPath)
        })
        assignAction.image = #imageLiteral(resourceName: "icon-cell-swipe-assign")
        assignAction.backgroundColor = UIColor(red: 101/255, green: 165/255, blue: 203/255, alpha: 1.0)
        let moveAction = UIContextualAction(style: .normal, title:  "", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            success(true)
            self.moveItemClicked(on: indexPath)
        })
        moveAction.image = #imageLiteral(resourceName: "icon-cell-swipe-move")
        moveAction.backgroundColor = UIColor(red: 248/255.0, green: 150/255.0, blue: 50/255.0, alpha: 1)
        let swipeAction = UISwipeActionsConfiguration(actions: [shareAction, assignAction, moveAction])
        swipeAction.performsFirstActionWithFullSwipe = false
        return self.categoryType == .custom ? swipeAction : UISwipeActionsConfiguration()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return section == self.toDoItemCellModels.count-1 ? 75 : 10
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footer = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: section == self.toDoItemCellModels.count-1 ? 75 : 10))
        footer.backgroundColor = UIColor.clear
        return footer
    }
    
}

