//
//  SearchAllShopItemViewController+Offline.swift
//  MiPlanIt
//
//  Created by Febin Paul on 17/02/21.
//  Copyright © 2021 Arun. All rights reserved.
//

import Foundation

extension SearchAllShopItemViewController {
    
    func addNewShopListItemUsingNetwork(_ itemName: String) {
        guard let shopList = currentPlanItShopList else { return }
        let shopListItemDetailModel = ShopListItemDetailModel(newItem: itemName, onShopList: shopList, withCategory: self.planItShopCategory)
        if SocialManager.default.isNetworkReachable() {
            self.createWebServiceToAddNewShopListItem(shopListItemDetailModel)
        }
        else {
            shopListItemDetailModel.saveNewShopListItemOffline()
            Session.shared.registerUserShopingListItemLocationNotification()
            self.delegate?.searchAllShopItemViewController(self, addedNewItem: shopListItemDetailModel)
        }
    }
}
