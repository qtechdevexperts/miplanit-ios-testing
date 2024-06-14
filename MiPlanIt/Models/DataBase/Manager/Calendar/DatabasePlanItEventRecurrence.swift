//
//  DatabasePlanItEventRecurrence.swift
//  MiPlanIt
//
//  Created by Arun on 17/06/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation
import CoreData
// import RRuleSwift

class DatabasePlanItEventRecurrence: DataBaseManager {

    func insertSilentEvent(_ event: PlanItSilentEvent, recurrence: String, using context: NSManagedObjectContext? = nil) {
        let objectContext = context ?? self.mainObjectContext
        let recurrenceEntity = event.recurrence ?? self.insertNewRecords(Table.planItEventRecurrence, context: objectContext) as! PlanItEventRecurrence
        event.isRecurrence = true
        recurrenceEntity.silentEvent = event
        recurrenceEntity.rule = self.updateIfGoogleRule(rule: recurrence.replacingOccurrences(of: "RRULE ", with: "RRULE:"), event: event)
        event.recurrenceEndDate = recurrenceEntity.readEndDate()
    }
    
    func insertEvent(_ event: PlanItEvent, recurrence: String, using context: NSManagedObjectContext? = nil) {
        let objectContext = context ?? self.mainObjectContext
        let recurrenceEntity = event.recurrence ?? self.insertNewRecords(Table.planItEventRecurrence, context: objectContext) as! PlanItEventRecurrence
        event.isRecurrence = true
        recurrenceEntity.event = event
        recurrenceEntity.rule = self.updateIfGoogleRule(rule: recurrence.replacingOccurrences(of: "RRULE ", with: "RRULE:"), event: event)
        event.recurrenceEndDate = recurrenceEntity.readEndDate()
    }
    
    func insertSilentEvent(_ event: PlanItSilentEvent, recurrence: [String: Any], using context: NSManagedObjectContext? = nil) {
        let objectContext = context ?? self.mainObjectContext
        let recurrenceEntity = event.recurrence ?? self.insertNewRecords(Table.planItEventRecurrence, context: objectContext) as! PlanItEventRecurrence
        event.isRecurrence = true
        recurrenceEntity.silentEvent = event
        recurrenceEntity.rule = Strings.empty
        if let pattern = recurrence["pattern"] as? [String: Any] {
            recurrenceEntity.dayOfMonth = pattern["dayOfMonth"] as? Double ?? 0
            recurrenceEntity.firstDayOfWeek = pattern["firstDayOfWeek"] as? String
            recurrenceEntity.index = pattern["index"] as? String
            recurrenceEntity.interval = pattern["interval"] as? Double ?? 0
            recurrenceEntity.month = pattern["month"] as? Double ?? 0
            recurrenceEntity.patternType = pattern["type"] as? String
            if let daysOfWeek = pattern["daysOfWeek"] as? [String]{
                recurrenceEntity.daysOfWeek = daysOfWeek.joined(separator: ",")
            }
        }
        if let range = recurrence["range"] as? [String: Any] {
            recurrenceEntity.endDate = range["endDate"] as? String
            recurrenceEntity.numberOfOccurrences = range["numberOfOccurrences"] as? Double ?? 0
            recurrenceEntity.startDate = range["startDate"] as? String
            recurrenceEntity.rangeType = range["type"] as? String
            recurrenceEntity.recurrenceTimeZone = range["recurrenceTimeZone"] as? String
        }
        event.recurrenceEndDate = recurrenceEntity.readEndDate()
    }
    
