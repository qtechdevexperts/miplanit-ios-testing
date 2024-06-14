//
//  CreateShareLinkViewController+Callback.swift
//  MiPlanIt
//
//  Created by Febin Paul on 26/03/21.
//  Copyright © 2021 Arun. All rights reserved.
//

import Foundation
import IQKeyboardManagerSwift

extension CreateShareLinkViewController: DayDatePickerDelegate {
    
    func dayDatePicker(_ dayDatePicker: DayDatePicker, selectedDate: Date) {
        self.dayDatePickerValueChanged(selectedDate.initialHour())
    }
}

extension CreateShareLinkViewController: CalendarListSelectionViewControllerDelegate {
    
    func calendarListSelectionViewController(_ controller: UserCalendarListSelectionViewController, selectedOptions: [UserCalendarVisibility]) {
        self.shareLinkModel.calendars = selectedOptions
        self.buttonCalendar.setTitle(self.shareLinkModel.readMainCalendar()?.readValueOfOrginalCalendarName(), for: .normal)
    }
}

extension CreateShareLinkViewController: AddInviteeShareLinkViewControllerDelegate {
    
    func addInviteeShareLinkViewController(_ addInviteeShareLinkViewController: AddInviteeShareLinkViewController, selectedAssige: CalendarUser?) {
        guard let user = selectedAssige else { return }
        self.buttonRemoveInvitee.isHidden = false
        self.imageViewSideArrowInvitee.isHidden = true
        self.shareLinkModel.invitees = [OtherUser(calendarUser: user)]
        self.updateInviteesUI()
    }
}

extension CreateShareLinkViewController: CommonMapViewControllerDelegate {
    
    func commonMapViewController(_ commonMapViewController: CommonMapViewController, selectedLocation: String, latitude: Double?, longitude: Double?) {
        self.textFieldLocation.text = self.shareLinkModel.setLocationFromMap(locationName: selectedLocation, latitude: latitude, longitude: longitude)
    }
}

extension CreateShareLinkViewController: ReminderBaseViewControllerDelegate {
    
    func reminderBaseViewController(_ reminderBaseViewController: ReminderBaseViewController, reminderValue: ReminderModel) {
        self.shareLinkModel.remindValue = reminderValue
        self.updateRemindMeTitle()
    }
    
    func reminderBaseViewControllerBackClicked(_ reminderBaseViewController: ReminderBaseViewController) {
        
    }    
}


extension CreateShareLinkViewController: TimeSlotViewControllerDelegate {
    
    func timeSlotViewControllerDelegateOnSave(_ timeSlotViewController: TimeSlotViewController, from startDate: Date, to endDate: Date) {
        self.shareLinkModel.setStartEndRange(start: startDate, end: endDate)
        self.updateTimeRangeUI()
    }
}


extension CreateShareLinkViewController: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
        switch textField {
        case self.textFieldLocation:
            self.textFieldLocation.text = self.shareLinkModel.setLocation(textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? Strings.empty)
        case self.textFieldEventName:
            self.shareLinkModel.eventName = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? Strings.empty
        default: break
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}


extension CreateShareLinkViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        IQKeyboardManager.shared.enableAutoToolbar = true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        textView.resignFirstResponder()
        IQKeyboardManager.shared.enableAutoToolbar = false
        if textView == self.textViewDescription {
            if let attributedText = textView.attributedText {
                if !attributedText.string.isHtml() {
                    self.shareLinkModel.eventDescription = attributedText.string.trimmingCharacters(in: .whitespacesAndNewlines)
                }
                else {
                    do {
                        let htmlData = try attributedText.data(from: .init(location: 0, length: attributedText.length), documentAttributes: [.documentType: NSAttributedString.DocumentType.html])
                        let htmlString = String(data: htmlData, encoding: .utf8) ?? ""
                        self.shareLinkModel.eventDescription = htmlString.trimmingCharacters(in: .whitespacesAndNewlines)
                    } catch {
                        print(error)
                    }
                }
            }
        }
    }
}

extension CreateShareLinkViewController: AddDurationViewControllerDelegate {
    
    func addDurationViewController(_ addDurationViewController: AddDurationViewController, duartion: DurationModel) {
        self.shareLinkModel.duration = duartion
        self.updateDurationUI()
        self.updateTimeRangeUI(onDurationUpdate: true)
    }
}

extension CreateShareLinkViewController: AddEventTagViewControllerDelegate {
    
    func addEventTagViewController(_ viewController: AddEventTagViewController, updated tags: [String]) {
        self.shareLinkModel.tags = tags
        self.showTagsCount()
    }
}
