//
//  RepeatModel.swift
//  MiPlanIt
//
//  Created by Febin Paul on 23/06/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

class RepeatModel {
    var frequency: DropDownItem = DropDownItem(name: Strings.never, type: .eNever)
    var interval: DropDownItem?
    var onDays: [Int] = []
    var untilDate: Date?
    var forever: Bool = true
    var byMonth: Int?
    var byMonthDay: Int?
}
