//
//  DayEvent.swift
//  MiPlanIt
//
//  Created by Febin Paul on 16/09/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation


class DaysItems {
    
    var date: Date?
    var items: [Any] = []
    
    init(date: Date?, items: [Any]) {
        self.date = date
        if let object = items as? [Event] {
            self.items = object.sorted(by: { $0.start < $1.start })
        }
        else {
            self.items = items
        }
    }
}
