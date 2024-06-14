//
//  CustomDashBoardListViewController+List.swift
//  MiPlanIt
//
//  Created by Aneesh Asokan on 20/11/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation
import UIKit
extension CustomDashBoardListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return section == 0 ? 1 : self.customDashboardProfile.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.cellCustomDashboards, for: indexPath) as! CustomDashboardTableViewCell
        if indexPath.section == 0 {
            cell.configureCell(user: Session.shared.readUser(), count: itemsCount, dashboards: self.customDashboardProfile, delegate: self)
        }
        else {
            cell.configureCell(indexPath: indexPath, dashboard: self.customDashboardProfile[indexPath.row], delegate: self)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if indexPath.section == 0 {
            return UISwipeActionsConfiguration()
        }
        let trailingAction = UIContextualAction(style: .normal, title:  "", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            success(true)
            self.deleteDashboard(self.customDashboardProfile[indexPath.row])
        })
        trailingAction.image = #imageLiteral(resourceName: "icon-cell-swipe-delete")
        trailingAction.backgroundColor = UIColor(red: 214/255, green: 101/255, blue: 101/255, alpha: 1.0)
        let swipeAction = UISwipeActionsConfiguration(actions: [trailingAction])
        swipeAction.performsFirstActionWithFullSwipe = false
        return swipeAction
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        var uiSwipeActionConfiguration: [UIContextualAction] = []
        let editAction = UIContextualAction(style: .normal, title:  "", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            success(true)
            self.performSegue(withIdentifier: Segues.toCreateDashboard, sender: self.customDashboardProfile[indexPath.row])
        })
        editAction.image = #imageLiteral(resourceName: "icon-cell-swipe-edit")
        editAction.backgroundColor = UIColor.init(red: 85/255.0, green: 111/255.0, blue: 210/255.0, alpha: 1.0)
        if indexPath.section != 0 {
            uiSwipeActionConfiguration.append(editAction)
        }
        let defaultAction = UIContextualAction(style: .normal, title:  "", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            success(true)
            self.markAsDefault( indexPath.section == 0 ? nil : self.customDashboardProfile[indexPath.row])
        })
        defaultAction.image = #imageLiteral(resourceName: "markasdefaulticon")
        defaultAction.backgroundColor = UIColor.init(red: 29/255.0, green: 183/255.0, blue: 173/255.0, alpha: 1.0)
        if indexPath.section != 0 && self.customDashboardProfile[indexPath.row].planItDashboard.isDefault {
            defaultAction.backgroundColor = UIColor.init(red: 95/255.0, green: 180/255.0, blue: 85/255.0, alpha: 1.0)
            defaultAction.image = #imageLiteral(resourceName: "defaultIcon")
        }
        if indexPath.section == 0 && self.customDashboardProfile.filter({ $0.planItDashboard.isDefault == true }).count == 0 {
            defaultAction.backgroundColor = UIColor.init(red: 95/255.0, green: 180/255.0, blue: 85/255.0, alpha: 1.0)
            defaultAction.image = #imageLiteral(resourceName: "defaultIcon")
        }
        uiSwipeActionConfiguration.append(defaultAction)
        let swipeAction = UISwipeActionsConfiguration(actions: uiSwipeActionConfiguration)
        swipeAction.performsFirstActionWithFullSwipe = false
        return swipeAction
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return self.editable
    }
    
}
