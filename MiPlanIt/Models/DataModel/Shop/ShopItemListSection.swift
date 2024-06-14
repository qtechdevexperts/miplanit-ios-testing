//
//  ShopItemListSection.swift
//  MiPlanIt
//
//  Created by Febin Paul on 07/04/21.
//  Copyright © 2021 Arun. All rights reserved.
//

import Foundation


class ShopItemListSection {
    
    var orderValue: Double = 1000
    var sectionName: String = Strings.empty
    var shopListItems: [ShopListItemCellModel] = []
    
    init(name: String, items: [ShopListItemCellModel], orderCategory: [PlanItShopListCategoryOrder]? = nil) {
        self.sectionName = name
        self.shopListItems = items
        if let planItCategoryOrders = orderCategory, let category = planItCategoryOrders.filter({ name == $0.readCategoryName() }).first {
            self.orderValue = category.orderValue
        }
        else {
            self.orderValue = self.sectionName == Strings.shopOtherCategoryName ? 1001 : 1000
        }
    }
    
    init(shopItemDict: [String: [ShopListItemCellModel]]) {
        self.sectionName = Array(shopItemDict.keys).first ?? Strings.empty
        self.shopListItems = Array(shopItemDict.values).first ?? []
    }
    
    func readSectionName() -> String { return self.sectionName }
    func readOrderValue() -> Double { return self.orderValue }
    func isDefaultOrderValue() -> Bool { return self.orderValue == 1000 }
    
    func setOrderValue(_ value: Int) { self.orderValue = Double(value) }
}
