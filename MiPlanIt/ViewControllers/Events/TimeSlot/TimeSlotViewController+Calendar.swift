//
//  TimeSlotViewController+CalendarDelegate.swift
//  MiPlanIt
//
//  Created by Febin Paul on 13/04/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

extension TimeSlotViewController: FSCalendarDataSource, FSCalendarDelegate {
    
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        self.view.layoutIfNeeded()
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        let selectedStartingDate = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: date)!
        let diffTimeInterval = (self.endingTime.timeIntervalSince1970 - self.startingTime.timeIntervalSince1970)
        self.startingTime = selectedStartingDate.adding(seconds: self.getHoursMinutesToSeconds(of: self.startingTime))
        self.endingTime = self.startingTime.addingTimeInterval(diffTimeInterval)
        self.buttonDate.setTitle(date.stringFromDate(format: DateFormatters.EEEDDHMMMHYYY), for: .normal)
        self.removeAllOtherUserEventTimeView()
        self.setOtherUserEventFrame()
        self.removeAllCurrentUserEventTimeView()
        self.setCurrentUserEventFrame()
        self.removeAllArrangedSubviews()
        self.setEventTimeView()
        self.updateInviteeStatus()
    }
    
    func updateYear(for calendar: FSCalendar) {
        
    }
}

