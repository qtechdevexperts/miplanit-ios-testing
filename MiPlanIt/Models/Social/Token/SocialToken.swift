//
//  SocialToken.swift
//  MiPlanIt
//
//  Created by Arun on 11/09/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation
import Alamofire

enum TokenSynchronisationType {
    case `default`, start, failed, completed, restarted
}

extension SocialManager {
    
    func isNetworkReachable() -> Bool {
        guard let manager = self.networkManager, manager.isReachable else {
            return false
        }
        return true
    }

    func listenNetwork() {
//        self.networkManager?.listener = { status in
//            switch status {
//            case .notReachable:
//                debugPrint("No")
//            case .unknown:
//                debugPrint("No")
//            case .reachable(_):
//                Session.shared.startOnlineDataProcessing()
//            }
//        }
//        self.networkManager?.startListening()
//      networkManager?.startListening()
      networkManager?.startListening(onUpdatePerforming: { status in
        switch status {
        case .notReachable:
            debugPrint("No")
        case .unknown:
            debugPrint("No")
        case .reachable(_):
            Session.shared.startOnlineDataProcessing()
        }
      })

    }
    
    func resetExpiryAlertDate() {
        self.readSocialAccounts().forEach { (socialUser) in
            socialUser.saveLastShownExpiryAlertDate(nil)
        }
    }
    
