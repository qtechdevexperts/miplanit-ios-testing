//
//  Task.swift
//  
//
//  Created by Nikhil RajG on 28/04/20.
//

import Foundation

class Task {
    
    var startDate: Date!
    var endDate: Date!
    var taskName = Strings.empty
    var taskDescription = Strings.empty
    var tags: [String] = []
    var repeatValue: DropDownItem?
    var remindValue: DropDownItem?
    
    init() {
        self.startDate = Date().nearestHalfHour()
        self.tags = ["Events"]
    }
    
}
