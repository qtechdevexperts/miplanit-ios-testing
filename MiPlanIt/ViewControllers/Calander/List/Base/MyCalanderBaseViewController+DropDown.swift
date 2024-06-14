//
//  MyCalanderBaseViewController+DropDown.swift
//  MiPlanIt
//
//  Created by Nikhil RajG on 08/04/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

extension MyCalanderBaseViewController: CalendarListViewControllerDelegate {
    
    func calendarListViewControllerSuccessFullySyncedCalendar(_ controller: UserCalendarListViewController) {
        self.createServiceToFetchUsersData()
    }
    
    func calendarListViewController(_ controller: UserCalendarListViewController, selectedOptions: [PlanItCalendar], selectedUsers:[OtherUser]) {
        self.allAvailableCalendars = self.getAvailableCalendars()
        self.viewCalendarList.alpha = 0.0
        if !selectedOptions.isEmpty && !selectedUsers.isEmpty {
            self.viewCalendarList.showCalendarColor = selectedOptions.filter({ $0.readValueOfParentCalendarId() == "0" }).isEmpty
            self.calendarType = .OtherUser
            self.selectedCalanders = selectedOptions
            self.otherUsers = selectedUsers
        }
        else if !selectedOptions.isEmpty {
            self.viewCalendarList.showCalendarColor = true
            self.otherUsers.removeAll()
            self.showMiPlanItCalendarValues(selectedOptions)
        }
        else if !selectedUsers.isEmpty {
            self.viewCalendarList.showCalendarColor = false
            self.calendarType = .OtherUser
            self.selectedCalanders.removeAll()
            self.otherUsers = selectedUsers
        }
        else {
            self.showMiPlanItCalendarValues(self.readParentCalendars())
        }
    }
    
    func calendarListViewController(_ controller: UserCalendarListViewController, deleted calendars: [PlanItCalendar]) {
        self.allAvailableCalendars = self.getAvailableCalendars()
        self.deleteSpecificCalendars(calendars)
    }
    
    func calendarListViewController(_ controller: UserCalendarListViewController, updated calendars: [PlanItCalendar]) {
        if self.selectedCalanders.contains(where: { return calendars.contains($0) }) || self.selectedCalanders.contains(where: { return $0.parentCalendarId == 0}) {
            self.viewCalendarList.reloadCalendarListWith(self.selectedCalanders)
            self.refreshEvents()
        }
    }
}


extension MyCalanderBaseViewController: UsersListViewDelegate {
    
    func showUsersListInLargeView(_ view: UsersListView) {
        //self.performSegue(withIdentifier: Segues.toInviteesList, sender: self)
    }
    
    func showUsersCalendar(_ view: UsersListView) {
        self.performSegue(withIdentifier: Segues.toShowAllCalendars, sender: self)
    }
    
    func showAllCalendars(_ view: UsersListView) {
        self.performSegue(withIdentifier: Segues.toShowAllCalendars, sender: self)
    }
}


extension MyCalanderBaseViewController: ExpandedMenuViewControllerDelegate {
    
    func expandedMenuViewControllerAddingCalendar(_ expandedMenuViewController: ExpandedMenuViewController) {
        if Session.shared.readIsExhausted() {
            self.showExhaustedAlert()
            return
        }
        self.performSegue(withIdentifier: Segues.toAddCalendar, sender: self)
    }
    
    func expandedMenuViewControllerAddingEvent(_ expandedMenuViewController: ExpandedMenuViewController) {
        if Session.shared.readIsExhausted() {
            self.showExhaustedAlert()
            return
        }
        self.performSegue(withIdentifier: Segues.toAddNewEventScreen, sender: self)
    }
    
    func expandedMenuViewControllerAddingShareLink(_ expandedMenuViewController: ExpandedMenuViewController) {
        if Session.shared.readIsExhausted() {
            self.showExhaustedAlert()
            return
        }
        self.performSegue(withIdentifier: Segues.toAddNewShareLink, sender: self)
    }
}
