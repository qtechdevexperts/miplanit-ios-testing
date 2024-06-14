//
//  DateSpecificEvent.swift
//  MiPlanIt
//
//  Created by Arun on 25/06/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

class DateSpecificEvent {

    let startDate: Date!
    let caption: String
    
    init(with date: Date) {
        self.startDate = date
        self.caption = date.stringFromDate(format: DateFormatters.EEEESDDMMM)
    }
    
    init(with dateEvent: Event) {
        self.startDate = dateEvent.initialDate
        self.caption = dateEvent.initialDate.stringFromDate(format: DateFormatters.EEEESDDMMM)
    }
    
    init(with dashboardEvent: DashboardEventItem) {
        self.startDate = dashboardEvent.initialDate
        self.caption = dashboardEvent.initialDate.stringFromDate(format: DateFormatters.EEEESDDMMM)
    }
}
