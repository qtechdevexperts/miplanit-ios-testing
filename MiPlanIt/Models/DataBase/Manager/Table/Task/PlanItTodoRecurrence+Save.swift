//
//  PlanItTodoRecurrence+Save.swift
//  MiPlanIt
//
//  Created by Febin Paul on 06/07/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation
// import RRuleSwift
import EventKit

extension PlanItTodoRecurrence {
    
    func readRule() -> String {
        if let ruleString = self.rule, !ruleString.isEmpty {
            return ruleString
        }
        return Strings.empty
    }
    
    func readEndDate() -> Date? {
        let ruleString = self.readRule()
        if ruleString.contains("UNTIL"), let lastDate = ruleString.components(separatedBy: "UNTIL=").last, let endDate = lastDate.components(separatedBy: ";").first {
            if let convertedDate = endDate.stringToDate(formatter: DateFormatters.YYYYMMDDTHHMMSSSZ) {
                return convertedDate.endOfDay
            }
            return endDate.stringToDate(formatter: DateFormatters.YYYMMDD)?.endOfDay
        }
        else if ruleString.contains("COUNT") {
            return RecurrenceRule(rruleString: ruleString)?.allOccurrences().last?.endOfDay
        }
        else {
            return nil
        }
    }
    
    func readEndDateFromStartBasedOnFrequency(_ start: Date, using mainRule: RecurrenceRule?) -> Date {
        guard let recurrenceRule = mainRule else { return start.adding(days: 1).adding(seconds: -1) }
        switch recurrenceRule.frequency {
        case .weekly:
            return start.adding(days: 7)
        case .monthly:
            return start.addMonth(n: 1)
        case .yearly:
            return start.adding(years: 1)
        default:
            return start.adding(days: 1).adding(seconds: -1)
        }
    }
    
    func readAllAvailableDates(from: Date, to: Date? = nil) -> [Date]? {
        let ruleString = self.readRule()
        var recurrenceRule = RecurrenceRule(rruleString: ruleString)
        if let startDate = self.todo?.dueDate {
            recurrenceRule?.startDate = startDate
        }
        guard let endDate = to else {
            return ruleString.readOccurenceBetween(from: from, to: self.readEndDateFromStartBasedOnFrequency(from, using: recurrenceRule), startDate: self.todo?.dueDate)
        }
        return ruleString.readOccurenceBetween(from: from, to: endDate, startDate: self.todo?.dueDate)
    }
    
    func deleteItSelf(withHardSave status: Bool = true) {
        self.managedObjectContext?.delete(self)
        if status { try? self.managedObjectContext?.save() }
    }
    
    func findIntervalInRule() -> String {
        if let rrRuleObject = RecurrenceRule(rruleString: self.readRule()) {
            return rrRuleObject.interval > 1 ? "\(rrRuleObject.interval)" : Strings.empty
        }
        return Strings.empty
    }
    
    func getByMonth() -> [String] {
        if let rrRuleObject = RecurrenceRule(rruleString: self.readRule()) {
            return rrRuleObject.bymonth.map({ $0.getMonth() })
        }
        return []
    }
    
    func getSetPosition() -> [String] {
        if let rrRuleObject = RecurrenceRule(rruleString: self.readRule()) {
            return rrRuleObject.bysetpos.map({ $0.getSetPosition() })
        }
        return []
    }
    
    func getByDay() -> [String] {
        if let rrRuleObject = RecurrenceRule(rruleString: self.readRule()) {
            return rrRuleObject.byweekday.map({ $0.rawValue.getWeekDay() })
        }
        return []
    }
    
    func getByMonthDay() -> [String] {
        if let rrRuleObject = RecurrenceRule(rruleString: self.readRule()) {
            return rrRuleObject.bymonthday.map({ "\($0)" })
        }
        return []
    }
    
    func getRepeatMonthyString() -> String {
        var repeatString = Strings.empty
        let interval = self.findIntervalInRule()
        repeatString += (interval.isEmpty ? Strings.empty : "every \(interval)" )
        let myMonth = self.getByMonth()
        repeatString += !interval.isEmpty ? (" months"+(myMonth.isEmpty ? Strings.empty : " in")) : (myMonth.isEmpty ? " Monthly" : Strings.empty)
        repeatString += myMonth.isEmpty ? Strings.empty : " \(myMonth.joined(separator: ","))"
        let myPosition = self.getSetPosition()
        repeatString += myPosition.isEmpty ? Strings.empty : " on \(myPosition.joined(separator: ","))"
        let byDay = self.getByDay()
        repeatString += byDay.isEmpty ? Strings.empty : " \(byDay.joined(separator: ","))"
        if byDay.isEmpty {
            let byMonthDay = self.getByMonthDay()
            repeatString += byMonthDay.isEmpty ? Strings.empty : " on \(byMonthDay.joined(separator: ","))"
        }
        return repeatString
    }
    
    func getWeekDays(weekDays: [Int]) -> [String] {
        var weekDayItem: [String] = []
        weekDays.forEach { (int) in
            weekDayItem.append(int.getWeekDay())
        }
        return weekDayItem
    }
    
    func getRepeatWeeklyString() -> String {
        var repeatString = Strings.empty
        let interval = self.findIntervalInRule()
        repeatString += (interval.isEmpty ? Strings.empty : "every \(interval) Weeks " )
        if let rrRuleObject = RecurrenceRule(rruleString: self.readRule()) {
            let weekDays = self.getWeekDays(weekDays: rrRuleObject.byweekday.map({$0.rawValue}))
            let everyWeek = interval.isEmpty ? Strings.weekly+" on"  : "on"
            repeatString += weekDays.isEmpty ? "\(Strings.weekly) " : "\(everyWeek) "+( weekDays.joined(separator: ",")+" ")
        }
        return repeatString
    }
}
