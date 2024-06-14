//
//  WSNetworkResponse.swift
//  MiPlanIt
//
//  Created by Arun on 25/03/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation
import Alamofire
import Gzip

class WSNetworkResponse {
    
    var rawResponse: DataResponse<Any, AFError>
    var rawData: [AnyObject]?
    var error: String?
    var statusCode: String?
    var success: Bool = false
    var dataBytes: Data?
    
    var data: [AnyObject]? {
        get {
            if let gzipBytes = self.dataBytes, gzipBytes.isGzipped, let decompressedData = try? gzipBytes.gunzipped() {
                return try? JSONSerialization.jsonObject(with: decompressedData, options: []) as? [AnyObject]
            }
            else {
                return self.rawData
            }
        }
    }
    init(response: DataResponse<Any, AFError>) {
        self.rawResponse = response
        self.success = false
        self.error = Strings.empty
        self.statusCode = Strings.empty

        switch response.result {
        case .success(let value):
            if let result = value as? [String: Any], let status = result["Status"] as? String {
                if status == "OK" {
                    self.success = true
                    self.error = result["Message"] as? String ?? Strings.empty
                    self.statusCode = result["Statuscode"] as? String ?? Strings.empty

                    if let isBase64Encoded = result["isBase64Encoded"] as? Bool, isBase64Encoded, let dataString = result["data"] as? String {
                        self.dataBytes = Data(base64Encoded: dataString)
                    } else {
                        self.rawData = result["data"] as? [AnyObject]
                    }
                } else {
                    self.error = result["Message"] as? String ?? Strings.empty
                    self.statusCode = result["Statuscode"] as? String ?? Strings.empty
                }
            }
        case .failure(let error):
            self.error = error.localizedDescription
            self.statusCode = "\(error.responseCode ?? -1)"
        }
    }
    
    func isSuccessful()->Bool {
        return self.success
    }
}


struct MyResponse {
    var rawResponse: DataResponse<Any, AFError>
    var success: Bool
    var error: String
    var statusCode: String
    var dataBytes: Data?
    var rawData: [AnyObject]?

    init(response: DataResponse<Any, AFError>) {
        self.rawResponse = response
        self.success = false
        self.error = Strings.empty
        self.statusCode = Strings.empty

        switch response.result {
        case .success(let value):
            if let result = value as? [String: Any], let status = result["Status"] as? String {
                if status == "OK" {
                    self.success = true
                    self.error = result["Message"] as? String ?? Strings.empty
                    self.statusCode = result["Statuscode"] as? String ?? Strings.empty

                    if let isBase64Encoded = result["isBase64Encoded"] as? Bool, isBase64Encoded, let dataString = result["data"] as? String {
                        self.dataBytes = Data(base64Encoded: dataString)
                    } else {
                        self.rawData = result["data"] as? [AnyObject]
                    }
                } else {
                    self.error = result["Message"] as? String ?? Strings.empty
                    self.statusCode = result["Statuscode"] as? String ?? Strings.empty
                }
            }
        case .failure(let error):
            self.error = error.localizedDescription
            self.statusCode = "\(error.responseCode ?? -1)"
        }
    }
}
