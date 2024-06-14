//
//  ShopService.swift
//  MiPlanIt
//
//  Created by Febin Paul on 08/05/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

class ShopService {
    
    func getShopMasterItem(_ user: PlanItUser, callback: @escaping ( Bool, [ServiceDetection], String?) -> ()) {
        let requestParameter:[String: Any] = ["userId": Session.shared.readUserId(), "lastSyncDate": user.readUserSettings().readLastFetchShopDataTime()]
        let shopCommand = ShopCommand()
        shopCommand.getShopMasterItem(requestParameter) { (response, error) in
            if let result = response {
                DatabasePlanItShopData().insertShopMasterCategoryAndItems(result) { (serviceDetection) in
                    if let lastSyncTime = result["lastSyncDate"] as? String {
                        user.readUserSettings().saveLastFetchShopDataTime(lastSyncTime)
                    }
                    callback(true, serviceDetection, error)
                }
            }
            else {
                callback(false, [], error ?? Message.unknownError)
            }
        }
    }
    
    func getUserShopItem(_ user: PlanItUser, callback: @escaping ( Bool, [ServiceDetection], String?) -> ()) {
        let requestParameter:[String: Any] = ["userId": Session.shared.readUserId(), "lastSyncDate": user.readUserSettings().readLastFetchUserShopDataTime()]
        let shopCommand = ShopCommand()
        shopCommand.getUserShopItem(requestParameter) { (response, error) in
            if let result = response {
                DatabasePlanItShopData().insertShopUserCategoryAndItems(result) { (serviceDetection) in
                    if let lastSyncTime = result["lastSyncDate"] as? String {
                        user.readUserSettings().saveLastFetchUserShopDataTime(lastSyncTime)
                    }
                    callback(true,serviceDetection,  error)
                }
            }
            else {
                callback(false, [], error ?? Message.unknownError)
            }
        }
    }
    
