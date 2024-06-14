//
//  AddDurationViewController+Action.swift
//  MiPlanIt
//
//  Created by Febin Paul on 26/03/21.
//  Copyright © 2021 Arun. All rights reserved.
//

import Foundation

extension AddDurationViewController {
    
    func initializeUI() {
        for (index, option) in self.arrayViewsDuration.enumerated() {
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
                option.reminderOption = .twoHourBefore
            case 5:
                option.reminderOption = .oneWeekBefore
            case 6:
                option.reminderOption = .oneMonthBefore
            default:
                break
            }
        }
        self.updateDurationOptionSelection()
        self.updateCustomDurationlabel()
        self.pickerViewNumber.setValue(UIColor.white, forKeyPath: "textColor")
        self.pickerViewTimeUnit.setValue(UIColor.white, forKeyPath: "textColor")
    }
    
    func clearDurationOptionSelection() {
        self.arrayViewsDuration.forEach { (optionView) in
            optionView.setSelectionStatus(option: nil)
        }
    }
    
    func updateDurationOption(_ option: ReminderOptionView) {
        if self.durationModel.durationOption == .custom {
            self.buttonRemoveCustomDuration.sendActions(for: .touchUpInside)
        }
        self.durationModel.setReminderBefore(option: option.reminderOption)
        self.arrayViewsDuration.forEach { (optionView) in
            optionView.setSelectionStatus(option: option.reminderOption)
        }
    }
    
    func updateCustomDurationNumbers(unit: String) {
        switch unit {
        case Strings.minUnit:
            self.arrayCustomDurationNumbers = [15, 20, 25, 30, 35, 40, 45, 50, 55]
        case Strings.hourUnit:
            self.arrayCustomDurationNumbers = Array(1...23)
        default:
            break
        }
        self.durationModel.setDurationUnit(unit)
    }
    
    func updateCustomDurationUnit(unit: String) {
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
    
    func updatedCustomDurationValue(_ value: Int) {
        if let index = self.arrayCustomDurationNumbers.firstIndex(where: { (number) -> Bool in
            number == value
        }) {
            self.pickerViewNumber.selectRow(index, inComponent: 0, animated: true)
        }
        else {
            self.durationModel.setDurationValue(15)
            self.pickerViewNumber.selectRow(0, inComponent: 0, animated: true)
        }
    }
    
    func updateDurationOptionSelection() {
        if self.durationModel.durationOption != .custom {
            self.arrayViewsDuration.forEach { (optionView) in
                optionView.setSelectionStatus(option: self.durationModel.durationOption)
            }
        }
    }
    
    func updateCustomDurationlabel() {
        if self.durationModel.durationOption == .custom {
            self.viewCustomTimeLabel.isHidden = false
            self.labelCustomDuration.text = "\(self.durationModel.durationValue) \(self.durationModel.durationUnit)"
            if self.durationModel.durationOption == .custom, let view = self.scrollView {
                self.scrollView?.layoutIfNeeded()
                var bottomOffset = CGPoint(x: 0, y: view.contentSize.height - view.bounds.size.height)
                bottomOffset.y = bottomOffset.y > 0.0 ? bottomOffset.y : 0.0
                self.scrollView?.setContentOffset(bottomOffset, animated: true)
            }
        }
        else {
            self.viewCustomTimeLabel.isHidden = true
            self.labelCustomDuration.text = nil
        }
        
        self.buttonRemoveCustomDuration.isSelected = !self.viewCustomTimeLabel.isHidden
        self.buttonRemoveCustomDuration.isUserInteractionEnabled = !self.viewCustomTimeLabel.isHidden
    }
    
}
