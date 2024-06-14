//
//  AddDurationViewController+Delagate.swift
//  MiPlanIt
//
//  Created by Febin Paul on 26/03/21.
//  Copyright © 2021 Arun. All rights reserved.
//

import Foundation


extension  AddDurationViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
         return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == self.pickerViewNumber {
            return self.arrayCustomDurationNumbers.count
        }
        return self.arrayUnits.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerView == self.pickerViewNumber ? String(self.arrayCustomDurationNumbers[row]) : self.arrayUnits[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 40.0
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == self.pickerViewTimeUnit {
            switch row {
            case 0:
                self.updateCustomDurationNumbers(unit: Strings.minUnit)
            case 1:
                self.updateCustomDurationNumbers(unit: Strings.hourUnit)
            default:
                break
            }
            var selectedRow = self.pickerViewNumber.selectedRow(inComponent: 0)
            if selectedRow >= self.arrayCustomDurationNumbers.count {
                selectedRow = self.arrayCustomDurationNumbers.count - 1
            }
            self.durationModel.setDurationValue(self.arrayCustomDurationNumbers[selectedRow])
        }
        else if pickerView == self.pickerViewNumber {
            switch self.durationModel.readDurationTypeInt() {
            case 1:
                self.durationModel.setDurationValue(self.arrayCustomDurationNumbers[row])
            case 2:
                self.durationModel.setDurationValue(self.arrayCustomDurationNumbers[row])
            default:
                break
            }
        }
        self.durationModel.setReminderBefore(option: .custom)
        self.updateCustomDurationlabel()
    }

}