    func fetchUsersShoppingServerData(_ user: PlanItUser, callback: @escaping (Bool, [ServiceDetection], String?) -> ()) {
        Session.shared.saveUsersShoppingDataFetching(true)
        let requestParameter:[String: Any] = ["userId": Session.shared.readUserId(), "lastSyncDate": user.readUserSettings().readLastFetchUserShopListDataTime() ]
        let shopCommand = ShopCommand()
        shopCommand.getUserShopListData(requestParameter) { (response, error) in
            if let result = response {
                DatabasePlanItShopData().insertUserShopingList(result, result: { serviceDetection in
                    if let lastSyncTime = result["lastSyncDate"] as? String {
                        user.readUserSettings().saveLastFetchUserShopListDataTime(lastSyncTime)
                    }
                    Session.shared.saveUsersShoppingDataFetching(false)
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: Notifications.shoppingUsersDataUpdated), object: serviceDetection)
                    callback(true, serviceDetection, error)
                })
            }
            else {
                Session.shared.saveUsersShoppingDataFetching(false)
                callback(false, [], error ?? Message.unknownError)
            }
        }
    }
    
    func addShopListItem(_ shopListItems: PlanItShopListItems, callback: @escaping (PlanItShopListItems?, String?) -> ()) {
        let shopCommand = ShopCommand()
        var params: [String: Any] = shopListItems.createRequestParams()
        params["userId"] = Session.shared.readUserId()
        shopCommand.addUpdateShopListItem(params) { (response, error) in
            if let result = response, let shopListArray = result["userShoppingList"] as? [[String: Any]], let shopList = shopListArray.first {
                DatabasePlanItShopList().insertOrUpdateShopList(shopList, updatePlanItShopListItem: shopListItems)
                Session.shared.registerUserShopingListItemLocationNotification()
                callback(shopListItems, nil)
            }
            else {
                callback(nil, error ?? Message.unknownError)
            }
        }
    }
    
    func addShopCategory(_ categoryName: String, appCategoryId: String = Strings.empty, callback: @escaping (PlanItShopMainCategory?, String?) -> ()) {
        let shopCommand = ShopCommand()
        var params: [String: Any] = [:]
        params["userProdCat"] = categoryName
        params["userId"] = Session.shared.readUserId()
        params["appUserProdCatId"] = appCategoryId
        shopCommand.addShopCategory(params) { (response, error) in
            if let result = response, let shopListArray = result["userProdCategory"] as? [[String: Any]], let shopList = shopListArray.first {
                let plantShopCategory = DatabasePlanItShopMasterCategory().insertOrUpdateShopCategory(shopList)
                callback(plantShopCategory, nil)
            }
            else {
                callback(nil, error ?? Message.unknownError)
            }
        }
    }
    
    func updateShopCategory(_ category: PlanItShopMainCategory, categoryName: String, appCategoryId: String = Strings.empty, callback: @escaping (PlanItShopMainCategory?, String?) -> ()) {
        let shopCommand = ShopCommand()
        var params: [String: Any] = [:]
        params["userProdCatId"] = category.readUserCategoryIdValue()
        params["userProdCat"] = categoryName
        params["userId"] = Session.shared.readUserId()
        params["appUserProdCatId"] = appCategoryId
        shopCommand.addShopCategory(params) { (response, error) in
            if let result = response, let shopListArray = result["userProdCategory"] as? [[String: Any]], let shopList = shopListArray.first {
                let plantShopCategory = DatabasePlanItShopMasterCategory().insertOrUpdateShopCategory(shopList)
                DatabasePlanItShopItems().updateShopItemCategorynameWith(category: plantShopCategory)
                callback(plantShopCategory, nil)
            }
            else {
                callback(nil, error ?? Message.unknownError)
            }
        }
    }
    
    func removeShopCategory(_ categorys: [PlanItShopMainCategory], callback: @escaping ([PlanItShopMainCategory], String?) -> ()) {
        let shopCommand = ShopCommand()
        var params: [String: Any] = [:]
        params["userId"] = Session.shared.readUserId()
        params["userProdCatIds"] = categorys.map({ $0.readUserCategoryIdValue() })
        shopCommand.deleteShopCategory(params) { (status, error) in
            if status {
                DatabasePlanItShopMasterCategory().deleteShopCategorys(categorys)
            }
            else {
                DatabasePlanItShopMasterCategory().deleteShopCategorysOffline(categorys)
            }
            callback(categorys, nil)
        }
    }
    
    func removeShopList(_ shop: ShopList, callback: @escaping (PlanItShopList?, String?) -> ()) {
        let shopCommand = ShopCommand()
        var params = shop.createRequestParams(removingCurrentUser: true)
        params["userId"] = Session.shared.readUserId()
        params["dueDate"] = Date().stringFromDate(format: DateFormatters.YYYYHMMMHDD)
        params["isRemoved"] = true
        shopCommand.updateShopList(params) { (response, error) in
            if let result = response, let shopListArray = result["userShoppingList"] as? [[String: Any]], let _ = shopListArray.first {
                guard let shopData = shop.shopListData else {
                    callback(nil, error ?? Message.unknownError)
                    return
                }
                let deletedShopingListItems = shop.shopListData?.readAllShopListItems().compactMap({ return LocalNotificationMethod.shopping.rawValue + $0.readValueOfNotificationId() }) ?? []
                let plantShopList = DatabasePlanItShopList().deleteSpecificShop(shopData.shopListId)
                Session.shared.removeShoppingNotifications(deletedShopingListItems)
                callback(plantShopList, nil)
            }
            else {
                callback(nil, error ?? Message.unknownError)
            }
        }
    }
    
    func addShopList(_ shop: ShopList, callback: @escaping (PlanItShopList?, String?) -> ()) {
        let shopCommand = ShopCommand()
        var params = shop.createRequestParams()
        params["userId"] = Session.shared.readUserId()
        params["dueDate"] = Date().stringFromDate(format: DateFormatters.YYYYHMMMHDD)
        shopCommand.updateShopList(params) { (response, error) in
            if let result = response, let shopListArray = result["userShoppingList"] as? [[String: Any]], let shopList = shopListArray.first {
                let plantShopList = DatabasePlanItShopList().insertOrUpdateShopList(shopList)
                Session.shared.registerUserShopingListItemLocationNotification()
                callback(plantShopList, nil)
            }
            else {
                callback(nil, error ?? Message.unknownError)
            }
        }
    }
    
    func updateNameShopList( withName name: String, shopList: PlanItShopList, callback: @escaping (Bool, String?) -> ()) {
        let shopCommand = ShopCommand()
        
        var params = shopList.createRequestParams()
        let allInvitees = shopList.readAllShopListShareInvitees().map({ OtherUser(invitee: $0) })
        let sharedUsers: [[String: Any]] = allInvitees.map({ return !$0.userId.isEmpty ? ["userId": $0.userId] : !$0.email.isEmpty ? ["email": $0.email, "fullName": $0.fullName] : ["phone": $0.phone, "fullName": $0.fullName, "countryCode": $0.countryCode] })
        params["invitees"] = sharedUsers
        params["shpListName"] = name
        params["userId"] = Session.shared.readUserId()
        params["shpListId"] = shopList.readShopListIdValue()
        params["dueDate"] = Date().stringFromDate(format: DateFormatters.YYYYHMMMHDD)
        
        shopCommand.updateShopList(params) { (response, error) in
            if let result = response, let shopListArray = result["userShoppingList"] as? [[String: Any]], let shopList = shopListArray.first {
                DatabasePlanItShopList().insertOrUpdateShopList(shopList)
                callback(true, nil)
            }
            else {
                callback(false, error ?? Message.unknownError)
            }
        }
    }
    
    func shareShopInvitees(_ invitees: [OtherUser], shopList: PlanItShopList, callback: @escaping (Bool, String?) -> ()) {
        let shopCommand = ShopCommand()
        
        var params = shopList.createRequestParams()
        var sharedUsers: [[String: Any]] = invitees.map({ return !$0.userId.isEmpty ? ["userId": $0.userId] : !$0.email.isEmpty ? ["email": $0.email, "fullName": $0.fullName] : ["phone": $0.phone, "fullName": $0.fullName, "countryCode": $0.countryCode] })
        sharedUsers.append(["userId": Session.shared.readUserId()])
        params["userId"] = Session.shared.readUserId()
        params["invitees"] = sharedUsers
        params["shpListId"] = shopList.readShopListIdValue()
        params["dueDate"] = Date().stringFromDate(format: DateFormatters.YYYYHMMMHDD)
        
        shopCommand.updateShopList(params) { (response, error) in
            if let result = response, let shopListArray = result["userShoppingList"] as? [[String: Any]], let shopList = shopListArray.first {
                DatabasePlanItShopList().insertOrUpdateShopList(shopList)
                callback(true, nil)
            }
            else {
                callback(false, error ?? Message.unknownError)
            }
        }
    }
    
    func deleteShopList(_ shop: PlanItShopList, callback: @escaping (PlanItShopList?, String?) -> ()) {
        let shopCommand = ShopCommand()
        let requestParams: [String: Any] = ["userId": Session.shared.readUserId(), "shpListId": [Int(Double(shop.readShopListID()) ?? 0.0)]]
        shopCommand.deleteShopList(requestParams) { (status, error) in
            if status {
                let deletedShopingListItems = shop.readAllShopListItems().compactMap({ return LocalNotificationMethod.shopping.rawValue + $0.readValueOfNotificationId() })
                let shopObj = DatabasePlanItShopList().deleteSpecificShop(shop.readShopListIDValue())
                Session.shared.removeShoppingNotifications(deletedShopingListItems)
                callback(shopObj, nil)
            }
            else {
                callback(nil, error ?? Message.unknownError)
            }
        }
    }
    
    func updateDueDateShopListItems(_ shopListItems: [PlanItShopListItems], shopList: PlanItShopList, dueDate: Date, callback: @escaping (Bool, String?) -> ()) {
        let shopCommand = ShopCommand()
        let requestParams: [String: Any] = ["userId": Session.shared.readUserId(), "shoppingListId": Int(Double(shopList.readShopListID()) ?? 0.0), "listDetailIds": shopListItems.compactMap({ $0.shopListItemId }), "dueDate": dueDate.stringFromDate(format: DateFormatters.YYYYHMMMHDD)]
        shopCommand.updateShopListItemDueDate(requestParams) { (response, error) in
            if let result = response, let shopListArray = result["userShoppingList"] as? [[String: Any]] {
                shopListArray.forEach { (item) in
                    DatabasePlanItShopList().insertOrUpdateShopList(item)
                }
                Session.shared.registerUserShopingListItemLocationNotification()
                callback(true, nil)
            }
            else {
                callback(false, error ?? Message.unknownError)
            }
        }
    }
    
    func deleteShopListItems(_ shopListItems: [PlanItShopListItems], shop: PlanItShopList, callback: @escaping (Bool, String?) -> ()) {
        let shopCommand = ShopCommand()
        let requestParams: [String: Any] = ["userId": Session.shared.readUserId(), "shoppingListId": Int(Double(shop.readShopListID()) ?? 0.0), "listDetailId": shopListItems.compactMap({ $0.shopListItemId })]
        shopCommand.deleteShopListItem(requestParams) { (status, error) in
            if status {
                let deletedShopingListItems = shopListItems.map({ return LocalNotificationMethod.shopping.rawValue + $0.readValueOfNotificationId() })
                DatabasePlanItShopListItem().deleteShopListItems(shopListItems.compactMap({ $0.shopListItemId }))
                Session.shared.removeShoppingNotifications(deletedShopingListItems)
                callback(true, nil)
            }
            else {
                callback(false, error ?? Message.unknownError)
            }
        }
    }
    
    func shopListItemMarkAsComplete(_ shopListItems: [PlanItShopListItems], shop: PlanItShopList, with status: Bool, callback: @escaping (Bool, String?) -> ()) {
        let shopCommand = ShopCommand()
        shopCommand.shopitemMarkAsComplete([ "shoppingListId": shop.readShopListIdValue(), "isComplete": status, "listDetailId": shopListItems.compactMap({ $0.shopListItemId }), "userId": Session.shared.readUserId()]) { (response, error) in
            if let result = response, let shopListArray = result["userShoppingList"] as? [[String: Any]], let shopList = shopListArray.first {
                DatabasePlanItShopList().insertOrUpdateShopList(shopList)
                callback(true, nil)
            }
            else {
                callback(false, error ?? Message.unknownError)
            }
        }
    }
    
    func shopListItemMarkAsFavorites(_ shopListItems: [PlanItShopListItems], shop: PlanItShopList, with status: Bool, callback: @escaping (Bool, String?) -> ()) {
        let shopCommand = ShopCommand()
        shopCommand.shopitemMarkAsFavorite([ "shoppingListId": shop.readShopListIdValue(), "isFavourite": status, "listDetailId": shopListItems.compactMap({ $0.shopListItemId }), "userId": Session.shared.readUserId()]) { (response, error) in
            if let result = response, let shopListArray = result["userShoppingList"] as? [[String: Any]], let shopList = shopListArray.first {
                DatabasePlanItShopList().insertOrUpdateShopList(shopList)
                callback(true, nil)
            }
            else {
                callback(false, error ?? Message.unknownError)
            }
        }
    }
    
    func updateShopListDetail(_ details: ShopListItemDetailModel, callback: @escaping (Bool, String?) -> ()) {
        let shopCommand = ShopCommand()
        var params: [String: Any] = details.createRequestParams(onUpdate: true)
        params["userId"] = Session.shared.readUserId()
        shopCommand.addUpdateShopListItem(params) { (response, error) in
            if let result = response, let shopListArray = result["userShoppingList"] as? [[String: Any]], let shopList = shopListArray.first {
                DatabasePlanItShopList().insertOrUpdateShopList(shopList, shopListItemDetailModel: details)
                Session.shared.registerUserShopingListItemLocationNotification()
                callback(true, nil)
            }
            else {
                callback(false, error ?? Message.unknownError)
            }
        }
    }
    
    func moveShopListItem(_ shopListItems: [PlanItShopListItems], fromList: PlanItShopList, toList: PlanItShopList, callback: @escaping (PlanItShopList?, String?) -> ()) {
        let shopCommand = ShopCommand()
        var params: [String: Any] = [:]
        params["listDetailId"] = shopListItems.map({$0.readShopListItemsIdValue()})
        params["shoppingListIdFrom"] = fromList.readShopListIDValue()
        params["shoppingListIdTo"] = toList.readShopListIDValue()
        params["userId"] = Session.shared.readUserId()
        shopCommand.moveShopListItem(params) { (response, error) in
            if let result = response, let shopListArray = result["userShoppingList"] as? [[String: Any]] {
                shopListItems.forEach({ $0.movedFrom = Strings.empty })
                for eachShoppingList in shopListArray {
                    DatabasePlanItShopList().insertOrUpdateShopList(eachShoppingList)
                }
                callback(fromList, nil)
            }
            else {
                callback(nil, error ?? Message.unknownError)
            }
        }
    }
    
    func movePendingShopListItem(_ shopListItems: [PlanItShopListItems], fromListId: String, toListId: String, callback: @escaping (Bool?, String?) -> ()) {
        let shopCommand = ShopCommand()
        var params: [String: Any] = [:]
        params["listDetailId"] = shopListItems.map({$0.readShopListItemsIdValue()})
        params["shoppingListIdFrom"] = fromListId
        params["shoppingListIdTo"] = toListId
        params["userId"] = Session.shared.readUserId()
        shopCommand.moveShopListItem(params) { (response, error) in
            if let result = response, let shopListArray = result["userShoppingList"] as? [[String: Any]] {
                shopListItems.forEach({ $0.movedFrom = Strings.empty })
                for eachShoppingList in shopListArray {
                    DatabasePlanItShopList().insertOrUpdateShopList(eachShoppingList)
                }
                callback(true, nil)
            }
            else {
                callback(nil, error ?? Message.unknownError)
            }
        }
    }
    
    func updateCategoryOfShopListItem(_ userShopItems: [PlanItShopItems], prodCatId: String, prodSubCatId: String, userProdCatId: String, callback: @escaping ([PlanItShopItems]?, String?) -> ()) {
        let shopCommand = ShopCommand()
        var params: [String: Any] = [:]
        params["userItemId"] = userShopItems.map({$0.readUserItemIdValue()})
        params["prodCatId"] = Double(prodCatId) ?? Strings.empty
        params["prodSubCatId"] = Double(prodSubCatId) ?? Strings.empty
        params["userProdCatId"] = Double(userProdCatId) ?? Strings.empty
        params["userId"] = Session.shared.readUserId()
        shopCommand.updateShopListItemCategory(params) { (response, error) in
            if let result = response, let shopItemsArray = result["userItems"] as? [[String: Any]] {
                DatabasePlanItShopItems().inserUserCategoryItems(shopItemsArray, hardSave: true)
                callback(userShopItems, nil)
            }
            else {
                callback(nil, error ?? Message.unknownError)
            }
        }
    }
    
    
    /////
    
    
    
    func uploadShopListImages(_ shopList: PlanItShopList, file: String, name: String, by owner: PlanItUser, callback: @escaping (Bool, String?) -> ()) {
        let shopCommand = ShopCommand()
        shopCommand.uploadShopListPic(["shpListId": shopList.readShopListID(), "fileName": name, "fileData": file, "userId": shopList.readOwnerUserId()]) { (response, error) in
            if let result = response, let image = result["shpListImage"] as? String {
                shopList.saveShopListImage(image)
                callback(true, nil)
            }
            else {
                callback(false, error)
            }
        }
    }
}

