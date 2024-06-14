//
//  TimePickerViewController+Action.swift
//  MiPlanIt
//
//  Created by Febin Paul on 09/03/21.
//  Copyright © 2021 Arun. All rights reserved.
//

import Foundation

extension TimePickerViewController {
    
    func initializeUI() {
        self.datePicker.setDate(self.startingTime, animated: false)
    }
    
    func updateStartTime(_ date: Date) {
        self.startingTime = date
        if self.endingTime <= self.startingTime {
            self.endingTime = self.startingTime.adding(minutes: 15)
        }
    }
    
    func updateEndTime(_ date: Date) {
        self.endingTime = date
        if self.endingTime <= self.startingTime {
            self.startingTime = self.endingTime.adding(minutes: -15)
        }
    }
}
