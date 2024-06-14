//
//  APNSService+Shoping.swift
//  MiPlanIt
//
//  Created by Arun Aniyappan on 14/12/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation
import UIKit

extension Session {
    
    func manageShoppingoNotification(_ notification: UserNotification, from controller: UIViewController, onTap tapFlag: Bool = false) {
        self.checkForValidPurchase { (verifyStatus) in
            if verifyStatus {
                switch notification.readNotificationAction() {
                case 1:
                    switch notification.readNotificationStatus() {
                    case 0:
                        self.manageUserActionNotification(notification, from: controller)
                    case 1:
                        if notification.readActvityType() == 4 {
                            self.manageShoppingListNotification(notification, from: controller)
                        }
                    default: break
                    }
                case 2:
                    if notification.readActvityType() == 4 {
                        self.manageShopListDeleteNotification(notification, from: controller)
                    }
                    else {
                        self.manageShopListItemDeleteNotification(notification, from: controller)
                    }
                case 3, 4, 5, 101:
                    if notification.readActvityType() == 7 {
                        if notification.readSubActivityTitles().count == 1 {
                            self.manageShopListItemDetailNotification(notification, from: controller, onTap: tapFlag)
                        }
                        else if notification.readSubActivityTitles().count > 1 {
                            self.manageShoppingItemsListNotification(notification, from: controller, onTap: tapFlag)
                        }
                    }
                    else if notification.readActvityType() == 4 {
                        self.manageShoppingListNotification(notification, from: controller)
                    }
                default: break
                }
            }
            else {
                Session.shared.showPricingViewController()
            }
        }
        
    }
    