class ShopCommand: WSManager {
    
    func uploadShopListPic(_ params: [String: Any]?, callback: @escaping (Dictionary<String, Any>?, String?) -> ()) {
        self.post(endPoint: ServiceData.uploadShopListImage, params: params, callback: { response, error in
            if let result = response {
                if let data = result.data as? [[String: Any]], let user = data.first {
                    callback(user, nil)
                }
                else {
                    callback(nil, result.error)
                }
            }
            else {
                callback(nil, error?.message ?? Message.unknownError)
            }
        })
    }
    
    func getUserShopListData(_ params: [String: Any]?, callback: @escaping (Dictionary<String, Any>?, String?) -> ()) {
        self.get(endPoint: ServiceData.userShopListItems, params: params, callback: { response, error in
            if let result = response {
                if let data = result.data as? [[String: Any]], let details = data.first {
                    callback(details, nil)
                }
                else {
                    callback(nil, result.error)
                }
            }
            else {
                callback(nil, error?.message ?? Message.unknownError)
            }
        })
    }
    
    func getUserShopItem(_ params: [String: Any]?, callback: @escaping (Dictionary<String, Any>?, String?) -> ()) {
        self.get(endPoint: ServiceData.userItems, params: params, callback: { response, error in
            if let result = response {
                if let data = result.data as? [[String: Any]], let details = data.first {
                    callback(details, nil)
                }
                else {
                    callback(nil, result.error)
                }
            }
            else {
                callback(nil, error?.message ?? Message.unknownError)
            }
        })
    }
    
