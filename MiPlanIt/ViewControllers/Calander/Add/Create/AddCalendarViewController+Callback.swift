//
//  AddCalendarViewController+Callback.swift
//  MiPlanIt
//
//  Created by Febin Paul on 06/04/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

extension AddCalendarViewController: CalendarInvitiesCellDelegare {
    
    func calendarInvitiesCell(_ calendarInvitiesCell: CalendarInvitiesCell, removedUser user: CalendarUser) {
        if calendarInvitiesCell.section == 0 {
            self.calendar.fullAccesUsers.removeAll(where: { $0 == user })
        }
        else {
            self.calendar.partailAccesUsers.removeAll(where: { $0 == user })
        }
        self.manageUsersInviteeView()
    }
}


extension AddCalendarViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.calendar.name = textField.text ?? Strings.empty
        self.imageViewDefaultUser.alpha = 1.0
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.imageViewDefaultUser.alpha = 0.1
    }
}

extension AddCalendarViewController: InviteUsersViewControllerDelegate {
    
    func inviteUsersViewController(_ viewController: InviteUsersViewController, selected invitees: CalendarInvitees) {
        self.calendar.fullAccesUsers = invitees.fullAccesUsers
        self.calendar.partailAccesUsers = invitees.partailAccesUsers
        self.manageUsersInviteeView()
    }
}


extension AddCalendarViewController: CalendarImageViewDelegate {
    
    func calendarImageView(_ calendarImageView: CalendarImageView, selectedImage: UIImage?) {
        self.arrayCalendarImageViews.forEach { (view) in
            view.resetSelection()
        }
        calendarImageView.setSelection()
        self.imageViewCalendarImage.image = selectedImage
    }
}

extension AddCalendarViewController: ProfileMediaDropDownViewControllerDelegate {
    
    func profileMediaDropDownViewController(_ controller: ProfileMediaDropDownViewController, selectedOption: DropDownItem) {
        if Session.shared.readIsExhausted() {
            self.showExhaustedAlert()
            return
        }
        switch selectedOption.dropDownType {
        case .eCamera:
            self.capturePhotoFromDevice()
        case .eGallery:
            self.captureMediaFromDeviceLibrary()
        default: break
        }
    }
}

extension AddCalendarViewController: CalendarColorViewDelegate {
    
    func calendarColorView(_ calendarColorView: CalendarColorView, selectedColorCode: String) {
        self.calendar.calendarColorCode = selectedColorCode
    }
}

extension AddCalendarViewController: NotifyUserViewControllerDelegate {
    
    func notifyUserViewController(_ viewController: NotifyUserViewController, selected users: [CalendarUser]) {
        self.calendar.notifyUsers = users
        self.updateNotifiUserCount()
    }
}
