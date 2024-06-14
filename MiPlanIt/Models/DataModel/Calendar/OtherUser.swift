//
//  OtherUser.swift
//  MiPlanIt
//
//  Created by Arun on 14/04/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation
import UIKit

public enum UserStatus: Int {
    case eDefault = 0, eBusy, eAvailable, eAway
}

public enum RespondStatus: Int {
    case eDefault = 0, eAccepted, eRejected, eNotResponded
}

public enum TypeOfBubbleList: Int {
    case eDefault = 0, ePlanitUser, eOtherUser, eCalendar
}

class OtherUser {
    
    let email: String
    let phone: String
    let countryCode: String
    let profileImage: String
    let userId: String
    let userName: String
    var color: String = Strings.empty
    var isPrivate = true
    var isDeletable: Bool
    var fullName: String
    var events: [OtherUserEvent] = []
    var currentStatus: UserStatus = .eDefault
    var sharedStatus: Double = 0
    var visibility: Double = 0
    var userContainsEmailInPhoneContact: Bool = false
    var userContainsPhoneInPhoneContact: Bool = false
    var calendarId:Int = -1
    init(with user: [String: Any], deletable: Bool = true, colors: [String], index: Int) {
        self.isDeletable = deletable
        self.email = user["email"] as? String ?? Strings.empty
        self.calendarId = user["calendarId"] as? Int ?? -1
        self.fullName = user["fullName"] as? String ?? Strings.empty
        self.phone = user["phone"] as? String ?? Strings.empty
        self.countryCode = user["countryCode"] as? String ?? Strings.empty
        self.profileImage = user["profileImage"] as? String ?? Strings.empty
        self.userName = user["userName"] as? String ?? Strings.empty
        self.userId = (user["userId"] as? Double)?.cleanValue() ?? Strings.empty
        self.color = colors[index%colors.count]
        self.visibility = user["visibility"] as? Double ?? 0
        if let userEvents =  user["events"] as? [[String: Any]] {
            self.events = userEvents.map({ return OtherUserEvent(with: $0, user: self.userId, visibility: self.visibility, userColor: Storage().readEventBGColorFromCode(self.color), colorCode: self.color)})
        }
        self.sharedStatus = user["sharedStatus"] as? Double ?? 0
        if let phoneContact = Session.shared.readFullContacts().first(where: { return ($0.email.caseInsensitiveCompare(self.email) == .orderedSame && !self.email.isEmpty) || ($0.phone.hasSuffix(self.phone) && !self.phone.isEmpty) || (self.phone.hasSuffix($0.phone) && !$0.phone.isEmpty) }) {
            self.isPrivate = phoneContact.isPrivate
            self.userContainsEmailInPhoneContact = phoneContact.userContainsEmailInPhoneContact
            self.userContainsPhoneInPhoneContact = phoneContact.userContainsPhoneInPhoneContact
            self.fullName = phoneContact.name
        }
    }
    
    init(invitee: PlanItInvitees, deletable: Bool = true) {
        self.isDeletable = deletable
        self.email = invitee.email ?? Strings.empty
        self.fullName = invitee.fullName ?? Strings.empty
        self.phone = invitee.phone ?? Strings.empty
        self.countryCode = invitee.countryCode ?? Strings.empty
        self.profileImage = invitee.profileImage ?? Strings.empty
        self.userName = invitee.userName ?? Strings.empty
        self.userId = invitee.readValueOfUserId()
        self.sharedStatus = invitee.readValueOfSharedStatus()
        self.isPrivate = !invitee.isOther
        if let phoneContact = Session.shared.readFullContacts().first(where: { return ($0.email.caseInsensitiveCompare(self.email) == .orderedSame && !self.email.isEmpty) || ($0.phone.hasSuffix(self.phone) && !self.phone.isEmpty) || (self.phone.hasSuffix($0.phone) && !$0.phone.isEmpty) }) {
            self.isPrivate = phoneContact.isPrivate
            self.userContainsEmailInPhoneContact = phoneContact.userContainsEmailInPhoneContact
            self.userContainsPhoneInPhoneContact = phoneContact.userContainsPhoneInPhoneContact
            self.fullName = phoneContact.name
        }
    }
    
