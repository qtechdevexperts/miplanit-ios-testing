//
//  DateExtension.swift
//  MiPlanIt
//
//  Created by Arun on 23/03/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

extension Date {
    
    func dayNumberOfMonth() -> Int? {
        return Calendar.current.dateComponents([.month], from: self).month
    }
    
    func dayNumberOfWeek() -> Int? {
        return Calendar.current.dateComponents([.weekday], from: self).weekday
    }
    
    func hourBetweenDate(toDate: Date) -> Int {
        let components = Calendar.current.dateComponents([.hour], from: self, to: toDate)
        return components.hour ?? 0
    }
    
    func daysBetweenDate(toDate: Date) -> Int {
        let components = Calendar.current.dateComponents([.day], from: self, to: toDate)
        return components.day ?? 0
    }
    
    func yearBetweenDate(toDate: Date) -> Int {
        let components = Calendar.current.dateComponents([.year], from: self, to: toDate)
        return components.year ?? 0
    }
    
    func monthBetweenDate(toDate: Date) -> Int {
        let components = Calendar.current.dateComponents([.month], from: self, to: toDate)
        return components.month ?? 0
    }
    
    var millisecondsSince1970: Int64 {
        return Int64((self.timeIntervalSince1970 * 1000.0).rounded())
    }
    
    func addMonth(n: Int) -> Date {
        let cal = NSCalendar.current
        return cal.date(byAdding: .month, value: n, to: self)!
    }
    
    func minutes(from date: Date) -> Int {
        return Calendar.current.dateComponents([.minute], from: date, to: self).minute ?? 0
    }
    
    func ifDate15minBefore() -> Bool {
        var components = DateComponents()
        components.minute = -15
        return Calendar.current.date(byAdding: components, to: self)! > Date()
    }
    
    func ifDate30minBefore() -> Bool {
        var components = DateComponents()
        components.minute = -30
        return Calendar.current.date(byAdding: components, to: self)! > Date()
    }
    
    func ifDate1hrBefore() -> Bool {
        var components = DateComponents()
        components.hour = -1
        return Calendar.current.date(byAdding: components, to: self)! > Date()
    }
    
    func ifDate1dayBefore() -> Bool {
        var components = DateComponents()
        components.day = -1
        return Calendar.current.date(byAdding: components, to: self)! > Date()
    }
    
