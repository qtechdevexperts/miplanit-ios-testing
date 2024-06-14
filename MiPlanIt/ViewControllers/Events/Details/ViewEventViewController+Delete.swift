//
//  ViewEventViewController+Delete.swift
//  MiPlanIt
//
//  Created by Arun on 24/06/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation
//import RRuleSwift
import EventKit

extension ViewEventViewController {
    
    func createDeleteRequestForEvent(_ type: RecursiveEditOption) -> [String: Any] {
        switch type {
        case .default:
            return self.defaultRequest()
        case .allEventInTheSeries:
            return self.allEventInTheSeriesRequest()
        case .thisPerticularEvent:
            return self.perticularEventRequest()
        case .allFutureEvent:
            return self.allFutureEventRequest()
        }
    }
    
    func defaultRequest() -> [String: Any] {
        var requestParams: [String: Any] = [:]
        var eventParams: [String: Any] = [:]
        eventParams["userId"] = Session.shared.readUserId()
        if let event = self.eventPlanOtherObject as? PlanItEvent {
            eventParams["eventId"] = event.readValueOfEventId()
            if !event.readRecurringEventId().isEmpty {
                eventParams["recurringEventId"] = event.readRecurringEventId()
            }
        }
        else if let event = self.eventPlanOtherObject as? OtherUserEvent {
            eventParams["eventId"] = event.eventId
            if !event.recurringEventId.isEmpty {
                eventParams["recurringEventId"] = event.recurringEventId
            }
        }
        requestParams["deletedEvents"] = [eventParams]
        return requestParams
    }
    
    func allEventInTheSeriesRequest() -> [String: Any] {
        var requestParams: [String: Any] = [:]
        var eventParams: [String: Any] = [:]
        eventParams["userId"] = Session.shared.readUserId()
        if let event = self.eventPlanOtherObject as? PlanItEvent {
            eventParams["eventId"] = event.readValueOfEventId()
        }
        else if let event = self.eventPlanOtherObject as? OtherUserEvent {
            eventParams["eventId"] = event.eventId
        }
        requestParams["deletedEvents"] = [eventParams]
        return requestParams
    }
    
    func perticularEventRequest() -> [String: Any] {
        var requestParams: [String: Any] = [:]
        var eventParams: [String: Any] = [:]
        eventParams["userId"] = Session.shared.readUserId()
        if let event = self.eventPlanOtherObject as? PlanItEvent {
            eventParams["calendar"] = event.readAllEventCalendars().map({ return ["calendarId": $0.calendarId.cleanValue(), "accessLevel": $0.accessLevel.cleanValue() ]})
            eventParams["notifyCalendar"] = event.readAllEventNotifyCalendars().map({ return ["calendarId": $0.calendarId.cleanValue(), "accessLevel": $0.accessLevel.cleanValue() ]})
            eventParams["recurringEventId"] = event.readValueOfEventId()
            eventParams["isOriginalAllDay"] = event.isAllDay
            if event.isAllDay {
                eventParams["originalStartTime"] = event.readStartDateTimeFromDate(self.dateEvent.startDate).stringFromDate(format: DateFormatters.YYYYHMMDDSHHMMSS)
            }
            else {
                eventParams["originalStartTime"] = event.readStartDateTimeFromDate(self.dateEvent.startDate).stringFromDate(format: DateFormatters.YYYYHMMDDSHHMMSS, timeZone: TimeZone(abbreviation: "UTC")!)
            }
        }
        if let event = self.eventPlanOtherObject as? OtherUserEvent {
            eventParams["recurringEventId"] = event.eventId
            if event.isAllDay {
                eventParams["originalStartTime"] = event.readStartDateTimeFromDate(self.dateEvent.startDate).stringFromDate(format: DateFormatters.YYYYHMMDDSHHMMSS)
            }
            else {
                eventParams["originalStartTime"] = event.readStartDateTimeFromDate(self.dateEvent.startDate).stringFromDate(format: DateFormatters.YYYYHMMDDSHHMMSS, timeZone: TimeZone(abbreviation: "UTC")!)
            }
        }
        requestParams["deletedEvents"] = [eventParams]
        return requestParams
    }
    
