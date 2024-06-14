//
//  PredictionTagService.swift
//  MiPlanIt
//
//  Created by Febin Paul on 27/05/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation


class PredictionActivityTagService {

    func getPredictedTags(_ user: PlanItUser, from text: String, callback: @escaping ([PredictionTag], String?, String?) -> ()) {
        var param: [String: String] = [:]
        param["message"] = text
        param["user_id"] = user.readValueOfUserId()
        param["user_name"] = user.readValueOfName()
        param["user_time"] = Date().stringFromDate(format: DateFormatters.DDHMMHYYYYSHHCMMCSSS, timeZone: TimeZone(abbreviation: "UTC")!)+" ITC"
        PredictionActivityTagCommand().getPredictedTags(param) { (response, error) in
            if let data = response, let entities = data["Entities"] as? [[String: Any]], let id =  data["id"] as? String {
                let predictionTags = Array(Set(entities.compactMap({ return PredictionTag(with: $0) })))
                callback(predictionTags, id, nil)
            }
            else {
                callback([], nil, error ?? Message.unknownError)
            }
        }
    }
    
    func sendPredictionFeedback(from tags: [String], id: String, callback: @escaping (Bool, String?) -> ()) {
        var param: [String: Any] = [:]
        param["tag"] = tags
        param["feedback_id"] = id
        param["user_time"] = Date().stringFromDate(format: DateFormatters.DDHMMHYYYYSHHCMMCSSS, timeZone: TimeZone(abbreviation: "UTC")!)+" ITC"
        PredictionActivityTagCommand().sendPredictionFeedback(param) { (status, error) in
            if status {
                callback(true, nil)
            }
            else {
                callback(false, error ?? Message.unknownError)
            }
        }
    }
}

class PredictionActivityTagCommand: WSManager {
    
    func getPredictedTags(_ params: [String: Any], callback: @escaping (Dictionary<String, Any>?, String?) -> ()) {
        PredictionService().predictionService(url: ServiceData.tagPrediction, method: .post, params: params) { (response, error) in
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
    
    func sendPredictionFeedback(_ params: [String: Any], callback: @escaping (Bool, String?) -> ()) {
        PredictionService().predictionService(url: ServiceData.tagFeedback, method: .post, params: params) { (response, error) in
            if let result = response {
                if result.success {
                    callback(true, nil)
                }
                else {
                    callback(false, result.error)
                }
            }
            else {
                callback(false, error?.message ?? Message.unknownError)
            }
        }
    }
}
