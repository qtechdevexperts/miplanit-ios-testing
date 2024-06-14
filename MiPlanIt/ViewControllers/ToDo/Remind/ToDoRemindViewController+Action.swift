//
//  ToDoRemindViewController+Action.swift
//  MiPlanIt
//
//  Created by Febin Paul on 13/07/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation


extension ToDoRemindViewController {
    
    func readDropDownOptions() -> [DropDownItem] {
        return [DropDownItem(name: Strings.fiveteenMinBefore, type: .e15MinBefore), DropDownItem(name: Strings.thirtyMinBefore, type: .e30MinBefore), DropDownItem(name: Strings.oneHourBefore, type: .e1HrBefore), DropDownItem(name: Strings.oneDayBefore, type: .e1DayBefore), DropDownItem(name: Strings.oneMonthBefore, type: .e1MonthBefore)]
    }
    
}