    func startSocialTokenRefreshTimer() {
        self.activateSocialSync()
        self.resetExpiryAlertDate()
        if self.socialTokenTimer == nil {
            self.socialTokenTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { _ in
                self.readyToCallNextExpirySocialToken()
            })
        }
    }
    
    func stopSocialTokenRefreshTimer() {
        if self.socialTokenTimer != nil {
            self.socialTokenTimer?.invalidate()
            self.socialTokenTimer = nil
        }
        self.saveSynchronisationType(.default)
    }
    
    private func saveSynchronisationType(_ type: TokenSynchronisationType) {
        self.synchronisationType = type
    }
    
    private func readSocialAccounts(withType type: Double = 0) -> [PlanItSocialUser] {
        let socialAccounts = DatabasePlanItSocialUser().readAllUsersSocialAccounts()
        switch type {
        case 1, 2:
            return socialAccounts.filter({ return $0.socialAccType == type })
        default:
            return socialAccounts
        }
    }
    
    func saveSocialAccountRefreshStatus(with type: Double, users: [SocialUser] = [], isbalanceAcoounts : Bool = false) {
        let socialAccounts = self.readSocialAccounts(withType: type)
        socialAccounts.forEach({ account in if users.contains(where: { $0.userId == account.socialAccountId}) { account.saveAccountRefreshStatus(true) } else if !isbalanceAcoounts { account.saveAccountRefreshStatus(false) } })
    }
    
    func isSocialAccountsExpired() -> Bool {
        guard let user = Session.shared.readUser(), let expireOn = user.readSocialAccountExpirationDate(), expireOn < Date() else { return false }
        return true
    }
    
    func isSocialAccountsExpiredAfterRefresh() -> Bool {
        guard let user = Session.shared.readUser(), let expireOn = user.readSocialAccountExpirationDate(), expireOn < Date(), self.isNetworkReachable(), self.isWorkFlowCompleted else { return false }
        return true
    }
    
    private func isReadyToRefreshSocialAccounts() -> Bool {
        guard self.isNetworkReachable(), !Session.shared.readUserId().isEmpty, (self.synchronisationType == .default || self.synchronisationType == .restarted) else { return false }
        return true
    }
    
    func readyToCallNextExpirySocialToken() {
        if (self.isSocialAccountsExpired() && self.synchronisationType == .completed) || self.synchronisationType == .default {
            self.saveSynchronisationType(self.synchronisationType == .default ? .default : .restarted)
            self.activateSocialSync()
        }
        else if !Session.shared.readUserId().isEmpty { self.triggerOutlookGoogleRefreshFromServer() }
    }
    
    public func activateSocialSync() {
        if self.isReadyToRefreshSocialAccounts() {
            self.saveSynchronisationType(.start)
            self.readAllSocialAccountsFromServer()
        }
        else {
            self.saveSynchronisationType(self.synchronisationType == .default ? .default : .completed)
        }
    }

    public func readAllSocialAccountsFromServer() {
        CalendarService().socialCalendarUsers(callback: { _, _ in
            if self.isSocialAccountsExpired() { self.sendBalanceOutlookRefreshTokenToServer() }
            else { self.saveSynchronisationType(.completed); self.triggerOutlookGoogleRefreshFromServer() }
        })
    }
    
    func sendBalanceOutlookRefreshTokenToServer() {
        let outlookAccount = DatabasePlanItSocialUser().readAllOutlookUsersSocialAccounts()
        guard !outlookAccount.isEmpty else {
        self.refreshGoogleAccounts()
        return }
        self.refreshOutlookAccounts(outlookAccount, at: 0)
    }
    
    public func refreshOutlookAccounts(_ socialUsers: [SocialUser], at index: Int) {
        if index < socialUsers.count {
            OutlookService().getOutlookAssessTokenFromRefreshToken(socialUsers[index], redirectUri: Strings.redirectUrl) { (user, error) in
                self.refreshOutlookAccounts(socialUsers, at: index + 1)
            }
        }
        else {
            self.sendBalanceOutlookAccountsToServer(socialUsers)
        }
    }
    
    func sendBalanceOutlookAccountsToServer(_ socialUsers: [SocialUser]) {
        let refreshedAccounts = socialUsers.filter({ return !$0.expiryTokenDate.isEmpty })
        self.saveSocialAccountRefreshStatus(with: 2, users: refreshedAccounts)
        CalendarService().syncUsers(socialUsers, callback: { result, _ in
            if !result { self.saveSynchronisationType(.failed) }
            self.refreshGoogleAccounts()
        })
    }
    
    public func refreshGoogleAccounts() {
        self.googleRefreshAccounts(client: ConfigureKeys.googleClientKey, result: { users in
            guard let socialUsers = users, !socialUsers.isEmpty else {
                self.saveSocialAccountRefreshStatus(with: 1)
                self.sendBalanceGoogleRefreshTokenToServer()
                return }
            self.sendGoogleAccountsToServer(socialUsers)
        })
    }
    
    public func sendGoogleAccountsToServer(_ socialUsers: [SocialUser]) {
        self.saveSocialAccountRefreshStatus(with: 1, users: socialUsers)
        CalendarService().syncUsers(socialUsers, callback: { result, _ in
            if !result { self.saveSynchronisationType(.failed) }
            self.sendBalanceGoogleRefreshTokenToServer(socialUsers)
        })
    }
    
    public func sendGoogleAccountsToServerFailed() {
        self.saveSocialAccountRefreshStatus(with: 1)
        self.sendBalanceGoogleRefreshTokenToServer()
    }
    
    func sendBalanceGoogleRefreshTokenToServer(_ socialUser: [SocialUser] = []) {
        let googleUsers = DatabasePlanItSocialUser().readAllPendingGoogleRefreshTokenAccounts(socialUser)
        guard !googleUsers.isEmpty else {
            self.fetchAccountInformationFromServer()
            return }
        self.refreshBalanceGoogleToken(googleUsers, at: 0)
    }
    
    func refreshBalanceGoogleToken(_ users: [SocialUser], at index: Int) {
        if index < users.count {
            GoogleService().refreshToken(users[index], callback: { _, _ in
                self.refreshBalanceGoogleToken(users, at: index + 1)
            })
        }
        else {
            self.sendBalanceGoogleAccountsToServer(users)
        }
    }
    
    func sendBalanceGoogleAccountsToServer(_ socialUsers: [SocialUser]) {
        let refreshedAccounts = socialUsers.filter({ return !$0.expiryTokenDate.isEmpty })
        self.saveSocialAccountRefreshStatus(with: 1, users: refreshedAccounts, isbalanceAcoounts: true)
        CalendarService().syncUsers(socialUsers, callback: { result, _ in
            if !result { self.saveSynchronisationType(.failed) }
            self.fetchAccountInformationFromServer()
        })
    }
    
    func fetchAccountInformationFromServer() {
        CalendarService().socialCalendarUsers(callback: { result, _ in
            if !result { self.saveSynchronisationType(.failed) }
            let isSuccessfulFlow = self.synchronisationType != .failed
            self.saveSynchronisationType(.completed)
            self.readAllSocialAccountsToCheckExpiry(isSuccessfulFlow)
        })
    }
    
    func readAllSocialAccountsToCheckExpiry(_ isSuccessfulFlow: Bool) {
        guard isSuccessfulFlow else { return }
        let socialAccounts = self.readSocialAccounts()
        let expiredAccounts = socialAccounts.filter({ return $0.isAccountExpired() && $0.isReachedMaximumAttempt() })
        if !expiredAccounts.isEmpty {
            expiredAccounts.forEach { (socialUser) in
                socialUser.saveLastShownExpiryAlertDate(Date())
            }
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: Notifications.detectedSocialAccountsExpiry), object: true)
        }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Notifications.detectedSocialAccountsRenewal), object: true)
        self.triggerOutlookGoogleRefreshFromServer()
    }
    
    func refrshSocialAccountsFromServer() {
        CalendarService().socialCalendarUsers(callback: { result, _ in
            if result {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: Notifications.detectedSocialAccountsRenewal), object: true)
            }
        })
    }
    
    func triggerOutlookGoogleRefreshFromServer() {//Only need from background
        guard Session.shared.readAppFromForeGround() || self.numberOfMinutesToCall >= Numbers.silentSyncTimeInterval*60 else { self.numberOfMinutesToCall += 1; return }
        self.numberOfMinutesToCall = 0
        Session.shared.saveAppFromForeGround(false)
        guard let user = Session.shared.readUser(), !Session.shared.isPricingViewController() else { return }
        InAppPurchaseService().verifySubscriptionStatus(user: user) {
            CalendarService().userCalendarSync(Strings.empty, callback: {_, _ in })
        }
    }
}