    func allFutureEventRequest() -> [String: Any] {
        var requestParams: [String: Any] = [:]
        var eventParams: [String: Any] = [:]
        eventParams["userId"] = Session.shared.readUserId()
        if let event = self.eventPlanOtherObject as? PlanItEvent {
            eventParams["eventId"] = event.readValueOfEventId()
            if let recurrence = event.recurrence, var recurrenceRule = RecurrenceRule(rruleString: recurrence.readRule()) {
                recurrenceRule.recurrenceEnd = EKRecurrenceEnd(end: event.readStartDateTimeFromDate(self.dateEvent.startDate).initialHour().adding(seconds: -1))
                recurrenceRule.startDate = event.readStartDateTime()
                eventParams["recurrence"] = [recurrenceRule.toRRuleString()]
            }
        }
        if let event = self.eventPlanOtherObject as? OtherUserEvent {
            eventParams["eventId"] = event.eventId
            if let recurrence = event.recurranceEvent, var recurrenceRule = RecurrenceRule(rruleString: recurrence.readRuleOfEvent(event)) {
                recurrenceRule.recurrenceEnd = EKRecurrenceEnd(end: event.readStartDateTimeFromDate(self.dateEvent.startDate).initialHour().adding(seconds: -1))
                recurrenceRule.startDate = event.readStartDateTime()
                eventParams["recurrence"] = [recurrenceRule.toRRuleString()]
            }
        }
        requestParams["deletedEvents"] = [eventParams]
        return requestParams
    }
}


public struct RecurrenceRule {
    /// The calendar of recurrence rule.
    public var calendar = Calendar.current

    /// The frequency of the recurrence rule.
    public var frequency: RecurrenceFrequency

    /// Specifies how often the recurrence rule repeats over the component of time indicated by its frequency. For example, a recurrence rule with a frequency type of RecurrenceFrequency.weekly and an interval of 2 repeats every two weeks.
    ///
    /// The default value of this property is 1.
    public var interval = 1

    /// Indicates which day of the week the recurrence rule treats as the first day of the week.
    ///
    /// The default value of this property is EKWeekday.monday.
    public var firstDayOfWeek: EKWeekday = .monday

    /// The start date of recurrence rule.
    ///
    /// The default value of this property is current date.
    public var startDate = Date()

    /// Indicates when the recurrence rule ends. This can be represented by an end date or a number of occurrences.
    public var recurrenceEnd: EKRecurrenceEnd?

    /// An array of ordinal integers that filters which recurrences to include in the recurrence rule’s frequency. Values can be from 1 to 366 and from -1 to -366.
    ///
    /// For example, if a bysetpos of -1 is combined with a RecurrenceFrequency.monthly frequency, and a byweekday of (EKWeekday.monday, EKWeekday.tuesday, EKWeekday.wednesday, EKWeekday.thursday, EKWeekday.friday), will result in the last work day of every month.
    ///
    /// Negative values indicate counting backwards from the end of the recurrence rule’s frequency.
    public var bysetpos = [Int]()

    /// The days of the year associated with the recurrence rule, as an array of integers. Values can be from 1 to 366 and from -1 to -366.
    ///
    /// Negative values indicate counting backwards from the end of the year.
    public var byyearday = [Int]()

    /// The months of the year associated with the recurrence rule, as an array of integers. Values can be from 1 to 12.
    public var bymonth = [Int]()

    /// The weeks of the year associated with the recurrence rule, as an array of integers. Values can be from 1 to 53 and from -1 to -53. According to ISO8601, the first week of the year is that containing at least four days of the new year.
    ///
    /// Negative values indicate counting backwards from the end of the year.
    public var byweekno = [Int]()

    /// The days of the month associated with the recurrence rule, as an array of integers. Values can be from 1 to 31 and from -1 to -31.
    ///
    /// Negative values indicate counting backwards from the end of the month.
    public var bymonthday = [Int]()

    /// The days of the week associated with the recurrence rule, as an array of EKWeekday objects.
    public var byweekday = [EKWeekday]()

