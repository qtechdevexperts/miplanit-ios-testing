//
//  RepeatFullDropDownViewController+Action.swift
//  MiPlanIt
//
//  Created by Febin Paul on 14/04/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

extension RepeatFullDropDownViewController {
    
    func readDropDownOptions() -> [DropDownItem] {
        switch self.dropDownCategory {
        case .eFrequency:
            self.itemSelectionDropDown = self.repeatModel?.frequency
            return [DropDownItem(name: Strings.never, type: .eNever), DropDownItem(name: Strings.everyDay, type: .eEveryDay, value: "DAILY"), DropDownItem(name: Strings.everyWeek, type: .eEveryWeek, value: "WEEKLY"), DropDownItem(name: Strings.everyMonth, type: .eEveryMonth, value: "MONTHLY"), DropDownItem(name: Strings.everyYear, type: .eEveryYear, value: "YEARLY")]
        case .eInterval: do {
            self.itemSelectionDropDown = self.repeatModel?.interval
            var intervalString = Strings.empty
            switch self.repeatModel?.frequency.dropDownType {
            case .eEveryDay?:
                intervalString = "day"
            case .eEveryWeek?:
                intervalString = "week"
            case .eEveryMonth?:
                intervalString = "month"
            case .eEveryYear?:
                intervalString = "year"
            default:
                break
            }
            return (1...10).map { DropDownItem(name: "\($0) \(intervalString)\($0 > 1 ? "s" : "")", value: "\($0)") }
            }
        case .eOnDays:
            if let repeatModel = self.repeatModel, repeatModel.frequency.dropDownType == .eEveryWeek {
                return [DropDownItem(name: Strings.Sunday, type: .eDefault), DropDownItem(name: Strings.Monday, type: .eDefault), DropDownItem(name: Strings.everyWeek, type: .eDefault), DropDownItem(name: Strings.everyMonth, type: .eDefault), DropDownItem(name: Strings.everyYear, type: .eDefault)]
            }
            else {
                return [DropDownItem(name: Strings.never, type: .eNever), DropDownItem(name: Strings.everyDay, type: .eEveryDay), DropDownItem(name: Strings.everyWeek, type: .eEveryWeek), DropDownItem(name: Strings.everyMonth, type: .eEveryMonth), DropDownItem(name: Strings.everyYear, type: .eEveryYear)]
            }
            
        default:
            return [DropDownItem(name: Strings.never, type: .eNever), DropDownItem(name: Strings.everyDay, type: .eEveryDay), DropDownItem(name: Strings.everyWeek, type: .eEveryWeek), DropDownItem(name: Strings.everyMonth, type: .eEveryMonth), DropDownItem(name: Strings.everyYear, type: .eEveryYear)]
        }
    }
}
