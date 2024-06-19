//
//  PlanItEventRecurrence+Save.swift
//  MiPlanIt
//
//  Created by Arun on 17/06/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation
//// import RRuleSwift
import EventKit

extension PlanItEventRecurrence {
    
    func readDaysOfWeek() -> String { return self.daysOfWeek ?? Strings.empty }
    func readDayOfMonth() -> Double { return self.dayOfMonth }
    func readFirstDayOfWeek() -> String { return self.firstDayOfWeek ?? Strings.empty }
    func readIndex() -> String { return self.index ?? Strings.empty }
    func readInterval() -> Double { return self.interval }
    func readMonth() -> Double { return self.month }
    func readNumberOfOccurrences() -> Double { return self.numberOfOccurrences }
    func readPatternType() -> String { return self.patternType ?? Strings.empty }
    func readRangeType() -> String { return self.rangeType ?? Strings.empty }
    func readStartDate() -> String { return self.startDate ?? Strings.empty }
    
    func readRule() -> String {
        if let ruleString = self.rule, !ruleString.isEmpty {
            return ruleString
        }
        else {
            let ruleString = self.createRuleForOutlook()
            self.rule = ruleString
            return ruleString
        }
    }
    
    func readAllAvailableDates(from: Date, to: Date) -> [Date]? {
        let ruleString = self.readRule()
        return ruleString.readOccurenceBetween(from: from, to: to, startDate: self.event?.readOrginalUserStartDateTime(), timeZone: self.readTimeZoneOfEvent())
    }
    
    func readTimeZoneOfEvent() -> TimeZone? {
        if let calendar = self.event?.readEventCalendar(), (calendar.readValueOfCalendarType() == "1" || calendar.readValueOfCalendarType() == "3") {
            if let timezone = self.event?.readTimeZone() {
                return timezone.identifier == "UTC" ? TimeZone.current : timezone
            }
        }
        return nil
    }
    
    func readEndDate() -> Date? {
        let ruleString = self.readRule()
        if ruleString.contains("UNTIL"), let lastDate = ruleString.components(separatedBy: "UNTIL=").last, let endDate = lastDate.components(separatedBy: ";").first {
            if endDate.contains("0001-01-01") {
                return nil
            }
            if let timeZone = self.readTimeZoneOfEvent(), let convertedDate = endDate.stringToDate(formatter: DateFormatters.YYYYMMDDTHHMMSSSZ, timeZone: TimeZone(abbreviation: "UTC")!) {
                return convertedDate.convertTimeZone(timeZone, to: TimeZone.current).endOfDay
            }
            if let convertedDate = endDate.stringToDate(formatter: DateFormatters.YYYYMMDDTHHMMSSSZ) {
                return convertedDate.endOfDay
            }
            return endDate.stringToDate(formatter: DateFormatters.YYYMMDD)?.endOfDay
        }
        else if ruleString.contains("COUNT") {
          //  return RecurrenceRule(rruleString: ruleString)?.allOccurrences().last?.endOfDay
          return nil
        }
        else {
            return nil
        }
    }
    
    func findSetPosition(frequency: String, indexValue: String? = nil) -> Int? {
        if let index = indexValue, frequency.uppercased() == "RELATIVEMONTHLY" {
            switch index.lowercased() {
            case "first":
                return 1
            case "second":
                return 2
            case "third":
                return 3
            case "fourth":
                return 4
            case "last":
                return -1
            default:
                return nil
            }
        }
        return nil
    }
    
    func createRuleForOutlook() -> String {
        var recurrenceRule = RecurrenceRule(frequency: .daily)
        if let frequency = self.patternType {
            recurrenceRule.frequency = frequency.getfrequencyFromString()
            if let setPosition = findSetPosition(frequency: frequency, indexValue: self.index) {
                recurrenceRule.bysetpos = [setPosition]
            }
        }
        if self.interval > 0 {
            recurrenceRule.interval = Int(self.interval)
        }
        if let firstDayOfWeek = self.firstDayOfWeek {
            recurrenceRule.firstDayOfWeek = firstDayOfWeek.getfirstDayofWeekFromString()
        }
        var days = 0
        if let date = self.startDate?.stringToDate(formatter: DateFormatters.YYYYHMMMHDD) {
            recurrenceRule.startDate = date
            days = self.getTimeDifference(recurrenceRule.startDate)
        }
        if let rangeType = self.rangeType {
            switch rangeType {
            case "endDate":
                if let date = self.endDate?.stringToDate(formatter: DateFormatters.YYYYHMMMHDD)?.endOfDay {
                    recurrenceRule.recurrenceEnd = EKRecurrenceEnd(end: date.adding(days: days))
                }
            case "numbered":
                if self.numberOfOccurrences > 0 {
                    recurrenceRule.recurrenceEnd = EKRecurrenceEnd(occurrenceCount: Int(self.numberOfOccurrences))
                }
            default:
                break
            }
        }
        if self.month > 0 {
            recurrenceRule.bymonth = [Int(self.month)]
        }
        
        if self.dayOfMonth > 0 {
            recurrenceRule.bymonthday = [Int(self.dayOfMonth)]
        }
        
        if let daysOfWeek = self.daysOfWeek, !daysOfWeek.isEmpty {
            recurrenceRule.byweekday = daysOfWeek.components(separatedBy: ",").map({ return $0.getfirstDayofWeekFromString()})
        }
        return recurrenceRule.toRRuleString()
    }
    
    func getTimeDifference(_ startDate: Date) -> Int {
        guard let startDateTime = self.event?.readStartDateTime() else { return 0 }
        return startDate.initialHour().daysBetweenDate(toDate: startDateTime.initialHour())
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
        repeatString += myPosition.isEmpty ? Strings.empty : " on the \(myPosition.joined(separator: ","))"
        let byDay = self.getByDay()
        repeatString += byDay.isEmpty ? Strings.empty : "\(myPosition.isEmpty ? " on " : Strings.empty) \(byDay.joined(separator: ","))"
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
