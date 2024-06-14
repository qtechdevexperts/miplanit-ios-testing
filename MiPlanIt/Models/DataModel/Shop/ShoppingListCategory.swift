//
//  ShoppingListCategory.swift
//  MiPlanIt
//
//  Created by Aneesh Asokan on 21/12/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

class ShoppingListCategory {
    var title: String
    var items: [PlanItShopList]
    
    init(with title: String, items: [PlanItShopList]) {
        self.title = title
        self.items = items
    }
}
