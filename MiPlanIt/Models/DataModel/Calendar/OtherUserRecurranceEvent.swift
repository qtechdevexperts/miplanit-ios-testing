//
//  OtherUserRecurranceEvent.swift
//  MiPlanIt
//
//  Created by Febin Paul on 18/06/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation
// import RRuleSwift
import EventKit

class OtherUserRecurranceEvent {
    
    var dayOfMonth: Double = 0
    var daysOfWeek: String = Strings.empty
    var endDate: String = Strings.empty
    var firstDayOfWeek: String = Strings.empty
    var index: String = Strings.empty
    var interval: Double = 0
    var month: Double = 0
    var numberOfOccurrences: Double = 0
    var patternType: String = Strings.empty
    var rangeType: String = Strings.empty
    var rule: String = Strings.empty
    var startDate: String = Strings.empty
    var recurrenceTimeZone: String = Strings.empty
    
    init(with event: [String: Any]) {
        if let pattern = event["pattern"] as? [String: Any] {
            self.dayOfMonth = pattern["dayOfMonth"] as? Double ?? 0
            self.firstDayOfWeek = pattern["firstDayOfWeek"] as? String ?? Strings.empty
            self.index = pattern["index"] as? String ?? Strings.empty
            self.interval = pattern["interval"] as? Double ?? 0
            self.month = pattern["month"] as? Double ?? 0
            self.patternType = pattern["type"] as? String ?? Strings.empty
            if let daysOfWeek = pattern["daysOfWeek"] as? [String]{
                self.daysOfWeek = daysOfWeek.joined(separator: ",")
            }
        }
        if let range = event["range"] as? [String: Any] {
            self.endDate = range["endDate"] as? String ?? Strings.empty
            self.numberOfOccurrences = range["numberOfOccurrences"] as? Double ?? 0
            self.startDate = range["startDate"] as? String ?? Strings.empty
            self.rangeType = range["type"] as? String ?? Strings.empty
            self.recurrenceTimeZone = range["recurrenceTimeZone"] as? String ?? Strings.empty
        }
    }
    
    init(with rule: String) {
        self.rule = rule
    }
    
    func readRuleOfEvent(_ event: OtherUserEvent) -> String {
        if !self.rule.isEmpty {
            return self.rule
        }
        else {
            let ruleString = self.createRuleForOutlookOfEvent(event)
            self.rule = ruleString
            return ruleString
        }
    }
    
    func readAllAvailableDates(from: Date, to: Date, event: OtherUserEvent) -> [Date]? {
        let ruleString = self.readRuleOfEvent(event)
        return ruleString.readOccurenceBetween(from: from, to: to, startDate: event.readOrginalUserStartDateTime(), timeZone: self.readTimeZoneOfEvent(event))
    }
    
    func readTimeZoneOfEvent(_ event: OtherUserEvent) -> TimeZone? {
        if let calendar = event.readMainCalendar(), (calendar.calendarType == 1 || calendar.calendarType == 3) {
            if let timezone = event.readTimeZone() {
                return timezone.identifier == "UTC" ? TimeZone.current : timezone
            }
        }
        return nil
    }
    
    func readEndDateOfEvent(_ event: OtherUserEvent) -> Date? {
        let ruleString = self.readRuleOfEvent(event)
        if ruleString.contains("UNTIL"), let lastDate = ruleString.components(separatedBy: "UNTIL=").last, let endDate = lastDate.components(separatedBy: ";").first {
            if let timeZone = self.readTimeZoneOfEvent(event), let convertedDate = endDate.stringToDate(formatter: DateFormatters.YYYYMMDDTHHMMSSSZ, timeZone: TimeZone(abbreviation: "UTC")!) {
                return convertedDate.convertTimeZone(timeZone, to: TimeZone.current).endOfDay
            }
            if let convertedDate = endDate.stringToDate(formatter: DateFormatters.YYYYMMDDTHHMMSSSZ) {
                return convertedDate.endOfDay
            }
            return endDate.stringToDate(formatter: DateFormatters.YYYMMDD)?.endOfDay
        }
        else if ruleString.contains("COUNT") {
          //return RecurrenceRule(rruleString: ruleString)?.allOccurrences().last?.endOfDay
          return nil
        }
        else {
            return nil
        }
    }
    
