//
//  File.swift
//  MiPlanIt
//
//  Created by Arun on 08/04/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation
import EventKit

public extension EKRecurrenceRule {
    
    func stringForICalendar() -> String {
        let ret = self.description
        return "RRULE " + ret.components(separatedBy: " RRULE ")[1]
    }
}