    func insertEvent(_ event: PlanItEvent, recurrence: [String: Any], using context: NSManagedObjectContext? = nil) {
        let objectContext = context ?? self.mainObjectContext
        let recurrenceEntity = event.recurrence ?? self.insertNewRecords(Table.planItEventRecurrence, context: objectContext) as! PlanItEventRecurrence
        event.isRecurrence = true
        recurrenceEntity.event = event
        recurrenceEntity.rule = Strings.empty
        if let pattern = recurrence["pattern"] as? [String: Any] {
            recurrenceEntity.dayOfMonth = pattern["dayOfMonth"] as? Double ?? 0
            recurrenceEntity.firstDayOfWeek = pattern["firstDayOfWeek"] as? String
            recurrenceEntity.index = pattern["index"] as? String
            recurrenceEntity.interval = pattern["interval"] as? Double ?? 0
            recurrenceEntity.month = pattern["month"] as? Double ?? 0
            recurrenceEntity.patternType = pattern["type"] as? String
            if let daysOfWeek = pattern["daysOfWeek"] as? [String]{
                recurrenceEntity.daysOfWeek = daysOfWeek.joined(separator: ",")
            }
        }
        if let range = recurrence["range"] as? [String: Any] {
            recurrenceEntity.endDate = range["endDate"] as? String
            recurrenceEntity.numberOfOccurrences = range["numberOfOccurrences"] as? Double ?? 0
            recurrenceEntity.startDate = range["startDate"] as? String
            recurrenceEntity.rangeType = range["type"] as? String
            recurrenceEntity.recurrenceTimeZone = range["recurrenceTimeZone"] as? String
        }
        event.recurrenceEndDate = recurrenceEntity.readEndDate()
    }
    
    func updateIfGoogleRule(rule: String, event: PlanItSilentEvent) -> String {
        if event.readValueOfCalendarType() == "1" {
            return self.setMonthByDayOfGoogle(rule: rule)
        }
        return rule
    }
    
    func updateIfGoogleRule(rule: String, event: PlanItEvent) -> String {
        if event.readEventCalendar()?.readValueOfCalendarType() == "1" {
            return self.setMonthByDayOfGoogle(rule: rule)
        }
        return rule
    }
    
    private func getFrequency(recurrence: String) -> String? {
        if let repeatValue = recurrence.slice(from: "FREQ=", to: ";") {
            return repeatValue
        }
        else if let repeatValue = recurrence.slice(from: "FREQ=") {
            return repeatValue
        }
        return nil
    }
    
    private func getRepeatValueType(recurrence: String) -> DropDownOptionType {
        if let repeatValue = self.getFrequency(recurrence: recurrence) {
            switch repeatValue.uppercased() {
            case "DAILY":
                return .eEveryDay
            case "WEEKLY":
                return .eEveryWeek
            case "MONTHLY", "RELATIVEMONTHLY", "ABSOLUTEMONTHLY":
                return .eEveryMonth
            case "YEARLY":
                 return .eEveryYear
            default:
                break
            }
        }
        return .eNever
    }
    
    private func getByDayCount(byDay: String) -> String? {
        return byDay.components(separatedBy: CharacterSet.decimalDigits.inverted).filter({ !$0.isEmpty }).first
    }
    
    private func getByDayName(byDay: String) -> String? {
        return byDay.components(separatedBy: CharacterSet.decimalDigits).joined(separator: "")
    }
    
    private func generateBySetPosDay(indexDay: String, dayName: String) -> String {
        return "BYSETPOS=\(indexDay);BYDAY=\(dayName)"
    }
        
    func setMonthByDayOfGoogle(rule: String) -> String {
        if self.getRepeatValueType(recurrence: rule) == .eEveryMonth, let repeatValue = rule.slice(from: "BYDAY=") {
            let byDays = repeatValue.split(separator: ",")
            if let day = byDays.first, let indexDay = self.getByDayCount(byDay: String(day)), let dayName = self.getByDayName(byDay: String(day)) {
                if let indexOf = rule.range(of: "BYDAY=")?.lowerBound {
                    return rule[..<indexOf] + self.generateBySetPosDay(indexDay: indexDay, dayName: dayName)
                }
            }
        }
        return rule
    }
    
}
