//
//  AddCalendarViewController+Action.swift
//  MiPlanIt
//
//  Created by Arun on 12/04/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation
import UIKit

extension AddCalendarViewController {
    
    func initialiseUIComponents() {
        self.tableView.isEditing = true
        self.textFieldCalendarName.text = self.calendar.name
        self.labelCalendarTitle.text = self.calendar.name.isEmpty ? Strings.addNewCalendar : Strings.editCalnder
        self.viewAddInvitees.isHidden = self.calendar.isSocialCalendar()
        self.viewNotifyUsers.isHidden = !self.calendar.isNotifyCalendar() 
        self.manageUsersInviteeView()
        self.setCalendarImageColor()
        self.updateNotifiUserCount()
        self.inviteUserButton.setGradientBackground(colors: UIColor.primaryButtonGradient)
    }
    
    @objc func triggerEventUpdateFromNotification(_ notification: Notification) {
        
    }
    
    func updateNotifiUserCount() {
        self.labelNotifyUser.isHidden = self.calendar.notifyUsers.isEmpty
        self.labelNotifyUser.text = "\(self.calendar.notifyUsers.count)"
    }
    
    func setCalendarImageColor() {
        self.arrayCalendarImageViews.forEach { (view) in
            view.buttonImage.isSelected = false
            view.delegate = self
        }
        if self.calendar.calendarImage.isEmpty {
            if self.calendar.isSocialCalendar(), let type = self.calendar.readValueOfCalendarTypeNewCalendar() {
                switch type {
                case "1":
                    self.imageViewCalendarImage.image = #imageLiteral(resourceName: "googleIcon")
                case "2":
                    self.imageViewCalendarImage.image = #imageLiteral(resourceName: "outlookIcon")
                case "3":
                    self.imageViewCalendarImage.image = #imageLiteral(resourceName: "appleIcon")
                default:
                    break
                }
            }
            else {
                self.imageViewCalendarImage.image = #imageLiteral(resourceName: "defaultCalendarIcon") 
            }
        }
        else {
            self.downloadCalendarImageFromServer()
        }
        self.viewCalendarColor.delegate = self
        self.viewCalendarColor.setSelectionForColor(colorCode: self.calendar.calendarColorCode)
    }
    
    func manageUsersInviteeView() {
       self.viewImageHolder.isHidden = !self.calendar.fullAccesUsers.isEmpty || !self.calendar.partailAccesUsers.isEmpty
        self.tableView.reloadData()
        self.calculateTableViewHeight()
    }
    
    func validateCalendarName() -> Bool {
        self.view.endEditing(true)
        var userCalendarStatus = false
        do {
            userCalendarStatus = try self.textFieldCalendarName.validateTextWithType(.username)
        } catch {
            self.textFieldCalendarName.showError(Message.incorrectCalendarName, animated: true)
        }
        
        if userCalendarStatus && DatabasePlanItCalendar().checkCalendarNameExist(self.textFieldCalendarName.text!) && self.calendar.planItCalendar == nil {
            userCalendarStatus = false
            self.textFieldCalendarName.showError(Message.calendarNameExist, animated: true)
        }
        return userCalendarStatus
    }
    
    func calculateTableViewHeight() {
        var height: CGFloat = 0.0
        if !self.calendar.fullAccesUsers.isEmpty {
            height += 20
            height += CGFloat(self.calendar.fullAccesUsers.count*75)
            height += 20
        }
        else {
            height += 100
        }
        if !self.calendar.partailAccesUsers.isEmpty {
            height += 20
            height += CGFloat(self.calendar.partailAccesUsers.count*75)
            height += 20
        }
        else {
            height += 100
        }
        self.constraintTableViewHeight.constant = height > 100 ? height : 100
    }
    
    func downloadCalendarImageFromServer() {
        self.imageViewCalendarImage.pinImageFromURL(URL(string: self.calendar.calendarImage), placeholderImage: nil)
    }
    
    func isHelpShown() -> Bool {
        return Storage().readBool(UserDefault.notifyCalendarHelp) ?? false
    }
}
