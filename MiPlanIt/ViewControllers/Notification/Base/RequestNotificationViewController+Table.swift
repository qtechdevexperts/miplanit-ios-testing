//
//  RequestNotificationViewController+Table.swift
//  MiPlanIt
//
//  Created by Febin Paul on 08/04/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

extension RequestNotificationViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.showingUserNotifications.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let notification = self.showingUserNotifications[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: notification.isReadyToShowUserActions() ? CellIdentifier.requestNotificationPendingCell : CellIdentifier.requestNotificationDoneCell, for: indexPath) as! RequestNotificationTableViewCell
        cell.configure(notification, indexPath: indexPath, callback: self)
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if self.selectedFilter == .eDefault, self.userNotifications.count % self.itemsPerPage == 0, SocialManager.default.isNetworkReachable() {
            self.createWebServiceToFetchNotification()
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        let notification = self.showingUserNotifications[indexPath.row]
        return !notification.isReadyToShowUserActions()
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let trailingAction = UIContextualAction(style: .normal, title:  "", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            success(true)
            self.deleteNotification(on: indexPath)
        })
        trailingAction.image =  #imageLiteral(resourceName: "icon-cell-swipe-delete")
        trailingAction.backgroundColor = UIColor(red: 214/255, green: 101/255, blue: 101/255, alpha: 1.0)
        return UISwipeActionsConfiguration(actions: [trailingAction])
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footer = UIView.init(frame: .zero)
        footer.backgroundColor = UIColor.clear
        return footer
    }
}
