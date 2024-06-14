//
//  CreateEventsViewController+CalendarDelegate.swift
//  MiPlanIt
//
//  Created by Febin Paul on 12/04/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

extension CreateEventsViewController: DayDatePickerDelegate {
    
    func dayDatePicker(_ dayDatePicker: DayDatePicker, selectedDate: Date) {
        self.dayDatePickerValueChanged(selectedDate.initialHour())
    }
}

extension CreateEventsViewController: FSCalendarDataSource, FSCalendarDelegate	 {
    
    func minimumDate(for calendar: FSCalendar) -> Date {
        return Date() >= Date().initialHour().adding(hour: 24).adding(minutes: -30) ? Date().adding(days: 1) : Date()
    }
    
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        self.view.layoutIfNeeded()
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        for eachButton in self.buttonToggleCalendar {
            if eachButton.isSelected {
                if self.switchIsAllDay.isOn {
                    if eachButton.tag == 2 {
                        let order = Calendar.current.compare(self.eventModel.startDate, to: date, toGranularity: .day)
                        if order == .orderedDescending || order == .orderedSame {
                            break
                        }
                        self.eventModel.endDate = date
                    }
                    else {
                        let order = Calendar.current.compare(self.eventModel.endDate, to: date, toGranularity: .day)
                        if order == .orderedAscending {
                            self.eventModel.endDate = date
                            self.buttonAllDatEndDate.setTitle(self.eventModel.endDate.stringFromDate(format: DateFormatters.EEEDDHMMMHYYY), for: .normal)
                        }
                        self.eventModel.startDate = date
                    }
                }
                else {
                    let timeSeconds = self.eventModel.startDate.getTimeSeconds()
                    let startDate = date.adding(seconds: timeSeconds)
                    self.setStartEndDate(startDate: startDate < Date() ? Date().nearestHalfHour() : startDate)
                }
                eachButton.setTitle(date.stringFromDate(format: DateFormatters.EEEDDHMMMHYYY), for: .normal)
                break
            }
        }
        self.updateInviteeStatus()
    }
    
    func updateYear(for calendar: FSCalendar) {
        
    }
}
