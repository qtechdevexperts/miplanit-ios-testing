//
//  ShoppingDate.swift
//  MiPlanIt
//
//  Created by Aneesh Asokan on 03/05/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit


class ShoppingDate: NSObject {
    
    let title: String
    var isSelected: Bool = false
    var type: MiPlanItEnumDayType = .all
    var icon: String
    
    init(title: String, isSelected: Bool = false, type: MiPlanItEnumDayType, icon: String) {
        self.title = title
        self.type = type
        self.isSelected = isSelected
        self.icon = icon
    }
}
