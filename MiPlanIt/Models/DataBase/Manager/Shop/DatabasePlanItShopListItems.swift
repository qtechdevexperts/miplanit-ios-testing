//
//  DatabasePlanItShopListItem.swift
//  MiPlanIt
//
//  Created by Febin Paul on 10/11/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation
import CoreData

class DatabasePlanItShopListItem: DataBaseManager {
    
    @discardableResult func insertShopListItem(_ shopListItem: [[String: Any]], planItShopList: PlanItShopList, updatePlanItShopListItems planItShopListItems: PlanItShopListItems? = nil, shopListItemDetailModel: ShopListItemDetailModel? = nil, using context: NSManagedObjectContext? = nil) -> [PlanItShopListItems] {
        var shoppingListItems: [PlanItShopListItems] = []
        let objectContext = context ?? self.mainObjectContext
        let localShopListItems = self.readShopListItemWithIds(shopLists: shopListItem, using: context)
        for eachShopListItem in shopListItem {
            
            var modifiedDate: Date?
            if let date = eachShopListItem["modifiedAt"] as? String {
                modifiedDate = date.stringToDate(formatter: DateFormatters.MMDDYYYYHMMSSA, timeZone: TimeZone(abbreviation: "UTC")!)
            }
            let shopListItemId = eachShopListItem["listDetailId"] as? Double ?? 0
            let appShopListItemId = eachShopListItem["appListDetailId"] as? String ?? Strings.empty
            let movedShopItem = self.readMovedItem(eachShopListItem["movedListDetailId"] as? Double, using: objectContext)
            let shopListItemEntity = movedShopItem ?? localShopListItems.filter({ return ($0.shopListItemId == shopListItemId && shopListItemId != 0) || ($0.appShopListItemId == appShopListItemId && !appShopListItemId.isEmpty) }).first ?? self.insertNewRecords(Table.planItShopListItems, context: objectContext) as! PlanItShopListItems
            if let movedItem = movedShopItem, movedItem.isPending {
                shopListItemEntity.shopListItemId = shopListItemId
                shopListItemEntity.appShopListItemId = appShopListItemId
                shopListItemEntity.shopList = planItShopList
                shoppingListItems.append(shopListItemEntity)
                continue
            }
            shopListItemEntity.isPending = false
            shopListItemEntity.shopListItemId = shopListItemId
            shoppingListItems.append(shopListItemEntity)
            shopListItemEntity.notifiedDate = nil
            shopListItemEntity.remindMe = LocalNotificationType.new.rawValue
            shopListItemEntity.userId = Session.shared.readUserId()
            shopListItemEntity.quantity = eachShopListItem["quantity"] as? String
            let favoriteStatus = eachShopListItem["isFavourite"] as? Bool ?? false
            if favoriteStatus == shopListItemEntity.isFavoriteLocal || shopListItemEntity.isFavoriteLocal == shopListItemEntity.isFavorite {
                shopListItemEntity.isFavorite = favoriteStatus
                shopListItemEntity.isFavoriteLocal = favoriteStatus
            }
            else {
                shopListItemEntity.isFavorite = favoriteStatus
            }
            shopListItemEntity.shopList = planItShopList
            shopListItemEntity.notes = eachShopListItem["notes"] as? String
            shopListItemEntity.storeName = eachShopListItem["store"] as? String
            shopListItemEntity.targetPrice = eachShopListItem["targetPrice"] as? String
            shopListItemEntity.url = eachShopListItem["url"] as? String
            shopListItemEntity.brand = eachShopListItem["brand"] as? String
            shopListItemEntity.isShopCustomItem = eachShopListItem["custom"] as? Bool ?? false
            shopListItemEntity.reminderId = eachShopListItem["reminderId"] as? Double ?? 0
            if let date = eachShopListItem["dueDate"] as? String {
                shopListItemEntity.dueDate = date.stringToDate(formatter: DateFormatters.MMDDYYYY)
            }
            else {
                shopListItemEntity.dueDate = nil
            }
            let completedStatus = (eachShopListItem["completionDate"] as? String) != nil
            if completedStatus == shopListItemEntity.isCompletedLocal || shopListItemEntity.isCompletedLocal == shopListItemEntity.isCompleted {
                shopListItemEntity.isCompleted = completedStatus
                shopListItemEntity.isCompletedLocal = completedStatus
            }
            else {
                shopListItemEntity.isCompleted = completedStatus
            }
            if let date = eachShopListItem["createdAt"] as? String {
                shopListItemEntity.createdDate = date.stringToDate(formatter: DateFormatters.MMDDYYYYHMMSSA, timeZone: TimeZone(abbreviation: "UTC")!)
            }
            if (eachShopListItem["modifiedAt"] as? String) != nil {
                shopListItemEntity.modifiedAt = modifiedDate
            }
            if let createdBy = eachShopListItem["createdBy"] as? [String: Any] {
                DatabasePlanItCreator().insertShopListItem(shopListItemEntity, creator: createdBy, using: objectContext)
            }
            if let modifiedBy = eachShopListItem["modifiedBy"] as? [String: Any] {
                DatabasePlanItModifier().insertShopListItem(shopListItemEntity, modifier: modifiedBy, using: objectContext)
            }
            if let tags = eachShopListItem["tags"] as? [[String: String]] {
                let arrayTags = tags.compactMap({$0.values.first})
                DatabasePlanItTags().insertTags(arrayTags, for: shopListItemEntity, using: objectContext)
            }
            if let attachments = eachShopListItem["attachments"] as? [[String: Any]] {
                DatabasePlanItUserAttachment().insertAttachments(attachments, for: shopListItemEntity, using: objectContext)
            }
            if let reminders = eachShopListItem["reminders"] as? [String: Any], shopListItemEntity.reminderId != 0.0 {
                DataBasePlanItTodoReminders().insertShopListItem(shopListItemEntity, reminders: reminders, using: objectContext)
            }
            else if let planItReminder = shopListItemEntity.reminder {
                planItReminder.deleteItSelf()
            }
            if shopListItemEntity.isShopCustomItem {
                if let shopItem =  eachShopListItem["userItems"] as? [String: Any] {
                    let planItShopItems = DatabasePlanItShopItems().insertUserShopItem(shopItem, using: objectContext)
                    shopListItemDetailModel?.planItShopItem = planItShopItems
                    shopListItemEntity.shopItemId = planItShopItems.readUserItemIdValue()
                }
            }
            else {
                if let shopItem =  eachShopListItem["items"] as? [String: Any] {
                    let planItShopItems = DatabasePlanItShopItems().insertShopItem(shopItem, using: objectContext)
                    shopListItemDetailModel?.planItShopItem = planItShopItems
                    shopListItemEntity.shopItemId = planItShopItems.readMasterItemIdValue()
                }
            }
        }
        return shoppingListItems
    }
    
    
    func insertShopListItem(_ shopItem: ShopListItemDetailModel, planItShopList: PlanItShopList, planItShopItem: PlanItShopItems? = nil) -> PlanItShopListItems? {
        let shopListItemEntity = self.insertNewRecords(Table.planItShopListItems, context: self.mainObjectContext) as! PlanItShopListItems
        shopListItemEntity.notifiedDate = nil
        shopListItemEntity.remindMe = LocalNotificationType.new.rawValue
        shopListItemEntity.userId = Session.shared.readUserId()
        shopListItemEntity.quantity = shopItem.quantity
        shopListItemEntity.appShopListItemId = UUID().uuidString
        shopListItemEntity.isPending = true
        shopListItemEntity.isCompleted = false
        shopListItemEntity.isFavorite = false
        shopListItemEntity.isFavoriteLocal = false
        shopListItemEntity.shopList = planItShopList
        shopListItemEntity.dueDate = shopItem.dueDate
        if let shopItemPlanItShopItem = shopItem.planItShopItem {
            if shopItemPlanItShopItem.isPending && !shopItemPlanItShopItem.readAppShopItemId().isEmpty {
                shopListItemEntity.appShopItemId = shopItemPlanItShopItem.readAppShopItemId()
            }
            else {
                shopListItemEntity.shopItemId = (shopItemPlanItShopItem.isCustom ) ? shopItemPlanItShopItem.readUserItemIdValue() : shopItemPlanItShopItem.readMasterItemIdValue()
            }
            shopListItemEntity.isShopCustomItem = shopItemPlanItShopItem.isUserCreated()
        }
        else {
            shopListItemEntity.isShopCustomItem = true
            if let unwrapPlanItShopItem = planItShopItem, unwrapPlanItShopItem.isPending {
                shopListItemEntity.appShopItemId = unwrapPlanItShopItem.appShopItemId
            }
            else if let unWrapPlanItShopItem = planItShopItem {
                shopListItemEntity.shopItemId = unWrapPlanItShopItem.readUserItemIdValue()
            }
        }
        shopListItemEntity.createdDate = shopItem.createdDate
        shopListItemEntity.notes = shopItem.notes
        shopListItemEntity.storeName = shopItem.store
        shopListItemEntity.targetPrice = shopItem.targetPrize
        shopListItemEntity.url = shopItem.url
        shopListItemEntity.brand = shopItem.brand
        if !shopItem.tags.isEmpty {
            DatabasePlanItTags().insertTags(shopItem.tags, for: shopListItemEntity, using: self.mainObjectContext)
        }
        if !shopItem.attachments.isEmpty {
            DatabasePlanItUserAttachment().insertAttachments(shopItem.attachments, for: shopListItemEntity, using: self.mainObjectContext)
        }
        if let _ = shopItem.remindValue {
            DataBasePlanItTodoReminders().insertShopListItem(shopListItemEntity, shopListItemModel: shopItem)
        }
        DatabasePlanItCreator().insertShopListItem(shopListItemEntity, creator: Session.shared.readUser(), using: self.mainObjectContext)
        shopListItemEntity.modifiedAt = Date()
        self.mainObjectContext.saveContext()
        return shopListItemEntity
    }
    
