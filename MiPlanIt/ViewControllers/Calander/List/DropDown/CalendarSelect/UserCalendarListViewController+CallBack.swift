//
//  UserCalendarListViewController+CallBack.swift
//  MiPlanIt
//
//  Created by Aneesh Asokan on 08/07/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

extension UserCalendarListViewController: AddCalendarViewControllerDelegate {
    
    func addCalendarViewController(_ viewController: AddCalendarViewController, createdNewCalendar calendar: PlanItCalendar) {
        if !self.updatedCalendars.contains(calendar) { self.updatedCalendars.append(calendar) }
        self.tableView.reloadData()
    }
}

extension UserCalendarListViewController: ShareMiPlaniTCalendarViewControllerDelegate {
    
    func shareMiPlaniTCalendarViewController(_ shareMiPlaniTCalendarViewController: ShareMiPlaniTCalendarViewController, onIndex: IndexPath, selected invitees: CalendarInvitees) {
        self.createWebServiceDefaultCalendarShare(invitees: invitees, calendar: self.userAvailableCalendarTypes[onIndex.section].calendars[onIndex.row].calendar, index: onIndex)
    }
}
