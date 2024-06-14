//
//  CreateEventsViewController+Action.swift
//  MiPlanIt
//
//  Created by Febin Paul on 09/04/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
//import RRuleSwift

extension CreateEventsViewController {
    
    func initialiseTagCollectionFlowLayout() {
        self.lottieAnimationView.backgroundBehavior = .pauseAndRestore
        self.lottieAnimationView2.backgroundBehavior = .pauseAndRestore
    }
    
    func setIntialValuesForScreenComponents() {
        self.viewInviteeList.bubbleAlignment = .right
        self.viewInviteeList.maxNumberOfBubbles = 3
        self.titles = self.eventModel.tags
        self.setEventValue()
        self.buttonCalendar.setTitle(self.setCalendarName(), for: .normal)
        self.buttonNotifyCalendar.setTitle( self.eventModel.notifycalendars.isEmpty ? Strings.empty : "\(self.eventModel.notifycalendars.count) Selected", for: .normal)
        self.eventModel.eventId != nil ? self.callServiceToFetchEventInviteeUserDetails() : self.callServiceToFetchCalendarUserDetails()
        self.buttonCalendar.isUserInteractionEnabled = self.isUpdatingMiCalendarEvent()
        self.imageViewCalendarSideArrow.isHidden = !self.buttonCalendar.isUserInteractionEnabled 
        self.viewRepeat.isHidden = self.eventModel.editType == .thisPerticularEvent
        self.constraintViewRepeatHeight.constant = (self.eventModel.editType == .thisPerticularEvent) ? 0 : 60.0
        self.dayDatePicker.dataSource = self.dayDatePicker
        self.dayDatePicker.delegate = self.dayDatePicker
        self.dayDatePicker.dayDatePickerDelegate = self
        self.dayDatePicker.setUpData()
        self.dayDatePicker.setValue(UIColor.white, forKeyPath: "textColor")
    }
    
    func setCalendarName() -> String? {
        if self.eventModel.readMainCalendar()?.parentCalendarId == 0.0 {
            return (self.eventModel.readMainCalendar()?.readValueOfOrginalCalendarName() ?? Strings.empty)
        }
        return self.eventModel.readMainCalendar()?.readValueOfOrginalCalendarName()
    }
    
    func isUpdatingMiCalendarEvent() -> Bool {
        if self.eventModel.isEdit() {
            if let calendar = self.eventModel.readMainCalendar(), calendar.isSocialCalendar() {
                return false
            }
            return (self.eventModel.editType == .default || self.eventModel.editType == .allEventInTheSeries) ? true : false
        }
        return true
    }
    
