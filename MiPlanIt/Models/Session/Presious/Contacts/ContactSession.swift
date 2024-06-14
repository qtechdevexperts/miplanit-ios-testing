//
//  ContactSession.swift
//  MiPlanIt
//
//  Created by Febin Paul on 19/02/21.
//  Copyright © 2021 Arun. All rights reserved.
//

import Foundation
import Contacts

extension Session {
    
    func postFinishNotification() {
        if !self.isAllDatabaseUserFetching && !self.isAllContactUserFetching {
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: Notifications.fetehUserContactProcessFinished), object: nil)
            }
        }
    }
    
    func readFullContacts() -> [CalendarUser] {
        return (self.allContactUser + self.allDatabaseUser).sorted(by: { return $0.readName().compare($1.readName(), options: .caseInsensitive) == .orderedAscending })
    }
    
    func removeAllDatabaseUserFromPhoneContacts() {
        if !self.isAllDatabaseUserFetching && !self.isAllContactUserFetching {
            var contactUsers = self.allContactUser
            contactUsers.removeAll { (phoneContact) -> Bool in
                return self.allDatabaseUser.contains(where: { return ($0.email.caseInsensitiveCompare(phoneContact.email) == .orderedSame && !phoneContact.email.isEmpty) || ($0.phone.hasSuffix(phoneContact.phone) && !phoneContact.phone.isEmpty) || (phoneContact.phone.hasSuffix($0.phone) && !$0.phone.isEmpty) })
            }
            self.allContactUser = contactUsers
        }
    }
    
    func removePhoneContactUserFromDatabase(_ user: CalendarUser) {
        if !self.isAllDatabaseUserFetching && !self.isAllContactUserFetching {
            var contactUsers = self.allContactUser
            contactUsers.removeAll { (phoneContact) -> Bool in return           (user.email.caseInsensitiveCompare(phoneContact.email) == .orderedSame && !phoneContact.email.isEmpty) || (user.phone.hasSuffix(phoneContact.phone) && !phoneContact.phone.isEmpty) || (phoneContact.phone.hasSuffix(user.phone) && !user.phone.isEmpty)
            }
            self.allContactUser = contactUsers
        }
    }
    
    func insertMyPlanItContacts(_ contact: PlanItContacts) {
        guard contact.readUserId() != Session.shared.readUserId() else { return }
        let creator = CalendarUser(contact)
        self.removePhoneContactUserFromDatabase(creator)
        if let index = self.allDatabaseUser.firstIndex(where: { return $0.userId == contact.readUserId() }) {
            self.allDatabaseUser[index] = creator
        }
        else {
            self.allDatabaseUser.append(creator)
        }
    }
    
    func insertDBUser(_ creater: PlanItCreator) {
        guard creater.readValueOfUserId() != Session.shared.readUserId() else { return }
        if !self.allDatabaseUser.contains(where: { return $0.userId == creater.readValueOfUserId() }) {
            let creator = CalendarUser(creater, conversionNeeded: false)
            self.removePhoneContactUserFromDatabase(creator)
            self.allDatabaseUser.append(creator)
        }
    }
    
    func insertDBUser(_ modifier: PlanItModifier) {
        guard modifier.readValueOfUserId() != Session.shared.readUserId() else { return }
        if !self.allDatabaseUser.contains(where: { return $0.userId == modifier.readValueOfUserId() }) {
            let creator = CalendarUser(modifier, conversionNeeded: false)
            self.removePhoneContactUserFromDatabase(creator)
            self.allDatabaseUser.append(creator)
        }
    }
    
    func insertDBUser(_ invitees: PlanItInvitees) {
        guard invitees.readValueOfUserId() != Session.shared.readUserId() else { return }
        if !self.allDatabaseUser.contains(where: { return $0.userId == invitees.readValueOfUserId() }) {
            let creator = CalendarUser(invitees, conversionNeeded: false)
            self.removePhoneContactUserFromDatabase(creator)
            self.allDatabaseUser.append(creator)
        }
    }
    
    func readAllUserContacts() {
        self.readAllDBUsers()
        self.getAllContactUsers()
    }
    
    func readAllDBUsers() {
        self.isAllDatabaseUserFetching = true
        DatabasePlanItData().readAllMiPlanItMembers(completionHandler: { plantItUser in
             self.allDatabaseUser = plantItUser
            self.isAllDatabaseUserFetching = false
            self.removeAllDatabaseUserFromPhoneContacts()
            self.postFinishNotification()
        })
    }
    
    func getAllContactUsers() {
        self.isAllContactUserFetching = true
        self.readAllContactUsers { (emails, phones) in
            UserService().getRegisteredContacts(phones, emails: emails) { (contacts, error) in
                contacts?.forEach({ self.insertMyPlanItContacts($0) })
                self.allContactUser = emails + phones
                self.isAllContactUserFetching = false
                self.removeAllDatabaseUserFromPhoneContacts()
                self.postFinishNotification()
            }
        }
    }
    
    func readAllContactUsers(completionHandler: @escaping ([CalendarUser], [CalendarUser]) -> ()) {
        DispatchQueue.global(qos: .userInitiated).async {
            var phoneAddedContacts: [String] = []
            var emailAddedContacts: [String] = []
            var devicePhoneContacts: [CalendarUser] = []
            var deviceEmailContacts: [CalendarUser] = []
            self.readPhoneContacts().forEach({ contact in
                let emails: [String] = contact.emailAddresses.compactMap({ if (emailAddedContacts.contains(($0.value as String).lowercased()) || ($0.value as String).isEmpty) { return nil } else { emailAddedContacts.append(($0.value as String).lowercased()); return $0.value as String } })
                let phoneNumbers: [String] = contact.phoneNumbers.compactMap({ if (phoneAddedContacts.contains($0.value.stringValue) || ($0.value.stringValue).isEmpty) { return nil } else { phoneAddedContacts.append($0.value.stringValue); return $0.value.stringValue } })
                deviceEmailContacts += emails.map({ return CalendarUser(contact.givenName + (contact.middleName.isEmpty ? Strings.empty : Strings.space + contact.middleName) + (contact.familyName.isEmpty ? Strings.empty : Strings.space + contact.familyName), mail: $0)})
                devicePhoneContacts += phoneNumbers.map({ return CalendarUser(contact.givenName + (contact.middleName.isEmpty ? Strings.empty : Strings.space + contact.middleName) + (contact.familyName.isEmpty ? Strings.empty : Strings.space + contact.familyName), number: $0)})
            })
            completionHandler(deviceEmailContacts, devicePhoneContacts)
        }
    }
    
    func readPhoneContacts() -> [CNContact] {
        var results: [CNContact] = []
        let contactStore = CNContactStore()
        let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactMiddleNameKey, CNContactPhoneNumbersKey, CNContactEmailAddressesKey]
        let request = CNContactFetchRequest(keysToFetch: keys as [CNKeyDescriptor])
        request.sortOrder = CNContactSortOrder.givenName
        
        do {
            try contactStore.enumerateContacts(with: request) {
                (contact, stop) in
                results.append(contact)
            }
        }
        catch {
            print("unable to fetch contacts")
        }
        return results
    }
}
