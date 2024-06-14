//
//  RepeatDropDown.swift
//  MiPlanIt
//
//  Created by Febin Paul on 05/05/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation


class RepeatDropDown {

    var dropDownItem: DropDownItem!
    var untilDate: Date!
    
    init(dropDownItem: DropDownItem, untilDate: Date = Date()) {
        self.dropDownItem = dropDownItem
        self.untilDate = untilDate
    }

}
