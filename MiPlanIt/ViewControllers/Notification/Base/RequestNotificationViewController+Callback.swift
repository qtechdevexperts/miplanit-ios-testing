//
//  RequestNotificationViewController+Callback.swift
//  MiPlanIt
//
//  Created by Nikhil RajG on 16/04/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

extension RequestNotificationViewController: RequestNotificationCellDelegate {
    
    func requestNotificationCell(_ requestNotificationCell: RequestNotificationTableViewCell, update notification: UserNotification, withAction action: ProcessingButton) {
        guard SocialManager.default.isNetworkReachable() else { return }
        self.createWebServiceForAcceptOrDeclainNotification(notification, from: action)
    }
    
    func requestNotificationCell(_ requestNotificationCell: RequestNotificationTableViewCell, showDetail notification: UserNotification) {
        guard SocialManager.default.isNetworkReachable() else { return }
        switch notification.readActvityType() {
        case 1:
            Session.shared.manageCalendarNotification(notification, from: self)
        case 2, 9:
            Session.shared.manageEventNotification(notification, from: self)
        case 3, 5:
            Session.shared.manageTodoNotification(notification, from: self, onTap: true)
        case 4, 7:
            Session.shared.manageShoppingoNotification(notification, from: self, onTap: true)
        default:
            break
        }
    }
}

extension RequestNotificationViewController: FilterViewControllerDelegate {
    
    func filterViewControllerResetAllOptions(_ viewController: FilterViewController) {
        self.selectedFilter = .eDefault
        self.showingUserNotifications = self.userNotifications
    }
    
    func filterViewController(_ viewController: FilterViewController, selected option: DropDownItem) {
        self.selectedFilter = option.dropDownType
        self.refreshScreensWithFilterObject()
    }
}

extension RequestNotificationViewController: TabViewControllerDelegate {
    
    func tabViewController(_ tabViewController: TabViewController, updateHeightWithAd: Bool) {
        self.constraintTabHeight?.constant = updateHeightWithAd ? 147 : 77
    }
}
