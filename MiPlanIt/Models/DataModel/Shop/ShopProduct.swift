//
//  ShopProduct.swift
//  MiPlanIt
//
//  Created by Arun on 12/05/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

class ShopProduct: Comparable {
    var itemId: Double = 0
    var category: Double = 0
    var itemName = Strings.empty
    var quantity = Strings.empty
    
    init(with product: String, category: Double) {
        self.category = category
        self.itemName = product
    }
    
    init(with product: PlanItShopItems, category: Double) {
        self.category = category
        self.itemName = product.itemName ?? Strings.empty
    }
    
    func readIdentifier() -> String {
        if self.itemId == 0 { return self.itemName }
        return self.itemId.cleanValue()
    }
    
    static func == (lhs: ShopProduct, rhs: ShopProduct) -> Bool {
        return lhs.readIdentifier() == rhs.readIdentifier()
    }
    
    static func < (lhs: ShopProduct, rhs: ShopProduct) -> Bool {
        return lhs.readIdentifier() == rhs.readIdentifier()
    }
}
