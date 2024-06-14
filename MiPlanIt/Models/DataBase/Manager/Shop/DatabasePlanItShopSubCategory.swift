//
//  DatabasePlanItShopSubCategory.swift
//  MiPlanIt
//
//  Created by Febin Paul on 09/11/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation
import CoreData

class DatabasePlanItShopSubCategory: DataBaseManager {
    
    func insertOrUpdateShopSubCategory(_ data: [[String: Any]], parentCategory: PlanItShopMainCategory, using context: NSManagedObjectContext? = nil) {
        let objectContext = context ?? self.mainObjectContext
        let subcategoryIds = data.compactMap({ return $0["prodSubCatId"] as? Double })
        let localSubCategories = self.readSpecificShopCategory(subcategoryIds, using: objectContext)
        for shopSubCategory in data {
            let categoryId = shopSubCategory["prodSubCatId"] as? Double ?? 0
            let shopSubCategoryEntity = localSubCategories.filter({ return $0.masterCategoryId == categoryId}).first ?? self.insertNewRecords(Table.planItShopSubCategory, context: objectContext) as! PlanItShopSubCategory
            shopSubCategoryEntity.masterCategoryId = categoryId
            shopSubCategoryEntity.parentCategory = parentCategory
            shopSubCategoryEntity.userId = Session.shared.readUserId()
            shopSubCategoryEntity.name = shopSubCategory["prodSubCatName"] as? String
            if let createdBy = shopSubCategory["createdBy"] as? [String: Any] {
                DatabasePlanItCreator().insertShopCategory(shopSubCategoryEntity, creator: createdBy, using: objectContext)
            }
        }
    }
    
    func readSpecificShopCategory(_ categoryIds: [Double], using context: NSManagedObjectContext? = nil) -> [PlanItShopSubCategory] {
        let objectContext = context ?? self.mainObjectContext
        let predicate = NSPredicate(format: "userId == %@ AND masterCategoryId IN %@", Session.shared.readUserId(), categoryIds)
        return self.readRecords(fromCoreData: Table.planItShopSubCategory, predicate: predicate, context: objectContext) as! [PlanItShopSubCategory]
    }
}
