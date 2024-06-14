//
//  CreateShareLinkViewController+Action.swift
//  MiPlanIt
//
//  Created by Febin Paul on 26/03/21.
//  Copyright © 2021 Arun. All rights reserved.
//

import Foundation
// import RRuleSwift

extension CreateShareLinkViewController {
    
    func setIntialValuesForScreenComponents() {
        self.dayDatePicker.dataSource = self.dayDatePicker
        self.dayDatePicker.delegate = self.dayDatePicker
        self.dayDatePicker.dayDatePickerDelegate = self
        self.buttonCalendar.setTitle(self.setCalendarName(), for: .normal)
        self.dayDatePicker.setUpData()
        self.setEventValue()
//        self.buttonRemoveInvitee.isHidden = self.shareLinkModel.planItShareLink != nil || self.shareLinkModel.invitees.isEmpty
        self.buttonRemoveInvitee.isHidden = self.shareLinkModel.invitees.isEmpty
        self.dayDatePicker.setValue(UIColor.white, forKeyPath: "textColor")
    }
    
    func linkEndTimeInvalid() -> Bool {
        return self.shareLinkModel.endDate.initialHour().adding(seconds: self.shareLinkModel.endRangeTime.getTimeSeconds()) < Date()
    }
    
    func resetAllButton(except: UIButton? = nil) {
        self.view.endEditing(true)
        self.buttonToggleCalendar.forEach { (button) in
            if let btn = except, btn == button { return }
            button.isSelected = false
        }
    }
    
