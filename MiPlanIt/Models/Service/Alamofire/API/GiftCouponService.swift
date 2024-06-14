//
//  GiftCouponService.swift
//  MiPlanIt
//
//  Created by Arun on 08/05/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

class GiftCouponService {
    
    func fetchUsersGiftServerData(_ user: PlanItUser, callback: @escaping (Bool, [ServiceDetection], String?) -> ()) {
        let giftCouponCommand = GiftCouponCommand()
        Session.shared.saveUsersGiftDataFetching(true)
        giftCouponCommand.usersGiftCouponData(["userId": user.readValueOfUserId(), "lastSyncDate": user.readUserSettings().readLastGiftFetchDataTime()], callback: { result, error in
            if let data = result {
                DatabasePlanItData().insertPlanItUserDataForGift(data, callback: { lastSyncTime, serviceDetection in
                    user.readUserSettings().saveLastGiftFetchDataTime(lastSyncTime)
                    Session.shared.saveUsersGiftDataFetching(false)
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: Notifications.giftUsersDataUpdated), object: serviceDetection)
                    callback(true, serviceDetection, error)
                })
            }
            else {
                Session.shared.saveUsersGiftDataFetching(false)
                callback(false, [], error ?? Message.unknownError)
            }
        })
    }
    
    func addGiftCoupon(_ giftCoupon: GiftCoupon, callback: @escaping (PlanItGiftCoupon?, String?) -> ()) {
        var requestParameter:[String: Any] = giftCoupon.createRequestParameter()
        requestParameter["createdBy"] = Session.shared.readUserId()
        requestParameter["modifiedBy"] = Session.shared.readUserId()
        let giftCouponCommand = GiftCouponCommand()
        giftCouponCommand.createGiftCoupon(requestParameter) { (response, error) in
            if let result = response {
                let newGiftCoupon = DatabasePlanItGiftCoupon().insertOrUpdateGiftCoupon(result)
                callback(newGiftCoupon, nil)
            }
            else {
                callback(nil, error ?? Message.unknownError)
            }
        }
    }
    
    func sendPendingGiftCouponToServer(_ giftCoupon: [PlanItGiftCoupon], callback: @escaping () -> ()) {
        var updatedGifts: [[String: Any]] = []
        var insertedGifts: [[String: Any]] = []
        giftCoupon.forEach({
            if $0.readCouponID().isEmpty { insertedGifts.append($0.makeRequestParameter()) } else { updatedGifts.append($0.makeRequestParameter()) }
        })
        var params: [String: Any] = [:]
        if !updatedGifts.isEmpty { params["updateGiftCoupon"] = updatedGifts }
        if !insertedGifts.isEmpty { params["insertGiftCoupon"] = insertedGifts }
        let giftCouponCommand = GiftCouponCommand()
        giftCouponCommand.createGiftCoupon(params) { (response, error) in
            if let result = response, let giftCoupons = result["giftCoupon"] as? [[String: Any]] {
                DatabasePlanItGiftCoupon().insertOrUpdateGiftCoupon(giftCoupons)
                callback()
            }
            else {
                callback()
            }
        }
    }
    
    func deleteGiftCoupon(_ giftCoupon: PlanItGiftCoupon, callback: @escaping (Bool, String?) -> ()) {
        let giftCouponCommand = GiftCouponCommand()
        giftCouponCommand.deleteGiftCoupon(["couponId": giftCoupon.readGiftCouponId()]) { (response, error) in
            if let _ = response {
                giftCoupon.deleteItSelf()
                callback(true, nil)
            }
            else {
                callback(false, error ?? Message.unknownError)
            }
        }
    }
    
    func redeemGiftCoupon(_ giftCoupon: PlanItGiftCoupon, callback: @escaping (PlanItGiftCoupon?, String?) -> ()) {
        let giftCouponCommand = GiftCouponCommand()
        giftCouponCommand.redeemGiftCoupon(["couponIds": giftCoupon.readGiftCouponId().cleanValue(), "actionType": Strings.empty]) { (response, error) in
            if let result = response {
                let newGiftCoupon = DatabasePlanItGiftCoupon().insertOrUpdateGiftCoupon(result)
                callback(newGiftCoupon, nil)
            }
            else {
                callback(nil, error ?? Message.unknownError)
            }
        }
    }
    
}

class GiftCouponCommand: WSManager {
    
    func usersGiftCouponData(_ params: [String: Any]?, callback: @escaping (Dictionary<String, Any>?, String?) -> ()) {
        self.get(endPoint: ServiceData.giftFetch, params: params, callback: { response, error in
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
    
    func createGiftCoupon(_ params: [String: Any]?, callback: @escaping (Dictionary<String, Any>?, String?) -> ()) {
        self.post(endPoint: ServiceData.giftCouponAdd, params: params, callback: { response, error in
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
    
    func deleteGiftCoupon(_ params: [String: Any]?, callback: @escaping (String?, String?) -> ()) {
        self.delete(endPoint: ServiceData.giftCouponDelete, params: params) { (response, error) in
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
    
    func redeemGiftCoupon(_ params: [String: Any]?, callback: @escaping (Dictionary<String, Any>?, String?) -> ()) {
        self.post(endPoint: ServiceData.giftCouponRedeem, params: params) { (response, error) in
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
