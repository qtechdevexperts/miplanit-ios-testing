//
//  PlanItSocialUser+Save.swift
//  MiPlanIt
//
//  Created by Arun on 11/09/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

extension PlanItSocialUser {
    
    func readSocialAccountId() -> String {
        return self.socialAccountId ?? Strings.empty
    }
    
    func readSocialToken() -> String {
        return self.token ?? Strings.empty
    }
    
    func readSocialRefreshToken() -> String {
        return self.refreshToken ?? Strings.empty
    }
    
    func readUserEmail() -> String {
        return self.socialAccountEmail ?? Strings.empty
    }
    
    func readUserName() -> String {
        return self.socialAccountName ?? Strings.empty
    }
    
    func readUserInformations() -> String {
        return self.readUserEmail().isEmpty ? self.readUserName() : self.readUserEmail()
    }
    
    func maxRefreshLimit() -> Double {
        return 3
    }
    
    func isAccountExpired() -> Bool {
        return SocialManager.default.synchronisationType != .start && self.isExpired()
    }
    
    func isExpired() -> Bool {
        if let expirationDate = self.accessTokenExpirationDate {
            return expirationDate < Date()
        }
        return true
    }
    
    func isReachedMaximumAttempt() -> Bool {
        if self.isExceedMaximumAttempt() {
            if let expiryAlertDate = self.lastShownExpiryAlert, expiryAlertDate.hourBetweenDate(toDate: Date()) >= 1 {
                return true
            }
            return self.lastShownExpiryAlert == nil
        }
        return self.refreshedLimit == self.maxRefreshLimit()
    }
    
    func isExceedMaximumAttempt() -> Bool {
        return self.refreshedLimit >= self.maxRefreshLimit()
    }
    
    func saveUpdateSocialAccountInformation(_ user: SocialUser) {
        self.token = user.token
        self.refreshedLimit = 0
        self.refreshToken = user.refreshToken
        if let expirationDate = user.expiryTokenDate.stringToDate(formatter: DateFormatters.YYYYHMMHDDSHHCMMCSSSZ, timeZone: TimeZone(abbreviation: "UTC")!) {
            self.accessTokenExpirationDate = expirationDate
        }
        try? self.managedObjectContext?.save()
    }
    
    func saveAccountRefreshStatus(_ status: Bool) {
        self.refreshedLimit = status ? 0 : self.refreshedLimit + 1
        try? self.managedObjectContext?.save()
    }
    
    func saveLastShownExpiryAlertDate(_ date: Date?) {
        self.lastShownExpiryAlert = date
        try? self.managedObjectContext?.save()
    }
}
