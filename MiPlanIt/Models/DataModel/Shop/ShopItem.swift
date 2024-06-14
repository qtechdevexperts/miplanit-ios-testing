//
//  ShopMasterItem.swift
//  MiPlanIt
//
//  Created by Febin Paul on 28/10/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

class ShopItem {
    
    var planItShopItem: PlanItShopItems?
    var itemName: String = Strings.empty
    var quantity: String = Strings.empty
    var itemSelected: Bool = false
    
    init(name: String) {
        self.itemName = name
    }
    
    init(_ planItShopItem: PlanItShopItems, quantity: String = Strings.empty) {
        self.itemName = planItShopItem.readItemName()
        self.planItShopItem = planItShopItem
        self.quantity = quantity
    }
    
    func readUserItemId() -> Double {
        return self.planItShopItem?.readUserItemIdValue() ?? 0.0
    }
    
    func readAppUserItemId() -> String {
        return self.planItShopItem?.appShopItemId ?? Strings.empty
    }
}