    func savePendingStatus(for items: [PlanItShopListItems]) {
        items.forEach { (planItShopListItems) in
            planItShopListItems.isPending = true
        }
        self.mainObjectContext.saveContext()
    }
    
    func readMovedItem(_ itemId: Double?, using context: NSManagedObjectContext? = nil) -> PlanItShopListItems? {
        if let shopItemId = itemId, shopItemId != 0 {
            return self.readSpecificShopListItem([shopItemId], using: context).first
        }
        return nil
    }
    
    func readShopListItemWithIds(shopLists: [[String: Any]], using context: NSManagedObjectContext? = nil) -> [PlanItShopListItems] {
        let objectContext = context ?? self.mainObjectContext
        let shopListItemIds = shopLists.compactMap({ return $0["listDetailId"] as? Double })
        let appShopListIds: [String] = shopLists.compactMap({ if let appToDoId = $0["appListDetailId"] as? String, !appToDoId.isEmpty { return appToDoId } else { return nil } })
        let predicate = NSPredicate(format: "userId == %@ AND (shopListItemId IN %@ OR appShopListItemId IN %@)", Session.shared.readUserId(), shopListItemIds, appShopListIds)
         return self.readRecords(fromCoreData: Table.planItShopListItems, predicate: predicate, context: objectContext) as! [PlanItShopListItems]
    }
    
