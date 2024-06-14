//
//  PlanItEventShareLinkCalendar+Save.swift
//  MiPlanIt
//
//  Created by Febin Paul on 30/03/21.
//  Copyright © 2021 Arun. All rights reserved.
//

import Foundation

extension PlanItEventShareLinkCalendar {
    
    func readValueOfCalendarName() -> String { return self.calendarName ?? Strings.empty }
    func readValueOfCalendarType() -> String { return self.calendarType.cleanValue() }
    func isSocialCalendar() -> Bool { return self.calendarType != 0 }
    func readValueOfSocialAccountEmail() -> String { return (self.socialAccountEmail ?? Strings.empty).isEmpty ? (self.socialAccountName ?? Strings.empty) : self.socialAccountEmail ?? Strings.empty }
    func readValueOfSocialAccountName() -> String { return self.socialAccountName ?? Strings.empty }
    func readValueOfAppCalendarId() -> String { return self.appCalendarId ?? Strings.empty }
}
