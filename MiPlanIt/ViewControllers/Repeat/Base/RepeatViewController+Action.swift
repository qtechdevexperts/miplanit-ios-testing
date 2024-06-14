//
//  RepeatViewController+Action.swift
//  MiPlanIt
//
//  Created by Febin Paul on 23/06/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation
// import RRuleSwift
import EventKit

extension RepeatViewController {
    
    func setDailyFrequency(recurrenceRule: RecurrenceRule) {
        self.repeatModel.frequency = DropDownItem(name: Strings.everyDay, type: .eEveryDay, value: "DAILY")
        if recurrenceRule.interval > 0 {
            self.repeatModel.interval =  DropDownItem(name: "\(recurrenceRule.interval) day\(recurrenceRule.interval > 1 ? "s" : "")", value: "\(recurrenceRule.interval)")
        }
    }
    
    func setMonthyFrequency(recurrenceRule: RecurrenceRule) {
        self.repeatModel.frequency = DropDownItem(name: Strings.everyMonth, type: .eEveryMonth, value: "MONTHLY")
        if recurrenceRule.interval > 0 {
            self.repeatModel.interval =  DropDownItem(name: "\(recurrenceRule.interval) month\(recurrenceRule.interval > 1 ? "s" : "")", value: "\(recurrenceRule.interval)")
        }
        self.repeatModel.onDays = recurrenceRule.bymonthday
    }
    
    func setWeeklyFrequency(recurrenceRule: RecurrenceRule) {
        self.repeatModel.frequency = DropDownItem(name: Strings.everyWeek, type: .eEveryWeek, value: "WEEKLY")
        if recurrenceRule.interval > 0 {
            self.repeatModel.interval =  DropDownItem(name: "\(recurrenceRule.interval) week\(recurrenceRule.interval > 1 ? "s" : "")", value: "\(recurrenceRule.interval)")
        }
        self.repeatModel.onDays = recurrenceRule.byweekday.map({$0.rawValue})
    }
    
    func setYearlyFrequency(recurrenceRule: RecurrenceRule, byDaily: Bool = false) {
        self.repeatModel.frequency = DropDownItem(name: Strings.everyYear, type: .eEveryYear, value: "YEARLY")
        if recurrenceRule.interval > 0 {
            self.repeatModel.interval =  DropDownItem(name: "\(recurrenceRule.interval) year\(recurrenceRule.interval > 1 ? "s" : "")", value: "\(recurrenceRule.interval)")
        }
        if byDaily, let eventStartDate = self.myPlanItEvent?.event?.readStartDateTime() {
            self.repeatModel.byMonth = eventStartDate.month
            self.repeatModel.byMonthDay = eventStartDate.day
        }
    }
    
    func createRepeatModelFromRule() {
        guard self.recurrenceRule != Strings.empty, let recurrenceRule = RecurrenceRule(rruleString: self.recurrenceRule) else {
            self.repeatModel.frequency = DropDownItem(name: Strings.never, type: .eNever)
            self.repeatModel.onDays.removeAll()
            return
        }
        switch recurrenceRule.frequency {
        case .daily:
            self.recurrenceRule.contains("BYMONTH=") ? self.setYearlyFrequency(recurrenceRule: recurrenceRule, byDaily: true) : self.setDailyFrequency(recurrenceRule: recurrenceRule)
        case .monthly:
            self.setMonthyFrequency(recurrenceRule: recurrenceRule)
        case .weekly:
            self.setWeeklyFrequency(recurrenceRule: recurrenceRule)
        case .yearly:
            self.setYearlyFrequency(recurrenceRule: recurrenceRule)
        default:
            break
        }
        if let until = recurrenceRule.recurrenceEnd {
            self.repeatModel.forever = false
            self.repeatModel.untilDate = until.endDate
        }
        else {
            self.repeatModel.forever = true
            self.repeatModel.untilDate = nil
        }
    }
    
    func setView() {
        self.createRepeatModelFromRule()
        self.viewInterval.isHidden = self.repeatModel.frequency.dropDownType == .eNever
        self.viewOccurence.isHidden = self.repeatModel.onDays.isEmpty
        self.updateFrequency(self.repeatModel.frequency.title)
        self.txtFldInterval.text = self.repeatModel.interval?.title
        self.viewUntil.isHidden = self.repeatModel.frequency.dropDownType == .eNever
        self.setAllDates()
        self.setAllWeekDays()
        self.setUntilDate()
    }
    
    func resetRepeatData() {
        self.viewInterval.isHidden = self.repeatModel.frequency.dropDownType == .eNever
        self.viewOccurence.isHidden = self.repeatModel.frequency.dropDownType == .eNever
        self.viewUntil.isHidden = self.repeatModel.frequency.dropDownType == .eNever
        self.repeatModel.forever = true
        self.viewOccurence.isHidden = !(self.repeatModel.frequency.dropDownType == .eEveryWeek || self.repeatModel.frequency.dropDownType == .eEveryMonth)
        switch self.repeatModel.frequency.dropDownType {
        case .eEveryDay:
            self.repeatModel.interval = DropDownItem(name: Strings.oneDay, type: .e1Day)
        case .eEveryWeek:
            self.repeatModel.interval = DropDownItem(name: Strings.oneWeek, type: .e1Week)
            if let presentDropDownDay = self.getPresentDropDownDay() {
                self.repeatModel.onDays = [presentDropDownDay]
            }
            self.setAllWeekDays()
        case .eEveryMonth:
            self.repeatModel.interval = DropDownItem(name: Strings.oneMonth, type: .e1Day)
            if let dateValue = Int(Date().stringFromDate(format: DateFormatters.dd)){
                self.repeatModel.onDays = [dateValue]
            }
            self.setAllDates()
        case .eEveryYear:
            self.repeatModel.interval = DropDownItem(name: Strings.oneYear, type: .e1Day)
        default:
            self.repeatModel.interval = nil
            break
        }
        self.txtFldInterval.text = self.repeatModel.interval?.title
        self.txtFldUntil.text = self.repeatModel.forever ? "Forever" : "Date"
    }
    
