//
//  ShoppingItemListViewController+Callback.swift
//  MiPlanIt
//
//  Created by Febin Paul on 09/11/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

extension ShoppingItemListViewController {
    
    func deleteShopCategoryUsingNetwotk(_ category: ShoppingItemOptionList) {
        if SocialManager.default.isNetworkReachable() {
            self.createWebServiceToDeleteShopCategory([category])
        }
        else {
            guard let shopCategory = category.planItShopMainCategory else { return }
            DatabasePlanItShopMasterCategory().deleteShopCategorysOffline([shopCategory])
            self.removeDeletedShopCategory([shopCategory])
        }
    }
}
