//
//  ShoppingItemListViewController+Callback.swift
//  MiPlanIt
//
//  Created by Febin Paul on 09/11/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

extension ShoppingItemListViewController {
    
    func createWebServiceToDeleteShopCategory(_ categorys: [ShoppingItemOptionList]) {
        guard !categorys.isEmpty else { return }
        self.startLoadingIndicatorForShoppingItemOption(categorys)
        ShopService().removeShopCategory(categorys.compactMap({ $0.planItShopMainCategory })) { (planItShopCategory, error) in
            self.stopLoadingIndicatorForShoppingItemOption(categorys)
            if !planItShopCategory.isEmpty {
                self.removeDeletedShopCategory(planItShopCategory)
            }
        }
    }
}
