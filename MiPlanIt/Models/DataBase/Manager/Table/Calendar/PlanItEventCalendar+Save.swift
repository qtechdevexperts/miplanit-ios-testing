//
//  PlanItEventCalendar+Save.swift
//  MiPlanIt
//
//  Created by Arun on 17/11/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

extension PlanItEventCalendar {
    
    func readValueOfCalendarName() -> String { return self.calendarName ?? Strings.empty }
    func readValueOfCalendarType() -> String { return self.calendarType.cleanValue() }
    func isSocialCalendar() -> Bool { return self.calendarType != 0 }
    func readValueOfSocialAccountEmail() -> String { return (self.socialAccountEmail ?? Strings.empty).isEmpty ? (self.socialAccountName ?? Strings.empty) : self.socialAccountEmail ?? Strings.empty }
    func readValueOfSocialAccountName() -> String { return self.socialAccountName ?? Strings.empty }
    func readValueOfAppCalendarId() -> String { return self.appCalendarId ?? Strings.empty }
}
