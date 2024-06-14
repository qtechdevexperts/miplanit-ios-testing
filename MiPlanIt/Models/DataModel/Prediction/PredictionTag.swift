//
//  PredictionTag.swift
//  MiPlanIt
//
//  Created by Febin Paul on 27/05/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

class PredictionTag: Hashable, Equatable {
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(text)
    }
    
    var score: Double = 0.0
    var type: String = Strings.empty
    var text: String = Strings.empty
    
    init(with tagDict: [String: Any]) {
        self.score = tagDict["score"] as? Double ?? 0.0
        self.type = tagDict["Type"] as? String ?? Strings.empty
        self.text = tagDict["Text"] as? String ?? Strings.empty
    }
    
    init(with string: String) {
        self.text = string
    }
    
    static func ==(left:PredictionTag, right:PredictionTag) -> Bool {
        return left.text == right.text
    }
}