    /// The hours of the day associated with the recurrence rule, as an array of integers.
    public var byhour = [Int]()

    /// The minutes of the hour associated with the recurrence rule, as an array of integers.
    public var byminute = [Int]()

    /// The seconds of the minute associated with the recurrence rule, as an array of integers.
    public var bysecond = [Int]()

    /// The inclusive dates of the recurrence rule.
    public var rdate: InclusionDate?

    /// The exclusion dates of the recurrence rule. The dates of this property will not be generated, even if some inclusive rdate matches the recurrence rule.
    public var exdate: ExclusionDate?

    public init(frequency: RecurrenceFrequency) {
        self.frequency = frequency
    }

    public init?(rruleString: String) {
        if let recurrenceRule = RRule.ruleFromString(rruleString) {
            self = recurrenceRule
        } else {
            return nil
        }
    }

    public func toRRuleString() -> String {
        return RRule.stringFromRule(self)
    }
}

public enum RecurrenceFrequency {
    case yearly
    case monthly
    case weekly
    case daily
    case hourly
    case minutely
    case secondly

    internal func toString() -> String {
        switch self {
        case .secondly: return "SECONDLY"
        case .minutely: return "MINUTELY"
        case .hourly: return "HOURLY"
        case .daily: return "DAILY"
        case .weekly: return "WEEKLY"
        case .monthly: return "MONTHLY"
        case .yearly: return "YEARLY"
        }
    }

    internal static func frequency(from string: String) -> RecurrenceFrequency? {
        switch string {
        case "SECONDLY": return .secondly
        case "MINUTELY": return .minutely
        case "HOURLY": return .hourly
        case "DAILY": return .daily
        case "WEEKLY": return .weekly
        case "MONTHLY": return .monthly
        case "YEARLY": return .yearly
        default: return nil
        }
    }
}


public struct ExclusionDate {
    /// All exclusion dates.
    public fileprivate(set) var dates = [Date]()
    /// The component of ExclusionDate, used to decide which exdate will be excluded.
    public fileprivate(set) var component: Calendar.Component!

    public init(dates: [Date], granularity component: Calendar.Component) {
        self.dates = dates
        self.component = component
    }

    public init?(exdateString string: String, granularity component: Calendar.Component) {
        let string = string.trimmingCharacters(in: .whitespaces)
        guard let range = string.range(of: "EXDATE:"), range.lowerBound == string.startIndex else {
            return nil
        }
        let exdateString = String(string.suffix(from: range.upperBound))
        let exdates = exdateString.components(separatedBy: ",").compactMap { (dateString) -> String? in
            if dateString.isEmpty {
                return nil
            }
            return dateString
        }

        self.dates = exdates.compactMap({ (dateString) -> Date? in
            if let date = RRule.dateFormatter.date(from: dateString) {
                return date
            } else if let date = RRule.realDate(dateString) {
                return date
            }
            return nil
        })
        self.component = component
    }

    public func toExDateString() -> String? {
        var exdateString = "EXDATE:"
        let dateStrings = dates.map { (date) -> String in
            return RRule.dateFormatter.string(from: date)
        }
        if dateStrings.count > 0 {
            exdateString += dateStrings.joined(separator: ",")
        } else {
            return nil
        }

        if String(exdateString.suffix(from: exdateString.index(exdateString.endIndex, offsetBy: -1))) == "," {
            exdateString.remove(at: exdateString.index(exdateString.endIndex, offsetBy: -1))
        }

        return exdateString
    }
}


public struct InclusionDate {
    /// All inclusive dates.
    public fileprivate(set) var dates = [Date]()

    public init(dates: [Date]) {
        self.dates = dates
    }

    public init?(rdateString string: String) {
        let string = string.trimmingCharacters(in: .whitespaces)
        guard let range = string.range(of: "RDATE:"), range.lowerBound == string.startIndex else {
            return nil
        }
        let rdateString = String(string.suffix(from: range.upperBound))
        let rdates = rdateString.components(separatedBy: ",").compactMap { (dateString) -> String? in
            if dateString.isEmpty {
                return nil
            }
            return dateString
        }

        self.dates = rdates.compactMap({ (dateString) -> Date? in
            if let date = RRule.dateFormatter.date(from: dateString) {
                return date
            } else if let date = RRule.realDate(dateString) {
                return date
            }
            return nil
        })
    }