    func ifDate1monthBefore() -> Bool {
        var components = DateComponents()
        components.month = -1
        return Calendar.current.date(byAdding: components, to: self)! > Date()
    }
    
    
    func stringFromDate(format: String, timeZone: TimeZone = .current) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = format
        dateFormatter.timeZone = timeZone
        return dateFormatter.string(from: self) 
    }
    
    func getCurrentHourString(_ format: String) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = format // "a" prints "pm" or "am"
        return formatter.string(from: self) // "12 AM"
    }
    
    func getNextTimeAfter(hour: Int) -> Date {
        return Calendar.current.date(byAdding: .hour, value: hour, to: self) ?? Date()
    }
    
    func isBetweeen(date date1: Date, andDate date2: Date) -> Bool {
        return date1.compare(self) == self.compare(date2)
    }
    
    func rounded(minutes: TimeInterval, rounding: DateRoundingType = .round) -> Date {
        return rounded(seconds: minutes * 60, rounding: rounding)
    }
    
    func rounded(seconds: TimeInterval, rounding: DateRoundingType = .round) -> Date {
        var roundedInterval: TimeInterval = 0
        switch rounding  {
        case .round:
            roundedInterval = (timeIntervalSinceReferenceDate / seconds).rounded() * seconds
        case .ceil:
            roundedInterval = ceil(timeIntervalSinceReferenceDate / seconds) * seconds
        case .floor:
            roundedInterval = floor(timeIntervalSinceReferenceDate / seconds) * seconds
        }
        return Date(timeIntervalSinceReferenceDate: roundedInterval)
    }
    
    func isEndOfDay(for date: Date) -> Bool {
        var components = DateComponents()
        let startingDate = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: self)!
        components.day = 1
        components.second = -1
        return date >= Calendar.current.date(byAdding: components, to: startingDate) ?? Date()
    }
    
    func lastDateTimeOfDate() -> Date {
        return Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: self)!.adding(minutes: 1430)
    }
    
    func adding(years: Int) -> Date {
        return Calendar.current.date(byAdding: .year, value: years, to: self)!
    }
    
    func adding(seconds: Int) -> Date {
        return Calendar.current.date(byAdding: .second, value: seconds, to: self)!
    }
    
    func adding(minutes: Int) -> Date {
        return Calendar.current.date(byAdding: .minute, value: minutes, to: self)!
    }
    
    func adding(days: Int) -> Date {
        return Calendar.current.date(byAdding: .day, value: days, to: self)!
    }
    
    func adding(hour: Int) -> Date {
        let cal = NSCalendar.current
        return cal.date(byAdding: .hour, value: hour, to: self)!
    }
    func getTimeSeconds() -> Int {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: self)
        let minutes = calendar.component(.minute, from: self)
        let seconds = calendar.component(.second, from: self)
        return hour*60*60 + minutes*60 + seconds
    }
    
    func nearestHalfHour() -> Date {
        var components = NSCalendar.current.dateComponents([.minute], from: self)
        let minute = components.minute ?? 0
        components.minute = ((minute >= 30 ? 60 : 30) - minute)
        return Calendar.current.date(byAdding: components, to: self) ?? self
    }
    
    func previoustHalfHour() -> Date {
        var components = NSCalendar.current.dateComponents([.minute], from: self)
        let minute = components.minute ?? 0
        components.minute = (minute < 30 ? -minute : -(minute-30))
        return Calendar.current.date(byAdding: components, to: self) ?? self
    }
    
    func commingHour() -> Date {
        var components = NSCalendar.current.dateComponents([.minute], from: self)
        let minute = components.minute ?? 0
        components.minute = (60-minute)
        return Calendar.current.date(byAdding: components, to: self) ?? self
    }
    
    func previousHour() -> Date {
        var components = NSCalendar.current.dateComponents([.minute], from: self)
        let minute = components.minute ?? 0
        components.minute =  -minute
        return Calendar.current.date(byAdding: components, to: self) ?? self
    }
    
    func startOfTheMonth() -> Date {
        return Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Calendar.current.startOfDay(for: self)))!.initialHour()
    }
    
    func endOfTheMonth() -> Date {
        return Calendar.current.date(byAdding: DateComponents(month: 1), to: self.startOfTheMonth())!
    }
    
    func initialHour() -> Date {
        let convertedDateString = self.stringFromDate(format: DateFormatters.YYYYHMMMHDD)
        if convertedDateString.count >= 8 {
            return convertedDateString.stringToDate(formatter: DateFormatters.YYYYHMMMHDD) ?? self
        }
        return self
    }
    
    func trimSeconds() -> Date {
        return Date(timeIntervalSince1970: Double(Int(self.timeIntervalSince1970/60) * 60))
    }
    
    func dayDiffrence(from date: Date) -> Int {
        let cal = Calendar.current
        let components = cal.dateComponents([.day, .hour, .minute], from: date, to: self)
        if let day = components.day, day > 0 {
            return day
        }
        return 0
    }
    
    func secondDiffrence(from date: Date) -> Int {
        let cal = Calendar.current
        let components = cal.dateComponents([.second], from: date, to: self)
        if let second = components.second, second > 0 {
            return second
        }
        return 0
    }
    
    func timeDiffrence(from date: Date) -> String {
        let cal = Calendar.current
        let components = cal.dateComponents([.day, .hour, .minute], from: date, to: self)
        var amountOfTime = ""
        if let day = components.day, day > 0 {
            amountOfTime += "\(day) \(day > 1 ? "days " : "day ")"
        }
        if let diffHr = components.hour, diffHr != 0 {
            amountOfTime += "\(diffHr) \(diffHr > 1 ? "hrs " : "hr ")"
        }
        if let diffMin = components.minute, diffMin != 0 {
            amountOfTime += "\(diffMin) mins"
        }
        return amountOfTime
    }
    
    func getTime() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = .current
        formatter.dateFormat = "h:mma"
        formatter.amSymbol = "AM"
        formatter.pmSymbol = "PM"
        return formatter.string(from: self)
    }
    
    func convertDateToComponents() -> String {
        let unitFlags = Set<Calendar.Component>([.hour, .year, .minute, .minute, .day, .month, .weekOfYear])
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(identifier: "UTC")!
        let components = calendar.dateComponents(unitFlags, from: self, to: Date())
        if (components.year! > 0) {
            return "\(Int(components.year!)) " + "years ago"
        }
        else if (components.month! > 0) {
            return "\(Int(components.month!)) " + "months ago"
        }
        else if (components.weekOfYear! > 0) {
            return "\(Int(components.weekOfYear!)) " + "weeks ago"
        }
        else if (components.day! > 0) {
            if (components.day! > 1) {
                return "\(Int(components.day!)) " + "days ago"
            }
            else {
                return "Yesterday"
            }
        }
        else {
            if (components.hour! > 0) {
                return "\(Int(components.hour!)) " + "hrs ago"
            }
            else {
                return "\(Int(components.minute!)) " + "mins ago"
            }
        }
    }
    
    
    func convertDateToComponentsForExpiry() -> String {
        let unitFlags = Set<Calendar.Component>([.year, .day, .month, .second, .weekOfYear])
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(identifier: "UTC")!
        let components = calendar.dateComponents(unitFlags, from: Date(), to: self.adding(hour: 24).adding(seconds: -1))
        var expiryComponentString: [String] = []
        if (components.year! > 0) {
            expiryComponentString.append("\(Int(components.year!)) \(Int(components.year!) > 1 ? "years" : "year")")
        }
        if (components.month! > 0) {
            expiryComponentString.append("\(Int(components.month!)) \(Int(components.month!) > 1 ? "months" : "month")")
        }
        if (components.weekOfYear! > 0) {
            expiryComponentString.append("\(Int(components.weekOfYear!)) \(Int(components.weekOfYear!) > 1 ? "weeks" : "week")")
        }
        if (components.day! > 0) {
            expiryComponentString.append("\(Int(components.day!)) \(Int(components.day!) > 1 ? "days" : "day")")
        }
        if !expiryComponentString.isEmpty {
            return "Expires in \(expiryComponentString.joined(separator: " "))"
        }
        else {
            if (components.second! > 0) {
                return "Expires today"
            }
            else {
                return "Expired"
            }
        }
    }
    
    
    
    func interval(ofComponent comp: Calendar.Component, fromDate date: Date) -> Int {

        let currentCalendar = Calendar.current
        guard let start = currentCalendar.ordinality(of: comp, in: .era, for: date) else { return 0 }
        guard let end = currentCalendar.ordinality(of: comp, in: .era, for: self) else { return 0 }
        return end - start
    }
    
    func getDayPart() -> String{
        let hour = Calendar.current.component(.hour, from: self)
        switch hour {
        case 1..<12 : return "Morning"
        case 12..<17 : return "Afternoon"
        case 17..<24 : return "Evening"
        default:
            return "Evening"
        }
    }
}


extension TimeZone {
    
    func offsetFromUTC() -> String {
        let localTimeZoneFormatter = DateFormatter()
        localTimeZoneFormatter.locale = Locale(identifier: "en_US_POSIX")
        localTimeZoneFormatter.timeZone = self
        localTimeZoneFormatter.dateFormat = "Z"
        return localTimeZoneFormatter.string(from: Date())
    }
    
    func offsetInHours() -> String {
        let hours = secondsFromGMT()/3600
        let minutes = abs(secondsFromGMT()/60) % 60
        let tz_hr = String(format: "%+.2d:%.2d", hours, minutes) // "+hh:mm"
        return tz_hr
    }
}

enum DateRoundingType {
    case round
    case ceil
    case floor
}

