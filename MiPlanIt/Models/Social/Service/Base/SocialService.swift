//
//  SocialService.swift
//  MiPlanIt
//
//  Created by Arun on 23/03/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation
import Alamofire
import MSGraphClientSDK

class SocialService {
    
    func googleService(url: String, method: HTTPMethod, params: [String: Any]?, completionHandler :@escaping (Any?, Error?) -> ()) {
        Alamofire.request(ServiceData.google + url, method: method, parameters: params, encoding: URLEncoding.queryString).responseJSON { response in
            DispatchQueue.main.async {
                if let anyObj = response.data, let jsonObject = try? JSONSerialization.jsonObject(with: anyObj, options: []) as? [String:Any] {
                    completionHandler(jsonObject, nil)
                }
                else {
                    completionHandler (nil, response.error)
                }
            }
        }
    }
    
    func googleRefreshToken(method: HTTPMethod, params: [String: Any]?, completionHandler :@escaping (Any?, Error?) -> ()) {
        Alamofire.request(ServiceData.googleToken, method: method, parameters: params, encoding: JSONEncoding.prettyPrinted).responseJSON { response in
            DispatchQueue.main.async {
                if let anyObj = response.data, let jsonObject = try? JSONSerialization.jsonObject(with: anyObj, options: []) as? [String:Any] {
                    completionHandler(jsonObject, nil)
                }
                else {
                    completionHandler (nil, response.error)
                }
            }
        }
    }
    
    func outlookService(url: String, client: MSHTTPClient, completionHandler :@escaping (Any?, String?, Error?) -> ()) {
        let eventsRequest = NSMutableURLRequest(url: URL(string: MSGraphBaseURL + url)!)
        let eventsDataTask = MSURLSessionDataTask(request: eventsRequest, client: client, completion: {
            (data: Data?, response: URLResponse?, graphError: Error?) in
           guard let eventsData = data, graphError == nil else {
               completionHandler(nil, nil, graphError)
               return
           }
            if let jsonObject = try? JSONSerialization.jsonObject(with: eventsData, options: []) as? [String:Any] {
                let nextLink = jsonObject["@odata.nextLink"] as? String
                if let calendars = jsonObject["value"] as? [[String: Any]] {
                    completionHandler(calendars, nextLink, nil)
                }
                else if (jsonObject["error"] as? [String: Any]) != nil {
                    completionHandler(nil, nil, nil)
                }
            }
        })
        eventsDataTask?.execute()
    }
    
    func outlookGetAccessRefreshToken(params: [String: Any], completionHandler :@escaping (Any?, Error?) -> ()) {
        let headers = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        Alamofire.request(ServiceData.outlookGetTokens, method: .post, parameters: params, encoding: URLEncoding.default, headers: headers).responseJSON { response in
            DispatchQueue.main.async {
               if let anyObj = response.data, let jsonObject = try? JSONSerialization.jsonObject(with: anyObj, options: []) as? [String:Any] {
                    completionHandler(jsonObject, nil)
                }
                else {
                    completionHandler (nil, response.error)
                }
            }
        }
    }
    
    func outlookGetUserInfo(token: String, completionHandler :@escaping (Any?, Error?) -> ()) {
        let headers = [
            "Authorization": "Bearer \(token)"
        ]
        Alamofire.request(ServiceData.outlookGetUserInfo, method: .get, parameters: nil, encoding: URLEncoding.default, headers: headers).responseJSON { response in
            DispatchQueue.main.async {
               if let anyObj = response.data, let jsonObject = try? JSONSerialization.jsonObject(with: anyObj, options: []) as? [String:Any] {
                    completionHandler(jsonObject, nil)
                }
                else {
                    completionHandler (nil, response.error)
                }
            }
        }
    }
    
}

