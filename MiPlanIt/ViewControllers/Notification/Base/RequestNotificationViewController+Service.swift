//
//  RequestNotificationViewController+Service.swift
//  MiPlanIt
//
//  Created by Arun on 16/04/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

extension RequestNotificationViewController {
    
    func createWebServiceToFetchNotification() {
        guard !self.serviceStarted, let user = Session.shared.readUser() else { return }
        self.serviceStarted = true
        NotificationService().fetchNotificationOfUser(user, page: self.currentPage + 1, itemsPerPage: self.itemsPerPage, callback: { response, error in
            self.serviceStarted = false
            if let result = response {
                self.currentPage += 1
                self.getPlanItUserNotification()
                self.sendMarkAsReadToServerForNotifications(result)
            }
            else if self.userNotifications.isEmpty {
                let message = error ?? Message.unknownError
                self.performSegue(withIdentifier: Segues.toMessageScreen, sender: [Message.error, message])
            }
            else {
                self.setEmptyNotificationView()
            }
        })
    }
    
    func createWebServiceToNotificationMarkAllAsRead(_ notifications: [UserNotification]) {
        guard let user = Session.shared.readUser() else { return }
        NotificationService().sendUser(user, notifications: notifications, status: 4, callback: { response, error in
            if let result = response {
                var allNotifications = self.userNotifications
                var showingNotifications = self.showingUserNotifications
                var notificationCount = user.readValueOfNotificationCount()
                result.forEach({ updatedPlanItNotification in
                    notificationCount = notificationCount - 1
                    if let index = allNotifications.firstIndex(where: { return $0.notificationId == updatedPlanItNotification.notificationId }) {
                        allNotifications[index] = UserNotification(with: updatedPlanItNotification)
                    }
                    if self.selectedFilter != .eDefault, let index = showingNotifications.firstIndex(where: { return $0.notificationId == updatedPlanItNotification.notificationId }) {
                        showingNotifications[index] = UserNotification(with: updatedPlanItNotification)
                    }
                })
                user.saveNotificationCount(notificationCount)
                self.userNotifications = allNotifications
                if self.selectedFilter != .eDefault { self.showingUserNotifications = showingNotifications }
            }
        })
    }
    
    func createWebServiceToNotificationDelete(_ notifications: [UserNotification], type: NotificationDelete, activityType: [Int]) {
        if SocialManager.default.isNetworkReachable() {
            guard let user = Session.shared.readUser() else { return }
            type == .deleteSpecific ? self.startLoadingIndicatorForNotification(notifications) : self.buttonClearAll.startAnimation()
            NotificationService().deleteNotification(user, notifications: notifications, type: type, activityType: activityType, completion: { response, error in
                type == .deleteSpecific ? self.stopLoadingIndicatorForNotification(notifications) : self.buttonClearAll.stopAnimation()
                if response {
                    self.getPlanItUserNotification()
                    if self.selectedFilter != .eDefault { self.refreshScreensWithFilterObject() }
                }
                else if self.userNotifications.isEmpty {
                    let message = error ?? Message.unknownError
                    self.performSegue(withIdentifier: Segues.toMessageScreen, sender: [Message.error, message])
                }
            })
        }
    }
    
    func createWebServiceForAcceptOrDeclainNotification(_ notification: UserNotification, from sender: ProcessingButton) {
        guard let user = Session.shared.readUser(), !self.pendingReadRequest.contains(notification.notificationId) else { return }
        sender.startAnimation()
        self.pendingReadRequest.append(notification.notificationId)
        NotificationService().sendUser(user, notifications: [notification], status: sender.tag == 0 ? 2 : sender.tag == 5 ? 4 : 1, callback: { response, error in
            if let result = response {
                sender.stopAnimation(animationStyle: .normal, revertAfterDelay: 0) {
                    result.forEach({ updatedPlanItNotification in
                        user.saveNotificationCount(user.readValueOfNotificationCount() - 1)
                        if let index = self.userNotifications.firstIndex(where: { return $0.notificationId == updatedPlanItNotification.notificationId }) {
                            self.userNotifications[index] = UserNotification(with: updatedPlanItNotification)
                        }
                        if self.selectedFilter != .eDefault, let index = self.showingUserNotifications.firstIndex(where: { return $0.notificationId == updatedPlanItNotification.notificationId }) {
                            self.showingUserNotifications[index] = UserNotification(with: updatedPlanItNotification)
                        }
                    })
                }
            }
            else if self.userNotifications.isEmpty {
                let message = error ?? Message.unknownError
                self.pendingReadRequest.removeAll(where: { $0 == notification.notificationId })
                sender.stopAnimation(animationStyle: .shake, revertAfterDelay: 0) {
                    self.performSegue(withIdentifier: Segues.toMessageScreen, sender: [Message.error, message])
                }
            }
        })
    }
}
