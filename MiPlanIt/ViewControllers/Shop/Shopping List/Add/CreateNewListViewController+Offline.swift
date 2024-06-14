//
//  CreateNewListViewController+Offline.swift
//  MiPlanIt
//
//  Created by Febin Paul on 02/12/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation


extension CreateNewListViewController {

    func saveShopListToServerUsingNetwork() {
        if SocialManager.default.isNetworkReachable(), !self.shop.isPending {
            self.addShopping()
        }
        else {
            let data = self.imageViewShoppingListImage.image?.jpegData(compressionQuality: 0.5)
            let planItShopList = DatabasePlanItShopList().insertOfflineShopList(self.shop, imageData: data)
            self.dismiss(animated: true) {
                self.delegate?.createNewListViewController(self, createdUpdatedShoppingList: planItShopList)
            }
        }
    }
}
