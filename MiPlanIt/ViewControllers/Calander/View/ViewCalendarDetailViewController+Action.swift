//
//  ViewCalendarDetailViewController+Action.swift
//  MiPlanIt
//
//  Created by Febin Paul on 20/08/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

extension ViewCalendarDetailViewController {
    
    func initialiseUIComponents() {
        self.tableView.isEditing = true
        self.labelCalendarName.text = self.calendar.name
        self.viewAddInvitees.isHidden = self.calendar.isSocialCalendar()
        self.manageUsersInviteeView()
        self.setCalendarImageColor()
        self.updateNotifiUserCount()
    }
    
    func updateNotifiUserCount() {
        self.viewNotify.isHidden = self.calendar.notifyUsers.isEmpty
        self.labelNotifyUserCount.isHidden = self.calendar.notifyUsers.isEmpty
        self.labelNotifyUserCount.text = "\(self.calendar.notifyUsers.count)"
    }
    
    func setCalendarImageColor() {
        if self.calendar.calendarImage.isEmpty {
            if self.calendar.isSocialCalendar(), let type = self.calendar.readValueOfCalendarTypeNewCalendar() {
                switch type {
                case "1":
                    self.imageViewCalendarImage.image = #imageLiteral(resourceName: "googleIcon")
                case "2":
                    self.imageViewCalendarImage.image = #imageLiteral(resourceName: "outlookIcon")
                case "3":
                    self.imageViewCalendarImage.image = #imageLiteral(resourceName: "appleIcon12")
                default:
                    break
                }
            }
            else {
                self.imageViewCalendarImage.image = #imageLiteral(resourceName: "calendar-image1")
            }
        }
        else {
            self.downloadCalendarImageFromServer()
        }
        self.imageViewColorCode.image = self.getCalendarColor()
    }
    
    func getCalendarColor() -> UIImage? {
        if !self.calendar.calendarColorCode.isEmpty {
            if let colorData = Storage().getAllColorCodes().filter({ $0.readColorCodeKey() == self.calendar.calendarColorCode }).first {
                return UIImage(named: colorData.colorCodeImageNameSelected)
            }
        }
        return nil
    }
    
    func manageUsersInviteeView() {
        self.tableView.reloadData()
        self.calculateTableViewHeight()
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
}


