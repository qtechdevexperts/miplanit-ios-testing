//
//  PredictionService.swift
//  MiPlanIt
//
//  Created by Febin Paul on 27/05/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation
import Alamofire

class PredictionService {
    
    func predictionService(url: String, method: HTTPMethod, params: [String: Any]?, callback :@escaping (WSNetworkResponse?, WSNetworkError?) -> ()) {
        AF.request(ServiceData.prediction + url, method: method, parameters: params, encoding: JSONEncoding.prettyPrinted).responseJSON { response in
//          switch response.result {
//          case .success(let result):
//            callback(WSNetworkResponse(response: result), nil)
//
//          case .failure(let error):
//            callback(nil, WSNetworkError(error: error))
//          }
//            if response.result.isFailure {
//                callback(nil, WSNetworkError(error: response.result.error!))
//            } else {
//                callback(WSNetworkResponse(response: response), nil)
//            }
          callback(.init(response: response), nil)
        }
    }
}
