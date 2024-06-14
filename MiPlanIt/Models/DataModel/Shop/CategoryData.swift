//
//  CategoryData.swift
//  MiPlanIt
//
//  Created by Febin Paul on 19/11/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation


class CategoryData {
    var categoryId: Double = 0
    var categoryAppId: String = Strings.empty
    var categoryName: String = Strings.empty
    
    init(id: Double, name: String, appId: String?) {
        self.categoryId = id
        self.categoryName = name
        self.categoryAppId = appId ?? Strings.empty
    }
}
