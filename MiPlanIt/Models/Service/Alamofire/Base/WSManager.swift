//
//  WSManager.swift
//  MiPlanIt
//
//  Created by Arun on 25/03/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation
import Alamofire

class WSManager {
    
    func get(endPoint: String, params: [String: Any]? = [:], callback:  @escaping (WSNetworkResponse?, WSNetworkError?) ->()) {
        self.makeRequest(method: .get, endPoint: endPoint, params: params, encoding: URLEncoding.queryString,  callback: callback)
    }
    
    func post(endPoint: String, params: [String: Any]? = [:], callback:  @escaping (WSNetworkResponse?, WSNetworkError?) ->()) {
        self.makeRequest(method: .post, endPoint: endPoint, params: params, encoding: JSONEncoding.prettyPrinted, callback: callback)
    }
    
    func delete(endPoint: String, params: [String: Any]? = [:], callback:  @escaping (WSNetworkResponse?, WSNetworkError?) ->()) {
        self.makeRequest(method: .delete, endPoint: endPoint, params: params, encoding: JSONEncoding.prettyPrinted, callback: callback)
    }
    
    func postToCheckPurchase( params: [String: Any]? = [:], on env: InAppEnviornment , callback:  @escaping (PurchaseResponse?, WSNetworkError?) ->()){
        self.makeRequestForRestorePurchase(method: .post, params: params, on: env, callback: callback)
    }
    
    func postToCheckIntroductoryEligibility( params: [String: Any]? = [:], on env: InAppEnviornment , callback:  @escaping (PurchaseResponse?, WSNetworkError?) ->()){
        self.makeRequestForRestorePurchase(method: .post, params: params, on: env, callback: callback)
    }
    //Note: Added few print methods to print request and response.
    func makeRequest(method: HTTPMethod, endPoint: String, params: [String: Any]? = [:], encoding: ParameterEncoding, callback: @escaping (WSNetworkResponse?, WSNetworkError?) ->()) {
        var header = ["Content-Type": "application/json"]
        if let user = Session.shared.readUser() {
            header["miplanitauthtoken"] = user.readValueOfAuthToken()
            header["isreminderlist"] = IsReminderList.False.rawValue
        }
        if  endPoint != "/users/subscription-status"{
            print("\nRequest -- ",endPoint)
            print("///////////////////////////////////////////")
            print("Body:",params ?? [])
            print("///////////////////////////////////////////")

            print("Request End\n")
        }

        
        Alamofire.request(ServiceData.baseUrl + endPoint, method: method, parameters: params, encoding:encoding, headers: header).responseJSON(completionHandler: { response in
            if response.result.isFailure {
                callback(nil, WSNetworkError(error: response.result.error!))
            } else {
                if let data = response.data, let resp = self.convertToDictionary(data: data){
                     print("\nResponse Starts\n", resp)
                    print("\nResponse Ends --", endPoint)
                }
                callback(WSNetworkResponse(response: response), nil)
            }
        })
    }
    
    func makeRequestForRestorePurchase(method: HTTPMethod,  params: [String: Any]? = [:],on env: InAppEnviornment, callback: @escaping (PurchaseResponse?, WSNetworkError?) ->()){
        Alamofire.request(env == .production ? ServiceData.itunesService : ServiceData.itunesSandboxService, method: method, parameters: params,
            encoding: JSONEncoding.default).responseJSON(completionHandler: { response in
            if response.result.isFailure {
                callback(nil, WSNetworkError(error: response.result.error!))
            } else if let networkResponse = PurchaseResponse(response: response) {
                callback(networkResponse, nil)
            }
        })
    }
    
    private func convertToDictionary(data: Data) -> [String: Any]? {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        return nil
    }
}