    func setAllDates() {
        var dates = Strings.empty
        self.repeatModel.onDays.forEach { (value) in
            dates += dates != Strings.empty ? ", \(value)" : "\(value)"
        }
        self.txtFldNoOfOccurences.text = dates
    }
    
    func setUntilDate() {
        if self.repeatModel.forever {
            self.txtFldUntil.text = "Forever"
        }
        else if let date =  self.repeatModel.untilDate{
            self.txtFldUntil.text = date.stringFromDate(format: DateFormatters.DDHMMHYYYY)
        }
    }
    
    func setAllWeekDays() {
        guard self.repeatModel.frequency.dropDownType == .eEveryWeek else { return }
        var weekDaysName = Strings.empty
        self.repeatModel.onDays.forEach { (value) in
            weekDaysName += weekDaysName != Strings.empty ? ", \(self.getWeekDayName(value: value))" : self.getWeekDayName(value: value)
        }
        self.txtFldNoOfOccurences.text = weekDaysName
    }
    
    func getWeekDayName(value: Int) -> String {
        switch value {
        case 1:
            return Strings.Sunday
        case 2:
            return Strings.Monday
        case 3:
            return Strings.Tuesday
        case 4:
            return Strings.Wednesday
        case 5:
            return Strings.Thursday
        case 6:
            return Strings.Friday
        default:
            return Strings.Saturday
        }
    }
    
    func getPresentDropDownDay() -> Int? {
        if let dayIndex = Date().dayNumberOfWeek(), let weekDay = Weekday(rawValue: dayIndex) {
            return weekDay.rawValue
        }
        return nil
    }
    
    func getFrequencyDropDownItemFromButton(_ sender: UIButton) -> DropDownItem{
        switch sender.tag {
        case 1:
            return DropDownItem(name: Strings.never, type: .eNever)
        case 2:
            return DropDownItem(name: Strings.everyDay, type: .eEveryDay, value: "DAILY")
        case 3:
            return DropDownItem(name: Strings.everyWeek, type: .eEveryWeek, value: "WEEKLY")
        case 4:
            return DropDownItem(name: Strings.everyMonth, type: .eEveryMonth, value: "MONTHLY")
        case 5:
            return DropDownItem(name: Strings.everyYear, type: .eEveryYear, value: "YEARLY")
        default:
            return DropDownItem(name: Strings.never, type: .eNever)
        }
    }
    
    func updateFrequency(_ frequencyString: String) {
        switch frequencyString {
        case Strings.never: buttonFrequencys[0].isSelected = true
        case Strings.everyDay: buttonFrequencys[1].isSelected = true
        case Strings.everyWeek: buttonFrequencys[2].isSelected = true
        case Strings.everyMonth: buttonFrequencys[3].isSelected = true
        case Strings.everyYear: buttonFrequencys[4].isSelected = true
        default: buttonFrequencys[0].isSelected = true
        }
    }
    
    func isEventOutlook() -> Bool {
        guard let planItEvent = self.myPlanItEvent?.event, planItEvent.isSocialEvent, planItEvent.readEventCalendar()?.readValueOfCalendarType() == "2" else {
            return false
        }
        return true
    }
    
    func createRecurrenceRule() -> String {
        if self.repeatModel.frequency.dropDownType == .eNever { return Strings.empty} else {
            let frequency = self.repeatModel.frequency.value.getfrequencyFromString()
            var recurrenceRule = RecurrenceRule(frequency: frequency)
//            recurrenceRule.startDate = Date().initialHour()
            if let interval = self.repeatModel.interval, let val = Int(interval.value), val > 0 {
                recurrenceRule.interval = val
            }
            if self.repeatModel.forever == false, let endOfDay = self.repeatModel.untilDate?.endOfDay {
                recurrenceRule.recurrenceEnd = EKRecurrenceEnd(end: endOfDay)
            }
            if frequency == .weekly {
                recurrenceRule.byweekday = self.repeatModel.onDays.map({ return self.getWeekDayName(value: $0).getfirstDayofWeekFromString()})
            }
            if frequency == .monthly {
                recurrenceRule.bymonthday = self.repeatModel.onDays
            }
            if self.isEventOutlook(), frequency == .yearly, let byMonth =  self.repeatModel.byMonth, let byMonthDay = self.repeatModel.byMonthDay {
                recurrenceRule.frequency = .daily
                recurrenceRule.bymonth = [byMonth]
                recurrenceRule.bymonthday = [byMonthDay]
            }
            return recurrenceRule.toRRuleString()
        }
    }
}