    func readSpecificShopListItem(_ shopsListItemIds: [Double], using context: NSManagedObjectContext? = nil) -> [PlanItShopListItems] {
        let objectContext = context ?? self.mainObjectContext
        let predicate = NSPredicate(format: "userId == %@ AND shopListItemId IN %@", Session.shared.readUserId(), shopsListItemIds)
        return self.readRecords(fromCoreData: Table.planItShopListItems, predicate: predicate, context: objectContext) as! [PlanItShopListItems]
    }
    
    func readFavoritedShopListItem(_ context: NSManagedObjectContext? = nil) -> [PlanItShopListItems] {
        let objectContext = context ?? self.mainObjectContext
        let predicate = NSPredicate(format: "userId == %@ AND (isFavorite == YES OR isFavoriteLocal == YES)", Session.shared.readUserId())
        return self.readRecords(fromCoreData: Table.planItShopListItems, predicate: predicate, context: objectContext) as! [PlanItShopListItems]
    }
    
    func readResendShopListItem(_ context: NSManagedObjectContext? = nil) -> [PlanItShopListItems] {
        let objectContext = context ?? self.mainObjectContext
        let predicate = NSPredicate(format: "userId == %@ AND createdBy.userId == %@", Session.shared.readUserId(), Session.shared.readUserId())
        return self.readRecords(fromCoreData: Table.planItShopListItems, predicate: predicate, sortDescriptor: ["modifiedAt"], ascending: false, context: objectContext) as! [PlanItShopListItems]
    }
    
    func readAllPendingShopListItem(using context: NSManagedObjectContext? = nil) -> [PlanItShopListItems] {
        let objectContext = context ?? self.mainObjectContext
        let predicate = NSPredicate(format: "userId == %@ AND isPending == YES AND deleteStatus == NO", Session.shared.readUserId())
        return self.readRecords(fromCoreData: Table.planItShopListItems, predicate: predicate, context: objectContext) as! [PlanItShopListItems]
    }
    
