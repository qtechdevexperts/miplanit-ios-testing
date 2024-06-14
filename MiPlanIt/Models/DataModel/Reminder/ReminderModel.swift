//
//  ReminderModel.swift
//  MiPlanIt
//
//  Created by Febin Paul on 12/08/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation


class ReminderModel {
    
    var sourceScreen: SourceScreen = .event
    var reminderTime: String = Strings.empty
    var reminderBeforeValue: Int = 15
    var reminderBeforeUnit: String = Strings.minUnit
    var reminderOption: ReminderOption = .fifteenMinBefore
    var emailNotification: Bool = false
    var emailNotificationBody: String = Strings.empty
    var isSocialEvent: Bool = false
    var isAllDayReminder: Bool = true
    
    init() {
    }
    
    init(_ planItReminder: PlanItReminder, from screen: SourceScreen) {
        self.sourceScreen = screen
        self.isSocialEvent = planItReminder.event?.isSocialEvent ?? false
        self.isAllDayReminder = planItReminder.event?.isAllDay ?? true
        self.reminderTime = planItReminder.startTime ?? Strings.empty
        if self.isSocialEvent {
            self.setReminderValueAndUnit(planItReminder)
        }
        else {
            if let unit = planItReminder.readIntervalUnit() {
                self.setReminderUnit(unit)
            }
            if planItReminder.readInterval() != 0.0 {
                self.setValueRiminderOption(interval: Int(planItReminder.readInterval()))
            }
        }
        //Missing email options
        self.emailNotification = planItReminder.readEmailNotification()
        self.emailNotificationBody = planItReminder.readEmailNotificationBody() ?? Strings.empty
    }
    
    init(_ reminderModel: ReminderModel?, from screen: SourceScreen, isAllDay: Bool = true) {
        self.sourceScreen = screen
        self.isSocialEvent = reminderModel?.isSocialEvent ?? false
        if let model = reminderModel {
            self.isAllDayReminder = model.isAllDayReminder
            self.reminderTime = model.reminderTime
            self.reminderBeforeUnit = model.reminderBeforeUnit
            self.reminderBeforeValue = model.reminderBeforeValue
            self.reminderOption = model.reminderOption
            self.emailNotification = model.emailNotification
            self.emailNotificationBody = model.emailNotificationBody
        }
        else {
            self.reminderTime = Date().previousHour().stringFromDate(format: DateFormatters.HHCMMCSSSA)
            self.isAllDayReminder = isAllDay
        }
    }
    
    func updateIsAllDay(with flag: Bool) {
        self.isAllDayReminder = flag
    }
    
    func setReminderValueAndUnit(_ planItReminder: PlanItReminder) {
        if planItReminder.readInterval() != 0.0 {
            if planItReminder.readInterval() > 59 {
                if planItReminder.readInterval().truncatingRemainder(dividingBy: 60) == 0 && planItReminder.readInterval() <= 1380 {
                    self.reminderBeforeValue = Int(planItReminder.readInterval()/60.0)
                    self.reminderOption = self.reminderBeforeValue == 1 ? .oneHourBefore : .custom
                    self.reminderBeforeUnit = Strings.hourUnit
                }
                else if planItReminder.readInterval().truncatingRemainder(dividingBy: 1440) == 0 && planItReminder.readInterval() > 1380 && planItReminder.readInterval() <= 8640 {
                    self.reminderBeforeValue = Int(planItReminder.readInterval()/1440)
                    self.reminderOption = self.reminderBeforeValue == 1 ? .oneDayBefore : .custom
                    self.reminderBeforeUnit = Strings.dayUnit
                }
                else if planItReminder.readInterval().truncatingRemainder(dividingBy: 10080) == 0 && planItReminder.readInterval() > 8640 && planItReminder.readInterval() <= 514080 {
                    self.reminderBeforeValue = Int(planItReminder.readInterval()/10080)
                    self.reminderOption = self.reminderBeforeValue == 1 ? .oneWeekBefore : .custom
                    self.reminderBeforeUnit = Strings.weekUnit
                }
                else {
                    self.reminderBeforeValue = Int(planItReminder.readInterval())
                    self.reminderOption = .custom
                }
            }
            else {
                if planItReminder.readInterval() == 5 {
                    self.reminderBeforeValue = 5
                    self.reminderOption = .fiveMinBefore
                }
                else if planItReminder.readInterval() == 15 {
                    self.reminderBeforeValue = 15
                    self.reminderOption = .fifteenMinBefore
                }
                else if planItReminder.readInterval() == 30 {
                    self.reminderBeforeValue = 30
                    self.reminderOption = .thirtyMinBefore
                }
                else {
                    self.reminderBeforeValue = Int(planItReminder.readInterval())
                    self.reminderOption = .custom
                }
            }
        }
    }
    
    func getReminderTimeDate() -> Date {
        if let date = self.reminderTime.toDateStrimg(withFormat: DateFormatters.HHCMMCSSSA) {
            return date
        }
        return Date().previousHour()
    }
    
    func readReminderTimeString() -> String {
        if let date = self.reminderTime.toDateStrimg(withFormat: DateFormatters.HHCMMCSSSA) {
            return date.stringFromDate(format: DateFormatters.HHMMSA)
        }
        else {
            let previousHour = Date().previousHour()
            self.reminderTime = previousHour.stringFromDate(format: DateFormatters.HHCMMCSSSA)
            return previousHour.stringFromDate(format: DateFormatters.HHMMSA)
        }
    }
    
