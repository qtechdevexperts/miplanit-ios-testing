//
//  APNSService+Social.swift
//  MiPlanIt
//
//  Created by Arun on 04/09/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation
import UIKit
extension Session {
    
    func manageUsersDataUpdatedPayload(_ payload: [String: Any]) {
        guard let isAutoSync = payload["isAutoSync"] as? Bool, isAutoSync else { return }
        let moduleType = payload["moduleType"] as? String ?? Strings.empty
        switch moduleType {
        case "Event":
            self.manipulateEventsDataFromApplicationState(payload)
        case "Todo":
            self.createServiceToFetchUsersTodoData()
        case "Shopping":
            self.createServiceToFetchUsersShoppingData()
        default:
            self.manipulateEventsDataFromApplicationState(payload)
            break
        }
    }
    
    func endBackgroundTask() {
        if self.backgroundTask != .invalid {
            UIApplication.shared.endBackgroundTask(self.backgroundTask)
            self.backgroundTask = .invalid
        }
    }
    
    func registerBackgroundTask() {
        if self.backgroundTask == .invalid {
            self.backgroundTask = UIApplication.shared.beginBackgroundTask()
        }
    }
    

    func manipulateEventsDataFromApplicationState(_ payload: [String: Any]) {
        if UIApplication.shared.applicationState == .background || UIApplication.shared.applicationState == .inactive {
            if let eventData = payload["eventData"] as? String {
                self.registerBackgroundTask()
                DatabasePlanItData().insertPlanItUserDataForEventNotification(eventData, callback: { serviceDetaction in
//                    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate, let rootViewController = appDelegate.window?.rootViewController as? UINavigationController, let currentController = rootViewController.viewControllers.first as? BaseViewController else {
//                        return
//                    }
//                    currentController.refreshScreensWithUsersDataResult(serviceDetaction)
                    
                    
                    
                    if #available(iOS 13.0, *) {
                        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate, let rootViewController = sceneDelegate.window!.rootViewController  as? UINavigationController, let currentController = rootViewController.viewControllers.first as? BaseViewController {
                            currentController.refreshScreensWithUsersDataResult(serviceDetaction)

                        }
                    } else {
                        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate, let rootViewController = appDelegate.window?.rootViewController as? UINavigationController, let currentController = rootViewController.viewControllers.first as? BaseViewController else { return }

                        currentController.refreshScreensWithUsersDataResult(serviceDetaction)

                    }
                    
                })
            }
        }
        else {
            self.createServiceToFetchUsersEventData()
        }
    }
    
    func createServiceToFetchUsersEventData(_ callback: ((Bool) -> ())? = nil) {
        guard let user = Session.shared.readUser(), !self.readUsersCalendarDataFetching() else { return }
        CalendarService().fetchUsersCalendarServerData(user, callback: { result, serviceDetaction, _ in
            callback?(result)
            if result {
//                guard let appDelegate = UIApplication.shared.delegate as? AppDelegate, let rootViewController = appDelegate.window?.rootViewController as? UINavigationController, let currentController = rootViewController.viewControllers.first as? BaseViewController else { return }
//                currentController.refreshScreensWithUsersDataResult(serviceDetaction)
//
                
                if #available(iOS 13.0, *) {
                    if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate, let rootViewController = sceneDelegate.window!.rootViewController  as? UINavigationController, let currentController = rootViewController.viewControllers.first as? BaseViewController {
                        currentController.refreshScreensWithUsersDataResult(serviceDetaction)

                    }
                } else {
                    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate, let rootViewController = appDelegate.window?.rootViewController as? UINavigationController, let currentController = rootViewController.viewControllers.first as? BaseViewController else { return }

                    currentController.refreshScreensWithUsersDataResult(serviceDetaction)

                }
                
                
            }
        })
    }
    
    func createServiceToFetchUsersTodoData() {
        guard let user = Session.shared.readUser(), !self.readUsersTodoDataFetching() else { return }
        TodoService().fetchUsersToDoServerData(user, callback: { result, serviceDetaction, _ in
            if result {
//                guard let appDelegate = UIApplication.shared.delegate as? AppDelegate, let rootViewController = appDelegate.window?.rootViewController as? UINavigationController, let currentController = rootViewController.viewControllers.first as? BaseViewController else { return }
//                currentController.refreshScreensWithUsersDataResult(serviceDetaction)
                
                
                if #available(iOS 13.0, *) {
                    if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate, let rootViewController = sceneDelegate.window!.rootViewController  as? UINavigationController, let currentController = rootViewController.viewControllers.first as? BaseViewController {
                        currentController.refreshScreensWithUsersDataResult(serviceDetaction)

                    }
                } else {
                    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate, let rootViewController = appDelegate.window?.rootViewController as? UINavigationController, let currentController = rootViewController.viewControllers.first as? BaseViewController else { return }

                    currentController.refreshScreensWithUsersDataResult(serviceDetaction)

                }

                
                
            }
        })
    }
    
    func createServiceToFetchUsersShoppingData() {
        guard let user = Session.shared.readUser(), !self.readUsersShoppingDataFetching() else { return }
        ShopService().fetchUsersShoppingServerData(user, callback: { result, serviceDetaction, _ in
            if result {
//                guard let appDelegate = UIApplication.shared.delegate as? AppDelegate, let rootViewController = appDelegate.window?.rootViewController as? UINavigationController, let currentController = rootViewController.viewControllers.first as? BaseViewController else { return }
//                currentController.refreshScreensWithUsersDataResult(serviceDetaction)
//
                
                
                if #available(iOS 13.0, *) {
                    if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate, let rootViewController = sceneDelegate.window!.rootViewController  as? UINavigationController, let currentController = rootViewController.viewControllers.first as? BaseViewController {
                        currentController.refreshScreensWithUsersDataResult(serviceDetaction)

                    }
                } else {
                    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate, let rootViewController = appDelegate.window?.rootViewController as? UINavigationController, let currentController = rootViewController.viewControllers.first as? BaseViewController else { return }

                    currentController.refreshScreensWithUsersDataResult(serviceDetaction)

                }
            }
        })
    }
}