    func getShopMasterItem(_ params: [String: Any]?, callback: @escaping (Dictionary<String, Any>?, String?) -> ()) {
        self.get(endPoint: ServiceData.masterItems, params: params, callback: { response, error in
            if let result = response {
                if let data = result.data as? [[String: Any]], let details = data.first {
                    callback(details, nil)
                }
                else {
                    callback(nil, result.error)
                }
            }
            else {
                callback(nil, error?.message ?? Message.unknownError)
            }
        })
    }
    
    func addUpdateShopListItem(_ params: [String: Any]?, callback: @escaping (Dictionary<String, Any>?, String?) -> ()) {
        self.post(endPoint: ServiceData.upsertShopListItem, params: params, callback: { response, error in
            if let result = response {
                if let data = result.data as? [[String: Any]], let details = data.first {
                    callback(details, nil)
                }
                else {
                    callback(nil, result.error)
                }
            }
            else {
                callback(nil, error?.message ?? Message.unknownError)
            }
        })
    }
    
    func moveShopListItem(_ params: [String: Any]?, callback: @escaping (Dictionary<String, Any>?, String?) -> ()) {
        self.post(endPoint: ServiceData.moveShopListItems, params: params, callback: { response, error in
            if let result = response {
                if let data = result.data as? [[String: Any]], let details = data.first {
                    callback(details, nil)
                }
                else {
                    callback(nil, result.error)
                }
            }
            else {
                callback(nil, error?.message ?? Message.unknownError)
            }
        })
    }
    
