//
//  CategoryListFilterController+Action.swift
//  MiPlanIt
//
//  Created by Febin Paul on 01/07/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

extension CategoryListFilterController {
 
    func readDropDownOptions() -> [DropDownItem] {
        if self.categoryType == .custom {
            return [DropDownItem(name: Strings.favourite, type: .eFavourite, isNeedImage: true, isSelected: self.isFilterActive(on: .eFavourite), imageName: FileNames.imageTodoFavouriteIcon), DropDownItem(name: Strings.unplanned, type: .eUnplanned, isNeedImage: true, isSelected: self.isFilterActive(on: .eUnplanned), imageName: FileNames.imageTodoUnplanned), DropDownItem(name: Strings.overDue, type: .eOverDue, isNeedImage: true, isSelected: self.isFilterActive(on: .eOverDue), imageName: FileNames.imageOverDue), DropDownItem(name: Strings.assignedToMe, type: .eAssignedToMe, isNeedImage: true, isSelected: self.isFilterActive(on: .eAssignedToMe), imageName: FileNames.imageAssigneToMe), DropDownItem(name: Strings.completed, type: .eCompleted, isNeedImage: true, isSelected: self.isFilterActive(on: .eCompleted), imageName: FileNames.imageToDoCompleted), DropDownItem(name: Strings.assignedByMe, type: .eAssignedByMe, isNeedImage: true, isSelected: self.isFilterActive(on: .eAssignedByMe), imageName: FileNames.imageAssigneToMe), DropDownItem(name: Strings.date, type: .eCreatedDate, isNeedImage: true, isSelected: self.isFilterActive(on: .eCreatedDate), imageName: FileNames.calendarIcon)]
        }
        else {
             return [DropDownItem(name: Strings.favourite, type: .eFavourite, isNeedImage: true, isSelected: self.isFilterActive(on: .eFavourite), imageName: FileNames.imageTodoFavouriteDropDown), DropDownItem(name: Strings.assignedToMe, type: .eAssignedToMe, isNeedImage: true, isSelected: self.isFilterActive(on: .eAssignedToMe), imageName: FileNames.imageTodoAssignToMeDropDown), DropDownItem(name: Strings.overDue, type: .eOverDue, isNeedImage: true, isSelected: self.isFilterActive(on: .eOverDue), imageName: FileNames.imageTodoOverdueDropDown),  DropDownItem(name: Strings.deleted, type: .eDelete, isNeedImage: true, isSelected: self.isFilterActive(on: .eDelete), imageName: FileNames.deleteDroDown)]
        }
    }
    
    func isFilterActive(on type: DropDownOptionType) -> Bool {
        guard let dropDownType = self.activeFilter?.dropDownType else { return false }
        return dropDownType == type
    }
}
