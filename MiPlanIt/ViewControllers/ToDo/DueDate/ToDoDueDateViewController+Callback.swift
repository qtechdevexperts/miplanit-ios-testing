//
//  ToDoDueDateViewController+Callback.swift
//  MiPlanIt
//
//  Created by Febin Paul on 09/03/21.
//  Copyright © 2021 Arun. All rights reserved.
//

import Foundation

extension DueDateViewController: DayDatePickerDelegate {
    
    func dayDatePicker(_ dayDatePicker: DayDatePicker, selectedDate: Date) {
        self.selectedDate = selectedDate
    }
    
}
