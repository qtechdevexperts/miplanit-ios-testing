//
//  RequestNotificationViewController+Action.swift
//  MiPlanIt
//
//  Created by Arun on 20/04/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

extension RequestNotificationViewController {
    
    func initialiseUIComponents() {
        self.lottieAnimationView.backgroundBehavior = .pauseAndRestore
        self.refreshControl.tintColor = UIColor.white
        self.refreshControl.attributedTitle = NSAttributedString(string: "")
        self.refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        self.buttonClearAll.isHidden = !SocialManager.default.isNetworkReachable() 
        self.tableViewNotification.addSubview(refreshControl) // not required when using UITableViewController
    }
    
    @objc func refresh(_ sender: AnyObject) {
        self.refreshData()
    }
    
    func refreshData() {
        guard SocialManager.default.isNetworkReachable() else {
            self.refreshControl.endRefreshing()
            return
        }
        self.currentPage = 0
        self.showAnimation = false
        self.createWebServiceToFetchNotification()
    }
    func startLottieAnimations() {
        guard self.currentPage == 0 else { return }
        self.viewFetchingData.isHidden = false
        self.lottieAnimationView.play(fromProgress: 0, toProgress: 0.1, loopMode: .loop, completion: nil)
    }
    
    func stopLottieAnimations() {
        guard self.currentPage == 0 else { return }
        self.viewFetchingData.isHidden = true
        if self.lottieAnimationView.isAnimationPlaying { self.lottieAnimationView.stop() }
    }
    
    func setEmptyNotificationView() {
        self.imageViewEmptyNotification.isHidden = !self.showingUserNotifications.isEmpty
        self.buttonClearAll.isHidden = self.showingUserNotifications.isEmpty
    }
    
    func sendMarkAsReadToServerForNotifications(_ notification: [PlanItUserNotification]) {
        let pendingNotifications = notification.map({ UserNotification(with: $0) }).filter({ return $0.isPossibleToUpdateMarkAsRead() })
        guard !pendingNotifications.isEmpty, SocialManager.default.isNetworkReachable() else { return }
        self.createWebServiceToNotificationMarkAllAsRead(pendingNotifications)
    }
    
    func getActivityTypeFromFilter() -> [Int] {
        if self.selectedFilter != .eDefault {
            switch self.selectedFilter {
            case .eCalendar:
                return [ActivityType.calendar.rawValue]
            case .eTask:
                return [ActivityType.todoList.rawValue, ActivityType.todoAssignee.rawValue]
            case .eEvent:
                return [ActivityType.event.rawValue]
            case .eShopping:
                return [ActivityType.shoppingList.rawValue]
            default:
                return []
            }
        }
        return []
    }
    
    func refreshScreensWithFilterObject() {
        switch self.selectedFilter {
        case .eCalendar:
            self.showingUserNotifications = self.userNotifications.filter({ return $0.actvityType == 1 })
        case .eEvent:
            self.showingUserNotifications = self.userNotifications.filter({ return $0.actvityType == 2 })
        case .eTask:
            self.showingUserNotifications = self.userNotifications.filter({ return ($0.actvityType == 5 || $0.actvityType == 3) })
        case .eShopping:
            self.showingUserNotifications = self.userNotifications.filter({ return ($0.actvityType == 4 || $0.actvityType == 7) })
        default: break
        }
    }
    
    func deleteNotification(on index: IndexPath? = nil) {
        var notificationsList: [UserNotification] = []
        var deleteType: NotificationDelete = self.selectedFilter != .eDefault ? .activityType : .all
        if let indexPath = index {
            notificationsList = [self.showingUserNotifications[indexPath.row]]
            deleteType = .deleteSpecific
        }
        self.createWebServiceToNotificationDelete(notificationsList, type: deleteType, activityType: self.getActivityTypeFromFilter())
    }
    
   func startLoadingIndicatorForNotification(_ userNotification: [UserNotification]) {
        for notification in userNotification {
            if let index = self.showingUserNotifications.firstIndex(where: { $0.readNotificationId() == notification.readNotificationId() }) {
              let indexPath = IndexPath(row: index, section: 0)
                if let cell = self.tableViewNotification.cellForRow(at: indexPath) as? RequestNotificationTableViewCell {
                    cell.startGradientAnimation()
                }
            }
        }
    }
    
    func stopLoadingIndicatorForNotification(_ userNotification: [UserNotification]) {
        for notification in userNotification {
            if let index = self.showingUserNotifications.firstIndex(where: { $0.readNotificationId() == notification.readNotificationId() }) {
              let indexPath = IndexPath(row: index, section: 0)
                if let cell = self.tableViewNotification.cellForRow(at: indexPath) as? RequestNotificationTableViewCell {
                    cell.stopGradientAnimation()
                }
            }
        }
    }
    
    func getPlanItUserNotification() {
        self.userNotifications = DatabasePlanItUserNotification().readAllUserNotification().map({ UserNotification(with: $0) })
    }
}
