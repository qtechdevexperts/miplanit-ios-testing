//
//  ShoppingItemDetailViewController+Offline.swift
//  MiPlanIt
//
//  Created by Febin Paul on 12/11/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

extension ShoppingItemDetailViewController {
    
    func saveShopListItemAttachmentsToServerUsingNetwotk(_ attachement: UserAttachment) {
        if SocialManager.default.isNetworkReachable() {
            self.createWebServiceToUploadAttachment(attachement)
        }
        else {
            self.saveDetailOffline()
        }
    }
    
    func saveShopListItemDetailsToServerUsingNetwotk() {
        if SocialManager.default.isNetworkReachable() {
            if let planItShopListItem = self.shopItemDetailModel.planItShopListItem, planItShopListItem.isPending || planItShopListItem.isShopItemPending() {
                self.saveDetailOffline()
                return
            }
            else if self.shopItemDetailModel.isCategoryPending() {
                self.saveDetailOffline()
                return
            }
            self.createWebServiceToEditShopListItemDetails(self.shopItemDetailModel)
        }
        else {
            self.saveDetailOffline()
        }
    }
    
    func saveDetailOffline() {
        self.updateModelWithData()
        self.shopItemDetailModel.saveNewShopListItemOffline()
        self.buttonSave.stopAnimation()
        Session.shared.registerUserShopingListItemLocationNotification()
        self.navigateBack()
        self.delegate?.shoppingItemDetailViewController(self, addUpdateItemDetail: self.shopItemDetailModel)
    }
    
    func saveShopListItemCompleteToServerUsingNetwotk(with status: Bool) {
        guard let planItShopListItem = self.shopItemDetailModel.planItShopListItem else { return }
        self.buttonCheckMarkAsComplete?.startAnimation()
        planItShopListItem.saveOnlyCompleteStatus(status)
        if SocialManager.default.isNetworkReachable(), (!planItShopListItem.isPending && !planItShopListItem.isShopItemPending() && !self.shopItemDetailModel.isCategoryPending()) {
            self.createWebServiceToCompleteShopListItem(status)
        }
        else {
            if status == false {
                self.buttonSave.isHidden = false;
                self.viewCompletedOverlay.isHidden = true;
                self.buttonCheckMarkAsComplete?.stopAnimation()
                return
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.buttonCheckMarkAsComplete?.stopAnimation()
                self.buttonCheckMarkAsComplete?.isSelected = status
                self.delegate?.shoppingItemDetailViewController(self, addUpdateItemDetail: self.shopItemDetailModel)
                self.navigateBack()
            }
        }
    }
    
    func saveShopListItemFavoriteToServerUsingNetwotk(with status: Bool) {
        guard let planItShopListItem = self.shopItemDetailModel.planItShopListItem else { return }
        if SocialManager.default.isNetworkReachable(), (!planItShopListItem.isPending && !planItShopListItem.isShopItemPending() && !self.shopItemDetailModel.isCategoryPending()) {
            self.createWebServiceToFavoriteShopListItem(status)
        }
        else {
            planItShopListItem.saveFovoriteStatus(status, details: self.shopItemDetailModel)
            self.buttonFavorite.isSelected = status
        }
    }
    
    func deleteShopListItemDetailsToServerUsingNetwotk() {
        guard let planItShopListItem = self.shopItemDetailModel.planItShopListItem else { return }
        if SocialManager.default.isNetworkReachable(), (!planItShopListItem.isPending && !planItShopListItem.isShopItemPending() && !self.shopItemDetailModel.isCategoryPending()) {
            self.createWebServiceToDeleteShopListItems()
        }
        else if let shoplistItem = self.shopItemDetailModel.planItShopListItem {
            Session.shared.removeNotification(LocalNotificationMethod.shopping.rawValue + shoplistItem.readValueOfNotificationId())
            shoplistItem.deleteOffline()
            self.delegate?.shoppingItemDetailViewController(self, onDeleteShopListItem: self.shopItemDetailModel)
            self.navigateBack()
        }
    }
}
