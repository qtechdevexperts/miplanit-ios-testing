//
//  PurchaseService.swift
//  MiPlanIt
//
//  Created by Aneesh Asokan on 07/05/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

class PurchaseService {
    
    func fetchUsersPurchaseServerData(_ user: PlanItUser, callback: @escaping (Bool, [ServiceDetection], String?) -> ()) {
        let purchaseCommand = PurchaseCommand()
        Session.shared.saveUsersPurchaseDataFetching(true)
        purchaseCommand.usersPurchaseData(["userId": user.readValueOfUserId(), "lastSyncDate": user.readUserSettings().readLastPurchaseFetchDataTime()], callback: { result, error in
            if let data = result {
                DatabasePlanItData().insertPlanItUserDataForPurchase(data, callback: { lastSyncTime, serviceDetection in
                    user.readUserSettings().saveLastPurchaseFetchDataTime(lastSyncTime)
                    Session.shared.saveUsersPurchaseDataFetching(false)
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: Notifications.purchaseUsersDataUpdated), object: serviceDetection)
                    callback(true, serviceDetection, error)
                })
            }
            else {
                Session.shared.saveUsersPurchaseDataFetching(false)
                callback(false, [], error ?? Message.unknownError)
            }
        })
    }
    
    func addPurchase(_ purchase: Purchase, callback: @escaping (PlanItPurchase?, String?) -> ()) {
        var requestParameter:[String: Any] = purchase.createRequestParameter()
        requestParameter["userId"] = Session.shared.readUserId()
        let purchaseCommand = PurchaseCommand()
        purchaseCommand.createPurchase(requestParameter) { (response, error) in
            if let result = response {
                let plantPurchase = DatabasePlanItPurchase().insertOrUpdatePurchase(result)
                callback(plantPurchase, nil)
            }
            else {
                callback(nil, error ?? Message.unknownError)
            }
        }
    }
    
    func sendPendingPurchaseToServer(_ purchase: [PlanItPurchase], callback: @escaping () -> ()) {
        var updatedPurchase: [[String: Any]] = []
        var insertedPurchase: [[String: Any]] = []
        purchase.forEach({
            if $0.readPurchaseId().cleanValue().isEmpty { insertedPurchase.append($0.makeRequestParameter()) } else { updatedPurchase.append($0.makeRequestParameter()) }
        })
        var params: [String: Any] = [:]
        if !updatedPurchase.isEmpty { params["updatePurchase"] = updatedPurchase }
        if !insertedPurchase.isEmpty { params["insertPurchase"] = insertedPurchase }
        let purchaseCommand = PurchaseCommand()
        purchaseCommand.createPurchase(params) { (response, error) in
            if let result = response, let purchases = result["purchase"] as? [[String: Any]] {
                DatabasePlanItPurchase().insertOrUpdatePurchase(purchases)
                callback()
            }
            else {
                callback()
            }
        }
    }
    
    func deletePurchase(_ purchase: PlanItPurchase, callback: @escaping (Bool, String?) -> ()) {
        let purchaseCommand = PurchaseCommand()
        purchaseCommand.deletePurchase(["purchaseId": purchase.readPurchaseId()]) { (response, error) in
            if let _ = response {
                purchase.deleteItSelf()
                callback(true, nil)
            }
            else {
                callback(false, error ?? Message.unknownError)
            }
        }
    }
}

class PurchaseCommand: WSManager {
    
    func usersPurchaseData(_ params: [String: Any]?, callback: @escaping (Dictionary<String, Any>?, String?) -> ()) {
        self.get(endPoint: ServiceData.purchaseFetch, params: params, callback: { response, error in
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
    
    func createPurchase(_ params: [String: Any]?, callback: @escaping (Dictionary<String, Any>?, String?) -> ()) {
        self.post(endPoint: ServiceData.purchaseAdd, params: params, callback: { response, error in
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
    
    func deletePurchase(_ params: [String: Any]?, callback: @escaping (String?, String?) -> ()) {
        self.delete(endPoint: ServiceData.purchaseDelete, params: params) { (response, error) in
            if let result = response {
                if let data = result.statusCode, data == "SU001" {
                    callback(result.error, nil)
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