    func readAllPendingDeleteShopListItem(using context: NSManagedObjectContext? = nil) -> [PlanItShopListItems] {
        let objectContext = context ?? self.mainObjectContext
        let predicate = NSPredicate(format: "userId == %@ AND isPending == YES AND deleteStatus == YES", Session.shared.readUserId())
        return self.readRecords(fromCoreData: Table.planItShopListItems, predicate: predicate, context: objectContext) as! [PlanItShopListItems]
    }
    
    func readAllPendingCompletionStatusShopListItem(using context: NSManagedObjectContext? = nil) -> [PlanItShopListItems] {
        let objectContext = context ?? self.mainObjectContext
        let predicate = NSPredicate(format: "userId == %@ AND isCompletedLocal != isCompleted AND deleteStatus == NO AND isPending == NO", Session.shared.readUserId())
        return self.readRecords(fromCoreData: Table.planItShopListItems, predicate: predicate, context: objectContext) as! [PlanItShopListItems]
    }
    
    func readAllPendingFavoriteStatusShopListItem(using context: NSManagedObjectContext? = nil) -> [PlanItShopListItems] {
        let objectContext = context ?? self.mainObjectContext
        let predicate = NSPredicate(format: "userId == %@ AND isFavoriteLocal != isFavorite AND deleteStatus == NO AND isPending == NO", Session.shared.readUserId())
        return self.readRecords(fromCoreData: Table.planItShopListItems, predicate: predicate, context: objectContext) as! [PlanItShopListItems]
    }
    
    func readAllShopQuantityListItem(_ shopItem: PlanItShopItems, context: NSManagedObjectContext? = nil) -> [PlanItShopListItems] {
        let objectContext = context ?? self.mainObjectContext
        var predicate: NSPredicate!
        if shopItem.isCustom, let appShopItemId = shopItem.appShopItemId, !appShopItemId.isEmpty && shopItem.userItemId == 0.0 {
            predicate = NSPredicate(format: "userId == %@ AND quantity.length > 0 AND appShopItemId == %@", Session.shared.readUserId(), appShopItemId )
        }
        else {
            let itemId: Double = shopItem.isCustom ? shopItem.userItemId : shopItem.masterItemId
            predicate = NSPredicate(format: "userId == %@ AND quantity.length > 0 AND shopItemId == %f", Session.shared.readUserId(), itemId )
        }
        return self.readRecords(fromCoreData: Table.planItShopListItems, predicate: predicate, sortDescriptor: ["modifiedAt"], ascending: false, limit: 15, context: objectContext) as! [PlanItShopListItems]
    }
    
    func readAllPendingMovedShopListItems(using context: NSManagedObjectContext? = nil) -> [PlanItShopListItems] {
        let objectContext = context ?? self.mainObjectContext
        let predicate = NSPredicate(format: "userId == %@ AND movedFrom.length > 0", Session.shared.readUserId())
        return self.readRecords(fromCoreData: Table.planItShopListItems, predicate: predicate, context: objectContext) as! [PlanItShopListItems]
    }
    
    func deleteShopListItems(_ shopsListItemIds: [Double]) {
        self.readSpecificShopListItem(shopsListItemIds).forEach { (items) in
            self.mainObjectContext.delete(items)
        }
        self.mainObjectContext.saveContext()
    }
    
    func readAllFutureShopListItemsUsingQueue(startOfMonth: Date, endOfMonth: Date, anyItemsExist: Bool, result: @escaping ([PlanItShopListItems]) -> ()) {
        self.privateObjectContext.perform {
            let start = startOfMonth as NSDate
            let end = endOfMonth as NSDate
            let predicate = NSPredicate(format: "userId == %@ AND ((dueDate >= %@ AND dueDate <= %@) \(anyItemsExist ? "" : "OR dueDate == nil")) AND isCompletedLocal == NO AND deleteStatus == NO", Session.shared.readUserId(), start, end)
            let purchases = self.readRecords(fromCoreData: Table.planItShopListItems, predicate: predicate, sortDescriptor: ["dueDate"], ascending: false, context: self.privateObjectContext) as! [PlanItShopListItems]
            result(purchases)
        }
    }
    
    func readUser(_ user: String, allPendingRemindMeShopingListItemsUsingType type: [LocalNotificationType], completionHandler: @escaping ([PlanItShopListItems]) -> ()) {
        self.privateObjectContext.perform {
            let types = type.map({ return $0.rawValue })
            let predicate = NSPredicate(format: "userId == %@ AND remindMe IN %@", user, types)
            let shopingListItems = self.readRecords(fromCoreData: Table.planItShopListItems, predicate: predicate, context: self.privateObjectContext) as! [PlanItShopListItems]
            completionHandler(shopingListItems)
        }
    }
}
