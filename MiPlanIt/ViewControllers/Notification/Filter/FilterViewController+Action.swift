//
//  FilterViewController+Action.swift
//  MiPlanIt
//
//  Created by Febin Paul on 08/04/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

extension FilterViewController {
    
    func readDropDownOptions() -> [DropDownItem] {
        return [DropDownItem(name: Strings.event, type: .eEvent, isNeedImage: true, isSelected: self.selectedFilter == .eEvent, imageName: FileNames.ballonIcon),
                DropDownItem(name: Strings.calendar, type: .eCalendar, isNeedImage: true, isSelected: self.selectedFilter == .eCalendar, imageName: FileNames.calendarIcon),
                DropDownItem(name: Strings.task, type: .eTask, isNeedImage: true, isSelected: self.selectedFilter == .eTask, imageName: FileNames.todoIcon),
                DropDownItem(name: Strings.shopping, type: .eShopping, isNeedImage: true, isSelected: self.selectedFilter == .eShopping, imageName: FileNames.shoppingIcon)]
    }
    
    func updateResetButtonStatus() {
        self.buttonResetFilter.isSelected = self.selectedFilter != .eDefault
        self.buttonResetFilter.backgroundColor = self.selectedFilter == .eDefault ? UIColor.clear : .grayLightPlus//UIColor(red: 86/255.0, green: 173/255.0, blue: 189/255.0, alpha: 1)
    }
}
