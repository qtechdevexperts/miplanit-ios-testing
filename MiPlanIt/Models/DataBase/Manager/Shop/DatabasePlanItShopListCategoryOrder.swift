//
//  DatabasePlanItShopListCategoryOrder.swift
//  MiPlanIt
//
//  Created by Febin Paul on 28/04/21.
//  Copyright © 2021 Arun. All rights reserved.
//

import Foundation
import CoreData

class DatabasePlanItShopListCategoryOrder: DataBaseManager {
    
    func insertShopListCategoryOrder(_ planItShopList: PlanItShopList, shopItemListSection: [ShopItemListSection], using context: NSManagedObjectContext? = nil) {
        planItShopList.deleteAllCategoryOrder()
        let objectContext = context ?? self.mainObjectContext
        for eachListSection in shopItemListSection {
            let shopListCategoryOrderEntity = self.insertNewRecords(Table.planItShopListCategoryOrder, context: objectContext) as! PlanItShopListCategoryOrder
            shopListCategoryOrderEntity.categoryName = eachListSection.readSectionName()
            shopListCategoryOrderEntity.orderValue = eachListSection.readOrderValue()
            shopListCategoryOrderEntity.shopList = planItShopList
        }
        context?.saveContext()
    }
    
}
