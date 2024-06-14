//
//  CalendarUser.swift
//  MiPlanIt
//
//  Created by Arun on 12/04/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

class CalendarUser: Comparable {
    
    var isPrivate = true
    var isDeletable = true
    var userType: CalendarUserType!
    var name: String = Strings.empty
    var userId: String = Strings.empty
    var profile: String = Strings.empty
    var email: String = Strings.empty
    var phone: String = Strings.empty
    var countryCode: String = Strings.empty
    var sharedStatus: Double = 0
    var visibility: Int?
    var accessLevel: Double = 2
    var respondStatus: RespondStatus = .eDefault
    var planItCalendarShared: PlanItCalendar?
    var isDisabled: Bool = false
    var userContainsEmailInPhoneContact: Bool = false
    var userContainsPhoneInPhoneContact: Bool = false
    var calendarId: Int = -1
//    calendarId
    init(_ name: String, number: String = Strings.empty, mail: String = Strings.empty) {
        self.isPrivate = false
        self.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        self.email = mail
        let numerSpecifier = self.readCountryCodeAndPhoneFromNumber(number)
        self.phone = numerSpecifier.phone
        self.countryCode = numerSpecifier.country
        self.userType = .contact
        self.userContainsEmailInPhoneContact = !mail.isEmpty
        self.userContainsPhoneInPhoneContact = !number.isEmpty
    }
    
    init(_ email: String) {
        self.email = email
        self.userType = .other
        self.name = email
    }
    
    init(_ user: OtherUser) {
        self.isPrivate = user.isPrivate
        self.name = user.fullName
        self.userId = user.userId
        self.profile = user.profileImage
        self.email = user.email
        self.phone = user.phone
        self.countryCode = user.countryCode
        self.isDeletable = user.isDeletable
        self.userType = user.userId.isEmpty ? .contact : .miplanit
        self.respondStatus = user.readResponseStatus()
        self.calendarId = user.calendarId
    }
    
    init(_ user: PlanItContacts) {
        self.isPrivate = false
        self.userType = .miplanit
        self.name = user.readName()
        self.userId = user.readUserId()
        self.profile = user.readProfileImage()
        self.email = user.readEmail()
        self.phone = user.readPhone()
        self.countryCode = user.readCountryCode()
        self.userContainsEmailInPhoneContact = user.readUserEmailExistInContact()
        self.userContainsPhoneInPhoneContact = user.readUserPhoneExistInContact()
    }
    
    init(_ user: PlanItCreator, conversionNeeded ifNeeded: Bool = true) {
        self.userType = .miplanit
        self.name = user.readValueOfFullName()
        self.userId = user.readValueOfUserId()
        self.profile = user.readValueOfProfileImage()
        self.email = user.readValueOfEmail()
        self.phone = user.readValueOfPhone()
        if ifNeeded, let phoneContact = Session.shared.readFullContacts().first(where: { return ($0.email.caseInsensitiveCompare(self.email) == .orderedSame && !self.email.isEmpty) || ($0.phone.hasSuffix(self.phone) && !self.phone.isEmpty) || (self.phone.hasSuffix($0.phone) && !$0.phone.isEmpty) }) {
            self.isPrivate = phoneContact.isPrivate
            self.userContainsEmailInPhoneContact = phoneContact.userContainsEmailInPhoneContact
            self.userContainsPhoneInPhoneContact = phoneContact.userContainsPhoneInPhoneContact
            self.name = phoneContact.name
        }
    }
    
    init(_ user: PlanItModifier, conversionNeeded ifNeeded: Bool = true) {
        self.userType = .miplanit
        self.name = user.readValueOfFullName()
        self.userId = user.readValueOfUserId()
        self.profile = user.readValueOfProfileImage()
        self.email = user.readValueOfEmail()
        self.phone = user.readValueOfPhone()
        if ifNeeded, let phoneContact = Session.shared.readFullContacts().first(where: { return ($0.email.caseInsensitiveCompare(self.email) == .orderedSame && !self.email.isEmpty) || ($0.phone.hasSuffix(self.phone) && !self.phone.isEmpty) || (self.phone.hasSuffix($0.phone) && !$0.phone.isEmpty) }) {
            self.isPrivate = phoneContact.isPrivate
            self.userContainsEmailInPhoneContact = phoneContact.userContainsEmailInPhoneContact
            self.userContainsPhoneInPhoneContact = phoneContact.userContainsPhoneInPhoneContact
            self.name = phoneContact.name
        }
    }
    
