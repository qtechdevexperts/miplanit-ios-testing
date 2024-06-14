//
//  UserCalendarType.swift
//  MiPlanIt
//
//  Created by Arun on 03/06/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

class UserCalendarType {
    
    let type: String
    let label: String
    var synced: Bool = false
    var calendars: [UserCalendarVisibility]
    
    init(with type: String?, title: String?, synced: Bool, calendars: [UserCalendarVisibility]) {
        self.type = type ?? Strings.empty
        self.label = title ?? Strings.empty
        self.calendars = calendars
        self.synced = synced
    }
    
    init(with type: String?, title: String?, calendars: [PlanItCalendar], selectedCalendars: [PlanItCalendar]) {
        self.type = type ?? Strings.empty
        self.label = title ?? Strings.empty
        self.calendars = calendars.filter({ return $0.parentCalendarId == 0 }).sorted(by: { if $0.parentCalendarId == 0 { return true } else { return $0.readValueOfCalendarName() < $1.readValueOfCalendarName() } }).map({ return UserCalendarVisibility(with: $0, selected: selectedCalendars.contains($0)) })
        self.calendars += calendars.filter({ return $0.parentCalendarId != 0 }).sorted(by: { if $0.parentCalendarId == 0 { return true } else { return $0.readValueOfCalendarName() < $1.readValueOfCalendarName() } }).map({ return UserCalendarVisibility(with: $0, selected: selectedCalendars.contains($0)) })
    }
    
    init(with type: String?, title: String?, calendars: [PlanItCalendar], selectedCalendars: [UserCalendarVisibility], visibility: Double) {
        self.type = type ?? Strings.empty
        self.label = title ?? Strings.empty
        self.calendars = calendars.filter({ return $0.parentCalendarId == 0 }).sorted(by: { if $0.parentCalendarId == 0 { return true } else { return $0.readValueOfCalendarName() < $1.readValueOfCalendarName() } }).map({ calendar in return UserCalendarVisibility(with: calendar, visibility: selectedCalendars.contains( where: { return $0.calendar == calendar && $0.visibility == 1}) ? 1 : selectedCalendars.contains( where: { return $0.calendar == calendar && $0.visibility == 0}) ? 0 : visibility, selected: selectedCalendars.contains(where: { return $0.calendar == calendar}) ) })
        self.calendars += calendars.filter({ return $0.parentCalendarId != 0 }).sorted(by: { if $0.parentCalendarId == 0 { return true } else { return $0.readValueOfCalendarName() < $1.readValueOfCalendarName() } }).map({ calendar in return UserCalendarVisibility(with: calendar, visibility: selectedCalendars.contains( where: { return $0.calendar == calendar && $0.visibility == 1}) ? 1 : selectedCalendars.contains( where: { return $0.calendar == calendar && $0.visibility == 0}) ? 0 : visibility, selected: selectedCalendars.contains(where: { return $0.calendar == calendar}) ) })
    }
}
