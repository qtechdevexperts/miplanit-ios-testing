//
//  PurchaseService.swift
//  BookReader
//
//  Created by Richin.C on 22/10/18.
//  Copyright © 2018 ARUN. All rights reserved.
//

import Foundation

class InAppPurchaseService {
    
    func verifyReceipt(data: Data, with LogID: String, price: String, currencyFormat: String, callback: @escaping(Bool, WSNetworkError?) ->()) {
        
    }
    
    func updatePaymentStatus(with LogID: String, paymentStatus: String, callback: @escaping(Bool, WSNetworkError?) ->()) {
        
    }
    
    func restorePurchase(data: Data, callback: @escaping(Bool, WSNetworkError?) ->()) {
        
    }
        
    func isEligibleForIntroductoryOffers(data: Data, callback: @escaping (Bool) -> Void) {
        let params = ["receipt-data" : data.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: 0)), "password" : ConfigureKeys.appSpecificSharedSecret, "exclude-old-transactions" : false] as [String : Any]
         let purchaseCommand = InAppPurchaseCommand()
        purchaseCommand.checkIntroductoryEligibility(params: params, on: .production, callback: { response, error in
            if error != nil {
                callback(false)
                return
            }
            guard let responseData = response?.data, let json = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? [String : AnyHashable] else {
                callback(false)
                return
            }
            guard let receipts_array = json["latest_receipt_info"] as? [[String : AnyHashable]] else {
                  callback(true)
                  return
            }
            var latestExpiresDate = Date(timeIntervalSince1970: 0)
            let formatter = DateFormatter()
            for receipt in receipts_array {
              let used_trial : Bool = receipt["is_trial_period"] as? Bool ?? false || (receipt["is_trial_period"] as? NSString)?.boolValue ?? false
              let used_intro : Bool = receipt["is_in_intro_offer_period"] as? Bool ?? false || (receipt["is_in_intro_offer_period"] as? NSString)?.boolValue ?? false
              if used_trial || used_intro {
                callback(false)
                return
              }
              formatter.dateFormat = "yyyy-MM-dd HH:mm:ss VV"
              if let expiresDateString = receipt["expires_date"] as? String, let date = formatter.date(from: expiresDateString) {
                  if date > latestExpiresDate {
                    latestExpiresDate = date
                  }
                }
              }

              if latestExpiresDate > Date() {
                callback(false)
              } else {
                callback(true)
              }
        })
    }
    
    func verifyRecieptDataWithItunes(data: Data, on env: InAppEnviornment = .production, callback: @escaping(PurchaseResponse?, WSNetworkError?) ->()) {
        let params = ["receipt-data" : data.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: 0)), "password": ConfigureKeys.appSpecificSharedSecret, "exclude-old-transactions": "1"]
         let purchaseCommand = InAppPurchaseCommand()
        purchaseCommand.verifyRecieptDataWithItunes(params: params, on: env, callback: { response, error in
            if let status = response?.verifyStatus, status == 21007 {
                self.verifyRecieptDataWithItunes(data: data, on: .sandbox, callback: callback)
            }
            else {
                callback(response, error)
            }
        })
    }
    
    func verifyRecieptDataWithServer(data: Data, user: PlanItUser, switchReciept: Bool, callback: @escaping(Date?, Bool, String?) ->()) {
        guard let receiptData = NSData(data: data).aes128Encrypt(withKey: ConfigureKeys.aesKey)?.base64EncodedString() else {
            callback(nil, false, Strings.empty)
            return
        }
        let envMode: String = {
//               #if DEBUG
//               return "0"
//               #else
               return "1"
//               #endif
           }()
        let params: [String: Any] = ["userId" : user.readValueOfUserId() , "orgTransactionReceipt": receiptData, "envMode": envMode, "apiMode": switchReciept ? "1" : "0"]
         let purchaseCommand = InAppPurchaseCommand()
        purchaseCommand.verifyRecieptDataWithServer(params: params, callback: { response, error in
            if let result = response, let respStatus = result["purchaseStatus"] as? Int, respStatus == 0 {
                if let createdAt = result["receiptExpiryDate"] as? String, let date = createdAt.stringToDate(formatter: DateFormatters.MMDDYYYYHMMSSA, timeZone: TimeZone(abbreviation: "UTC")!) {
                    callback(date, (result["transactionIdExist"] as? Bool) ?? false , error)
                    return
                }
            }
            callback(nil, false, error)
        })
    }
    
    func verifySubscriptionStatus(user: PlanItUser, callback: @escaping() ->()) {
        guard ConfigureKeys.purchaseFeatureEnabled else {
            let date = Date().adding(minutes: 5)
            user.savePurchase(date)
            callback()
            return
        }
        let params: [String: Any] = ["userId" : user.readValueOfUserId()]
        let purchaseCommand = InAppPurchaseCommand()
        purchaseCommand.verifySubscriptionStatus(params: params) { (response, error) in
            if let resultArray = response {
                if let result = resultArray.first, let respStatus = result["purchaseStatus"] as? Int, respStatus == 0, let createdAt = result["receiptExpiryDate"] as? String, let date = createdAt.stringToDate(formatter: DateFormatters.MMDDYYYYHMMSSA, timeZone: TimeZone(abbreviation: "UTC")!) {
                    user.savePurchase(date)
                    callback()
                }
                else {
                    user.savePurchase(nil)
                    callback()
                }
            }
            else {
                callback()
            }
        }
    }
}

class InAppPurchaseCommand: WSManager {
    
    func checkIntroductoryEligibility(params: [String: Any]?, on env: InAppEnviornment, callback: @escaping (PurchaseResponse?, WSNetworkError?) -> ()) {
        self.postToCheckIntroductoryEligibility(params: params, on: env, callback: { response, error in
            if error != nil {
                callback(nil, error)
            }
            else {
                callback(response, nil)
            }
        })
    }
    
    func verifyRecieptDataWithItunes(params: [String: Any]?, on env: InAppEnviornment, callback: @escaping (PurchaseResponse?, WSNetworkError?) -> ()) {
        self.postToCheckPurchase(params: params, on: env, callback: { response, error in
            if error != nil {
                callback(nil, error)
            }
            else {
                callback(response, nil)
            }
        })
    }
    
    func verifyRecieptDataWithServer(params: [String: Any]?, callback: @escaping (Dictionary<String, Any>?, String?) -> ()) {
        self.post(endPoint: ServiceData.verifyPurchase, params: params, callback: { response, error in
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
    
    func verifySubscriptionStatus(params: [String: Any]?, callback: @escaping ([[String: Any]]?, String?) -> ()) {
        self.get(endPoint: ServiceData.subscriptionStatus, params: params) { (response, error) in
            if let result = response {
                if let data = result.data as? [[String: Any]] {
                    callback(data, nil)
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
