//
//  ShopListSelectionViewController+Action.swift
//  MiPlanIt
//
//  Created by Febin Paul on 13/11/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

extension ShopListSelectionViewController {
    
    func createShopListData() {
        let planItShopList =  DatabasePlanItShopList().readAllUserShopList()
        self.allShopListSelectionOptions = planItShopList.map({
            if self.currentShopList.readShopListIDValue() == 0.0 && !self.currentShopList.readAppShopListID().isEmpty {
                return ShopListSelectionOption(shopList: $0, currentAppShopId: self.currentShopList.readAppShopListID())
            }
            else {
                return ShopListSelectionOption(shopList: $0, currentShopId: self.currentShopList.readShopListIDValue())
            }
        })
    }
}
