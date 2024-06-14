//
//  RepeatViewController+Delegate.swift
//  MiPlanIt
//
//  Created by Aneesh Asokan on 21/06/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

extension RepeatViewController: RepeatFullDropDownViewControllerDelegate {
    func repeatDropDownViewController(_ controller: RepeatFullDropDownViewController, selectedDone: RepeatDropDown) {
        switch self.dropDownCategory {
        case .eInterval:
            self.repeatModel.interval = selectedDone.dropDownItem
            self.txtFldInterval.text = selectedDone.dropDownItem.title
        case .eUntil:
            self.txtFldUntil.text = selectedDone.dropDownItem.title
        case .eOnDays:
            self.txtFldNoOfOccurences.text = selectedDone.dropDownItem.title
        case .eFrequency:
            break
        }
    }
}

extension RepeatViewController: RepeatMultiSelectionDropDownControllerDelegate {
    
    func repeatMultiSelectionDropDownController(_ repeatMultiSelectionDropDownController: RepeatMultiSelectionDropDownController, selectedItem: [Any]) {
        self.repeatModel.onDays.removeAll()
        if self.repeatModel.frequency.dropDownType == .eEveryWeek, let dropDownItems = selectedItem as? [DropDownItem] {
            dropDownItems.forEach { (items) in
                switch items.dropDownType {
                case .eSunday:
                    self.repeatModel.onDays.append(1)
                case .eMonday:
                    self.repeatModel.onDays.append(2)
                case .eTuesday:
                    self.repeatModel.onDays.append(3)
                case .eWednesday:
                    self.repeatModel.onDays.append(4)
                case .eThursday:
                    self.repeatModel.onDays.append(5)
                case .eFriday:
                    self.repeatModel.onDays.append(6)
                case .eSaturday:
                    self.repeatModel.onDays.append(7)
                default:
                    break
                }
            }
            self.setAllWeekDays()
        }
        else if self.repeatModel.frequency.dropDownType == .eEveryMonth, let dropDownItems = selectedItem as? [Int] {
            dropDownItems.forEach { (value) in
                self.repeatModel.onDays.append(value)
            }
            self.setAllDates()
        }
    }
}


extension RepeatViewController: RepeatUntilViewControllerDelegate {
    
    func repeatUntilViewController(_ RepeatUntilViewController: RepeatUntilViewController, isForever: Bool, untilDate: Date?) {
        if isForever {
            self.repeatModel.forever = true
            self.repeatModel.untilDate = nil
        }
        else if let date = untilDate {
            self.repeatModel.forever = false
            self.repeatModel.untilDate = date
        }
        self.setUntilDate()
    }
}
