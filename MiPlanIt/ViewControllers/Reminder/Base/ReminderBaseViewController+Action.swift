//
//  ReminderBaseViewController+Action.swift
//  MiPlanIt
//
//  Created by Febin Paul on 12/08/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

extension ReminderBaseViewController {
    
    func initializeUI() {
        self.viewTopColorHeader.isHidden = self.navigationController == nil
        self.viewTopNonColorHeader.isHidden = self.navigationController != nil
        self.viewTopBarGradient.isHidden = self.navigationController == nil
        for (index, option) in self.arrayViewsReminders.enumerated() {
            switch index {
            case 0:
                option.reminderOption = .fiveMinBefore
            case 1:
                option.reminderOption = .fifteenMinBefore
            case 2:
                option.reminderOption = .thirtyMinBefore
            case 3:
                option.reminderOption = .oneHourBefore
            case 4:
                option.reminderOption = .oneDayBefore
            case 5:
                option.reminderOption = .oneWeekBefore
            case 6:
                option.reminderOption = .oneMonthBefore
            default:
                break
            }
        }
        self.labelReminderTime.text = (self.remindModel.sourceScreen == .task || self.remindModel.sourceScreen == .shopping || self.remindModel.readIsAllDayEvent()) ? self.remindModel.readReminderTimeString() : self.startDate.stringFromDate(format: DateFormatters.HHMMSA)
        self.labelReminderDate.text = self.startDate.stringFromDate(format: DateFormatters.EEEDDHMMMHYYY)
        self.updateReminderOptionSelection()
        self.imageViewTimeArrow?.isHidden = self.remindModel.sourceScreen != .task && self.remindModel.sourceScreen != .shopping && !self.remindModel.readIsAllDayEvent()
        self.buttonTimePicker.isUserInteractionEnabled = self.remindModel.sourceScreen == .task || self.remindModel.sourceScreen == .shopping || self.remindModel.readIsAllDayEvent()
        self.updateCustomReminderlabel()
        self.dateTimePicker.setValue(UIColor.white, forKeyPath: "textColor")
        self.pickerViewNumber.setValue(UIColor.white, forKeyPath: "textColor")
        self.pickerViewTimeUnit.setValue(UIColor.white, forKeyPath: "textColor")
    }
    
    func updateReminderOption(_ option: ReminderOptionView) {
        if self.remindModel.reminderOption == .custom {
            self.buttonRemoveCustomReminder.sendActions(for: .touchUpInside)
        }
        self.remindModel.setReminderBefore(option: option.reminderOption)
        self.arrayViewsReminders.forEach { (optionView) in
            optionView.setSelectionStatus(option: option.reminderOption)
        }
    }
    
    func updateCustomReminderlabel() {
        if self.remindModel.reminderOption == .custom {
            self.viewCustomTimeLabel.isHidden = false
            self.labelCustomReminderBeforeTime.text = "\(self.remindModel.reminderBeforeValue) \(self.remindModel.reminderBeforeUnit) before"
            if self.remindModel.reminderOption == .custom, let view = self.scrollView {
                self.scrollView?.layoutIfNeeded()
                let bottomOffset = CGPoint(x: 0, y: view.contentSize.height - view.bounds.size.height)
                self.scrollView?.setContentOffset(bottomOffset, animated: true)
            }
        }
        else {
            self.viewCustomTimeLabel.isHidden = true
            self.labelCustomReminderBeforeTime.text = nil
        }
        self.buttonRemoveCustomReminder.isSelected = !self.viewCustomTimeLabel.isHidden
        self.buttonRemoveCustomReminder.isUserInteractionEnabled = !self.viewCustomTimeLabel.isHidden
    }
    
    func updateReminderOptionSelection() {
        if self.remindModel.reminderOption != .custom {
            self.arrayViewsReminders.forEach { (optionView) in
                optionView.setSelectionStatus(option: self.remindModel.reminderOption)
            }
        }
    }
    
    func clearReminderOptionSelection() {
        self.arrayViewsReminders.forEach { (optionView) in
            optionView.setSelectionStatus(option: nil)
        }
    }
    
    func updateCustomReminderNumbers(unit: String) {
        switch unit {
        case Strings.minUnit:
            self.arrayCustomReminderNumbers = Array(1...59)
        case Strings.hourUnit:
            self.arrayCustomReminderNumbers = Array(1...23)
        case Strings.dayUnit:
            self.arrayCustomReminderNumbers = Array(1...6)
        case Strings.weekUnit:
            self.arrayCustomReminderNumbers = Array(1...4)
        case Strings.monthUnit:
            self.arrayCustomReminderNumbers = Array(arrayLiteral: 1)
        default:
            break
        }
        self.remindModel.setReminderUnit(unit)
    }
    
    func updateCustomReminderUnit(unit: String) {
        switch unit {
        case Strings.minUnit:
            self.pickerViewTimeUnit.selectRow(0, inComponent: 0, animated: true)
        case Strings.hourUnit:
            self.pickerViewTimeUnit.selectRow(1, inComponent: 0, animated: true)
        case Strings.dayUnit:
            self.pickerViewTimeUnit.selectRow(2, inComponent: 0, animated: true)
        case Strings.weekUnit:
            self.pickerViewTimeUnit.selectRow(3, inComponent: 0, animated: true)
        case Strings.monthUnit:
            self.pickerViewTimeUnit.selectRow(4, inComponent: 0, animated: true)
        default:
            break
        }
    }
    
    func updatedCustomReminderValue(_ value: Int) {
        if let index = self.arrayCustomReminderNumbers.first(where: { (number) -> Bool in
            number == value
        }) {
            self.pickerViewNumber.selectRow(index-1, inComponent: 0, animated: true)
        }
    }
    
}
