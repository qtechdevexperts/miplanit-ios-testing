//
//  DatabasePlanItContacts.swift
//  MiPlanIt
//
//  Created by Febin Paul on 24/02/21.
//  Copyright © 2021 Arun. All rights reserved.
//

import Foundation
import CoreData

class DatabasePlanItContacts: DataBaseManager {

    func insertPlanItContacts(_ contacts: [[String: Any]]?, phones: [CalendarUser], emails: [CalendarUser], callback: @escaping ([PlanItContacts]) -> ()) {
        self.privateObjectContext.perform {
            guard let miContacts = contacts  else {
                callback([]); return
            }
            self.deleteAllRecord(using: self.privateObjectContext)
            if miContacts.isEmpty { callback([]); return }
            var addedContact: [PlanItContacts] = []
            for contact in miContacts {
                let planItContact = self.insertNewRecords(Table.planItContacts, context: self.privateObjectContext) as! PlanItContacts
                planItContact.userId = contact["userId"] as? Double ?? 0.0
                planItContact.fullName = contact["fullName"] as? String
                planItContact.phone = contact["phone"] as? String
                planItContact.telCountryCode = contact["telCountryCode"] as? String
                planItContact.email = contact["email"] as? String
                planItContact.profileImage = contact["profileImage"] as? String
                planItContact.isEmailExistInContact = false
                planItContact.isPhoneExistInContact = false
                if let phone = contact["phone"] as? String, !phone.isEmpty, let deviceContact = phones.first(where: { return ($0.phone.hasSuffix(phone) && !phone.isEmpty) || (phone.hasSuffix($0.phone) && !$0.phone.isEmpty) }) {
                    planItContact.userName = deviceContact.readName()
                    planItContact.isPhoneExistInContact = true
                }
                if let email = contact["email"] as? String, !email.isEmpty, let deviceContact = emails.first(where: { return $0.email.caseInsensitiveCompare(email) == .orderedSame }) {
                    planItContact.userName = deviceContact.readName()
                    planItContact.isEmailExistInContact = true
                }
                if !planItContact.isEmailExistInContact && !planItContact.isPhoneExistInContact {
                    planItContact.userName = contact["userName"] as? String
                }
                addedContact.append(planItContact)
            }
            self.privateObjectContext.saveContext()
            callback(addedContact)
        }
    }
    
    func deleteAllRecord(using context: NSManagedObjectContext? = nil) {
        let objectContext = context ?? self.mainObjectContext
        let allContact = self.readAllUsersContact(using: context)
        allContact.forEach({ objectContext.delete($0) })
    }
    
    func readUsersContact(userId: String, using context: NSManagedObjectContext? = nil) -> [PlanItContacts] {
        let objectContext = context ?? self.mainObjectContext
        let predicate = NSPredicate(format: "userId == %@", userId)
        return self.readRecords(fromCoreData: Table.planItContacts, predicate: predicate, context: objectContext) as! [PlanItContacts]
    }
    
    func readAllUsersContact(using context: NSManagedObjectContext? = nil) -> [PlanItContacts] {
        let objectContext = context ?? self.mainObjectContext
        return self.readRecords(fromCoreData: Table.planItContacts, context: objectContext) as! [PlanItContacts]
    }
}
