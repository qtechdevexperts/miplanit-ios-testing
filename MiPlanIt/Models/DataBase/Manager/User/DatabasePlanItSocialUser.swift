//
//  DatabasePlanItSocialUser.swift
//  MiPlanIt
//
//  Created by Arun on 10/09/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation
import CoreData

class DatabasePlanItSocialUser: DataBaseManager {
    
    func insertSocialUsers(_ users: [[String: Any]], result: @escaping (Date?) -> ()) {
        self.privateObjectContext.perform {
            var tokenExpiryDate: Date?
            let socialAccountIds = users.compactMap({ return $0["socialAccountId"] as? String })
            self.deleteAllNonExistingSocialAccounts(socialAccountIds, using: self.privateObjectContext)
            for user in users {
                let socialAccountId = user["socialAccountId"] as? String ?? Strings.empty
                let predicate = NSPredicate(format: "user == %@ AND socialAccountId == %@", Session.shared.readUserId(), socialAccountId)
                let arrayRecords = self.readRecords(fromCoreData: Table.planItSocialUser, predicate: predicate, context: self.privateObjectContext) as! [PlanItSocialUser]
                let plantItSocialUser = arrayRecords.first ?? self.insertNewRecords(Table.planItSocialUser, context: self.privateObjectContext) as! PlanItSocialUser
                plantItSocialUser.token = user["token"] as? String
                plantItSocialUser.refreshToken = user["refreshToken"] as? String
                plantItSocialUser.socialAccountEmail = user["socialAccountEmail"] as? String
                plantItSocialUser.socialAccountId = socialAccountId
                plantItSocialUser.socialAccountName = user["socialAccountName"] as? String
                plantItSocialUser.socialAccType = user["calendarType"] as? Double ?? 1
                plantItSocialUser.user = Session.shared.readUserId()
                var accessTokenExpirationDate = plantItSocialUser.accessTokenExpirationDate ?? Date()
                if let date = user["accessTokenExpirationDate"] as? String, let expirationDate = date.stringToDate(formatter: DateFormatters.MMDDYYYYHMMSSA, timeZone: TimeZone(abbreviation: "UTC")!) {
                    accessTokenExpirationDate = expirationDate
                }
                plantItSocialUser.accessTokenExpirationDate = accessTokenExpirationDate
                if plantItSocialUser.accessTokenExpirationDate != accessTokenExpirationDate { plantItSocialUser.refreshedLimit = 0 }
//                if !plantItSocialUser.isExceedMaximumAttempt() {
                    if let expiry = tokenExpiryDate {
                        if accessTokenExpirationDate < expiry {
                            tokenExpiryDate = accessTokenExpirationDate
                        }
                    } else {
                        tokenExpiryDate = accessTokenExpirationDate
                    }
//                }
            }
            self.privateObjectContext.saveContext()
            DispatchQueue.main.async {
                result(tokenExpiryDate)
            }
        }
    }
    
    func deleteAllNonExistingSocialAccounts(_ accounts: [String], using context: NSManagedObjectContext? = nil) {
        let objectContext = context ?? self.mainObjectContext
        let predicate = NSPredicate(format: "user == %@ AND NOT(socialAccountId IN %@)", Session.shared.readUserId(), accounts)
        let users = self.readRecords(fromCoreData: Table.planItSocialUser, predicate: predicate, context: objectContext) as! [PlanItSocialUser]
        users.forEach({ objectContext.delete($0) })
    }
    
    func readAllPendingGoogleRefreshTokenAccounts(_ socialUsers: [SocialUser]) -> [SocialUser] {
        let predicate = NSPredicate(format: "user == %@ AND NOT(socialAccountId IN %@) AND socialAccType == 1", Session.shared.readUserId(), socialUsers.map({ return $0.userId }))
        let users = self.readRecords(fromCoreData: Table.planItSocialUser, predicate: predicate, context: self.mainObjectContext) as! [PlanItSocialUser]
        return users.map({ return SocialUser(with: $0) })
    }
    
    func readAllUsersSocialAccounts() -> [PlanItSocialUser] {
        let predicate = NSPredicate(format: "user == %@", Session.shared.readUserId())
        return self.readRecords(fromCoreData: Table.planItSocialUser, predicate: predicate, context: self.mainObjectContext) as! [PlanItSocialUser]
    }
    //TODO: Google
    ///Call this method for getting google account
    func readAllGoogleUsersSocialAccounts() -> [SocialUser] {
        let predicate = NSPredicate(format: "user == %@ AND socialAccType == 1", Session.shared.readUserId())
        let users = self.readRecords(fromCoreData: Table.planItSocialUser, predicate: predicate, context: self.mainObjectContext) as! [PlanItSocialUser]
        return users.map({ return SocialUser(with: $0) })
    }
    
    func readAllOutlookUsersSocialAccounts() -> [SocialUser] {
        let predicate = NSPredicate(format: "user == %@ AND socialAccType == 2", Session.shared.readUserId())
        let users = self.readRecords(fromCoreData: Table.planItSocialUser, predicate: predicate, context: self.mainObjectContext) as! [PlanItSocialUser]
        return users.map({ return SocialUser(with: $0) })
    }
    
    func checkUserExistsInMiPlaniT(_ email: String) -> Bool {
        let predicate = NSPredicate(format: "user == %@ AND (socialAccountEmail == %@ OR socialAccountName == %@)", Session.shared.readUserId(), email, email)
        return !(self.readRecords(fromCoreData: Table.planItSocialUser, predicate: predicate, context: self.mainObjectContext) as! [PlanItSocialUser]).isEmpty
    }
}