    func updateShopListItemCategory(_ params: [String: Any]?, callback: @escaping (Dictionary<String, Any>?, String?) -> ()) {
        self.post(endPoint: ServiceData.updateCategory, params: params, callback: { response, error in
            if let result = response {
                if let data = result.data as? [[String: Any]], let details = data.first {
                    callback(details, nil)
                }
                else {
                    callback(nil, result.error)
                }
            }
            else {
                callback(nil, error?.message ?? Message.unknownError)
            }
        })
    }
    
    func addShopCategory(_ params: [String: Any]?, callback: @escaping (Dictionary<String, Any>?, String?) -> ()) {
        self.post(endPoint: ServiceData.addShopCategory, params: params, callback: { response, error in
            if let result = response {
                if let data = result.data as? [[String: Any]], let details = data.first {
                    callback(details, nil)
                }
                else {
                    callback(nil, result.error)
                }
            }
            else {
                callback(nil, error?.message ?? Message.unknownError)
            }
        })
    }
    
    
    func deleteShopCategory(_ params: [String: Any]?, callback: @escaping (Bool, String?) -> ()) {
        self.delete(endPoint: ServiceData.deleteShopCategory, params: params, callback: { response, error in
            if let result = response {
                callback(true, result.error)
            }
            else {
                callback(false, error?.message ?? Message.unknownError)
            }
        })
    }
    
