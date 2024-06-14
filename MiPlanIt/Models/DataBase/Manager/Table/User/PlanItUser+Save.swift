//
//  PlanItUser+Save.swift
//  MiPlanIt
//
//  Created by Nikhil RajG on 20/03/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation
import PINRemoteImage

extension PlanItUser {
    
    func readValueOfUserName() -> String { return self.userName ?? Strings.empty }
    func readValueOfFirstName() -> String { return self.readValueOfName().components(separatedBy: Strings.space).first ?? Strings.empty }
    func readValueOfUserId() -> String { return self.userId ?? Strings.empty }
    func readValueOfName() -> String { return self.name ?? Strings.empty }
    func readValueOfLoginType() -> String { return self.signInType ?? Strings.empty }
    func readValueOfLoginToken() -> String { return self.signInToken ?? Strings.empty }
    func readValueOfPhoneNumber() -> String { return self.phone ?? Strings.empty }
    func readValueOfCountryCode() -> String { return self.countryCode ?? Strings.empty }
    func readValueOfEmail() -> String { return self.email ?? Strings.empty }
    func readValueOfCountry() -> String { return self.country ?? Strings.empty }
    func readValueOfProfile() -> String { return self.imageUrl ?? Strings.empty }
    func readValueOfLang() -> String { return self.language ?? Strings.empty }
    func readValueOfUTCOffset() -> String { return self.utcOffset ?? Strings.empty }
    func readValueOfLoggedInStatus() -> Bool { return self.isLoggedIn }
    func readValueOfNotificationCount() -> Double { return self.notifications }
    func readSocialAccountExpirationDate() -> Date? { return self.socialAccountExpirationDate }
    func readProfileImageData() -> Data? { return self.profileImageData }
    func readNotificationPerformDate() -> Date? { return self.notificationPerformDate }
    func readValueOfAuthToken() -> String { return self.authToken ?? Strings.empty }
    func readReceiptExpirationDate() -> Date? { return self.recieptExpiryDate }
    func readIsExhausted() -> Bool { return self.isExhausted }
    func readLinkExpiryTime() -> Double { return self.eventLinkExpiryInSeconds }
    func readUserHaveValidPurchase() -> Bool {
        guard let purchaseDate = self.isValidPurchase, purchaseDate > Date() else { return false }
        return true
    }
    func readUserSettings() -> PlanItSettings {
        guard let bSettings = self.settings else {
            let newSettings = DatabasePlanItSettings().insertUserNewSettings()
            self.settings = newSettings
            try? self.managedObjectContext?.save()
            return newSettings
        }
        return bSettings
    }
    
    func updateUser(email: String, phone: String, name: String) {
        self.email = email
        self.phone = phone
        self.name = name
        self.isPending = false
        try? self.managedObjectContext?.save()
    }
    
    func updateUserOffline(email: String, phone: String, name: String) {
        self.email = email
        self.phone = phone
        self.name = name
        self.isPending = true
        try? self.managedObjectContext?.save()
    }
    
    func saveProfileImage(_ image: String) {
        self.imageUrl = image
        self.profileImageData = nil
        if let profileURL = URL(string:image) {
            let orginal = PINRemoteImageManager.shared().cacheKey(for: profileURL, processorKey: nil)
            PINRemoteImageManager.shared().cache.removeObject(forKey: orginal)
            let rounded = PINRemoteImageManager.shared().cacheKey(for: profileURL, processorKey: "rounded")
            PINRemoteImageManager.shared().cache.removeObject(forKey: rounded)
        }
        try? self.managedObjectContext?.save()
    }
    
    func saveProfileImageOffline(_ image: Data) {
        self.profileImageData = image
        try? self.managedObjectContext?.save()
    }
    
    func saveLoggedInStatus(_ status: Bool) {
        self.isLoggedIn = false
        try? self.managedObjectContext?.save()
    }
    
    func saveNotificationPerformDate(_ value: Date) {
        self.notificationPerformDate = value
        try? self.managedObjectContext?.save()
    }
    
    func saveNotificationCount(_ value: Double) {
        guard value >= 0 else { return }
        self.notifications = value
        try? self.managedObjectContext?.save()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Notifications.userNotifications), object: nil)
        UIApplication.shared.applicationIconBadgeNumber = Int(value)
    }
    
    func saveSocialAccountExpirationDate(_ value: Date?) {
        guard self.socialAccountExpirationDate != value else { return }
        self.socialAccountExpirationDate = value
        try? self.managedObjectContext?.save()
    }
    
    func savePurchase(_ value: Date?) {
        if self.isValidPurchase != value {
            self.isValidPurchase = value
            try? self.managedObjectContext?.save()
        }
    }
    
    func saveExhaustedFlag(_ flag: Bool) {
        self.isExhausted = flag
        try? self.managedObjectContext?.save()
    }
    
    func saveLinkExpiryTime(_ time: Double) {
        self.eventLinkExpiryInSeconds = time
        try? self.managedObjectContext?.save()
    }
}
