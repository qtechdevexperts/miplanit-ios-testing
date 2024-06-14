//
//  CreateEventsViewController+TimeSlotDelegate.swift
//  MiPlanIt
//
//  Created by Febin Paul on 13/04/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation


extension CreateEventsViewController: TimeSlotViewControllerDelegate {
    
    func timeSlotViewControllerDelegateOnSave(_ timeSlotViewController: TimeSlotViewController, from startDate: Date, to endDate: Date) {
        self.viewDatePicker.isHidden = true
        self.buttonSingleDate.isSelected = false
        self.eventModel.startDate = startDate
        self.eventModel.endDate = endDate
        self.buttonTimeSlot.setTitle(startDate.getTime() + "-" + endDate.getTime(), for: .normal)
        self.buttonSingleDate.setTitle(startDate.stringFromDate(format: DateFormatters.DDHMMMMHYYYY), for: .normal)
        self.hideLabelBillDateError()
        self.updateInviteeStatus()
    }
}
