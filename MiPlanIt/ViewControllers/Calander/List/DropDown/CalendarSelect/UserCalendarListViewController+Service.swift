//
//  UserCalendarListViewController+Service.swift
//  MiPlanIt
//
//  Created by Febin Paul on 05/08/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

extension UserCalendarListViewController {
    
    func createWebServiceDefaultCalendarShare(invitees: CalendarInvitees, calendar: PlanItCalendar, index: IndexPath) {
        self.startLoadingIndicator(at: index)
        CalendarService().setDefaultCalendarShare(calendar: calendar, invitees: invitees) { (responseStatus, error) in
            self.stopLoadingIndicator(at: index)
            if responseStatus {
                self.tableView.reloadRows(at: [index], with: .none)
            }
            else {
                let message = error ?? Message.unknownError
                self.performSegue(withIdentifier: Segues.toMessageScreen, sender: [Message.error, message])
            }
        }
    }
    func createWebServiceForFetchUserEvents(_ users: [CalendarUser]) {
        self.startLottieAnimations()
        CalendarService().fetchOtherUserEvents(users, callback: { response, error in
            self.stopLottieAnimations()
            if let result = response {
                self.updatedCalendars.removeAll()
                let usersCalendar = self.selectedUsers.filter({ return $0.isSharedMiPlanItCalendar() }).compactMap({ $0.planItCalendarShared })
                let selectedOptions = self.userAvailableCalendarTypes.flatMap({ return $0.calendars }).filter({ return $0.selected }).map({ return $0.calendar })
                self.navigationController?.popViewController(animated: true)
                self.delegate?.calendarListViewController(self, selectedOptions: selectedOptions + usersCalendar, selectedUsers: result)
            }
            else {
                let message = error ?? Message.unknownError
                self.performSegue(withIdentifier: Segues.toMessageScreen, sender: [Message.error, message])
            }
        })
    }
    
    func createWebServiceGetDefaultCalendarShare() {
        if SocialManager.default.isNetworkReachable() {
            self.startLottieAnimations()
            CalendarService().getDefaultCalendarSharedUsers(callback: { response, error in
                self.stopLottieAnimations()
                if let result = response {
                    self.allUsers += result
                }
                else {
                    let message = error ?? Message.unknownError
                    self.performSegue(withIdentifier: Segues.toMessageScreen, sender: [Message.error, message])
                }
            })
            self.buttonSearch.isHidden = false
        }
    }
}
