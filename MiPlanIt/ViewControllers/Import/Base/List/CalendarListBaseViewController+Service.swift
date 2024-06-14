//
//  CalendarListBaseViewController+Service.swift
//  MiPlanIt
//
//  Created by Arun on 09/04/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

extension CalendarListBaseViewController {
    
    func createServiceToFetchGoogleUsersCalendar(_ socialUser: SocialUser) {
        GoogleService().readCalendarEventsForUser(socialUser, callback: { result, error in
            if let list = result {
                self.calanderList = list
            }
            else {
                self.showErrorScreenOnEmptyCalanderList()
            }
        })
    }
    
    func createServiceToFetchOutlookUsersCalendar(_ socialUser: SocialUser) {
        OutlookService().readCalendarEventsForUser(socialUser, callback: { result, error in
            if let list = result {
                self.calanderList = list
            }
            else {
                self.showErrorScreenOnEmptyCalanderList()
            }
        })
    }
    //TODO: outlook
    func createServiceToImportCalendarEvents(_ calendars: [SocialCalendar]) {
        self.buttonSyncCalendar.startAnimation()
        self.showImportLoader()
        CalendarService().importUser(calendars: calendars, appliedColorCodes: self.appliedColorCodeObjects, callback: { result, addedColorCodes, error in
            if result, let user = Session.shared.readUser() {
                self.showFetchngLoader()
                CalendarService().fetchUsersCalendarServerData(user) { (_, _, _) in
                    self.hideLoaderLabel()
                    self.buttonSyncCalendar.clearButtonTitleForAnimation()
                    self.buttonSyncCalendar.stopAnimation(animationStyle: .normal, revertAfterDelay: 0) {
                        self.buttonSyncCalendar.showTickAnimation(completion: { (finish) in
                            if self.calendarType == .outlook || self.calendarType == .google {
                                SocialManager.default.refrshSocialAccountsFromServer()
                            }
                            self.showAlertWithAction(message: Message.importOtherOptions, items: [Message.yes, Message.no], callback: { index in
                                if index == 0 {
                                    self.delegate?.calendarListBaseViewController(self, allAddedColorCodes: addedColorCodes)
                                    self.navigationController?.popViewController(animated: true)
                                }
                                else {
                                    self.importCalendarSuccessfully()
                                }
                            })
                        })
                    }
                }
            }
            else {
                self.hideLoaderLabel()
                let message = error ?? Message.unknownError
                self.buttonSyncCalendar.stopAnimation(animationStyle: .shake, revertAfterDelay: 0) {
                    self.performSegue(withIdentifier: Segues.toMessageScreen, sender: [Message.error, message])
                }
            }
        })
    }
}
