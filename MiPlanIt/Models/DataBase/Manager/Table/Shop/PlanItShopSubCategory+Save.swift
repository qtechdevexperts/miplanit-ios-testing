//
//  PlanItShopSubCategory+Save.swift
//  MiPlanIt
//
//  Created by Febin Paul on 09/11/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

extension PlanItShopSubCategory {
    
    func readCategoryName() -> String { return self.name ?? Strings.empty }
    func readSubCategoryIdValue() -> Double { return self.masterCategoryId }
    
//    func readAllShopItems() -> [PlanItShopItems] {
//        if let items = self.shopItem, let shopItems = Array(items) as? [PlanItShopItems] {
//            return shopItems
//        }
//        return []
//    }
}
