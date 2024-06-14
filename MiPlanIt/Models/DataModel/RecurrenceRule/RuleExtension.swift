//
//  RuleExtension.swift
//  MiPlanIt
//
//  Created by Arun on 27/09/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation
// import RRuleSwift
import EventKit

extension Dictionary {
    
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
    
    func readOccurenceBetween(from: Date, to: Date, startDate: Date?) -> [Date]? {
        guard let recurrence = self as? [String: Any] else {return nil}
        var recurrenceRule = RecurrenceRule(frequency: .daily)
        if let pattern = recurrence["pattern"] as? [String: Any] {
            let dayOfMonth = pattern["dayOfMonth"] as? Double ?? 0
            let interval = pattern["interval"] as? Double ?? 0
            let month = pattern["month"] as? Double ?? 0
            if let daysOfWeek = pattern["daysOfWeek"] as? [String], !daysOfWeek.isEmpty{
                recurrenceRule.byweekday = daysOfWeek.map({ return $0.getfirstDayofWeekFromString()})
            }
            if let frequency = pattern["type"] as? String {
                recurrenceRule.frequency = frequency.getfrequencyFromString()
                if let setPosition = findSetPosition(frequency: frequency, indexValue: pattern["index"] as? String) {
                    recurrenceRule.bysetpos = [setPosition]
                }
            }
            if interval > 0 {
                recurrenceRule.interval = Int(interval)
            }
            
            if let firstDayOfWk = pattern["firstDayOfWeek"] as? String {
                recurrenceRule.firstDayOfWeek = firstDayOfWk.getfirstDayofWeekFromString()
            }
            if month > 0 {
                recurrenceRule.bymonth = [Int(month)]
            }
            
            if dayOfMonth > 0 {
                recurrenceRule.bymonthday = [Int(dayOfMonth)]
            }
        }
        if let range = recurrence["range"] as? [String: Any] {
            let endDate = range["endDate"] as? String
            let numberOfOccurrences = range["numberOfOccurrences"] as? Int ?? 0
            let startDateObj = range["startDate"] as? String
            var days = 0
            if let date = startDateObj?.stringToDate(formatter: DateFormatters.YYYYHMMMHDD) {
                recurrenceRule.startDate = date
                days = self.getTimeDifference(recurrenceRule.startDate, eventStartDate: startDate)
            }
            if let rangeType = range["type"] as? String {
                switch rangeType {
                case "endDate":
                    if let date = endDate?.stringToDate(formatter: DateFormatters.YYYYHMMMHDD)?.endOfDay {
                        recurrenceRule.recurrenceEnd = EKRecurrenceEnd(end: date.adding(days: days))
                    }
                case "numbered":
                    if numberOfOccurrences > 0 {
                        recurrenceRule.recurrenceEnd = EKRecurrenceEnd(occurrenceCount: numberOfOccurrences)
                    }
                default:
                    break
                }
            }
        }
        return recurrenceRule.toRRuleString().readOccurenceBetween(from: from, to: to, startDate: startDate)
    }
    
    func getTimeDifference(_ startDate: Date, eventStartDate: Date?) -> Int {
        guard let startDateTime = eventStartDate else { return 0 }
        return startDate.initialHour().daysBetweenDate(toDate: startDateTime.initialHour())
    }
}

extension String {
    
    func readOccurenceBetween(from: Date, to: Date, startDate: Date?, timeZone: TimeZone? = nil) -> [Date]? {
        var startingDate = self.readRuleStartDate()
        if let newstartDate = startDate {
            startingDate = newstartDate
        }
        if startingDate == nil {
            startingDate = Date().initialHour()
        }
        let readByDayAndPos = self.readRuleDaysAndItsPositions()
        let ruleCount = self.readRuleCount()
        let ruleObj = rrule(frequency: self.readRuleFrequency(), dtstart: startingDate, until: self.readRuleEndDate(using: timeZone), count: ruleCount, interval: self.readRuleIntervals(), wkst: self.readRuleWeekStart(), bysetpos: readByDayAndPos.positions, bymonth: self.readRuleByMonth(), bymonthday: self.readRuleByMonthDay(), byyearday: self.readRuleByYearDay(), byweekno:self.readRuleByWeekNo(), byweekday: readByDayAndPos.days)
        if ruleCount != nil {
            return ruleObj.getOccurrences().filter({ return $0 >= from && $0 <= to })
        }
        return ruleObj.getOccurrencesBetween(beginDate: from, endDate: to)
    }
    
    
    func readRuleFrequency() -> RruleFrequency {
        let freqRule = self.slice(from: "FREQ=", to: ";") ?? self.slice(from: "FREQ=")
        if let repeatValue = freqRule {
            switch repeatValue {
            case "DAILY":
                return .daily
            case "WEEKLY":
                return .weekly
            case "MONTHLY", "RELATIVEMONTHLY", "ABSOLUTEMONTHLY":
                return .monthly
            case "YEARLY":
                 return .yearly
            default:
                break
            }
        }
        return .daily
    }
    
    func readRuleIntervals() -> Int {
        let intervalRule = self.slice(from: "INTERVAL=", to: ";") ?? self.slice(from: "INTERVAL=")
        if let interval = intervalRule {
            return Int(interval) ?? 1
        }
        return 1
    }
    
