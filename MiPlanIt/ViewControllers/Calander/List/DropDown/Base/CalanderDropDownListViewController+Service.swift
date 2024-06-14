//
//  CalendarMenuDropDownViewController+Service.swift
//  MiPlanIt
//
//  Created by Arun on 04/06/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

extension CalanderDropDownBaseListViewController {
    
    func createWebServiceToSyncUserCalendar(_ type: String) {
        self.buttonSyncCalendar?.startAnimation()
        CalendarService().userCalendarSync(type, callback: { result, error in
            if result {
                self.buttonSyncCalendar?.stopAnimation(animationStyle: .normal, revertAfterDelay: 0) {
                    self.reloadCalendarSectionAfterSync()
                    self.showAlert(message: Message.syncingWillNotify(type))
                }
            }
            else {
                let message = error ?? Message.unknownError
                self.buttonSyncCalendar?.stopAnimation(animationStyle: .shake, revertAfterDelay: 0) {
                    self.performSegue(withIdentifier: Segues.toMessageScreen, sender: [Message.error, message])
                }
            }
        })
    }
    
    func createServiceToFetchGoogleUsersCalendar(_ socialUser: SocialUser) {
        self.buttonSyncCalendar?.startAnimation()
        GoogleService().readCalendarEventsForUser(socialUser, callback: { result, error in
            if let list = result {
                self.sendGoogleCalendarSynchronisationToServer(list)
            }
            else {
                let message = error?.localizedDescription ?? Message.unknownError
                self.buttonSyncCalendar?.stopAnimation(animationStyle: .shake, revertAfterDelay: 0) {
                    self.performSegue(withIdentifier: Segues.toMessageScreen, sender: [Message.error, message])
                }
            }
        })
    }
    //TODO: Outlook Sync
    func createServiceToFetchOutlookUsersCalendar(_ socialUser: SocialUser) {
        self.buttonSyncCalendar?.startAnimation()
        OutlookService().readCalendarEventsForUser(socialUser, callback: { result, error in
            if let list = result {
                self.sendOutlookCalendarSynchronisationToServer(list)
            }
            else {
                let message = error?.localizedDescription ?? Message.unknownError
                self.buttonSyncCalendar?.stopAnimation(animationStyle: .shake, revertAfterDelay: 0) {
                    self.performSegue(withIdentifier: Segues.toMessageScreen, sender: [Message.error, message])
                }
            }
        })
    }
    
    func createServiceToImportCalendarEvents(_ calendars: [SocialCalendar]) {
        CalendarService().importUser(calendars: calendars, callback: { result, addedColorCodes, error in
            if result {
                self.isModified = true
                self.buttonSyncCalendar?.stopAnimation(animationStyle: .normal, revertAfterDelay: 0) {
                    self.reloadCalendarSectionAfterSync()
                    self.delegateRefresh?.calendarRefresh()
                }
            }
            else {
                let message = error ?? Message.unknownError
                self.buttonSyncCalendar?.stopAnimation(animationStyle: .shake, revertAfterDelay: 0) {
                    self.performSegue(withIdentifier: Segues.toMessageScreen, sender: [Message.error, message])
                }
            }
        })
    }
}
