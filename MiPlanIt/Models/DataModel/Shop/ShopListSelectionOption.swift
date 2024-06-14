//
//  ShopListSelectionOption.swift
//  MiPlanIt
//
//  Created by Febin Paul on 13/11/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

class ShopListSelectionOption {
    
    var shopList: PlanItShopList!
    var isSelected: Bool = false
    
    init(shopList: PlanItShopList, currentShopId: Double) {
        self.shopList = shopList
        self.isSelected = shopList.readShopListIdValue() == currentShopId
    }
    
    init(shopList: PlanItShopList, currentAppShopId: String) {
        self.shopList = shopList
        self.isSelected = shopList.readAppShopListID() == currentAppShopId
    }
}