    func setEventValue() {
        if let offsetDateTime = self.selectedDateTime {
            self.eventModel.startDate =  offsetDateTime.previoustHalfHour()
            self.eventModel.endDate = offsetDateTime.previoustHalfHour().adding(seconds: 1800)
        }
        else if let selectedDate = self.selectedData?.initialHour(), selectedDate >= Date().initialHour() {
            let offsetSeconds = Date().getTimeSeconds()
            let finalDate = selectedDate.adding(seconds: offsetSeconds)
            let actualDate = finalDate.adding(seconds: Int(TimeZone.current.daylightSavingTimeOffset(for: selectedDate)) - Int(TimeZone.current.daylightSavingTimeOffset(for: finalDate)))
            self.eventModel.startDate = actualDate.nearestHalfHour()
            let endDate = actualDate.nearestHalfHour().adding(seconds: 1800)
            if let endOfDay = self.eventModel.startDate.endOfDay, endDate > endOfDay {
                self.eventModel.endDate = endDate.adding(minutes: -1)
            }
            else {
                self.eventModel.endDate = endDate
            }
        }
        
        self.buttonTimeSlot.setTitle(self.eventModel.startDate.getTime() + "-" + self.eventModel.endDate.getTime(), for: .normal)
        if let calendar = self.selectedCalendar {
            self.eventModel.calendars = [UserCalendarVisibility(with: calendar)]
        }
        let startDateString = self.eventModel.startDate.stringFromDate(format: DateFormatters.DDHMMMMHYYYY)
//        if let dateEvent = self.eventModel.dateEvent {
//            startDateString = self.eventModel.isRecurrance ? (dateEvent.startDate.adding(seconds: self.eventModel.startDate.getTimeSeconds()).stringFromDate(format: DateFormatters.DDHMMMMHYYYY)) : (self.eventModel.startDate.stringFromDate(format: DateFormatters.DDHMMMMHYYYY))
//        }
        self.buttonToggleCalendar.forEach({ $0.setTitle(startDateString, for: .normal)})
        self.textFieldEventName.text = self.eventModel.eventName != Strings.empty ? self.eventModel.eventName : Strings.empty
        if self.eventModel.invitees.count > 0 { self.updateInviteesUI() }
        self.textFieldLocation.text = self.eventModel.location
        var attributedString = NSAttributedString(string: self.eventModel.eventDescription, attributes: [.font: UIFont(name: Fonts.SFUIDisplayRegular, size: 16)!])
        if self.eventModel.eventDescription.filter({ !$0.isWhitespace }).isHtml() {
            attributedString = try! NSAttributedString(data: self.makeDescription(description: self.eventModel.eventDescription, htmlString: self.eventModel.otherLinks).data(using: .utf8)!, options: [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil)
        }
        self.textViewDescription.attributedText = attributedString
        self.textViewDescription.textColor = .white
        self.switchIsTravelling.setOn(self.eventModel.isTravelling, animated: false)
        self.switchIsAllDay.setOn(self.eventModel.isAllday, animated: false)
        self.viewSingleDay.isHidden = self.eventModel.isAllday
        self.viewAllDay.isHidden = !self.eventModel.isAllday
        if self.eventModel.isAllday {
            self.buttonAllDayStartDate.setTitle(self.eventModel.startDate.stringFromDate(format: DateFormatters.DDHMMMMHYYYY), for: .normal)
            self.buttonAllDatEndDate.setTitle(self.eventModel.showDateOnChangeAllDay().stringFromDate(format: DateFormatters.DDHMMMMHYYYY), for: .normal)
        }
        self.setRepeatTitle(rule: self.eventModel.recurrence)
        self.labelEventTitle.text = self.eventModel.eventId == nil ? Strings.createNewEvent : Strings.editEvent
        self.showTagsCount()
        self.updateRemindMeTitle()
    }
    
    func makeDescription(description: String, htmlString: String) -> String {
        return description
    }
    
    func updateRemindMeTitle() {
        if let remider = self.eventModel.remindValue {
            self.imageReminderSideArrow.isHidden = true
            self.buttonRemoveReminder.isHidden = false
            self.buttonRemind.setTitle("\(remider.reminderBeforeValue) \(remider.reminderBeforeUnit) before\(remider.readIsAllDayEvent() ? " "+remider.readReminderTimeString() : Strings.empty)", for: .normal)
        }
        else {
            self.buttonRemind.setTitle(Strings.never, for: .normal)
            self.imageReminderSideArrow.isHidden = false
            self.buttonRemoveReminder.isHidden = true
        }
    }
    
    func setRepeatTitle(rule: String) {
        var repeatText = ""
        if let rrRuleObject = RecurrenceRule(rruleString: rule) {
            switch rrRuleObject.frequency {
            case .daily:
                repeatText = rule.contains("BYMONTH=") ? "Yearly" : "Daily"
            case .weekly:
                repeatText = "Weekly"
            case .monthly:
                repeatText = "Monthly"
            case .yearly:
                repeatText = "Yearly"
            default:
                repeatText = ""
            }
        }
        self.buttonRepeat.setTitle(repeatText, for: .normal)
    }
    
    func showTagsCount() {
        self.labelEventTagCount.text = "\(self.eventModel.tags.count)"
        self.labelEventTagCount.isHidden = self.eventModel.tags.isEmpty
    }
    
    func startFindingInvitees() {
        self.buttonInvitees.isHidden = true
        self.buttonInviteesArrow.isHidden = true
        self.lottieAnimationView2.isHidden = false
        self.lottieAnimationView2.loopMode = .loop
        self.lottieAnimationView2.play()
    }
    
    func stopFindingInvitees() {
        self.buttonInvitees.isHidden = false
        self.buttonInviteesArrow.isHidden = false
        self.lottieAnimationView2.isHidden = true
        self.lottieAnimationView2.stop()
    }
    
    func resetAllButton(except: UIButton? = nil) {
        self.view.endEditing(true)
        self.buttonToggleCalendar.forEach { (button) in
            if let btn = except, btn == button { return }
            button.isSelected = false
        }
    }
    
    func dayDatePickerValueChanged(_ date: Date) {
        for eachButton in self.buttonToggleCalendar {
            if eachButton.isSelected {
                if self.switchIsAllDay.isOn {
                    if eachButton.tag == 2 {
                        let order = Calendar.current.compare(self.eventModel.startDate, to: date, toGranularity: .day)
                        if order == .orderedDescending {
                            break
                        }
                        self.eventModel.endDate = date.addDays(1)
                    }
                    else {
                        let order = Calendar.current.compare(self.eventModel.endDate, to: date, toGranularity: .day)
                        if order == .orderedAscending || order == .orderedSame {
                            self.eventModel.endDate = date.addDays(1)
                            self.buttonAllDatEndDate.setTitle(self.eventModel.showDateOnChangeAllDay().stringFromDate(format: DateFormatters.DDHMMMMHYYYY), for: .normal)
                        }
                        self.eventModel.startDate = date
                    }
                }
                else {
                    let timeSeconds = self.eventModel.startDate.getTimeSeconds()
                    let startDate = date.adding(seconds: timeSeconds)
                    self.setStartEndDate(startDate: startDate)
                }
                eachButton.setTitle(date.stringFromDate(format: DateFormatters.DDHMMMMHYYYY), for: .normal)
                break
            }
        }
        self.hideLabelBillDateError()
        self.updateInviteeStatus()
    }
    
    func datePickerValueUpdate(sender: UIDatePicker) {
        for eachButton in self.buttonToggleCalendar {
            if eachButton.isSelected {
                if self.switchIsAllDay.isOn {
                    if eachButton.tag == 2 {
                        let order = Calendar.current.compare(self.eventModel.startDate, to: self.datePicker.date, toGranularity: .day)
                        if order == .orderedDescending {
                            break
                        }
                        self.eventModel.endDate = self.datePicker.date.addDays(1)
                    }
                    else {
                        let order = Calendar.current.compare(self.eventModel.endDate, to: self.datePicker.date, toGranularity: .day)
                        if order == .orderedAscending || order == .orderedSame {
                            self.eventModel.endDate = self.datePicker.date.addDays(1)
                            self.buttonAllDatEndDate.setTitle(self.eventModel.showDateOnChangeAllDay().stringFromDate(format: DateFormatters.DDHMMMMHYYYY), for: .normal)
                        }
                        self.eventModel.startDate = self.datePicker.date
                    }
                }
                else {
                    let timeSeconds = self.eventModel.startDate.getTimeSeconds()
                    let startDate = self.datePicker.date.adding(seconds: timeSeconds)
                    self.setStartEndDate(startDate: startDate)
                }
                eachButton.setTitle(self.datePicker.date.stringFromDate(format: DateFormatters.DDHMMMMHYYYY), for: .normal)
                break
            }
        }
        self.hideLabelBillDateError()
        self.updateInviteeStatus()
    }
    
    func updateInviteeStatus() {
        self.eventModel.invitees.forEach { (invitees) in
            _ = invitees.checkUserStatus(from: self.eventModel.startDate, to: self.eventModel.endDate)
        }
        self.viewInviteeList.reloadUsersListWith(self.eventModel.invitees, enableEventColor: false)
    }
    
    func updateInviteesUI() {
        self.viewInviteeList.reloadUsersListWith( self.eventModel.invitees, enableEventColor: false)
        self.buttonInvitees.setTitle(  self.eventModel.invitees.isEmpty ? Strings.empty : "\( self.eventModel.invitees.count) \( self.eventModel.invitees.count > 1 ? "people" : "person")", for: .normal)
        self.updateInviteeStatus()
    }
    
    func validateMandatoryFields() -> Bool {
        self.view.endEditing(true)
        var eventNameStatus = true
        if self.eventModel.eventName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            eventNameStatus = false
            self.textFieldEventName.showError(Message.eventNameError, animated: true)
        }
        return eventNameStatus
    }
    
