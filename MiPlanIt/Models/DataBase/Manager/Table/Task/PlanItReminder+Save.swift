//
//  PlanItReminder+Save.swift
//  MiPlanIt
//
//  Created by Febin Paul on 12/08/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

extension PlanItReminder {
    
    func readInterval() -> Double { return self.interval }
    func readIntervalType() -> Double { return self.intervalType }
    func readEmailNotification() -> Bool { return self.emailNotification }
    func readEmailNotificationBody() -> String? { return self.emailNotificationBody ?? Strings.empty }
    func readStartTime() -> String { return self.startTime ?? Strings.empty }
    
    func readIntervalUnit() -> String? {
        switch self.readIntervalType() {
        case 1.0:
            return Strings.minUnit
        case 2.0:
            return Strings.hourUnit
        case 3.0:
            return Strings.dayUnit
        case 4.0:
            return Strings.weekUnit
        case 5.0:
            return Strings.monthUnit
        case 6.0:
            return Strings.yearUnit
        default:
            return nil
        }
    }
    
    func deleteItSelf(withHardSave status: Bool = true) {
        self.managedObjectContext?.delete(self)
        if status { try? self.managedObjectContext?.save() }
    }
    
    func readReminderNumericValueParameter() -> [String: Any]? {
        var remimderParameter: [String: Any] = [:]
        if let startTime = self.startTime?.toDateStrimg(withFormat: DateFormatters.HHCMMCSSSA) {
            remimderParameter["startTime"] = startTime.stringFromDate(format: DateFormatters.HHCMMCSS)
        }
        if self.readInterval() != 0 {
            remimderParameter["intrvl"] = self.interval
        }
        if self.readIntervalType() != 0 {
            remimderParameter["intrvlType"] = self.intervalType
        }
        remimderParameter["emailNotification"] = self.readEmailNotification()
        if let notificationBody = self.readEmailNotificationBody() {
            remimderParameter["emailNotificationBody"] = notificationBody
        }
        return remimderParameter
    }
    
    func readReminderMinutesFromDate(_ date: Date) -> Date {
        guard let time = self.startTime, let timeDate = time.toDateStrimg(withFormat: DateFormatters.HHCMMCSSSA) else {
            return date.adding(minutes: -self.getReminderValueInMinutes())
        }
        let reminderMinutes = (timeDate.hour * 60 ) + (timeDate.minute) - self.getReminderValueInMinutes()
        let finalDate = date.adding(minutes: reminderMinutes)
        return finalDate.adding(seconds: Int(TimeZone.current.daylightSavingTimeOffset(for: date)) - Int(TimeZone.current.daylightSavingTimeOffset(for: finalDate)))
    }
    
    func getReminderValueInMinutes() -> Int {
        switch self.readIntervalType() {
        case 1.0:
            return Int(self.interval)
        case 2.0:
            return Int(self.interval) * 60
        case 3.0:
            return Int(self.interval) * 60 * 24
        case 4.0:
            return Int(self.interval) * 60 * 24 * 7
        case 5.0:
            return Int(self.interval) * 60 * 24 * 30
        case 6.0:
            return Int(self.interval) * 365 * 24 * 60
        default:
            return 5
        }
    }
}
