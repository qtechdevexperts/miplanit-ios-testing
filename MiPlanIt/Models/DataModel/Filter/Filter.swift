//
//  Filter.swift
//  MiPlanIt
//
//  Created by Aneesh Asokan on 14/05/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation
class Filter: Comparable {
    
    let fieldName: Filters
    let fieldValue: String
    let fieldType: Int
    
    init(with name: Filters, value: String, type: Int) {
        self.fieldName = name
        self.fieldValue = value
        self.fieldType = type
    }
    
    static func ==(lhs: Filter, rhs: Filter) -> Bool {
        return lhs.fieldValue == rhs.fieldValue
    }
    
    static func < (lhs: Filter, rhs: Filter) -> Bool {
        return lhs.fieldValue < rhs.fieldValue
    }
}
