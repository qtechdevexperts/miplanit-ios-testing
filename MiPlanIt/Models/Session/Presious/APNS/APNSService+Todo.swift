//
//  APNSService+Todo.swift
//  MiPlanIt
//
//  Created by Arun on 25/08/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation
import UIKit

extension Session {
    
    func manageTodoNotification(_ notification: UserNotification, from controller: UIViewController, onTap tapFlag: Bool = false) {
        self.checkForValidPurchase { (verifyStatus) in
            if verifyStatus {
                switch notification.readNotificationAction() {
                case 1:
                    switch notification.readNotificationStatus() {
                    case 0:
                        self.manageUserActionNotification(notification, from: controller)
                    case 1:
                        if notification.readActvityType() == 3 {
                            self.manageTodoListEditNotification(notification, from: controller)
                        }
                        else {
                            self.manageTodoEditNotification(notification, from: controller, onTap: tapFlag)
                        }
                    default: break
                    }
                case 2:
                    if notification.readActvityType() == 3 {
                        self.manageTodoListDeleteNotification(notification, from: controller)
                    }
                    else {
                        self.manageTodoDeleteNotification(notification, from: controller)
                    }
                case 3, 4, 5, 101:
                    if notification.readActvityType() == 3 {
                        self.manageTodoListEditNotification(notification, from: controller)
                    }
                    else {
                        self.manageTodoEditNotification(notification, from: controller, onTap: tapFlag)
                    }
                default: break
                }
            }
            else {
                Session.shared.showPricingViewController()
            }
        }
    }
    
    func manageTodoEditNotification(_ notification: UserNotification, from controller: UIViewController, onTap tapFlag: Bool) {
        self.updateLoaderInRequestNotification(show: true, on: notification, from: controller)
        self.createWebServiceToFetchPayloadOfNotification(notification, result: { response, _, error in
            self.updateLoaderInRequestNotification(show: false, on: notification, from: controller)
            if let result = response {
                guard let todo = DataBasePlanItTodoCategory().insertNewNotificationPlanItToDo(result) else { return }
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: Notifications.dashboardToDoUpdate), object: todo)
                guard !todo.completed || tapFlag else { return }
                if let notificationDetail = controller as? TodoDetailViewController, notificationDetail.mainToDoItem == todo { return }
                guard let notificationToDoDetail = UIStoryboard(name: StoryBoards.myTask, bundle: nil).instantiateViewController(withIdentifier: StoryBoardIdentifier.notificationToDoDetailViewController) as? NotificationToDoDetailViewController, !todo.readDeleteStatus() else {
                    controller.showAlert(message: "Item already deleted", title: Message.error)
                    return
                }
                notificationToDoDetail.mainToDoItem = todo
                notificationToDoDetail.isNeedBorder = true
                controller.readPresentedController().present(notificationToDoDetail, animated: true, completion: nil)
            }
//            else if let message = error {
//                controller.showAlert(message: message, title: Message.error)
//            }
        })
    }
    
    func manageTodoDeleteNotification(_ notification: UserNotification, from controller: UIViewController) {
        self.createWebServiceToFetchPayloadOfNotification(notification, result: { response, statusCode, error in
            if let result = response {
                guard let todo = DataBasePlanItTodoCategory().insertNewNotificationPlanItToDo(result) else { return }
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: Notifications.dashboardToDoUpdate), object: todo)
            }
            else if let code = statusCode, code == Strings.deleteStatusCode {
                guard let todo = DataBasePlanItTodo().readTodoWithId(todoId: notification.activityId).first else { return }
                todo.deletedStatus = true
                try? todo.managedObjectContext?.save()
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: Notifications.dashboardToDoUpdate), object: todo)
            }
