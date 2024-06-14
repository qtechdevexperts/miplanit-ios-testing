//
//  ShoppingItemDetailViewController+Service.swift
//  MiPlanIt
//
//  Created by Febin Paul on 12/11/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

extension ShoppingItemDetailViewController {
    
    func createWebServiceToUploadAttachment(_ attachement: UserAttachment) {
        UserService().uploadAttachement(attachement, callback: { response, error in
            if let _ = response {
                self.startPendingUploadOfAttachment()
            }
            else {
                let message = error ?? Message.unknownError
                self.buttonSave.stopAnimation(animationStyle: .shake, revertAfterDelay: 0) {
                    self.resetButton(self.buttonSave)
                    self.performSegue(withIdentifier: Segues.toMessageScreen, sender: [Message.error, message])
                }
            }
        })
    }
    
    func createWebServiceToEditShopListItemDetails(_ details: ShopListItemDetailModel) {
        ShopService().updateShopListDetail(details) { (result, error) in
            if result {
                self.buttonSave.clearButtonTitleForAnimation()
                self.buttonSave.stopAnimation(animationStyle: .normal, revertAfterDelay: 0) {
                    self.buttonSave.showTickAnimation { (results) in
                        self.navigationController?.popViewController(animated: true)
                        self.delegate?.shoppingItemDetailViewController(self, addUpdateItemDetail: details)
                    }
                }
            }
            else {
                let message = error ?? Message.unknownError
                self.buttonSave.stopAnimation(animationStyle: .shake, revertAfterDelay: 0) {
                    self.performSegue(withIdentifier: Segues.toMessageScreen, sender: [Message.error, message])
                }
            }
        }
    }
    
    func createWebServiceToFavoriteShopListItem(_ status: Bool) {
        guard let planItShopListItem = self.shopItemDetailModel.planItShopListItem, let shopList = planItShopListItem.shopList else { return }
        self.buttonFavorite.startAnimation()
        ShopService().shopListItemMarkAsFavorites([planItShopListItem], shop: shopList, with: status) { (result, error) in
            if result {
                self.buttonFavorite.stopAnimation(animationStyle: .normal, revertAfterDelay: 0.0) {
                    self.buttonFavorite.isSelected = status
                    self.delegate?.shoppingItemDetailViewController(self, addUpdateItemDetail: self.shopItemDetailModel)
                }
            }
            else {
                self.buttonSave.stopAnimation(animationStyle: .shake, revertAfterDelay: 0) {
                    let message = error ?? Message.unknownError
                    self.performSegue(withIdentifier: Segues.toMessageScreen, sender: [Message.error, message])
                }
            }
        }
        
    }
    
    func createWebServiceToCompleteShopListItem(_ status: Bool) {
        guard let planItShopListItem = self.shopItemDetailModel.planItShopListItem, let shopList = planItShopListItem.shopList else { return }
        ShopService().shopListItemMarkAsComplete([planItShopListItem], shop: shopList, with: status) { (result, error) in
            if result {
                self.buttonCheckMarkAsComplete?.stopAnimation(animationStyle: .normal, revertAfterDelay: 0.0) {
                    self.buttonCheckMarkAsComplete?.isSelected = status
                    self.delegate?.shoppingItemDetailViewController(self, addUpdateItemDetail: self.shopItemDetailModel)
                    if status {
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
            else {
                self.buttonCheckMarkAsComplete?.stopAnimation(animationStyle: .shake, revertAfterDelay: 0) {
                    let message = error ?? Message.unknownError
                    self.performSegue(withIdentifier: Segues.toMessageScreen, sender: [Message.error, message])
                }
            }
        }
    }
    
    func createWebServiceToDeleteShopListItems() {
        guard let planItShopListItem = self.shopItemDetailModel.planItShopListItem, let shopList = planItShopListItem.shopList else { return }
        self.buttonDelete?.startAnimation()
        ShopService().deleteShopListItems([planItShopListItem], shop: shopList) { (status, error) in
            if status {
                self.buttonDelete?.stopAnimation(animationStyle: .normal, revertAfterDelay: 0.0) {
                    self.navigationController?.popViewController(animated: true)
                    self.delegate?.shoppingItemDetailViewController(self, onDeleteShopListItem: self.shopItemDetailModel)
                }
            }
            else {
                self.buttonSave.stopAnimation(animationStyle: .shake, revertAfterDelay: 0) {
                    let message = error ?? Message.unknownError
                    self.performSegue(withIdentifier: Segues.toMessageScreen, sender: [Message.error, message])
                }
            }
        }
    }
    
}