    func manageShoppingItemsListNotification(_ notification: UserNotification, from controller: UIViewController, onTap tapFlag: Bool = false) {
        self.updateLoaderInRequestNotification(show: true, on: notification, from: controller)
        self.createWebServiceToFetchPayloadOfNotification(notification, result: { response, _, error in
            self.updateLoaderInRequestNotification(show: false, on: notification, from: controller)
            if let result = response {
                let planItShopList = DatabasePlanItShopList().insertOrUpdateShopList(result)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: Notifications.dashboardShoppingUpdate), object: planItShopList)
                guard tapFlag else { return }
                guard !planItShopList.readDeleteStatus() else {
                    controller.showAlert(message: "Item already deleted", title: Message.error)
                    return
                }
                self.manageShopItemListNotification(notification, from: controller, shopList: planItShopList)
            }
            else if let message = error {
                controller.showAlert(message: message, title: Message.error)
            }
        })
    }
    
    func manageShoppingListNotification(_ notification: UserNotification, from controller: UIViewController) {
        self.updateLoaderInRequestNotification(show: true, on: notification, from: controller)
        self.createWebServiceToFetchPayloadOfNotification(notification, result: { response, _, error in
            self.updateLoaderInRequestNotification(show: false, on: notification, from: controller)
            if let result = response {
                let planItShopList = DatabasePlanItShopList().insertOrUpdateShopList(result)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: Notifications.dashboardShoppingUpdate), object: planItShopList)
                if controller is ShoppingListViewController { return }
                guard !planItShopList.readDeleteStatus() else {
                    controller.showAlert(message: "Item already deleted", title: Message.error)
                    return
                }
                self.manageShopItemListNotification(notification, from: controller, shopList: planItShopList)
            }
            //            else if let message = error {
            //                controller.showAlert(message: message, title: Message.error)
            //            }
        })
    }
    
    fileprivate func manageShopListDeleteNotification(_ notification: UserNotification, from controller: UIViewController) {
        self.createWebServiceToFetchPayloadOfNotification(notification, result: { response, statusCode, error in
            if let code = statusCode, code == Strings.deleteStatusCode  {
                DatabasePlanItShopList().deleteSpecificShop(notification.activityId)
                if let navController = controller.navigationController, let baseViewController = navController.viewControllers.first, baseViewController is ShoppingListViewController {
                    navController.storyboard(StoryBoards.shoppingList, setRootViewController: StoryBoardIdentifier.shoppingList, animated: false, force: true)
                }
                else if let navController = controller.navigationController, let baseViewController = navController.viewControllers.first, baseViewController is DashBoardViewController {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: Notifications.dashboardShoppingUpdate), object: nil)
                }
            }
        })
    }
    
    fileprivate func manageShopListItemDeleteNotification(_ notification: UserNotification, from controller: UIViewController) {
        self.createWebServiceToFetchPayloadOfNotification(notification, result: { response, statusCode, error in
            if let code = statusCode, code == Strings.deleteStatusCode  {
                DatabasePlanItShopListItem().deleteShopListItems([notification.activityId])
                if let navController = controller.navigationController, let baseViewController = navController.viewControllers.first, baseViewController is ShoppingListViewController {
                    navController.storyboard(StoryBoards.shoppingList, setRootViewController: StoryBoardIdentifier.shoppingList, animated: false, force: true)
                }
                else if let navController = controller.navigationController, let baseViewController = navController.viewControllers.first, baseViewController is DashBoardViewController {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: Notifications.dashboardShoppingUpdate), object: nil)
                }
            }
        })
    }
    
    func manageShopListItemDetailNotification(_ notification: UserNotification, from controller: UIViewController, onTap tapFlag: Bool = false) {
        self.updateLoaderInRequestNotification(show: true, on: notification, from: controller)
        self.createWebServiceToFetchPayloadOfNotification(notification, result: { response, _, error in
            self.updateLoaderInRequestNotification(show: false, on: notification, from: controller)
            if let result = response {
                guard let planItShopListItem = DatabasePlanItShopList().inserShopListItemFromShopData(result) else { return }
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: Notifications.dashboardShoppingUpdate), object: planItShopListItem)
                guard tapFlag else { return }
                if let notificationDetail = controller as? ShoppingItemDetailViewController, notificationDetail.shopItemDetailModel.planItShopListItem == planItShopListItem { return }
                guard let notificationShopingListDetail = UIStoryboard(name: StoryBoards.shoppingList, bundle: nil).instantiateViewController(withIdentifier: StoryBoardIdentifier.ShopListItemViewDetails) as? ShopListItemViewDetails else {
                    return
                }
                guard let planItShopItem = (planItShopListItem.isShopCustomItem ? DatabasePlanItShopItems().readSpecificUserShopItem([planItShopListItem.shopItemId]).first : DatabasePlanItShopItems().readSpecificMasterShopItem([planItShopListItem.shopItemId]).first) else {
                    return
                }
                notificationShopingListDetail.shopItemDetailModel = ShopListItemDetailModel(shopListItem: planItShopListItem, shopItem: planItShopItem)
                controller.readPresentedController().present(notificationShopingListDetail, animated: true, completion: nil)
            }
//            else if let message = error {
//                controller.showAlert(message: message, title: Message.error)
//            }
        })
    }
    
    func manageShopItemListNotification(_ notification: UserNotification, from controller: UIViewController, shopList: PlanItShopList) {
        controller.navigationController?.storyboardShoppingItemList(planItShopList: shopList, onComplete: notification.readNotificationAction() == 5)
    }
    
    //MARK: Local Notification
    func manageShopingLocalNotification(_ notification: [String: AnyObject]) {
        self.checkForValidPurchase { (verifyStatus) in
            if verifyStatus {
                if let shopingListItemId = notification["id"] as? Double, let specificShopingListItem = DatabasePlanItShopListItem().readSpecificShopListItem([shopingListItemId]).first {
                    
                    
                    
                    if #available(iOS 13.0, *) {
                        
                        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate, let rootViewController = sceneDelegate.window!.rootViewController  as? UINavigationController {
                            guard let notificationShopingListDetail = UIStoryboard(name: StoryBoards.shoppingList, bundle: nil).instantiateViewController(withIdentifier: StoryBoardIdentifier.ShopListItemViewDetails) as? ShopListItemViewDetails else {
                                return
                            }
                            guard let planItShopItem = (specificShopingListItem.isShopCustomItem ? DatabasePlanItShopItems().readSpecificUserShopItem([specificShopingListItem.shopItemId]).first : DatabasePlanItShopItems().readSpecificMasterShopItem([specificShopingListItem.shopItemId]).first) else {
                                return
                            }
                        }
                        
                        
                    }else{
                        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate, let rootViewController = appDelegate.window?.rootViewController as? UINavigationController else { return }
                        
                        guard let notificationShopingListDetail = UIStoryboard(name: StoryBoards.shoppingList, bundle: nil).instantiateViewController(withIdentifier: StoryBoardIdentifier.ShopListItemViewDetails) as? ShopListItemViewDetails else {
                            return
                        }
                        guard let planItShopItem = (specificShopingListItem.isShopCustomItem ? DatabasePlanItShopItems().readSpecificUserShopItem([specificShopingListItem.shopItemId]).first : DatabasePlanItShopItems().readSpecificMasterShopItem([specificShopingListItem.shopItemId]).first) else {
                            return
                        }
                        notificationShopingListDetail.shopItemDetailModel = ShopListItemDetailModel(shopListItem: specificShopingListItem, shopItem: planItShopItem)
                        rootViewController.present(notificationShopingListDetail, animated: true, completion: nil)
                    }
                    
                    
                    
  
                    
                }
            }
            else {
                Session.shared.showPricingViewController()
            }
        }
        
    }
}