    func readRuleStartDate() -> Date? {
        let dtstrtRule = self.slice(from: "DTSTART=", to: ";") ?? self.slice(from: "DTSTART=")
        if let startDate = dtstrtRule {
            if let convertedDate = startDate.stringToDate(formatter: DateFormatters.YYYYMMDDTHHMMSSSZ) {
                return convertedDate.startOfDay
            }
            return startDate.stringToDate(formatter: DateFormatters.YYYMMDD)?.startOfDay
        }
        else {
            return nil
        }
    }
    
    func readRuleEndDate(using timezone: TimeZone?) -> Date? {
        let untilRule = self.slice(from: "UNTIL=", to: ";") ?? self.slice(from: "UNTIL=")
        if let endDate = untilRule {
            if let organizerTimeZone = timezone, let convertedDate = endDate.stringToDate(formatter: DateFormatters.YYYYMMDDTHHMMSSSZ, timeZone: TimeZone(abbreviation: "UTC")!) {
                return convertedDate.convertTimeZone(organizerTimeZone, to: TimeZone.current).endOfDay
            }
            if let convertedDate = endDate.stringToDate(formatter: DateFormatters.YYYYMMDDTHHMMSSSZ) {
                return convertedDate.endOfDay
            }
            return endDate.stringToDate(formatter: DateFormatters.YYYMMDD)?.endOfDay
        }
        else {
            return nil
        }
    }
    
    func readRuleCount() -> Int? {
        let countRule = self.slice(from: "COUNT=", to: ";") ?? self.slice(from: "COUNT=")
        if let count = countRule {
            return Int(count)
        }
        else {
            return nil
        }
    }
    
    func readRuleWeekStart() -> Int {
        let wkstRule = self.slice(from: "WKST=", to: ";") ?? self.slice(from: "WKST=")
        if let weekStart = wkstRule {
            return weekStart.readRuleDayIndex()
        }
        return 1
    }
    
    func readRuleDayIndex() -> Int {
        switch self {
            case "SU":
                return 1
            case "MO":
                return 2
            case "TU":
                return 3
            case "WE":
                return 4
            case "TH":
                return 5
            case "FR":
                return 6
            case "SA":
                return 7
            default:
                return 1
        }
    }
    
    func numberFromString() -> String? {
        return self.components(separatedBy: CharacterSet.decimalDigits.inverted).filter({ !$0.isEmpty }).first
    }
    
    func readRuleDaysAndItsPositions() -> (days: [Int], positions: [Int]) {
        var days: [Int] = []
        var positions: [Int] = []
        let byDayRule = self.slice(from: "BYDAY=", to: ";") ?? self.slice(from: "BYDAY=")
        if let weekStart = byDayRule {
            let daysPositions = weekStart.components(separatedBy: ",")
            for item in daysPositions {
                if let position = item.numberFromString(), let numberPosition = Int(position) {
                    let actualDay = item.replacingOccurrences(of: position, with: "")
                    days.append(actualDay.readRuleDayIndex())
                    positions.append(numberPosition)
                }
                else {
                    days.append(item.readRuleDayIndex())
                    positions.append(contentsOf: self.readRuleBYSETPOS())
                }
            }
        }
        return (days: days, positions: positions)
    }
    
    func readRuleBYSETPOS() -> [Int] {
        let setPosRule = self.slice(from: "BYSETPOS=", to: ";") ?? self.slice(from: "BYSETPOS=")
        if let bySetPosition = setPosRule {
            let positions = bySetPosition.components(separatedBy: ",")
            return positions.compactMap({ return Int($0) })
        }
        return []
    }
    
    func readRuleByMonthDay() -> [Int] {
        let monthDayRule = self.slice(from: "BYMONTHDAY=", to: ";") ?? self.slice(from: "BYMONTHDAY=")
        if let byMonthDay = monthDayRule {
            let positions = byMonthDay.components(separatedBy: ",")
            return positions.compactMap({ return Int($0) })
        }
        return []
    }
    
    func readRuleByWeekNo() -> [Int] {
        let weekNoRule = self.slice(from: "BYWEEKNO=", to: ";") ?? self.slice(from: "BYWEEKNO=")
        if let byWeekNo = weekNoRule {
            let positions = byWeekNo.components(separatedBy: ",")
            return positions.compactMap({ return Int($0) })
        }
        return []
    }
    
    
    func readRuleByYearDay() -> [Int] {
        let yearDayRule = self.slice(from: "BYYEARDAY=", to: ";") ?? self.slice(from: "BYYEARDAY=")
        if let byYearDay = yearDayRule {
            let positions = byYearDay.components(separatedBy: ",")
            return positions.compactMap({ return Int($0) })
        }
        return []
    }
    
    
    func readRuleByMonth() -> [Int] {
        let byMonthRule = self.slice(from: "BYMONTH=", to: ";") ?? self.slice(from: "BYMONTH=")
        if let byMonth = byMonthRule {
            let positions = byMonth.components(separatedBy: ",")
            return positions.compactMap({ return Int($0) })
        }
        return []
    }
}