    init(invitee: OtherUserEventInvitees) {
        self.isDeletable = true
        self.email = invitee.email
        self.fullName = invitee.fullName
        self.phone = invitee.phone
        self.profileImage = invitee.profileImage
        self.userName = invitee.userName
        self.userId = invitee.userId
        self.countryCode = Strings.empty
        self.sharedStatus = invitee.sharedStatus
        self.isPrivate = !invitee.userId.isEmpty
        if let phoneContact = Session.shared.readFullContacts().first(where: { return ($0.email.caseInsensitiveCompare(self.email) == .orderedSame && !self.email.isEmpty) || ($0.phone.hasSuffix(self.phone) && !self.phone.isEmpty) || (self.phone.hasSuffix($0.phone) && !$0.phone.isEmpty) }) {
            self.isPrivate = phoneContact.isPrivate
            self.userContainsEmailInPhoneContact = phoneContact.userContainsEmailInPhoneContact
            self.userContainsPhoneInPhoneContact = phoneContact.userContainsPhoneInPhoneContact
            self.fullName = phoneContact.name
        }
    }
    
    init(calendarUser: CalendarUser) {
        self.isDeletable = true
        self.fullName = calendarUser.name
        self.email = calendarUser.email
        self.phone = calendarUser.phone
        self.profileImage = calendarUser.profile
        self.userId = calendarUser.userId
        self.countryCode = calendarUser.countryCode
        self.userName = calendarUser.name
    }
    
    init(calendarUser: CalendarUser, colors: [String], index: Int) {
        self.isDeletable = true
        self.fullName = calendarUser.name
        self.email = calendarUser.email
        self.phone = calendarUser.phone
        self.profileImage = calendarUser.profile
        self.userId = calendarUser.userId
        self.countryCode = calendarUser.countryCode
        self.userName = calendarUser.name
    }
    
    init(attendees: PlanItEventAttendees, deletable: Bool = true) {
        self.isDeletable = deletable
        self.fullName = attendees.readName()
        self.email = attendees.readEmail()
        self.phone = Strings.empty
        self.profileImage = Strings.empty
        self.userId = Strings.empty
        self.countryCode = Strings.empty
        self.userName = Strings.empty
        self.sharedStatus = self.setSharedStatus(status: attendees.status)
        self.isPrivate = false
        if let phoneContact = Session.shared.readFullContacts().first(where: { return $0.email.caseInsensitiveCompare(self.email) == .orderedSame && !self.email.isEmpty }) {
            self.fullName = phoneContact.name
        }
    }
    
    init(attendees: OtherUserEventAttendees, deletable: Bool = true) {
        self.isDeletable = deletable
        self.fullName = attendees.name
        self.email = attendees.email
        self.phone = Strings.empty
        self.profileImage = Strings.empty
        self.userId = Strings.empty
        self.countryCode = Strings.empty
        self.userName = Strings.empty
        self.isPrivate = false
        self.sharedStatus = self.setSharedStatus(status: attendees.status)
        if let phoneContact = Session.shared.readFullContacts().first(where: { return $0.email.caseInsensitiveCompare(self.email) == .orderedSame && !self.email.isEmpty }) {
            self.fullName = phoneContact.name
        }
    }
    
    init(planItUser: PlanItUser) {
        self.email = planItUser.readValueOfEmail()
        self.phone = planItUser.readValueOfPhoneNumber()
        self.profileImage = planItUser.imageUrl ?? Strings.empty
        self.userId = planItUser.readValueOfUserId()
        self.countryCode = planItUser.readValueOfCountryCode()
        self.userName = planItUser.readValueOfUserName()
        self.fullName = planItUser.readValueOfName()
        self.color = Strings.defaultColor
        self.isDeletable = false
    }
    
    init(userName: String) {
        self.email = userName
        self.userName = userName
        self.fullName = userName
        self.phone = Strings.empty
        self.profileImage = Strings.empty
        self.userId = Strings.empty
        self.countryCode = Strings.empty
        self.isDeletable = false
    }
    
    func readResponseStatus() -> RespondStatus {
        switch self.sharedStatus {
        case 0:
            return .eNotResponded
        case 1:
            return .eAccepted
        case 2:
            return .eRejected
        default:
            return .eNotResponded
        }
    }
    