    func updateShopList(_ params: [String: Any]?, callback: @escaping (Dictionary<String, Any>?, String?) -> ()) {
        self.post(endPoint: ServiceData.addShopList, params: params, callback: { response, error in
            if let result = response {
                if let data = result.data as? [[String: Any]], let details = data.first {
                    callback(details, nil)
                }
                else {
                    callback(nil, result.error)
                }
            }
            else {
                callback(nil, error?.message ?? Message.unknownError)
            }
        })
    }
    
    func updateShopListItemDueDate(_ params: [String: Any]?, callback: @escaping (Dictionary<String, Any>?, String?) -> ()) {
        self.post(endPoint: ServiceData.updateDueDate, params: params, callback: { response, error in
            if let result = response {
                if let data = result.data as? [[String: Any]], let details = data.first {
                    callback(details, nil)
                }
                else {
                    callback(nil, result.error)
                }
            }
            else {
                callback(nil, error?.message ?? Message.unknownError)
            }
        })
    }
    
    func deleteShopListItem(_ params: [String: Any]?, callback: @escaping (Bool, String?) -> ()) {
        self.delete(endPoint: ServiceData.deleteShoppingListItemData, params: params, callback: { response, error in
            if response != nil {
                callback(true, nil)
            }
            else {
                callback(false, error?.message ?? Message.unknownError)
            }
        })
    }
    
