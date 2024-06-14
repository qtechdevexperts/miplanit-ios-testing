//
//  ReminderBaseViewController+Delegatd.swift
//  MiPlanIt
//
//  Created by Febin Paul on 12/08/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

extension  ReminderBaseViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
         return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == self.pickerViewNumber {
            return self.arrayCustomReminderNumbers.count
        }
        return self.arrayUnits.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerView == self.pickerViewNumber ? String(self.arrayCustomReminderNumbers[row]) : self.arrayUnits[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 40.0
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == self.pickerViewTimeUnit {
            switch row {
            case 0:
                self.updateCustomReminderNumbers(unit: Strings.minUnit)
            case 1:
                self.updateCustomReminderNumbers(unit: Strings.hourUnit)
            case 2:
                self.updateCustomReminderNumbers(unit: Strings.dayUnit)
            case 3:
                self.updateCustomReminderNumbers(unit: Strings.weekUnit)
            case 4:
                self.updateCustomReminderNumbers(unit: Strings.monthUnit)
            default:
                break
            }
            var selectedRow = self.pickerViewNumber.selectedRow(inComponent: 0)
            if selectedRow >= self.arrayCustomReminderNumbers.count {
                selectedRow = self.arrayCustomReminderNumbers.count - 1
            }
            self.remindModel.setReminderBeforeValue(self.arrayCustomReminderNumbers[selectedRow])
        }
        else if pickerView == self.pickerViewNumber {
            self.remindModel.setReminderBeforeValue(self.arrayCustomReminderNumbers[row])
        }
        self.remindModel.setReminderBefore(option: .custom)
        self.updateCustomReminderlabel()
    }

}