    func setReminderTimeFrom(_ date: Date?) {
        guard let date = date else {
            self.reminderTime = Strings.empty
            return
        }
        self.reminderTime = date.stringFromDate(format: DateFormatters.HHCMMCSSSA)
    }
    
    func readEmailNotification() -> Bool {
        return self.emailNotification
    }
    
    func readEmailNotificationBody() -> String {
        return self.emailNotificationBody
    }
    
    func readStringInterval() -> String {
        return String(self.reminderBeforeValue)
    }
    
    func readStringIntervalType() -> String {
        switch self.reminderBeforeUnit {
        case Strings.minUnit:
            return "1"
        case Strings.hourUnit:
            return "2"
        case Strings.dayUnit:
            return "3"
        case Strings.weekUnit:
            return "4"
        case Strings.monthUnit:
            return "5"
        case Strings.yearUnit:
            return "6"
        default:
            return Strings.empty
        }
    }
    
    func setValueRiminderOption(interval: Int?) {
        let unit = self.reminderBeforeUnit
        if interval == 1 {
            self.reminderBeforeValue = 1
            if unit == Strings.hourUnit {
                self.reminderOption = .oneHourBefore
            }
            else if unit == Strings.dayUnit {
                self.reminderOption = .oneDayBefore
            }
            else if unit == Strings.weekUnit {
                self.reminderOption = .oneWeekBefore
            }
            else if unit == Strings.monthUnit {
                self.reminderOption = .oneMonthBefore
            }
            else if unit == Strings.yearUnit {
                self.reminderOption = .oneYearBefore
            }
        }
        else if interval == 5 && unit == Strings.minUnit {
            self.reminderBeforeValue = 5
            self.reminderOption = .fiveMinBefore
        }
        else if interval == 15 && unit == Strings.minUnit {
            self.reminderBeforeValue = 15
            self.reminderOption = .fifteenMinBefore
        }
        else if interval == 30 && unit == Strings.minUnit {
            self.reminderBeforeValue = 30
            self.reminderOption = .thirtyMinBefore
        }
        else {
            self.reminderBeforeValue = interval ?? 15
            self.reminderOption = .custom
        }
    }
    
    func setUnit(intervalType: Int?) {
        if let type = intervalType {
            switch type {
            case 1:
                self.reminderBeforeUnit = Strings.minUnit
            case 2:
                self.reminderBeforeUnit = Strings.hourUnit
            case 3:
                self.reminderBeforeUnit = Strings.dayUnit
            case 4:
                self.reminderBeforeUnit = Strings.weekUnit
            case 5:
                self.reminderBeforeUnit = Strings.monthUnit
            case 6:
                self.reminderBeforeUnit = Strings.yearUnit
            default:
                break
            }
        }
    }
    
    func setReminderBefore(option: ReminderOption) {
        self.reminderOption = option
        switch option {
        case .fiveMinBefore:
            self.reminderBeforeValue = 5
            self.reminderBeforeUnit = Strings.minUnit
        case .fifteenMinBefore:
            self.reminderBeforeValue = 15
            self.reminderBeforeUnit = Strings.minUnit
        case .thirtyMinBefore:
            self.reminderBeforeValue = 30
            self.reminderBeforeUnit = Strings.minUnit
        case .oneHourBefore:
            self.reminderBeforeValue = 1
            self.reminderBeforeUnit = Strings.hourUnit
        case .oneDayBefore:
            self.reminderBeforeValue = 1
            self.reminderBeforeUnit = Strings.dayUnit
        case .oneWeekBefore:
            self.reminderBeforeValue = 1
            self.reminderBeforeUnit = Strings.weekUnit
        case .oneMonthBefore:
            self.reminderBeforeValue = 1
            self.reminderBeforeUnit = Strings.monthUnit
        case .oneYearBefore:
            self.reminderBeforeValue = 1
            self.reminderBeforeUnit = Strings.monthUnit
        case .custom:
            break
        default:
            break
        }
    }
    
    func setReminderOption(_ option: ReminderOption) {
        self.reminderOption = option
    }
    
    func setReminderUnit(_ unit: String) {
        self.reminderBeforeUnit = unit
    }
    
    func setReminderBeforeValue(_ value: Int) {
        self.reminderBeforeValue = value
    }
    
    func setInitDefaultReminder() {
        self.reminderBeforeValue = 15
        self.reminderBeforeUnit = Strings.minUnit
        self.reminderOption = .fifteenMinBefore
    }
    
    func readReminderNumericValueParameter() -> [String: Any]? {
        var remimderParameter: [String: Any] = [:]
        if let date = self.reminderTime.toDateStrimg(withFormat: DateFormatters.HHCMMCSSSA), self.isAllDayReminder {
            remimderParameter["startTime"] = date.stringFromDate(format: DateFormatters.HHCMMCSS)
        }
        else {
            remimderParameter["startTime"] = Strings.empty
        }
        remimderParameter["intrvl"] = self.readStringInterval()
        remimderParameter["intrvlType"] = self.readStringIntervalType()
        remimderParameter["emailNotification"] = !self.readEmailNotification()
        remimderParameter["emailNotificationBody"] = self.readEmailNotificationBody()
        return remimderParameter
    }
    
    func readIsAllDayEvent() -> Bool {
        return self.isAllDayReminder
    }
}