    public func toRDateString() -> String {
        var rdateString = "RDATE:"
        let dateStrings = dates.map { (date) -> String in
            return RRule.dateFormatter.string(from: date)
        }
        if dateStrings.count > 0 {
            rdateString += dateStrings.joined(separator: ",")
        }

        if String(rdateString.suffix(from: rdateString.index(rdateString.endIndex, offsetBy: -1))) == "," {
            rdateString.remove(at: rdateString.index(rdateString.endIndex, offsetBy: -1))
        }

        return rdateString
    }
}


public struct RRule {
    public static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatter.dateFormat = "yyyyMMdd'T'HHmmss'Z'"
        return dateFormatter
    }()
    public static let ymdDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatter.dateFormat = "yyyyMMdd"
        return dateFormatter
    }()

    internal static let ISO8601DateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        return dateFormatter
    }()

    public static func ruleFromString(_ string: String) -> RecurrenceRule? {
        let string = string.trimmingCharacters(in: .whitespaces)
        guard let range = string.range(of: "RRULE:"), range.lowerBound == string.startIndex else {
            return nil
        }
        let ruleString = String(string.suffix(from: range.upperBound))
        let rules = ruleString.components(separatedBy: ";").compactMap { (rule) -> String? in
            if rule.isEmpty {
                return nil
            }
            return rule
        }

        var recurrenceRule = RecurrenceRule(frequency: .daily)
        var ruleFrequency: RecurrenceFrequency?
        for rule in rules {
            let ruleComponents = rule.components(separatedBy: "=")
            guard ruleComponents.count == 2 else {
                continue
            }
            let ruleName = ruleComponents[0]
            let ruleValue = ruleComponents[1]
            guard !ruleValue.isEmpty else {
                continue
            }

            if ruleName == "FREQ" {
                ruleFrequency = RecurrenceFrequency.frequency(from: ruleValue)
            }

            if ruleName == "INTERVAL" {
                if let interval = Int(ruleValue) {
                    recurrenceRule.interval = max(1, interval)
                }
            }

            if ruleName == "WKST" {
                if let firstDayOfWeek = EKWeekday.weekdayFromSymbol(ruleValue) {
                    recurrenceRule.firstDayOfWeek = firstDayOfWeek
                }
            }

            if ruleName == "DTSTART" {
                if let startDate = dateFormatter.date(from: ruleValue) {
                    recurrenceRule.startDate = startDate
                } else if let startDate = realDate(ruleValue) {
                    recurrenceRule.startDate = startDate
                }
            }

            if ruleName == "UNTIL" {
                if let endDate = dateFormatter.date(from: ruleValue) {
                    recurrenceRule.recurrenceEnd = EKRecurrenceEnd(end: endDate)
                } else if let endDate = realDate(ruleValue) {
                    recurrenceRule.recurrenceEnd = EKRecurrenceEnd(end: endDate)
                }
            } else if ruleName == "COUNT" {
                if let count = Int(ruleValue) {
                    recurrenceRule.recurrenceEnd = EKRecurrenceEnd(occurrenceCount: count)
                }
            }

            if ruleName == "BYSETPOS" {
                let bysetpos = ruleValue.components(separatedBy: ",").compactMap({ (string) -> Int? in
                    guard let setpo = Int(string), (-366...366 ~= setpo) && (setpo != 0) else {
                        return nil
                    }
                    return setpo
                })
                recurrenceRule.bysetpos = bysetpos.sorted(by: <)
            }

            if ruleName == "BYYEARDAY" {
                let byyearday = ruleValue.components(separatedBy: ",").compactMap({ (string) -> Int? in
                    guard let yearday = Int(string), (-366...366 ~= yearday) && (yearday != 0) else {
                        return nil
                    }
                    return yearday
                })
                recurrenceRule.byyearday = byyearday.sorted(by: <)
            }

            if ruleName == "BYMONTH" {
                let bymonth = ruleValue.components(separatedBy: ",").compactMap({ (string) -> Int? in
                    guard let month = Int(string), 1...12 ~= month else {
                        return nil
                    }
                    return month
                })
                recurrenceRule.bymonth = bymonth.sorted(by: <)
            }

            if ruleName == "BYWEEKNO" {
                let byweekno = ruleValue.components(separatedBy: ",").compactMap({ (string) -> Int? in
                    guard let weekno = Int(string), (-53...53 ~= weekno) && (weekno != 0) else {
                        return nil
                    }
                    return weekno
                })
                recurrenceRule.byweekno = byweekno.sorted(by: <)
            }

            if ruleName == "BYMONTHDAY" {
                let bymonthday = ruleValue.components(separatedBy: ",").compactMap({ (string) -> Int? in
                    guard let monthday = Int(string), (-31...31 ~= monthday) && (monthday != 0) else {
                        return nil
                    }
                    return monthday
                })
                recurrenceRule.bymonthday = bymonthday.sorted(by: <)
            }

            if ruleName == "BYDAY" {
                // These variables will define the weekdays where the recurrence will be applied.
                // In the RFC documentation, it is specified as BYDAY, but was renamed to avoid the ambiguity of that argument.
                let byweekday = ruleValue.components(separatedBy: ",").compactMap({ (string) -> EKWeekday? in
                    return EKWeekday.weekdayFromSymbol(string)
                })
                recurrenceRule.byweekday = byweekday.sorted(by: <)
            }

            if ruleName == "BYHOUR" {
                let byhour = ruleValue.components(separatedBy: ",").compactMap({ (string) -> Int? in
                    return Int(string)
                })
                recurrenceRule.byhour = byhour.sorted(by: <)
            }

            if ruleName == "BYMINUTE" {
                let byminute = ruleValue.components(separatedBy: ",").compactMap({ (string) -> Int? in
                    return Int(string)
                })
                recurrenceRule.byminute = byminute.sorted(by: <)
            }

            if ruleName == "BYSECOND" {
                let bysecond = ruleValue.components(separatedBy: ",").compactMap({ (string) -> Int? in
                    return Int(string)
                })
                recurrenceRule.bysecond = bysecond.sorted(by: <)
            }
        }

        guard let frequency = ruleFrequency else {
            print("error: invalid frequency")
            return nil
        }
        recurrenceRule.frequency = frequency

        return recurrenceRule
    }

    public static func stringFromRule(_ rule: RecurrenceRule) -> String {
        var rruleString = "RRULE:"

        rruleString += "FREQ=\(rule.frequency.toString());"

        let interval = max(1, rule.interval)
        rruleString += "INTERVAL=\(interval);"

        rruleString += "WKST=\(rule.firstDayOfWeek.toSymbol());"

        rruleString += "DTSTART=\(dateFormatter.string(from: rule.startDate as Date));"

        if let endDate = rule.recurrenceEnd?.endDate {
            rruleString += "UNTIL=\(dateFormatter.string(from: endDate));"
        } else if let count = rule.recurrenceEnd?.occurrenceCount {
            rruleString += "COUNT=\(count);"
        }

        let bysetposStrings = rule.bysetpos.compactMap({ (setpo) -> String? in
            guard (-366...366 ~= setpo) && (setpo != 0) else {
                return nil
            }
            return String(setpo)
        })
        if bysetposStrings.count > 0 {
            rruleString += "BYSETPOS=\(bysetposStrings.joined(separator: ","));"
        }

        let byyeardayStrings = rule.byyearday.compactMap({ (yearday) -> String? in
            guard (-366...366 ~= yearday) && (yearday != 0) else {
                return nil
            }
            return String(yearday)
        })
        if byyeardayStrings.count > 0 {
            rruleString += "BYYEARDAY=\(byyeardayStrings.joined(separator: ","));"
        }

        let bymonthStrings = rule.bymonth.compactMap({ (month) -> String? in
            guard 1...12 ~= month else {
                return nil
            }
            return String(month)
        })
        if bymonthStrings.count > 0 {
            rruleString += "BYMONTH=\(bymonthStrings.joined(separator: ","));"
        }

        let byweeknoStrings = rule.byweekno.compactMap({ (weekno) -> String? in
            guard (-53...53 ~= weekno) && (weekno != 0) else {
                return nil
            }
            return String(weekno)
        })
        if byweeknoStrings.count > 0 {
            rruleString += "BYWEEKNO=\(byweeknoStrings.joined(separator: ","));"
        }

        let bymonthdayStrings = rule.bymonthday.compactMap({ (monthday) -> String? in
            guard (-31...31 ~= monthday) && (monthday != 0) else {
                return nil
            }
            return String(monthday)
        })
        if bymonthdayStrings.count > 0 {
            rruleString += "BYMONTHDAY=\(bymonthdayStrings.joined(separator: ","));"
        }

        let byweekdaySymbols = rule.byweekday.map({ (weekday) -> String in
            return weekday.toSymbol()
        })
        if byweekdaySymbols.count > 0 {
            rruleString += "BYDAY=\(byweekdaySymbols.joined(separator: ","));"
        }

        let byhourStrings = rule.byhour.map({ (hour) -> String in
            return String(hour)
        })
        if byhourStrings.count > 0 {
            rruleString += "BYHOUR=\(byhourStrings.joined(separator: ","));"
        }

        let byminuteStrings = rule.byminute.map({ (minute) -> String in
            return String(minute)
        })
        if byminuteStrings.count > 0 {
            rruleString += "BYMINUTE=\(byminuteStrings.joined(separator: ","));"
        }

        let bysecondStrings = rule.bysecond.map({ (second) -> String in
            return String(second)
        })
        if bysecondStrings.count > 0 {
            rruleString += "BYSECOND=\(bysecondStrings.joined(separator: ","));"
        }

        if String(rruleString.suffix(from: rruleString.index(rruleString.endIndex, offsetBy: -1))) == ";" {
            rruleString.remove(at: rruleString.index(rruleString.endIndex, offsetBy: -1))
        }

        return rruleString
    }
    
    static func realDate(_ dateString: String?) -> Date? {
        guard let dateString = dateString else { return nil }
        
        let date = ymdDateFormatter.date(from: dateString)
        let destinationTimeZone = NSTimeZone.local
        let sourceGMTOffset = destinationTimeZone.secondsFromGMT(for: Date())
        
        if let timeInterval = date?.timeIntervalSince1970 {
            let realOffset = timeInterval - Double(sourceGMTOffset)
            let realDate = Date(timeIntervalSince1970: realOffset)
            
            return realDate
        }
        return nil
    }
}

