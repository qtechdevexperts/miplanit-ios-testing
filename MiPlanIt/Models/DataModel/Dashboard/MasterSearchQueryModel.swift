//
//  MasterSearchQueryModel.swift
//  MiPlanIt
//
//  Created by Febin Paul on 22/12/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

class MasterSearchQueryModel {
    
    var searchText: String = Strings.empty
    var startDate: Date?
    
    init(searchText: String = Strings.empty, startDate: Date? = nil) {
        self.searchText = searchText
        self.startDate = startDate
    }
}
