//
//  PriorityDropDownViewController+Action.swift
//  MiPlanIt
//
//  Created by Febin Paul on 19/05/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

extension PriorityDropDownViewController {
 
    func readDropDownOptions() -> [DropDownItem] {
        return [DropDownItem(name: Strings.low, type: .ePriorityLow, isNeedImage: true, imageName: Strings.priorityLowImage), DropDownItem(name: Strings.medium, type: .ePriorityMedium, isNeedImage: true, imageName: Strings.priorityMediumImage), DropDownItem(name: Strings.high, type: .ePriorityHigh, isNeedImage: true, imageName: Strings.priorityHighImage)]
    }
}