internal extension EKWeekday {
    func toSymbol() -> String {
        switch self {
        case .monday: return "MO"
        case .tuesday: return "TU"
        case .wednesday: return "WE"
        case .thursday: return "TH"
        case .friday: return "FR"
        case .saturday: return "SA"
        case .sunday: return "SU"
        }
    }

    func toNumberSymbol() -> Int {
        switch self {
        case .monday: return 0
        case .tuesday: return 1
        case .wednesday: return 2
        case .thursday: return 3
        case .friday: return 4
        case .saturday: return 5
        case .sunday: return 6
        }
    }

    static func weekdayFromSymbol(_ symbol: String) -> EKWeekday? {
        switch symbol {
        case "MO", "0": return EKWeekday.monday
        case "TU", "1": return EKWeekday.tuesday
        case "WE", "2": return EKWeekday.wednesday
        case "TH", "3": return EKWeekday.thursday
        case "FR", "4": return EKWeekday.friday
        case "SA", "5": return EKWeekday.saturday
        case "SU", "6": return EKWeekday.sunday
        default: return nil
        }
    }
}

extension EKWeekday: Comparable { }

public func <(lhs: EKWeekday, rhs: EKWeekday) -> Bool {
    return lhs.toNumberSymbol() < rhs.toNumberSymbol()
}

public func ==(lhs: EKWeekday, rhs: EKWeekday) -> Bool {
    return lhs.toNumberSymbol() == rhs.toNumberSymbol()
}
