//
//  ShoppingListViewController+Service.swift
//  MiPlanIt
//
//  Created by Febin Paul on 09/05/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation


extension ShoppingListViewController {
    
    func createServiceToMasterData() {
        if SocialManager.default.isNetworkReachable() {
            guard let user = Session.shared.readUser() else { return }
            self.startLottieAnimations()
            ShopService().getShopMasterItem(user, callback: { result, serviceDetection, error in
                if result {
                    self.createServiceToUsersMasterData(user)
                }
                else {
                    self.shopPullToRefresh()
                    self.stopLottieAnimations()
                    self.showErrorMessage(error ?? Message.unknownError)
                }
            })
        }
    }
    
    func createServiceToUsersMasterData(_ user: PlanItUser) {
        ShopService().getUserShopItem(user, callback: { result, serviceDetection, error in
            if result {
                self.createServiceToUsersShopingList(user)
            }
            else {
                self.stopLottieAnimations()
                self.showErrorMessage(error ?? Message.unknownError)
            }
        })
    }
    
    func createServiceToUsersShopingList(_ user: PlanItUser) {
        ShopService().fetchUsersShoppingServerData(user, callback: { result, serviceDetection, error in
            if result {
                self.stopLottieAnimations()
                self.readAllUserShoppingList()
            }
            else {
                self.stopLottieAnimations()
                self.showErrorMessage(error ?? Message.unknownError)
            }
        })
    }
    
    func createWebServiceForDeleteShopList(shoppList: PlanItShopList, cell: ShoppingListTableViewCell?) {
        cell?.startGradientAnimation()
        ShopService().deleteShopList(shoppList) { (response, error) in
            cell?.stopGradientAnimation()
            if let _ = response {
                self.removeShoppingList(shoppList)
            }
            else {
                let message = error ?? Message.unknownError
                self.performSegue(withIdentifier: Segues.toMessageScreen, sender: [Message.error, message])
            }
        }
    }
    
    func createWebServiceForRemoveShopList(shoppList: PlanItShopList, cell: ShoppingListTableViewCell?) {
        cell?.startGradientAnimation()
        ShopService().removeShopList(ShopList(with: shoppList)) { (response, error) in
            cell?.stopGradientAnimation()
            if let _ = response {
                self.removeShoppingList(shoppList)
            }
            else {
                let message = error ?? Message.unknownError
                self.performSegue(withIdentifier: Segues.toMessageScreen, sender: [Message.error, message])
            }
        }
    }
    
    func updateInvitees(_ invitees: [OtherUser]) {
        guard let shopList = self.selectedShopList else { return }
        if let index = self.selectedIndexPath, let cell = self.tableView.cellForRow(at: index) as? ShoppingListTableViewCell {
            cell.startGradientAnimation()
        }
        ShopService().shareShopInvitees(invitees, shopList: shopList) { (result, error) in
            if let index = self.selectedIndexPath, let cell = self.tableView.cellForRow(at: index) as? ShoppingListTableViewCell {
                cell.stopGradientAnimation()
            }
            if result {
                self.tableView.reloadData()
            }
            else if let message = error {
                self.performSegue(withIdentifier: Segues.toMessageScreen, sender: [Message.error, message])
            }
            else {
                self.performSegue(withIdentifier: Segues.toMessageScreen, sender: [Message.error, Message.unknownError])
            }
        }
    }
}
