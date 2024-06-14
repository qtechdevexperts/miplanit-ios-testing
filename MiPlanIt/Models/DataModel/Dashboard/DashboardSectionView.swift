//
//  DashboardSectionView.swift
//  MiPlanIt
//
//  Created by Aneesh Asokan on 08/01/21.
//  Copyright © 2021 Arun. All rights reserved.
//

import Foundation
class DashboardSectionView: NSObject {
    
    var title: String
    let icon: String
    var isSelected: Bool = false
    var dashboardSectionType: DashBoardTitle?
    
    init(title: String, icon: String, isSelected: Bool = false, dashboardSectionType: DashBoardTitle) {
        self.title = title
        self.icon = icon
        self.isSelected = isSelected
        self.dashboardSectionType = dashboardSectionType
    }
}