    fileprivate func setSharedStatus(status: String?) -> Double {
        guard let sharedStatus = status else {
            return 0
        }
        if sharedStatus == "accepted" {
            return 1
        }
        else if sharedStatus == "declined" {
            return 2
        }
        else {
            return 0
        }
    }
    
    func readAllEvents() -> [OtherUserEvent] {
        let recurrenceEvent = self.events.filter({ return $0.isRecurrence }).flatMap({ return $0.readAllChildEvents() }).filter({ return $0.status == 0})
        return self.events + recurrenceEvent
    }
    
    func readAllOtherEventsFrom(start:Date, end:Date) -> [OtherUserEvent] {
        return self.readAllEvents().filter({
            if !$0.isRecurrence { return ($0.readStartDateTime() >= start && $0.readStartDateTime() <= end) || ($0.readEndDateTime() >= start && $0.readEndDateTime() <= end) || ($0.readStartDateTime() < start && $0.readEndDateTime() > end) }
            else { guard let recurrenceDate = $0.readRecurrenceEndDate() else { return $0.readStartDateTime() <= end }
                return ($0.readStartDateTime() >= start && $0.readStartDateTime() <= end) || (recurrenceDate >= start && recurrenceDate <= end) || ($0.readStartDateTime() < start && recurrenceDate > end)
            }
        })
    }
    
    convenience init(with user: [String: Any], contains invitees: [CalendarUser], colors: [String], index: Int) {
        let invitee = invitees.filter({ return $0.userType == .miplanit && $0.userId == (user["userId"] as? Double)?.cleanValue() }).first
        self.init(with: user, deletable: invitee?.isDeletable ?? true, colors: colors, index: index)
    }
    
    convenience init(with user: [String: Any], contains invitees: [PlanItInvitees], colors: [String], index: Int) {
        let invitee = invitees.filter({ return $0.readValueOfUserId() == (user["userId"] as? Double)?.cleanValue() }).first
        self.init(with: user, deletable: invitee?.accessLevel == 1, colors: colors, index: index)
    }
    
    func checkUserStatus(from startDate: Date, to endDate: Date) -> UserStatus {
        
        let endOfDate = startDate.initialHour().adding(days: 2)
        let startOfDate = endDate.initialHour().adding(days: -1)
        let availableTimeSlotEvents = self.readAllTimeSlotEvents(self.readAllOtherEventsFrom(start: startOfDate, end: endOfDate), start: startOfDate, end: endOfDate)
        
        let range = startDate...endDate
        var status: UserStatus = .eAvailable
        for eachTimeSlot in availableTimeSlotEvents {
            if (eachTimeSlot.startDate > range.lowerBound && eachTimeSlot.startDate < range.upperBound)
                || (eachTimeSlot.endDate > range.lowerBound && eachTimeSlot.endDate < range.upperBound)
                || (eachTimeSlot.startDate < range.lowerBound && eachTimeSlot.endDate > range.upperBound)
                || (eachTimeSlot.startDate == range.lowerBound && eachTimeSlot.endDate >= range.upperBound)
                || (eachTimeSlot.startDate >= range.lowerBound && eachTimeSlot.endDate == range.upperBound)
                || (eachTimeSlot.startDate < range.lowerBound && eachTimeSlot.endDate == range.upperBound) {
                status = .eBusy
                break
            }
//            else if eachTimeSlot.endDate > eachTimeSlot.startDate {
//                if (eachTimeSlot.startDate...eachTimeSlot.endDate).contains(startDate) || (eachTimeSlot.startDate...eachTimeSlot.endDate).contains(endDate) {
//                    status = .eBusy
//                    break
//                }
//            }
        }
        self.currentStatus = status
        return status
    }
    
    func readAllTimeSlotEvents(_ allEvents: [OtherUserEvent], start: Date, end: Date) -> [TimeSlotEvent] {
        var arrayTimeSlotEvent: [TimeSlotEvent] = []
        let nonAllDayEvent = allEvents.filter({ !$0.isAllDay })
        nonAllDayEvent.forEach { (event) in
            arrayTimeSlotEvent += event.readAllAvailableDates(from: start, to: end).map({ return  TimeSlotEvent(with: $0, event: event) })
        }
        return arrayTimeSlotEvent
    }
    
    func readDisplayName() -> String {
        return self.fullName.isEmpty ? self.email : self.fullName
    }
}
