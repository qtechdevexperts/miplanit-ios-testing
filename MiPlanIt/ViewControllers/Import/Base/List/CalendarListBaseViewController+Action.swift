//
//  CalendarListBaseViewController+Action.swift
//  MiPlanIt
//
//  Created by Arun on 09/04/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit
import EventKit

extension CalendarListBaseViewController {
    
    func intialiseUIComponents() {
        self.lottieAnimationView.backgroundBehavior = .pauseAndRestore
        self.labelCalendarCaption.isHidden = true
        if self.calendarType == .apple {
            self.viewCalendarOwner.isHidden = false
            self.imgCalendarType.image = #imageLiteral(resourceName: "logoAppleSmall")
            self.labelCalendarOwner.isHidden = true
            self.labelEmail.isHidden = true
        }
    }
    
    func startLottieAnimations() {
        self.viewErrorStatus.isHidden = true
        self.viewCalanderStatus.isHidden = false
        self.lottieAnimationView.isHidden = false
        self.lottieAnimationView.play(fromProgress: 0, toProgress: 0.1, loopMode: .loop, completion: nil)
    }
    
    func stopLottieAnimations() {
        self.lottieAnimationView.isHidden = true
        self.viewErrorStatus.isHidden = !self.calanderList.isEmpty
        self.viewCalanderStatus.isHidden = !self.calanderList.isEmpty
        if self.lottieAnimationView.isAnimationPlaying { self.lottieAnimationView.stop() }
    }
    //MARK: Events
    func readEventsAfterNavigation() {
        self.startLottieAnimations()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.readEventsFromCalendar()
        }
    }
    
    func readEventsFromCalendar() {
        switch self.calendarType {
        case .outlook?:
            SocialManager.default.getOutlookAssessRefreshTokens(self.outlookAuthenticationCode, redirectUri: self.outlookRedirectionUrl, result: self)
            //SocialManager.default.loginOutlookFromViewController(self, client: ConfigureKeys.outlookClientKey, scopes: ServiceData.outlookScopes, result: self)
        case .google?:
            SocialManager.default.loginGoogleFromViewController(self, client: ConfigureKeys.googleClientKey, scopes: ServiceData.googleScope, result: self)
        case .apple?:
            self.readCalendarFromAppleUsingGrantPermission()
        case .none: break
        }
    }
    
    func readCalendarFromAppleUsingGrantPermission() {
        switch EKEventStore.authorizationStatus(for: .event) {
        case .authorized:
            self.labelCalendarCaption.isHidden = false
            self.fetchCalendarFromAppleWithPermission()
        case .denied:
            self.showAlertWithAction(message: Message.calendarPermission, title: Message.permissionError, items: [Message.cancel, Message.settings], callback: { index in
                if index == 0 {
                    self.showErrorScreenOnEmptyCalanderList()
                }
                else {
                    guard let settingsUrl = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(settingsUrl) else { return }
                    UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                        print("Settings opened: \(success)") // Prints true
                    })
                }
            })
        case .notDetermined:
            Session.shared.eventStore.requestAccess(to: .event, completion: { granted, error in
                DispatchQueue.main.async {
                    guard granted else {
                        self.showErrorScreenOnEmptyCalanderList()
                        return
                    }
                    self.fetchCalendarFromAppleWithPermission()
                }
            })
        default: break
        }
    }
    
    func fetchCalendarFromAppleWithPermission() {
        let calendars = Session.shared.eventStore.calendars(for: .event)
        let appleCalanders = calendars.map({ return SocialCalendar(with: $0) })
        self.calanderList = appleCalanders
    }
    
    func showErrorScreenOnEmptyCalanderList() {
        self.viewCalanderStatus.isHidden = false
        self.viewErrorStatus.isHidden = false
        if(self.lottieAnimationView.isAnimationPlaying == true) {
            self.lottieAnimationView.stop()
        }
    }
}


extension CalendarListBaseViewController { // event download
    
    func readCalendarCellAtIndexPath(_ index: IndexPath) -> CalanderNameCell? {
        let indexPath = IndexPath(row: index.row, section: index.section)
        return self.tableViewCalanderList.cellForRow(at: indexPath) as? CalanderNameCell
    }
    
    func downloadCalnderEventsWithDelay(_ calander: SocialCalendar, atIndexPath: IndexPath) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            switch self.calendarType {
            case .google?:
                calander.readGoogleEvents { (status) in
                    calander.calendarProgress = status ? 100 : -10
                    self.updateProgress(atIndexPath: atIndexPath)
                }
                break
            case .apple?:
                calander.readAppleEventsUsingEventStore(Session.shared.eventStore, callback: { (status) in
                    calander.calendarProgress = status ? 100 : -10
                    self.updateProgress(atIndexPath: atIndexPath)
                })
                break
            case .outlook?:
                calander.readOutlookEvents { (status) in
                    calander.calendarProgress = status ? 100 : -10
                    self.updateProgress(atIndexPath: atIndexPath)
                }
            default:
                break
            }
        }
    }
    
    func updateProgress(atIndexPath: IndexPath)  {
        let calander = self.calanderList[atIndexPath.row]
        guard calander.calendarProgress < 100, calander.calendarProgress >= 0 else {
            if calander.calendarProgress == 100 {
                calander.calendarProgress = 0.0
                self.buttonSyncCalendar.isEnabled = true
//                self.buttonSyncCalendar.backgroundColor = #colorLiteral(red: 86/255.0, green: 173/255.0, blue: 189/255.0, alpha: 1)
                self.buttonSyncCalendar.setType(type: .primary)
            }
            self.readCalendarCellAtIndexPath(atIndexPath)?.resetCalanderItemWithStatus()
            return   }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            calander.calendarProgress = calander.calendarProgress + 1
            self.readCalendarCellAtIndexPath(atIndexPath)?.circularProgressBar.progress = CGFloat(calander.calendarProgress)
            guard calander.calendarProgress < 98 else { return }
            self.updateProgress(atIndexPath: atIndexPath)
        }
    }
    
    func showFetchngLoader() {
        self.viewLoadingContainer?.isHidden = false
        self.labelLoadingContent?.text = Strings.fetchingLabel
        self.dotLoader?.startAnimating()
    }
    
    func showImportLoader() {
        self.viewLoadingContainer?.isHidden = false
        self.labelLoadingContent?.text = Strings.importingLabel
        self.dotLoader?.startAnimating()
    }
    
    func hideLoaderLabel() {
        self.viewLoadingContainer?.isHidden = true
         self.dotLoader?.stopAnimating()
    }
}

