//
//  AddPurchaseViewController+CalendarDelegate.swift
//  MiPlanIt
//
//  Created by Febin Paul on 12/04/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

extension AddPurchaseViewController: FSCalendarDataSource, FSCalendarDelegate	 {
    
//    func minimumDate(for calendar: FSCalendar) -> Date {
//        return Date().initialHour() > Date().initialHour().adding(hour: 24).adding(minutes: -30) ? Date().adding(days: 1) : Date()
//    }
    
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        self.view.layoutIfNeeded()
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        self.purchaseModel.setBiilDate(date: date)
        self.labelBillDate.text = date.stringFromDate(format: DateFormatters.EEEEMMMDDYYYY)
        self.viewBillBorder.backgroundColor = UIColor.init(red: 233/255.0, green: 233/255.0, blue: 233/255.0, alpha: 1)
        self.labelBillDateError.isHidden = true
    }
    
    
    func updateYear(for calendar: FSCalendar) {
        
    }
}


extension AddPurchaseViewController: DayDatePickerDelegate {
    
    func dayDatePicker(_ dayDatePicker: DayDatePicker, selectedDate: Date) {
        self.updateDateChanged(selectedDate)
    }
}