    func setEventValue() {
        self.switchExcludeWeekend.isOn = self.shareLinkModel.excludeWeekEnds
        let startDateString = self.shareLinkModel.startDate.stringFromDate(format: DateFormatters.DDHMMMMHYYYY)
        self.buttonToggleCalendar.forEach({ $0.setTitle(startDateString, for: .normal)})
        self.textFieldEventName.text = self.shareLinkModel.eventName != Strings.empty ? self.shareLinkModel.eventName : Strings.empty
        if self.shareLinkModel.invitees.count > 0 { self.updateInviteesUI() }
        self.imageViewSideArrowInvitee.isHidden = !self.shareLinkModel.invitees.isEmpty
        self.textFieldLocation.text = self.shareLinkModel.location
        var attributedString = NSAttributedString(string: self.shareLinkModel.eventDescription, attributes: [.font: UIFont(name: Fonts.SFUIDisplayRegular, size: 16)!])
        if self.shareLinkModel.eventDescription.filter({ !$0.isWhitespace }).isHtml() {
            attributedString = try! NSAttributedString(data: self.shareLinkModel.eventDescription.data(using: .utf8)!, options: [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil)
        }
        self.textViewDescription.attributedText = attributedString
        self.showTagsCount()
        self.updateRemindMeTitle()
        self.updateDurationUI()
        self.updateTimeRangeUI()
        self.setStartEndDate()
    }
    
    func setStartEndDate() {
        self.buttonStartDate.setTitle(self.shareLinkModel.startDate.stringFromDate(format: DateFormatters.DDHMMMMHYYYY), for: .normal)
        self.buttonEndDate.setTitle(self.shareLinkModel.endDate.stringFromDate(format: DateFormatters.DDHMMMMHYYYY), for: .normal)
    }
    
    func setCalendarName() -> String? {
        if self.shareLinkModel.readMainCalendar()?.parentCalendarId == 0.0 {
            return (self.shareLinkModel.readMainCalendar()?.readValueOfOrginalCalendarName() ?? Strings.empty)
        }
        return self.shareLinkModel.readMainCalendar()?.readValueOfOrginalCalendarName()
    }
    
    func showTagsCount() {
        self.labelShareLinkTagCount.text = "\(self.shareLinkModel.tags.count)"
        self.labelShareLinkTagCount.isHidden = self.shareLinkModel.tags.isEmpty
    }
    
    func dayDatePickerValueChanged(_ date: Date) {
        for eachButton in self.buttonToggleCalendar {
            if eachButton.isSelected {
                if eachButton.tag == 2 {
                    let order = Calendar.current.compare(self.shareLinkModel.startDate, to: date, toGranularity: .day)
                    if order == .orderedDescending {
                        break
                    }
                    self.shareLinkModel.endDate = date
                }
                else {
                    let order = Calendar.current.compare(self.shareLinkModel.endDate, to: date, toGranularity: .day)
                    if order == .orderedAscending || order == .orderedSame {
                        self.shareLinkModel.endDate = date
                        self.buttonEndDate.setTitle(self.shareLinkModel.showDateOnChangeStartDate().stringFromDate(format: DateFormatters.DDHMMMMHYYYY), for: .normal)
                    }
                    self.shareLinkModel.startDate = date
                }
                eachButton.setTitle(date.stringFromDate(format: DateFormatters.DDHMMMMHYYYY), for: .normal)
                break
            }
        }
    }
    
    func updateRemindMeTitle() {
        if let remider = self.shareLinkModel.remindValue {
            self.imageReminderSideArrow.isHidden = true
            self.buttonRemoveReminder.isHidden = false
            self.buttonRemind.setTitle("\(remider.reminderBeforeValue) \(remider.reminderBeforeUnit) before", for: .normal)
        }
        else {
            self.buttonRemind.setTitle(Strings.never, for: .normal)
            self.imageReminderSideArrow.isHidden = false
            self.buttonRemoveReminder.isHidden = true
        }
    }
    
    func updateInviteesUI() {
        self.buttonInvitees.setTitle(  self.shareLinkModel.invitees.isEmpty ? Strings.empty : "\(self.shareLinkModel.invitees.first?.email ?? Strings.empty)", for: .normal)
    }
    
    func updateDurationUI() {
        self.buttonDuration.setTitle(self.shareLinkModel.duration.readStringInterval()+" "+self.shareLinkModel.duration.durationUnit, for: .normal)
    }
    
    func updateStartEndTime() {
        let dateDiffrence = self.shareLinkModel.readStartEndRangeDiffrenceInSeconds()
        if self.shareLinkModel.duration.readDurationInSeconds() > dateDiffrence {
            var startDate = self.shareLinkModel.startRangeTime
            var endDate = self.shareLinkModel.startRangeTime.adding(seconds: self.shareLinkModel.duration.readDurationInSeconds())
            if (endDate > startDate.endOfDay ?? Date().nearestHalfHour()) {
                endDate = startDate.endOfDay ?? Date().nearestHalfHour()
                startDate = endDate.adding(seconds: -(self.shareLinkModel.duration.readDurationInSeconds()))
            }
            self.shareLinkModel.setStartEndRange(start: startDate, end: endDate)
            return
        }
    }
    
    func updateTimeRangeUI(onDurationUpdate: Bool = false) {
        if onDurationUpdate {
            self.updateStartEndTime()
        }
        self.buttonTimeRange.setTitle(self.shareLinkModel.startRangeTime.getTime()+" - "+self.shareLinkModel.endRangeTime.getTime(), for: .normal)
    }
    
    func validateMandatoryFields() -> Bool {
        self.view.endEditing(true)
        var eventNameStatus = true
        if self.shareLinkModel.eventName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            eventNameStatus = false
            self.textFieldEventName.showError(Message.eventNameError, animated: true)
        }
        else if self.shareLinkModel.invitees.isEmpty {
            eventNameStatus = false
            self.performSegue(withIdentifier: Segues.toMessageScreen, sender: [Message.warning, Message.inviteeMissingShareLink])
        }
        else if self.linkEndTimeInvalid() {
            eventNameStatus = false
            self.performSegue(withIdentifier: Segues.toMessageScreen, sender: [Message.warning, Message.invalidShareLinkShareLink])
        }
        return eventNameStatus
    }
    
    func confirmingSaveForPastDate(callback: @escaping (Bool)->Void) {
        if self.shareLinkModel.startDate.initialHour() < Date().initialHour() && self.shareLinkModel.planItShareLink == nil {
            self.showAlertWithAction(message: Message.pastScheduleShareLink, title: Message.confirm, items: [Message.yes, Message.no], callback: { index in
                index == 0 ? callback(true) : callback(false)
            })
        }
        else {
            callback(true)
        }
    }
}
