//
//  IntroductoryEligibilityResponse.swift
//  MiPlanIt
//
//  Created by Febin Paul on 05/02/21.
//  Copyright © 2021 Arun. All rights reserved.
//

import Foundation
import Alamofire

class IntroductoryEligibilityResponse {
    
    var rawResponse: DataResponse<Any, AFError>
    var meta: NSDictionary?
    var data: Data?
    var error: String?
    var statusCode: Int?
    var status: PurchaseServiceStatus = .failed
    
    init?(response: DataResponse<Any, AFError>) {
            self.rawResponse = response
            self.statusCode = response.response?.statusCode ?? -1
            
            switch response.result {
            case .success(let value):
                if let result = value as? NSDictionary, let status = result["status"] as? Int, status == 0 {
                    if let _ = result["latest_receipt_info"] as? [String: Any] {
                        self.status = .success
                        self.data = response.data
                    } else {
                        self.status = .refresh
                    }
                } else {
                    self.status = .failed
                    self.error = (value as? [String: Any])?["message"] as? String
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



