//
//  DashboardShopListItem.swift
//  MiPlanIt
//
//  Created by Febin Paul on 30/11/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation


class DashboardShopListItem {
    
    var tags: [String] = []
    var shopListItemId: Double = 0.0
    var itemName: String = Strings.empty
    var description: String = Strings.empty
    var quantity: String = Strings.empty
    var duedate: Date = Date()
    var actualDueDate: Date?
    var createdDate: Date = Date()
    var shopListName: String = Strings.empty
    var shopListImage: String = Strings.empty
    var planItShopItem: PlanItShopItems?
    var planItShopListItems: PlanItShopListItems?
    var shopItemCategoryName: String = Strings.empty
    
    init(_ planItShopListItems: PlanItShopListItems, converter: DatabasePlanItShopListItem) {
        self.shopListItemId = planItShopListItems.readShopListItemsIdValue()
        self.description = planItShopListItems.readNotes()
        if let shopItem = planItShopListItems.isShopCustomItem ? DatabasePlanItShopItems().readSpecificUserShopItem([planItShopListItems.shopItemId]).first : DatabasePlanItShopItems().readSpecificMasterShopItem([planItShopListItems.shopItemId]).first {
            self.itemName = shopItem.readItemName()
            self.shopItemCategoryName = shopItem.readUserCategoryId().isEmpty ? shopItem.readMasterCategoryName() : shopItem.readUserCategoryName()
            self.planItShopItem = try? converter.mainObjectContext.existingObject(with: shopItem.objectID) as? PlanItShopItems
        }
        self.quantity = planItShopListItems.readQuantity()
        self.tags = planItShopListItems.readTags().compactMap({ $0.readTag() })
        self.duedate = planItShopListItems.readDueDate() ?? Date()
        self.actualDueDate = planItShopListItems.readDueDate()
        self.createdDate = planItShopListItems.readCreatedDate()
        self.shopListName = planItShopListItems.shopList?.readShopListName() ?? Strings.empty
        self.shopListImage = planItShopListItems.shopList?.readShopListImage() ?? Strings.empty
        self.planItShopListItems = try? converter.mainObjectContext.existingObject(with: planItShopListItems.objectID) as? PlanItShopListItems
    }
    
    func readAllTags() -> [String] {
        return self.tags.compactMap({ $0.lowercased() })
    }
    
    func containsName(_ string: String) -> Bool {
        return self.itemName.lowercased().contains(string)
    }
    
    func containsTags(_ string: String) -> Bool {
        return !self.tags.filter({ $0.lowercased().contains(string) }).isEmpty
    }
    
    func containsDescription(_ string: String) -> Bool {
        return self.description.lowercased().contains(string)
    }
    
    func containsCategory(_ string: String) -> Bool {
        return self.shopItemCategoryName.lowercased().contains(string)
    }
}