    func createRuleForOutlookOfEvent(_ event: OtherUserEvent) -> String {
        var recurrenceRule = RecurrenceRule(frequency: .daily)
        recurrenceRule.frequency = self.patternType.getfrequencyFromString()
        if self.interval > 0 {
            recurrenceRule.interval = Int(self.interval)
        }
        recurrenceRule.firstDayOfWeek = self.firstDayOfWeek.getfirstDayofWeekFromString()
        
        
        var days = 0
        if let date = self.startDate.stringToDate(formatter: DateFormatters.YYYYHMMMHDD) {
            recurrenceRule.startDate = date
            days = self.getTimeDifference(recurrenceRule.startDate, startDateTime: event.readStartDateTime())

        }
        
        switch self.rangeType {
        case "endDate":
            if let date = self.endDate.stringToDate(formatter: DateFormatters.YYYYHMMMHDD)?.endOfDay {
                recurrenceRule.recurrenceEnd = EKRecurrenceEnd(end: date.adding(days: days))
            }
        case "numbered":
            if self.numberOfOccurrences > 0 {
                recurrenceRule.recurrenceEnd = EKRecurrenceEnd(occurrenceCount: Int(self.numberOfOccurrences))
            }
        default:
            break
        }
        if self.month > 0 {
            recurrenceRule.bymonth = [Int(self.month)]
        }
        
        if self.dayOfMonth > 0 {
            recurrenceRule.bymonthday = [Int(self.dayOfMonth)]
        }
        
        if !self.daysOfWeek.isEmpty {
            recurrenceRule.byweekday = daysOfWeek.components(separatedBy: ",").map({ return $0.getfirstDayofWeekFromString()})
        }
        return recurrenceRule.toRRuleString()
    }
    
    func getTimeDifference(_ startDate: Date, startDateTime: Date) -> Int {
        return startDate.initialHour().daysBetweenDate(toDate: startDateTime.initialHour())
    }
    
    func findIntervalInRuleOfEvent(_ event: OtherUserEvent) -> String {
        if let rrRuleObject = RecurrenceRule(rruleString: self.readRuleOfEvent(event)) {
            return rrRuleObject.interval > 1 ? "\(rrRuleObject.interval)" : Strings.empty
        }
        return Strings.empty
    }
    
    func getByMonthOfEvent(_ event: OtherUserEvent) -> [String] {
        if let rrRuleObject = RecurrenceRule(rruleString: self.readRuleOfEvent(event)) {
            return rrRuleObject.bymonth.map({ $0.getMonth() })
        }
        return []
    }
    
    func getSetPositionOfEvent(_ event: OtherUserEvent) -> [String] {
        if let rrRuleObject = RecurrenceRule(rruleString: self.readRuleOfEvent(event)) {
            return rrRuleObject.bysetpos.map({ $0.getSetPosition() })
        }
        return []
    }
    
    func getByDayOfEvent(_ event: OtherUserEvent) -> [String] {
        if let rrRuleObject = RecurrenceRule(rruleString: self.readRuleOfEvent(event)) {
            return rrRuleObject.byweekday.map({ $0.rawValue.getWeekDay() })
        }
        return []
    }
    
    func getByMonthDayOfEvent(_ event: OtherUserEvent) -> [String] {
        if let rrRuleObject = RecurrenceRule(rruleString: self.readRuleOfEvent(event)) {
            return rrRuleObject.bymonthday.map({ "\($0)" })
        }
        return []
    }
    
    func getRepeatMonthyStringOfEvent(_ event: OtherUserEvent) -> String {
        var repeatString = Strings.empty
        let interval = self.findIntervalInRuleOfEvent(event)
        repeatString += (interval.isEmpty ? Strings.empty : "every \(interval)" )
        let myMonth = self.getByMonthOfEvent(event)
        repeatString += !interval.isEmpty ? (" months"+(myMonth.isEmpty ? Strings.empty : " in")) : (myMonth.isEmpty ? " Monthly" : Strings.empty)
        repeatString += myMonth.isEmpty ? Strings.empty : " \(myMonth.joined(separator: ","))"
        let myPosition = self.getSetPositionOfEvent(event)
        repeatString += myPosition.isEmpty ? Strings.empty : " on \(myPosition.joined(separator: ","))"
        let byDay = self.getByDayOfEvent(event)
        repeatString += byDay.isEmpty ? Strings.empty : " \(byDay.joined(separator: ","))"
        if byDay.isEmpty {
            let byMonthDay = self.getByMonthDayOfEvent(event)
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
    
    
    func getRepeatWeeklyStringOfEvent(_ event: OtherUserEvent) -> String {
        var repeatString = Strings.empty
        let interval = self.findIntervalInRuleOfEvent(event)
        repeatString += (interval.isEmpty ? Strings.empty : "every \(interval) Weeks " )
        if let rrRuleObject = RecurrenceRule(rruleString: self.readRuleOfEvent(event)) {
            let weekDays = self.getWeekDays(weekDays: rrRuleObject.byweekday.map({$0.rawValue}))
            let everyWeek = interval.isEmpty ? Strings.weekly+" on" : "on"
            repeatString += weekDays.isEmpty ? "\(Strings.weekly) " : "\(everyWeek) "+( weekDays.joined(separator: ",")+" ")
        }
        return repeatString
    }
}
