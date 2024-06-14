//
//  ShoppingListViewController+Offline.swift
//  MiPlanIt
//
//  Created by Febin Paul on 02/12/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

extension ShoppingListViewController {
    
    func deleteShopListToServerUsingNetwotk(_ shopList: PlanItShopList, cell: ShoppingListTableViewCell?) {
        if SocialManager.default.isNetworkReachable() && !shopList.isPending {
            self.createWebServiceForDeleteShopList(shoppList: shopList, cell: cell)
        }
        else {
            let deletedShopingListItems = shopList.readAllShopListItems().compactMap({ return LocalNotificationMethod.shopping.rawValue + $0.readValueOfNotificationId() })
            shopList.deleteOffline()
            Session.shared.removeShoppingNotifications(deletedShopingListItems)
            self.navigationController?.popViewController(animated: true)
            self.removeShoppingList(shopList)
        }
    }
    
    func removeShopListToServerUsingNetwotk(_ shopList: PlanItShopList, cell: ShoppingListTableViewCell?) {
        if SocialManager.default.isNetworkReachable() && !shopList.isPending {
            self.createWebServiceForRemoveShopList(shoppList: shopList, cell: cell)
        }
        else {
            let deletedShopingListItems = shopList.readAllShopListItems().compactMap({ return LocalNotificationMethod.shopping.rawValue + $0.readValueOfNotificationId() })
            shopList.deleteOffline()
            Session.shared.removeShoppingNotifications(deletedShopingListItems)
            self.navigationController?.popViewController(animated: true)
            self.removeShoppingList(shopList)
        }
    }
}