    func hideLabelBillDateError() {
        self.viewBillBorder.backgroundColor = UIColor.init(red: 233/255.0, green: 233/255.0, blue: 233/255.0, alpha: 1)
        self.labelBillDateError.isHidden = true
    }
    
    func setStartEndDate(startDate: Date) {
        let actualTime = startDate.adding(seconds: Int(TimeZone.current.daylightSavingTimeOffset(for: startDate.initialHour())) - Int(TimeZone.current.daylightSavingTimeOffset(for: startDate)))
        self.eventModel.startDate = actualTime
        self.eventModel.endDate = self.eventModel.startDate.adding(seconds: 1800)
        self.buttonTimeSlot.setTitle(self.eventModel.startDate.getTime() + "-" + self.eventModel.endDate.getTime(), for: .normal)
    }
    
    func updateAllDateWithButton() {
        if self.eventModel.isAllday {
            self.buttonAllDayStartDate.setTitle(self.buttonSingleDate.titleLabel?.text, for: .normal)
            self.buttonAllDatEndDate.setTitle(self.buttonAllDayStartDate.titleLabel?.text, for: .normal)
            if let startDateString = self.buttonAllDayStartDate.titleLabel?.text, let endDate = self.buttonAllDatEndDate.titleLabel?.text {
                let startDate = startDateString.toDate(withFormat: DateFormatters.DDHMMMMHYYYY) ?? Date()
                self.eventModel.startDate = Calendar.current.isDateInToday(startDate) ? Date().nearestHalfHour() : startDate
                self.eventModel.endDate = startDateString == endDate ? (endDate.toDate(withFormat: DateFormatters.DDHMMMMHYYYY)?.adding(hour: 24) ?? Date()) : (endDate.toDate(withFormat: DateFormatters.DDHMMMMHYYYY) ?? Date()).addDays(1)
                self.buttonAllDatEndDate.setTitle(self.eventModel.showDateOnChangeAllDay().stringFromDate(format: DateFormatters.DDHMMMMHYYYY), for: .normal)
            }
        }
        else  {
            self.buttonSingleDate.setTitle(self.buttonAllDayStartDate.titleLabel?.text, for: .normal)
            if let stringStartDate = self.buttonSingleDate.titleLabel?.text {
                let startDate = stringStartDate.toDate(withFormat: DateFormatters.DDHMMMMHYYYY) ?? Date()
                self.setStartEndDate(startDate: Calendar.current.isDateInToday(startDate) ? Date().nearestHalfHour() : startDate)
            }
        }
    }
}
