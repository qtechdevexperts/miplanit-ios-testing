//
//  APNSService+Event.swift
//  MiPlanIt
//
//  Created by Arun on 25/08/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation
import UIKit

extension Session {
    
    func manageEventNotification(_ notification: UserNotification, from controller: UIViewController) {
        self.checkForValidPurchase { (verifyStatus) in
            if verifyStatus {
                switch notification.readNotificationAction() {
                case 1:
                    switch notification.readNotificationStatus() {
                    case 0:
                        self.manageUserActionNotification(notification, from: controller)
                    case 1:
                        self.manageEventDetailtNotification(notification, from: controller)
                    default: break
                    }
                case 2:
                    self.manageEventDeleteNotification(notification, from: controller)
                case 3, 4, 101:
                    self.manageEventDetailtNotification(notification, from: controller)
                    
                default: break
                }
            }
            else {
                Session.shared.showPricingViewController()
            }
        }
        
    }
    
    fileprivate func manageEventDetailtNotification(_ notification: UserNotification, from controller: UIViewController) {
        self.updateLoaderInRequestNotification(show: true, on: notification, from: controller)
        self.createWebServiceToFetchPayloadOfNotification(notification, result: { response, _, error in
            self.updateLoaderInRequestNotification(show: false, on: notification, from: controller)
            if let result = response {
                guard let event = DatabasePlanItEvent().insertNewPlanItEvent([result], hardSave: true).first else { return }
                if let navController = controller.navigationController, let baseViewController = navController.viewControllers.first, baseViewController is MyCalanderBaseViewController {
                    navController.storyboard(StoryBoards.calendar, setRootViewController: StoryBoardIdentifier.calendar, animated: false, force: true)
                    return
                }
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: Notifications.dashboardEventUpdate), object: nil)
                guard let notificationEventDetail = UIStoryboard(name: StoryBoards.event, bundle: nil).instantiateViewController(withIdentifier: StoryBoardIdentifier.viewEventViewController) as? ViewEventViewController else {
                    return
                }
                notificationEventDetail.eventPlanOtherObject = event
                notificationEventDetail.dateEvent = DateSpecificEvent(with: event.readStartDateTime().initialHour())
                controller.readPresentedController().present(notificationEventDetail, animated: true, completion: nil)
            }
//            else if let message = error {
//                controller.showAlert(message: message, title: Message.error)
//            }
        })
    }
    
    fileprivate func manageEventDeleteNotification(_ notification: UserNotification, from controller: UIViewController) {
        self.createWebServiceToFetchPayloadOfNotification(notification, result: { response, statusCode, error in
            if let code = statusCode, code == Strings.deleteStatusCode  {
                DatabasePlanItEvent().removedPlantItEvents([notification.activityId])
                if let navController = controller.navigationController, let baseViewController = navController.viewControllers.first, baseViewController is MyCalanderBaseViewController {
                    navController.storyboard(StoryBoards.calendar, setRootViewController: StoryBoardIdentifier.calendar, animated: false, force: true)
                }
                else if let navController = controller.navigationController, let baseViewController = navController.viewControllers.first, baseViewController is DashboardBaseViewController {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: Notifications.dashboardEventUpdate), object: nil)
                }
            }
        })
    }
    
    func manageCalendarNotification(_ notification: UserNotification, from controller: UIViewController) {
        switch notification.readNotificationAction() {
        case 1:
            switch notification.readNotificationStatus() {
            case 0:
                self.manageUserActionNotification(notification, from: controller)
            case 1:
                self.manageCalendarDetailtNotification(notification, from: controller)
            default: break
            }
        case 2:
            self.manageCalendarDeleteNotification(notification, from: controller)
        case 3, 4, 101:
            self.manageCalendarDetailtNotification(notification, from: controller)
        default: break
        }
    }
    
    fileprivate func manageCalendarDetailtNotification(_ notification: UserNotification, from controller: UIViewController) {
        self.updateLoaderInRequestNotification(show: true, on: notification, from: controller)
        self.createWebServiceToFetchPayloadOfNotification(notification, result: { response, _, error in
            self.updateLoaderInRequestNotification(show: false, on: notification, from: controller)
            if let result = response {
                guard let calendar = DatabasePlanItCalendar().insertNewPlanItCalendars([result]).first else { return }
                Session.shared.loadFastestCalendars()
                if let navController = controller.navigationController, let baseViewController = navController.viewControllers.first, baseViewController is MyCalanderBaseViewController {
                    navController.storyboard(StoryBoards.calendar, setRootViewController: StoryBoardIdentifier.calendar, animated: false, force: true)
                    return
                }
                guard let notificationCalendarDetail = UIStoryboard(name: StoryBoards.calendar, bundle: nil).instantiateViewController(withIdentifier: StoryBoardIdentifier.viewCalendarDetailViewController) as? ViewCalendarDetailViewController else {
                    return
                }
                notificationCalendarDetail.calendar = NewCalendar(planItCalendar: calendar)
                controller.readPresentedController().present(notificationCalendarDetail, animated: true, completion: nil)
            }
//            else if let message = error {
//                controller.showAlert(message: message, title: Message.error)
//            }
        })
    }
    
    fileprivate func manageCalendarDeleteNotification(_ notification: UserNotification, from controller: UIViewController) {
        self.createWebServiceToFetchPayloadOfNotification(notification, result: { response, statusCode, error in
            if let code = statusCode, code == Strings.deleteStatusCode  {
                DatabasePlanItCalendar().removePlanItCalendars([notification.activityId])
                if let navController = controller.navigationController, let baseViewController = navController.viewControllers.first, baseViewController is MyCalanderBaseViewController {
                    navController.storyboard(StoryBoards.calendar, setRootViewController: StoryBoardIdentifier.calendar, animated: false, force: true)
                }
            }
        })
    }
    
    //MARK: Local Notification
    func manageEventLocalNotification(_ notification: [String: AnyObject]) {
        self.checkForValidPurchase { (verifyStatus) in
            if verifyStatus {
                if let eventId = notification["id"] as? Double, let specificDate = notification["date"] as? Date, let specificEvent = DatabasePlanItEvent().readSpecificEvent(eventId).first {
                    if specificEvent.eventHidden {
                        self.createWebServiceToFetchActivityDataPayloadOfNotification(1, activityId: Int(specificEvent.eventId)) { response, _, error  in
                            if let result = response, let event = DatabasePlanItEvent().insertNewPlanItEvent([result], hardSave: true).first {
                                self.showEventLocalNotificationDetails(event, at: specificDate)
                            }
                        }
                    }
                    else {
                        self.showEventLocalNotificationDetails(specificEvent, at: specificDate)
                    }
                }
            }
            else {
                Session.shared.showPricingViewController()
            }
        }
    }
    
    func showEventLocalNotificationDetails(_ event: PlanItEvent, at date: Date) {
//        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate, let rootViewController = appDelegate.window?.rootViewController as? UINavigationController else { return }
        
        
        if #available(iOS 13.0, *) {
            if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate, let rootViewController = sceneDelegate.window!.rootViewController  as? UINavigationController {
                guard let notificationEventDetail = UIStoryboard(name: StoryBoards.event, bundle: nil).instantiateViewController(withIdentifier: StoryBoardIdentifier.viewEventViewController) as? ViewEventViewController else {
                    return
                }
                notificationEventDetail.eventPlanOtherObject = event
                notificationEventDetail.dateEvent = DateSpecificEvent(with: date)
                rootViewController.present(notificationEventDetail, animated: true, completion: nil)
            }
        } else {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate, let rootViewController = appDelegate.window?.rootViewController as? UINavigationController else { return }
            guard let notificationEventDetail = UIStoryboard(name: StoryBoards.event, bundle: nil).instantiateViewController(withIdentifier: StoryBoardIdentifier.viewEventViewController) as? ViewEventViewController else {
                return
            }
            notificationEventDetail.eventPlanOtherObject = event
            notificationEventDetail.dateEvent = DateSpecificEvent(with: date)
            rootViewController.present(notificationEventDetail, animated: true, completion: nil)

        }
        
        
        
    }
}
