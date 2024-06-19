//
//  CalanderDropDownListViewController+Calendar.swift
//  MiPlanIt
//
//  Created by Arun on 09/06/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation
import GoogleSignIn
import EventKit

extension CalanderDropDownBaseListViewController: UserCalendarHeaderCellDelegate {
    func test2(){
        self.buttonSyncCalendar?.startAnimation()
        let socialAccounts = DatabasePlanItSocialUser().readAllGoogleUsersSocialAccounts()//.first!
        for i in socialAccounts{
            GoogleService().readCalendarEventsForUser(i, callback: { result, error in
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
    }
    func getCalaneder(){
            let getUserCalendarAvailableType = self.getUserCalendarAvailableType()
            let allUserAvailableCalendarTypes = self.userAvailableCalendarTypes.compactMap({ $0.calendars }).flatMap({ $0 })
            getUserCalendarAvailableType.compactMap({ $0.calendars }).flatMap({ $0 }).forEach { (eachGetUserCalendarVisibility) in
                if let filteredCalendar = allUserAvailableCalendarTypes.filter({ $0.calendar == eachGetUserCalendarVisibility.calendar }).first {
                    eachGetUserCalendarVisibility.disabled = filteredCalendar.disabled
                    eachGetUserCalendarVisibility.selected = filteredCalendar.selected
                }
            }
            self.userAvailableCalendarTypes = getUserCalendarAvailableType
            self.userCalendarTypes = self.userAvailableCalendarTypes
        DispatchQueue.main.asyncAfter(deadline: .now()+5) { [weak self] in
            self?.test2()

        }
    }
    func test3(){
        self.buttonSyncCalendar?.startAnimation()
        let  users = DatabasePlanItSocialUser().readAllOutlookUsersSocialAccounts()
        for i in users{
            OutlookService().readCalendarEventsForUser(i, callback: { result, error in
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
    }
    func userCalendarHeaderCell(_ cell: UserCalendarHeaderCell, syncCalendarAtIndex index: Int , type:String = "") {
        self.syncIndex = index
        self.buttonSyncCalendar = cell.buttonSyncCalendar
        let type = self.userCalendarTypes[index].type
        switch type {
        case "1":
            test2() //google
        case "2":
            test3() // microsoft
            break
        case "3":
            self.readCalendarFromAppleUsingGrantPermission(self.userCalendarTypes[index].calendars.map({ return $0.calendar }))
        default: break
        }
    }

}

extension CalanderDropDownBaseListViewController {
    
    func reloadCalendarSectionAfterSync() {
        self.buttonSyncCalendar = nil
        self.userCalendarTypes[self.syncIndex].synced = true
        self.tableView.reloadData()
    }
}

extension CalanderDropDownBaseListViewController {
    
    func readCalendarFromAppleUsingGrantPermission(_ calendars: [PlanItCalendar]) {
        switch EKEventStore.authorizationStatus(for: .event) {
        case .authorized:
            self.sendAppleCalendarSynchronisationToServer(calendars)
        case .denied:
            self.showAlertWithAction(message: Message.calendarPermission, title: Message.permissionError, items: [Message.cancel, Message.settings], callback: { index in
                if index != 0 {
                    guard let settingsUrl = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(settingsUrl) else { return }
                    UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                        print("Settings opened: \(success)") // Prints true
                    })
                }
            })
        case .notDetermined:
            Session.shared.eventStore.requestAccess(to: .event, completion: { granted, error in
                DispatchQueue.main.async {
                    guard granted else { return }
                    self.sendAppleCalendarSynchronisationToServer(calendars)
                }
            })
        default: break
        }
    }
    
    func sendAppleCalendarSynchronisationToServer(_ calendars: [PlanItCalendar]) {
        self.buttonSyncCalendar?.startAnimation()
        let calendarIds = calendars.compactMap({ return $0.socialCalendarId })
        let calendars = Session.shared.eventStore.calendars(for: .event).filter({ return calendarIds.contains($0.calendarIdentifier) })
        if !calendars.isEmpty {
            let appleCalanders = calendars.map({ return SocialCalendar(with: $0) })
            self.downloadAppleEventsFromCalendars(appleCalanders)
        }
        else {
            self.buttonSyncCalendar?.stopAnimation()
            self.showAlert(message: Message.appleInValidCalendars, title: Message.warning)
        }
    }
    
    func downloadAppleEventsFromCalendars(_ calendars: [SocialCalendar], at index: Int = 0) {
        if index < calendars.count {
            calendars[index].readAppleEventsUsingEventStore(Session.shared.eventStore, callback: { [weak self] _ in
                self?.downloadAppleEventsFromCalendars(calendars, at: index + 1)
            })
        }
        else {
            self.createServiceToImportCalendarEvents(calendars)
        }
    }
}

extension CalanderDropDownBaseListViewController {
    
    func readCalendarFromOutlookUsingGrantPermission(_ calendars: [PlanItCalendar]) {
        SocialManager.default.loadOutlookAccount(usingClient: ConfigureKeys.outlookClientId, scopes: ServiceData.outlookScopes, result: self)
    }
    
    func sendOutlookCalendarSynchronisationToServer(_ calendars: [SocialCalendar]) {
        let calendarIds = self.userCalendarTypes[self.syncIndex].calendars.compactMap({ return $0.calendar.socialCalendarId })
        let socialCalendars = calendars.filter({ return calendarIds.contains($0.calendarId) })
        if !socialCalendars.isEmpty {
            self.fetchEventsOfOutlookCalendars(socialCalendars, fromIndex: 0)
        }
        else {
            self.buttonSyncCalendar?.stopAnimation()
            self.showAlertWithAction(message: Message.socialInvalidCalendarAccount, title: Message.warning, items: [Message.no, Message.yes], callback: { option in
                if option == 1 {
                    SocialManager.default.loginOutlookFromViewController(self, client: ConfigureKeys.outlookClientId, scopes: ServiceData.outlookScopes, result: self)
                }
            })
        }
    }
    
    func fetchEventsOfOutlookCalendars(_ calendars: [SocialCalendar], fromIndex index: Int) {
        guard index < calendars.count else {
            self.createServiceToImportCalendarEvents(calendars)
            return }
        calendars[index].readOutlookEvents(callback: { _ in
            self.fetchEventsOfOutlookCalendars(calendars, fromIndex: index + 1)
        })
    }
}

extension CalanderDropDownBaseListViewController {
    
    func readCalendarFromGoogleUsingGrantPermission(_ calendars: [PlanItCalendar]) {
      if let googleUser = GIDSignIn.sharedInstance.currentUser, let expirationDate = googleUser.accessToken.expirationDate, expirationDate.compare(Date()) == .orderedDescending {
            let socialUser = SocialUser(with: googleUser)
            self.createServiceToFetchGoogleUsersCalendar(socialUser)

        }
        else {
            SocialManager.default.loginGoogleFromViewController(self, client: ConfigureKeys.googleClientKey, scopes: ServiceData.googleScope, result: self)
        }
    }
    
    func sendGoogleCalendarSynchronisationToServer(_ calendars: [SocialCalendar]) {
        let calendarIds = self.userCalendarTypes[self.syncIndex].calendars.compactMap({ return $0.calendar.socialCalendarId })
        let socialCalendars = calendars.filter({ return calendarIds.contains($0.calendarId) })
        if !socialCalendars.isEmpty {
            self.fetchEventsOfGoogleCalendars(socialCalendars, fromIndex: 0)
            self.delegateRefresh?.calendarRefresh()
        }
        else {
            self.buttonSyncCalendar?.stopAnimation()
            self.delegateRefresh?.calendarRefresh()
            self.showAlertWithAction(message: Message.socialInvalidCalendarAccount, title: Message.warning, items: [Message.no, Message.yes], callback: { option in
                if option == 1 {
                    SocialManager.default.loginGoogleFromViewController(self, client: ConfigureKeys.googleClientKey, scopes: ServiceData.googleScope, result: self)
                }
                self.delegateRefresh?.calendarRefresh()
            })
        }
        //implement delegate
    }
    
    func fetchEventsOfGoogleCalendars(_ calendars: [SocialCalendar], fromIndex index: Int) {
        guard index < calendars.count else {
            self.createServiceToImportCalendarEvents(calendars)
            return }
        calendars[index].readGoogleEvents(callback: { _ in
            self.fetchEventsOfGoogleCalendars(calendars, fromIndex: index + 1)
            self.delegateRefresh?.calendarRefresh()
        })
    }
}