    func deleteShopList(_ params: [String: Any]?, callback: @escaping (Bool, String?) -> ()) {
        self.delete(endPoint: ServiceData.deleteShoppingListData, params: params, callback: { response, error in
            if response != nil {
                callback(true, nil)
            }
            else {
                callback(false, error?.message ?? Message.unknownError)
            }
        })
    }
    
    func deleteShareLink(_ params: [String: Any]?, callback: @escaping (Bool, String?) -> ()) {
        self.delete(endPoint: ServiceData.deleteShareLink, params: params, callback: { response, error in
            if response != nil {
                callback(true, nil)
            }
            else {
                callback(false, error?.message ?? Message.unknownError)
            }
        })
    }
    
    func shopitemMarkAsComplete(_ params: [String: Any]?, callback: @escaping (Dictionary<String, Any>?, String?) -> ()) {
        self.post(endPoint: ServiceData.shoppingListItemCompleteUpdate, params: params) { (response, error) in
            if let result = response {
                if let data = result.data as? [[String: Any]], let details = data.first {
                    callback(details, nil)
                }
                else {
                    callback(nil, result.error)
                }
            }
            else {
                callback(nil, error?.message ?? Message.unknownError)
            }
        }
    }
    
    func shopitemMarkAsFavorite(_ params: [String: Any]?, callback: @escaping (Dictionary<String, Any>?, String?) -> ()) {
        self.post(endPoint: ServiceData.shoppingListItemFavoriteUpdate, params: params) { (response, error) in
            if let result = response {
                if let data = result.data as? [[String: Any]], let details = data.first {
                    callback(details, nil)
                }
                else {
                    callback(nil, result.error)
                }
            }
            else {
                callback(nil, error?.message ?? Message.unknownError)
            }
        }
    }
}