    init(_ user: PlanItInvitees, conversionNeeded ifNeeded: Bool = true) {
        self.userType = .miplanit
        self.name = user.readValueOfFullName()
        self.userId = user.readValueOfUserId()
        self.profile = user.readValueOfProfileImage()
        self.email = user.readValueOfEmail()
        self.phone = user.readValueOfPhone()
        self.countryCode = user.readValueOfCountryCode()
        self.sharedStatus = user.readValueOfSharedStatus()
        self.visibility = Int(user.readValueOfVisibility())
        self.respondStatus = user.readResponseStatus()
        self.isPrivate = !user.isOther
        if ifNeeded, let phoneContact = Session.shared.readFullContacts().first(where: { return ($0.email.caseInsensitiveCompare(self.email) == .orderedSame && !self.email.isEmpty) || ($0.phone.hasSuffix(self.phone) && !self.phone.isEmpty) || (self.phone.hasSuffix($0.phone) && !$0.phone.isEmpty) }) {
            self.isPrivate = phoneContact.isPrivate
            self.userContainsEmailInPhoneContact = phoneContact.userContainsEmailInPhoneContact
            self.userContainsPhoneInPhoneContact = phoneContact.userContainsPhoneInPhoneContact
            self.name = phoneContact.name
        }
    }
    
    init(_ calendar: PlanItCalendar, disabled: Bool = false) {
        self.planItCalendarShared = calendar
        self.isDisabled = disabled
    }
    
    init(_ sharedUser: [String: Any]) {
        if let userId = sharedUser["userId"] as? Int { self.userId = "\(userId)" }
        self.name = sharedUser["fullName"] as? String ?? Strings.empty
        self.phone = sharedUser["phone"] as? String ?? Strings.empty
        self.email = sharedUser["email"] as? String ?? Strings.empty
        self.profile = sharedUser["profileImage"] as? String ?? Strings.empty
        self.visibility = sharedUser["visibility"] as? Int
        self.calendarId = sharedUser["calendarId"] as? Int ?? -1
    }
    
    func readName() -> String {
        if !self.name.isEmpty {
            return self.name
        }
        if !self.email.isEmpty {
            return self.email
        }
        return self.countryCode + self.phone
    }
    
    func readEmailOrPhone() -> String {
        if !self.email.isEmpty {
            return self.email
        }
        return self.countryCode + self.phone
    }
    
    func readIdentifier() -> String {
        if !self.userId.isEmpty {
            return self.userId
        }
        if !self.email.isEmpty {
            return self.email
        }
        if let calendar = self.planItCalendarShared {
            return calendar.readValueOfCalendarId()
        }
        return self.countryCode + self.phone
    }
    
    func readCountryCodeAndPhoneFromNumber(_ number: String) -> (country: String, phone: String) {
        var countryCode = "+\(Storage().readDefaultCountryCodeOnPhone())"
        let splittedNumbers = number.components(separatedBy: Strings.space)
        if let code = splittedNumbers.first, code.hasPrefix("+") { countryCode = code }
        let balanceNumber = number.replacingOccurrences(of: countryCode, with: Strings.empty).filter("0123456789".contains)
        if balanceNumber.isEmpty && !countryCode.isEmpty {
            let newNumber = number.filter("+0123456789".contains)
            return (country: Strings.empty, phone: newNumber)
        }
        return (country: countryCode, phone: balanceNumber)
    }
    
    func isSharedMiPlanItCalendar() -> Bool {
        return self.planItCalendarShared != nil
    }
    
    func readAllShareUserList() -> [CalendarUser] {
        guard let calendar =  self.planItCalendarShared else { return [] }
        var calendarUser: [CalendarUser] = []
        if let creator = calendar.createdBy {
            calendarUser.append(CalendarUser(creator))
        }
        let sharedUsers = calendar.isSocialCalendar() ? calendar.readAllUserCalendarInvitees() : (calendar.readValueOfParentCalendarId() == "0" ? calendar.readAllCalendarSharedUser() : calendar.readAllUserCalendarInvitees())
        calendarUser.append(contentsOf: sharedUsers.compactMap({ CalendarUser($0) }))
        return calendarUser
    }
    
    func updateDisabledFlag(with flag: Bool) {
        if self.isSharedMiPlanItCalendar() {
            self.isDisabled = flag
        }
    }
    
    static func ==(lhs: CalendarUser, rhs: CalendarUser) -> Bool {
        return lhs.readIdentifier() == rhs.readIdentifier()
    }
    
    static func < (lhs: CalendarUser, rhs: CalendarUser) -> Bool {
        return lhs.readIdentifier() == rhs.readIdentifier()
    }
}
