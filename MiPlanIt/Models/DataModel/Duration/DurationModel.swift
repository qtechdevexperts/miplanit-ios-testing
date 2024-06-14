//
//  DurationModel.swift
//  MiPlanIt
//
//  Created by Febin Paul on 26/03/21.
//  Copyright © 2021 Arun. All rights reserved.
//

import Foundation

class DurationModel {
    
    var sourceScreen: SourceScreen = .event
    var durationValue: Int = 15
    var durationUnit: String = Strings.minUnit
    var durationOption: ReminderOption = .fifteenMinBefore
    
    init() {
    }
    
    init(with model: DurationModel?) {
        guard let durationModel = model else { return }
        self.sourceScreen = durationModel.sourceScreen
        self.durationValue = durationModel.durationValue
        self.durationUnit = durationModel.durationUnit
        self.durationOption = durationModel.durationOption
    }
    
    init(duartion: Double, duartionType: Double) {
        if duartionType == 1 {
            if duartion == 15 {
                self.durationValue = 15
                self.durationOption = .fifteenMinBefore
            }
            else if duartion == 30 {
                self.durationValue = 30
                self.durationOption = .thirtyMinBefore
            }
            else if duartion == 60 {
                self.durationValue = 60
                self.durationOption = .oneHourBefore
            }
            else if duartion == 120 {
                self.durationValue = 120
                self.durationOption = .twoHourBefore
            }
            else {
                self.durationValue = Int(duartion)
                self.durationOption = .custom
            }
        }
        else if duartionType == 2 {
            self.durationUnit = Strings.hourUnit
            self.durationOption = .custom
            self.durationValue = Int(duartion/60.0)
        }
    }
    
    func readDurationValue() -> Int {
        return self.durationUnit == Strings.minUnit ? self.durationValue : (self.durationValue*60)
    }
    
    
    func setReminderValueAndUnit(_ planItReminder: PlanItReminder) {
        if planItReminder.readInterval() != 0.0 {
            if planItReminder.readInterval() > 59 {
                if planItReminder.readInterval().truncatingRemainder(dividingBy: 60) == 0 && planItReminder.readInterval() <= 1380 {
                    self.durationValue = Int(planItReminder.readInterval()/60.0)
                    self.durationOption = self.durationValue == 1 ? .oneHourBefore : .custom
                    self.durationUnit = Strings.hourUnit
                }
                else if planItReminder.readInterval().truncatingRemainder(dividingBy: 1440) == 0 && planItReminder.readInterval() > 1380 && planItReminder.readInterval() <= 8640 {
                    self.durationValue = Int(planItReminder.readInterval()/1440)
                    self.durationOption = self.durationValue == 1 ? .oneDayBefore : .custom
                    self.durationUnit = Strings.dayUnit
                }
                else if planItReminder.readInterval().truncatingRemainder(dividingBy: 10080) == 0 && planItReminder.readInterval() > 8640 && planItReminder.readInterval() <= 514080 {
                    self.durationValue = Int(planItReminder.readInterval()/10080)
                    self.durationOption = self.durationValue == 1 ? .oneWeekBefore : .custom
                    self.durationUnit = Strings.weekUnit
                }
                else {
                    self.durationValue = Int(planItReminder.readInterval())
                    self.durationOption = .custom
                }
            }
            else {
                if planItReminder.readInterval() == 5 {
                    self.durationValue = 5
                    self.durationOption = .fiveMinBefore
                }
                else if planItReminder.readInterval() == 15 {
                    self.durationValue = 15
                    self.durationOption = .fifteenMinBefore
                }
                else if planItReminder.readInterval() == 30 {
                    self.durationValue = 30
                    self.durationOption = .thirtyMinBefore
                }
                else if planItReminder.readInterval() == 60 {
                    self.durationValue = 60
                    self.durationOption = .oneHourBefore
                }
                else if planItReminder.readInterval() == 120 {
                    self.durationValue = 120
                    self.durationOption = .twoHourBefore
                }
                else {
                    self.durationValue = Int(planItReminder.readInterval())
                    self.durationOption = .custom
                }
            }
        }
    }
    
