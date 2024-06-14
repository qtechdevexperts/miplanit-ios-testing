//
//  PurchaseResponse.swift
//  BookReader
//
//  Created by Remil.cv on 8/11/1397 AP.
//  Copyright © 1397 ARUN. All rights reserved.
//

import Foundation
import Alamofire

enum ResponseStatus {
    case success
    case refresh
    case failed
}


class PurchaseResponse {
    
    var rawResponse: DataResponse<Any, AFError>
    var meta: NSDictionary?
    var data: Data?
    var error: String?
    var statusCode: Int?
    var status: PurchaseServiceStatus = .failed
    var verifyStatus: Int?
    
    init?(response: DataResponse<Any, AFError>){
        self.rawResponse = response
        switch response.result {
        case .success(let value):
            if let result = value as? NSDictionary {
                self.verifyStatus = result["status"] as? Int
                if let status = result["status"] as? Int, status == 0 {
                    if let _ = result["receipt"] as? Dictionary<String, Any> {
                        if let latestReceiptInfo = result["latest_receipt_info"] as? Array<Dictionary<String, Any>>, let latestReceipt = latestReceiptInfo.first {
                            if let expiresDate = latestReceipt["expires_date"] as? String, let date = expiresDate.stringToDate(formatter: DateFormatters.YYYMMDDSHHCMMCSSVV, timeZone: TimeZone(abbreviation: "UTC")!), date > Date() {
                                self.status = .success
                            } else {
                                self.status = .failed
                                self.error = Strings.receiptExpired
                            }
                        }
                        if self.status == .success {
                            self.data = response.data
                        }
                    } else {
                        self.status = .refresh
                    }
                } else {
                    self.status = .failed
                    self.error = result["message"] as? String
                }
            } else {
                return nil
            }
        case .failure(let error):
            self.status = .failed
            self.error = error.localizedDescription
        }
    }
    
    func getError()->WSNetworkError {
        return WSNetworkError(error: self.error ?? Strings.empty)
    }
}
