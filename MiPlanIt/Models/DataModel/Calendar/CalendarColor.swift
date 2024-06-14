//
//  CalendarColor.swift
//  MiPlanIt
//
//  Created by Febin Paul on 03/06/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

class CalendarColor {
    
    var colorCode: ColorCode!
    var isSelected: Bool = false
    
    init(colorCode: ColorCode, isSelected: Bool = false) {
        self.colorCode = colorCode
        self.isSelected = isSelected
    }
}