    func readStringInterval() -> String {
        return String(self.durationValue)
    }
    
    func readStringIntervalType() -> String {
        switch self.durationUnit {
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
        let unit = self.durationUnit
        if interval == 1 {
            self.durationValue = 1
            if unit == Strings.hourUnit {
                self.durationOption = .oneHourBefore
            }
            else if unit == Strings.dayUnit {
                self.durationOption = .oneDayBefore
            }
            else if unit == Strings.weekUnit {
                self.durationOption = .oneWeekBefore
            }
            else if unit == Strings.monthUnit {
                self.durationOption = .oneMonthBefore
            }
            else if unit == Strings.yearUnit {
                self.durationOption = .oneYearBefore
            }
        }
        else if interval == 5 && unit == Strings.minUnit {
            self.durationValue = 5
            self.durationOption = .fiveMinBefore
        }
        else if interval == 15 && unit == Strings.minUnit {
            self.durationValue = 15
            self.durationOption = .fifteenMinBefore
        }
        else if interval == 30 && unit == Strings.minUnit {
            self.durationValue = 30
            self.durationOption = .thirtyMinBefore
        }
        else if interval == 60 && unit == Strings.minUnit {
            self.durationValue = 60
            self.durationOption = .oneHourBefore
        }
        else if interval == 120 && unit == Strings.minUnit {
            self.durationValue = 120
            self.durationOption = .twoHourBefore
        }
        else {
            self.durationValue = interval ?? 15
            self.durationOption = .custom
        }
    }
    
    func setUnit(intervalType: Int?) {
        if let type = intervalType {
            switch type {
            case 1:
                self.durationUnit = Strings.minUnit
            case 2:
                self.durationUnit = Strings.hourUnit
            case 3:
                self.durationUnit = Strings.dayUnit
            case 4:
                self.durationUnit = Strings.weekUnit
            case 5:
                self.durationUnit = Strings.monthUnit
            case 6:
                self.durationUnit = Strings.yearUnit
            default:
                break
            }
        }
    }
    
    func setReminderBefore(option: ReminderOption) {
        self.durationOption = option
        switch option {
        case .fiveMinBefore:
            self.durationValue = 5
            self.durationUnit = Strings.minUnit
        case .fifteenMinBefore:
            self.durationValue = 15
            self.durationUnit = Strings.minUnit
        case .thirtyMinBefore:
            self.durationValue = 30
            self.durationUnit = Strings.minUnit
        case .oneHourBefore:
            self.durationValue = 60
            self.durationUnit = Strings.minUnit
        case .twoHourBefore:
            self.durationValue = 120
            self.durationUnit = Strings.minUnit
        case .oneWeekBefore:
            self.durationValue = 1
            self.durationUnit = Strings.weekUnit
        case .oneMonthBefore:
            self.durationValue = 1
            self.durationUnit = Strings.monthUnit
        case .oneYearBefore:
            self.durationValue = 1
            self.durationUnit = Strings.monthUnit
        case .custom:
            break
        default:
            break
        }
    }
    
    func setDurationOption(_ option: ReminderOption) {
        self.durationOption = option
    }
    
    func setDurationUnit(_ unit: String) {
        self.durationUnit = unit
    }
    
    func setDurationValue(_ value: Int) {
        self.durationValue = value
    }
    
    func setInitDefaultReminder() {
        self.durationValue = 15
        self.durationUnit = Strings.minUnit
        self.durationOption = .fifteenMinBefore
    }
    
    func readDurationInSeconds() -> Int {
        switch self.durationUnit {
        case Strings.minUnit:
            return self.durationValue*60
        case Strings.hourUnit:
            return self.durationValue*60*60
        default:
            return 15
        }
    }
    
    func readDurationTypeInt() -> Int {
        switch self.durationUnit {
        case Strings.minUnit:
            return 1
        default:
            return 1
        }
    }
    
}
