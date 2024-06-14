//
//  DatabasePlanItUser.swift
//  MiPlanIt
//
//  Created by Nikhil RajG on 20/03/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation
import CoreData

class DatabasePlanItUser: DataBaseManager {
 
    func insertUser(_ user: [String: Any], using socialUser: SocialUser) -> PlanItUser {
        let userId = String(user["userId"] as? Int ?? 0)
        let predicate = NSPredicate(format: "userId == %@", userId)
        let arrayRecords = self.readRecords(fromCoreData: Table.planItUser, predicate: predicate, context: self.mainObjectContext) as! [PlanItUser]
        let plantItUser = arrayRecords.first ?? self.insertNewRecords(Table.planItUser, context: self.mainObjectContext) as! PlanItUser
        plantItUser.userId = userId
        plantItUser.isLoggedIn = true
        plantItUser.userName = user["userName"] as? String ?? Strings.empty
        plantItUser.email = user["email"] as? String ?? Strings.empty
        plantItUser.phone = user["phone"] as? String ?? Strings.empty
        plantItUser.countryCode = user["telCountryCode"] as? String ?? Strings.empty
        plantItUser.name = user["fullName"] as? String ?? Strings.empty
        let profileImage = user["profileImage"] as? String ?? Strings.empty
        plantItUser.imageUrl = profileImage.isEmpty ? socialUser.profile : profileImage
        plantItUser.signInType = user["socialLogin"] as? String ?? Strings.empty
        plantItUser.signInToken = user["socialUnique"] as? String ?? Strings.empty
        plantItUser.country = user["country"] as? String ?? Strings.empty
        plantItUser.language = user["lang"] as? String ?? Strings.empty
        plantItUser.utcOffset = user["utcOffset"] as? String ?? Strings.empty
        plantItUser.authToken = user["authToken"] as? String ?? Strings.empty
        if let date = user["recieptExpiryDate"] as? String {
            plantItUser.recieptExpiryDate = date.stringToDate(formatter: DateFormatters.MMDDYYYYHMMSSA, timeZone: TimeZone(abbreviation: "UTC")!)
        }
        self.mainObjectContext.saveContext()
        return plantItUser
    }
    
    func readLoggedInUser() -> PlanItUser? {
        let predicate = NSPredicate(format: "isLoggedIn == YES")
        let users = self.readRecords(fromCoreData: Table.planItUser, predicate: predicate, context: self.mainObjectContext) as! [PlanItUser]
        return users.first
    }
    
    func readCurrentUser() -> PlanItUser? {
        let predicate = NSPredicate(format: "isLoggedIn == YES && userId == %@", Session.shared.readUserId())
        let users = self.readRecords(fromCoreData: Table.planItUser, predicate: predicate, context: self.mainObjectContext) as! [PlanItUser]
        return users.first
    }
    
    func updateReceiptExpiryDate(_ date: Date) {
        if let user = self.readCurrentUser() {
            user.recieptExpiryDate = date
            self.mainObjectContext.saveContext()
        }
    }
}
