//
//  CustomDashboard.swift
//  MiPlanIt
//
//  Created by Aneesh Asokan on 19/05/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

class CustomDashboard: NSObject {
    
    var title: String
    let icon: String
    var isSelected: Bool = false
    var type: DashBoardSection!
    
    init(title: String, icon: String, isSelected: Bool = false, type: DashBoardSection) {
        self.title = title
        self.icon = icon
        self.isSelected = isSelected
        self.type = type
    }
}