//            else if let message = error {
//                controller.showAlert(message: message, title: Message.error)
//            }
        })
    }
    
    func manageTodoListEditNotification(_ notification: UserNotification, from controller: UIViewController) {
        self.updateLoaderInRequestNotification(show: true, on: notification, from: controller)
        self.createWebServiceToFetchPayloadOfNotification(notification, result: { response, _, error in
            self.updateLoaderInRequestNotification(show: false, on: notification, from: controller)
            if let result = response, let planItToDoCategory = DataBasePlanItTodoCategory().insertNewPlanItToDoCategory([result]).first, !planItToDoCategory.deletedStatus {
                controller.navigationController?.storyboardToDoList(planItToDoCategory: planItToDoCategory)
            }
            else {
                controller.navigationController?.storyboard(StoryBoards.myTask, setRootViewController: StoryBoardIdentifier.todoBase, animated: false, force: true)
            }
        })
    }
    
    func manageTodoListDeleteNotification(_ notification: UserNotification, from controller: UIViewController) {
        self.createWebServiceToFetchPayloadOfNotification(notification, result: { response, statusCode, error in
            if let result = response {
                guard let category = DataBasePlanItTodoCategory().insertNewPlanItToDoCategory([result]).first else { return }
                if category.deletedStatus { category.readAllTodos().forEach({$0.deletedStatus = true}) }
                if let navController = controller.navigationController, let baseViewController = navController.viewControllers.first, baseViewController is TodoBaseViewController {
                    navController.storyboard(StoryBoards.myTask, setRootViewController: StoryBoardIdentifier.todoBase, animated: false, force: true)
                }
            }
            else if let code = statusCode, code == Strings.deleteStatusCode {
                guard let category = DataBasePlanItTodoCategory().readSpecificToDoCategories([notification.activityId]).first else { return }
                category.readAllTodos().forEach({$0.deletedStatus = true})
                category.updateDeleteStatus()
                if let navController = controller.navigationController, let baseViewController = navController.viewControllers.first, baseViewController is TodoBaseViewController {
                    navController.storyboard(StoryBoards.myTask, setRootViewController: StoryBoardIdentifier.todoBase, animated: false, force: true)
                }
            }
        })
    }
    
    //MARK: Local Notification
    func manageTodoLocalNotification(_ notification: [String: AnyObject]) {
        self.checkForValidPurchase { (verifyStatus) in
            if verifyStatus {
                if let todoId = notification["id"] as? Double, let specificTodo = DataBasePlanItTodo().readTodoWithId(todoId: todoId).first {
                    
                    
//                    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate, let rootViewController = appDelegate.window?.rootViewController as? UINavigationController else { return }
                    
                    
                    if #available(iOS 13.0, *) {
                        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate, let rootViewController = sceneDelegate.window!.rootViewController  as? UINavigationController {
                            guard let notificationToDoDetail = UIStoryboard(name: StoryBoards.myTask, bundle: nil).instantiateViewController(withIdentifier: StoryBoardIdentifier.notificationToDoDetailViewController) as? NotificationToDoDetailViewController else { return }
                            notificationToDoDetail.mainToDoItem = specificTodo
                            notificationToDoDetail.isNeedBorder = true
                            rootViewController.present(notificationToDoDetail, animated: true, completion: nil)
                        }
                    } else {
                        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate, let rootViewController = appDelegate.window?.rootViewController as? UINavigationController else { return }
                        guard let notificationToDoDetail = UIStoryboard(name: StoryBoards.myTask, bundle: nil).instantiateViewController(withIdentifier: StoryBoardIdentifier.notificationToDoDetailViewController) as? NotificationToDoDetailViewController else { return }
                        notificationToDoDetail.mainToDoItem = specificTodo
                        notificationToDoDetail.isNeedBorder = true
                        rootViewController.present(notificationToDoDetail, animated: true, completion: nil)

                    }

                    
                    
//                    guard let notificationToDoDetail = UIStoryboard(name: StoryBoards.myTask, bundle: nil).instantiateViewController(withIdentifier: StoryBoardIdentifier.notificationToDoDetailViewController) as? NotificationToDoDetailViewController else { return }
//                    notificationToDoDetail.mainToDoItem = specificTodo
//                    notificationToDoDetail.isNeedBorder = true
//                    rootViewController.present(notificationToDoDetail, animated: true, completion: nil)
                }
            }
            else {
                Session.shared.showPricingViewController()
            }
        }
    }
}
