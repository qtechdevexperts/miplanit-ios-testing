//
//  PlanItEvent+Save.swift
//  MiPlanIt
//
//  Created by Arun on 08/04/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation
// import RRuleSwift
import EventKit
import CoreData

extension PlanItEvent {
    
    func readValueOfEventId() -> String { return self.eventId == 0 ? Strings.empty : self.eventId.cleanValue() }
    func readValueOfAppEventId() -> String { return self.appEventId ?? Strings.empty }
    func readValueOfUserId() -> String { return self.user ?? Strings.empty }
    func readValueOfSocialEventId() -> String { return self.extEventId ?? Strings.empty }
    func readValueOfEventName() -> String { return self.eventName ?? Strings.empty }
    func readStartDate() -> String { return self.startDate ?? Strings.empty }
    func readStartTime() -> String { return self.startTime ?? Strings.empty }
    func readEndDate() -> String { return self.endDate ?? Strings.empty }
    func readEndTime() -> String { return self.endTime ?? Strings.empty }
    func readLocation() -> String { return self.location ?? Strings.empty }
    func readBodyContentType() -> String { return self.bodyContentType ?? Strings.empty }
    func readValueOfEventDescription() -> String { return self.eventDescription ?? Strings.empty }
    func isUserTravelling() -> Bool { return self.isAvailable == 1 }
    func isHTMLContent() -> Bool { return self.readBodyContentType().lowercased() == "html" }
    func readHtmlLink() -> String { return self.htmlLink ?? Strings.empty }
    func readRecurringEventId() -> String { return self.recurringEventId ?? Strings.empty }
    func readSortedTime() -> Date { return self.sortedTime ?? self.readStartDateTime() }
    func readStartDateTime() -> Date { return self.startDateTime ?? Date() }
    func readEndDateTime() -> Date { return self.endDateTime ?? Date() }
    func readRecurrenceEndDate() -> Date? { return self.recurrenceEndDate }
    func readReminders() -> PlanItReminder? { return self.reminder }
    func readconferenceType() -> String { return self.conferenceType ?? Strings.empty  }
    func readconferenceURL() -> String { return self.conferenceUrl ?? Strings.empty  }
    func readValueOfNotificationId() -> String {
        if let bNotificationId = self.notificationId, !bNotificationId.isEmpty {
            return bNotificationId
        }
        else {
            let newNotificationId = self.readValueOfEventId().isEmpty ? self.readValueOfAppEventId() : self.readValueOfEventId()
            self.notificationId = newNotificationId
            return newNotificationId
        }
    }
    
    func readEndTimeZoneOfEvent() -> String? {
        return self.originalEndTimeZone
    }
    
    func readTimeZoneOfEvent() -> String? {
        if let recurrenceTimeZone = self.recurrence?.recurrenceTimeZone, !recurrenceTimeZone.isEmpty {
            return recurrenceTimeZone
        }
        return self.originalStartTimeZone
    }
    func readFullConferenceData() -> String {
        return self.fullConferenceData ?? Strings.empty
    }
    
    func readEventCalendar() -> PlanItEventCalendar? {
        return self.readAllEventCalendars().first
    }
    
    func readMainCalendar() -> MiPlanItEventCalendar? {
        if let eventCalendar = self.readEventCalendar() {
            if let miplanitCalendar = Session.shared.readFastestCalendars().filter({ return $0.calendarId == eventCalendar.calendarId }).first {
                return miplanitCalendar
            }
            else if let miplanitCalendar = Session.shared.readFastestCalendars().filter({
                return $0.readValueOfAppCalendarId() == eventCalendar.readValueOfAppCalendarId() && !$0.readValueOfAppCalendarId().isEmpty
            }).first {
                return miplanitCalendar
            }
        }
        return Session.shared.readFastestCalendars().filter({ return $0.parentCalendarId == 0 }).first
    }
    
    func isMainCalendarPending() -> Bool {
        return self.readMainCalendar()?.calendar.isPending ?? false
    }
    
    
    func readEventCalendarName() -> String {
        return self.readMainCalendar()?.calendar.readValueOfCalendarName() ?? Strings.empty
    }
    
    func readSocialResponseStatus() -> Bool {
        if let status = self.responseStatus, status.lowercased() == "organizer" || status.lowercased() == "accepted" {
            return true
        }
        return false
    }
    
    func loginUserContainsInAttendees() -> PlanItEventAttendees? {
        if let loginEmail = Session.shared.readUser()?.email, !loginEmail.isEmpty {
            return self.readAllAttendees().filter({ $0.email == loginEmail }).first
        }
        return nil
    }
    
    func creatorUserContainsInAttendees() -> PlanItEventAttendees? {
        if let email = self.createdBy?.readValueOfEmail(), let loginEmail = Session.shared.readUser()?.email, !loginEmail.isEmpty, loginEmail == email {
            return self.readAllAttendees().filter({ $0.email == email }).first
        }
        return nil
    }
    
    func loginUserOrSocialAccountEmailIsOrganizer() -> Bool? {
        let oEmail = self.readSocialCalendarEventCreatorEmail()
        if let importedAccountId = self.readEventCalendar()?.readValueOfSocialAccountEmail() {
            return oEmail == importedAccountId
        }
        return false
    }
    
    func importedAccountContainsInAttendees() -> PlanItEventAttendees? {
        if let importedAccountId = self.readEventCalendar()?.readValueOfSocialAccountEmail() {
            return self.readAllAttendees().filter({ $0.readEmail() == importedAccountId }).first
        }
        return nil
    }
    
    func isEventAccepted()->Bool {
        if let invitees = self.readAllEventInvitees().filter({ return $0.readValueOfUserId() == Session.shared.readUserId() }).first {
            return invitees.sharedStatus == 1
        }
        if self.isSocialEvent {
            if self.readSocialResponseStatus() {
                return true
            }
            if let planItEventAttendees = self.creatorUserContainsInAttendees() {
                return planItEventAttendees.readSharedStatus == 1
            }
            else if let planItEventAttendees = self.importedAccountContainsInAttendees() {
                guard let calendar = self.readEventCalendar() else {
                    return planItEventAttendees.readSharedStatus == 1
                }
                switch calendar.readValueOfCalendarType() {
                case "1":
                    return planItEventAttendees.readSharedStatus != 1 ? calendar.readValueOfSocialAccountEmail() == self.readSocialCalendarEventCreatorEmail() : true
                case "2":
                    return planItEventAttendees.readSharedStatus != 1 ? calendar.readValueOfSocialAccountName() == self.organizerEmail: true
                case "3":
                    return planItEventAttendees.readSharedStatus != 1 ? calendar.readValueOfSocialAccountEmail() == self.organizerEmail : true
                default:
                    return planItEventAttendees.readSharedStatus == 1
                }
            }
            return self.loginUserOrSocialAccountEmailIsOrganizer() ?? false
        }
        return true
    }
    
    func readAllAvailableCalendars(includingParent parent: Bool = false) -> [PlanItCalendar] {
        let selectedCalendars = self.readAllEventCalendars().map({ return $0.calendarId })
        let selectedAppCalendars = self.readAllEventCalendars().compactMap({ return $0.appCalendarId })
        return DatabasePlanItCalendar().readCalendersUsingId(selectedCalendars, appCalendarIds: selectedAppCalendars, includingParent: parent)
    }
    
    func readAllAvailableNotifyCalendars() -> [PlanItCalendar] {
        let selectedCalendars = self.readAllEventNotifyCalendars().map({ return $0.calendarId })
        let selectedAppCalendars = self.readAllEventCalendars().compactMap({ return $0.appCalendarId })
        return DatabasePlanItCalendar().readCalendersUsingId(selectedCalendars, appCalendarIds: selectedAppCalendars)
    }
    
    func readAllEventCalendars() -> [PlanItEventCalendar] {
        if let calendar = self.calendars, let eventCalendars = Array(calendar) as? [PlanItEventCalendar] {
            return eventCalendars
        }
        return []
    }
    
    func readAllEventNotifyCalendars() -> [PlanItEventCalendar] {
        if let calendar = self.notifyCalendars, let eventCalendars = Array(calendar) as? [PlanItEventCalendar] {
            return eventCalendars
        }
        return []
    }
    
    func readOrginalUserStartDateTime() -> Date {
        if let timeZone = self.readTimeZone(), !self.isAllDay {
            return self.readStartDateTime().convertTimeZone(timeZone, to: TimeZone.current)
        }
        return self.readStartDateTime()
    }

    func readStartDateTimeFromDate(_ date: Date) -> Date {
        if self.isAllDay {
            return (date.stringFromDate(format: DateFormatters.MMDDYYYY) + Strings.space + self.readStartTime()).stringToDate(formatter: DateFormatters.MMDDYYYYHMMSSA) ?? self.readStartDateTime()
        }
        let calculatedDateTime = (date.stringFromDate(format: DateFormatters.MMDDYYYY) + Strings.space + self.readStartTime()).stringToDate(formatter: DateFormatters.MMDDYYYYHMMSSA, timeZone: TimeZone(abbreviation: "UTC")!) ?? self.readStartDateTime()
        if calculatedDateTime.initialHour() == date || !self.isEventOnSameDayForUser() {
            let timezoneOffset = self.readStartDateDayLightTimeOffSet() - self.readDayLightTimeOffSetForDate(calculatedDateTime)
            return calculatedDateTime.adding(seconds: timezoneOffset)
        }
        else {
            let days = calculatedDateTime.initialHour().daysBetweenDate(toDate: date)
            let orginalDate = calculatedDateTime.addDays(days)
            let timezoneOffset = self.readStartDateDayLightTimeOffSet() - self.readDayLightTimeOffSetForDate(orginalDate)
            return orginalDate.adding(seconds: timezoneOffset)
        }
    }
    
    func isEventOnSameDayForUser() -> Bool {
        if let timeZone = self.readTimeZone() {
            return self.readStartDateTime().convertTimeZone(timeZone, to: TimeZone.current).initialHour() ==  self.readStartDateTime().initialHour()
        }
        return true
    }
    
    func readEndDateTimeFromDate(_ date: Date) -> Date {
        return self.readStartDateTimeFromDate(date).addingTimeInterval(self.readEndDateTime().timeIntervalSince1970 - self.readStartDateTime().timeIntervalSince1970)
    }
    
    func readTimeZone() -> TimeZone? {
        guard let timezone = self.readTimeZoneOfEvent(), !timezone.isEmpty else { return nil }
        let eventTimeZone = timezone.convertTimeZoneToAppleZone()
        return (eventTimeZone == "GMT" || eventTimeZone.hasPrefix("tzone")) && self.responseStatus != "organizer" ? TimeZone.current : TimeZone(identifier: eventTimeZone)
    }
    
    func readStartDateDayLightTimeOffSet() -> Int {
        guard let eventOrginalTimeZone = self.readTimeZone() else { return 0 }
        return Int(eventOrginalTimeZone.daylightSavingTimeOffset(for: self.readStartDateTime()))
    }
    
    func readDayLightTimeOffSetForDate(_ date: Date) -> Int {
        guard let eventOrginalTimeZone = self.readTimeZone() else { return 0 }
        return Int(eventOrginalTimeZone.daylightSavingTimeOffset(for: date))
    }
    
    func readOrginalStartDateTime() -> Date? {
        return self.originalStartDateTime
    }
    
    func readPlanItRecurrance() -> PlanItEventRecurrence? {
        return self.recurrence
    }
    
    func readOrginalStartTimeZone() -> String {
        return self.originalStartTimeZone ?? Strings.empty
    }

    func readAllAvailableDates(from: Date, to: Date) -> [Date] {
        if self.isRecurrence {
            guard let availableDate = self.recurrence?.readAllAvailableDates(from: from, to: to) else { return [] }
            var excludedDates: [Date] = []
            self.readAllChildEvents().forEach({ childEvent in
                if let googleDeletedItem = childEvent.readOrginalStartDateTime() { excludedDates.append(googleDeletedItem.initialHour()) }
                else { excludedDates.append(childEvent.readStartDateTime().initialHour()) }
            })
            let availableDates: [Date] = availableDate.compactMap({ let initialDate = $0.initialHour(); if excludedDates.contains(initialDate) { return nil } else { return initialDate } })
            return availableDates
        }
        else {
            let eventDateTime = self.readStartDateTime().initialHour()
            return eventDateTime >= from && eventDateTime <= to ? [eventDateTime] : []
        }
    }
    
    func readCalendarColorCode() -> UIColor {
        return Storage().readCalendarColorFromCode(self.readMainCalendar()?.calendar.readValueOfColorCode())
    }
    
    func isSocialCalendarEvent() -> Bool {
        return self.readEventCalendar()?.isSocialCalendar() ?? false
    }
    
    func readSocialCalendarEventCreatorName() -> String? {
        guard let calendar = self.readEventCalendar() else {
            return Strings.empty
        }
        var socialCreator: String = Strings.empty
        switch calendar.calendarType {
        case 1 where self.isSocialEvent:
            let name = !(self.organizerName ?? Strings.empty).isEmpty ? (self.organizerName ?? Strings.empty) : (self.creatorName ?? Strings.empty)
            socialCreator = !(name).isEmpty ? name : self.creatorEmail ?? Strings.empty
        case 2 where self.isSocialEvent:
            socialCreator = !(self.organizerName ?? Strings.empty).isEmpty ? self.organizerName ?? Strings.empty : self.organizerEmail ?? Strings.empty
        case 3 where self.isSocialEvent:
            socialCreator = !(self.organizerName ?? Strings.empty).isEmpty ? self.organizerName ?? Strings.empty : self.organizerEmail ?? Strings.empty
        default:
            break
        }
        if socialCreator.isEmpty && calendar.isSocialCalendar() {
            socialCreator = calendar.readValueOfSocialAccountName()
        }
        if socialCreator.isEmpty, let creator = self.createdBy {
            if calendar.calendarType == 3 && self.isSocialEvent {
                return calendar.readValueOfCalendarName()
            }
            return !creator.readValueOfFullName().isEmpty ? creator.readValueOfFullName() : (!creator.readValueOfEmail().isEmpty ? creator.readValueOfEmail() : creator.readValueOfPhone())
        }
        return socialCreator
    }
    
    func readSocialCalendarEventCreatorEmail() -> String {
        guard let calendar = self.readEventCalendar() else {
            return Strings.empty
        }
        var socialCreator: String = Strings.empty
        switch calendar.calendarType {
        case 1 where self.isSocialEvent:
            socialCreator =  !(self.organizerEmail ?? Strings.empty).isEmpty ? (self.organizerEmail ?? Strings.empty) : (self.creatorEmail ?? Strings.empty)
        case 2 where self.isSocialEvent:
            socialCreator = self.organizerEmail ?? Strings.empty
        case 3 where self.isSocialEvent:
            socialCreator = (self.organizerEmail ?? Strings.empty).isEmpty ? self.organizerName ?? Strings.empty : self.organizerEmail ?? Strings.empty
        default:
            break
        }
        if socialCreator.isEmpty && calendar.isSocialCalendar() {
            socialCreator = calendar.readValueOfSocialAccountEmail()
        }
        if socialCreator.isEmpty, let creator = self.createdBy {
            if calendar.calendarType == 3 && self.isSocialEvent {
                return Strings.empty
            }
            return !creator.readValueOfEmail().isEmpty ? creator.readValueOfEmail() : creator.readValueOfPhone()
        }
        return socialCreator
    }
    
    func readRecurrenceStatement() -> String {
        var repeatString = ""
        if self.isRecurrence {
            if let planItEventRecurrence = self.recurrence {
                repeatString += "Repeats "
                switch self.getRepeatValueType(recurrence: planItEventRecurrence.readRule()) {
                case .eEveryDay:
                    let interval = planItEventRecurrence.findIntervalInRule()
                    let everyYear = "\(interval.isEmpty ? "Yearly " : "every \(interval) \(Strings.years) " )"
                    let everyDay = "\(interval.isEmpty ? "Daily " : "every \(interval) \(Strings.days) " )"
                    repeatString += planItEventRecurrence.readRule().contains("BYMONTH=") ? everyYear : everyDay
                case .eEveryWeek:
                    repeatString += planItEventRecurrence.getRepeatWeeklyString()+" "
                case .eEveryMonth:
                    repeatString += planItEventRecurrence.getRepeatMonthyString()+" "
                case .eEveryYear:
                    let interval = planItEventRecurrence.findIntervalInRule()
                    repeatString += "\(interval.isEmpty ? "Yearly " : "every \(interval) Year " )"
                default:
                    repeatString += Strings.empty
                }
                if let repeatUntilDate = self.readRecurrenceEndDate() {
                    repeatString += "until \(repeatUntilDate.stringFromDate(format: DateFormatters.DDHMMMMHYYYY))"
                }
            }
        }
        return repeatString
    }
    
    
    
    private func getFrequency(recurrence: String) -> String? {
        if let repeatValue = recurrence.slice(from: "FREQ=", to: ";") {
            return repeatValue
        }
        else if let repeatValue = recurrence.slice(from: "FREQ=") {
            return repeatValue
        }
        return nil
    }
    
    func getRepeatValueType(recurrence: String) -> DropDownOptionType {
        if let repeatValue = self.getFrequency(recurrence: recurrence) {
            switch repeatValue.uppercased() {
            case "DAILY":
                return .eEveryDay
            case "WEEKLY":
                return .eEveryWeek
            case "MONTHLY", "RELATIVEMONTHLY", "ABSOLUTEMONTHLY":
                return .eEveryMonth
            case "YEARLY":
                return .eEveryYear
            default:
                break
            }
        }
        return .eNever
    }
    
    func readReminderIntervalsFromStartDate(_ date: Date) -> Date? {
        if let reminder = self.readReminders() {
            return reminder.readReminderMinutesFromDate(date)
        }
        return nil
    }
    
    func readLocationString() -> String {
        let locatinData = self.readLocation().split(separator: Strings.locationSeperator)
        if let locationName = locatinData.first {
            return String(locationName)
        }
        return Strings.empty
    }
    
    func readPlaceLatLong() -> (Double, Double)? {
        let locatinData = self.readLocation().split(separator: Strings.locationSeperator)
        if locatinData.count > 2, let latitude = Double(locatinData[1]), let longitude = Double(locatinData[2]) {
            return (latitude, longitude)
        }
        return nil
    }
    
    private func readAllEventInvitees() -> [PlanItInvitees] {
        if let bInvitees = self.invitees, let localInvitees = Array(bInvitees) as? [PlanItInvitees] {
            return localInvitees
        }
        return []
    }
    
    func readAllInvitees() -> [PlanItInvitees] {
        return self.readAllEventInvitees().filter({ return $0.readValueOfUserId() != Session.shared.readUserId() })
    }
    
    func readAllInviteesIncludingLoginUser() -> [PlanItInvitees] {
        if self.createdBy?.readValueOfUserId() == Session.shared.readUserId() {
            return self.readAllInvitees()
        }
        return self.readAllEventInvitees()
    }
    
    func readAllTags() -> [PlanItTags] {
        if let tags = self.tags, let eventTags = Array(tags) as? [PlanItTags] {
            return eventTags
        }
        return []
    }
    
    func readAllAttendees() -> [PlanItEventAttendees] {
        if let attendees = self.attendees, let eventAttendees = Array(attendees) as? [PlanItEventAttendees] {
            return eventAttendees
        }
        return []
    }
    
    func readOtherUsers() -> [OtherUser] {
        var otherUserList: [OtherUser] = []
        let allMiPlanItCalendars = self.readAllAvailableCalendars()
        let calendarInvitees = allMiPlanItCalendars.flatMap({ return $0.readAllAcceptedInvitees() }).filter({ return $0.accessLevel == 2 }).map({ return $0.readValueOfUserId()})
        Dictionary(grouping: self.readAllAttendees(), by: { $0.readEmail() }).forEach({ (email, socialAttendees) in
            if let firstAttendee = socialAttendees.first {
                otherUserList.append(OtherUser(attendees: firstAttendee, deletable: false))
            }
        })
        let emailIds = otherUserList.compactMap({ return $0.email.isEmpty ? nil : $0.email })
        self.updateAttendeeStatusIfOrganizer(otherUserList: &otherUserList)
        otherUserList += self.readAllInvitees().filter({ return !emailIds.contains($0.readValueOfEmail()) }).map({ return OtherUser(invitee: $0, deletable: !calendarInvitees.contains($0.readValueOfUserId())) })
        return otherUserList
    }
    
    func readViewEventOtherUsersIncludingLoginUser() -> [OtherUser] {
        var otherUserList: [OtherUser] = []
        let allMiPlanItCalendars = self.readAllAvailableCalendars()
        let calendarInvitees = allMiPlanItCalendars.flatMap({ return $0.readAllAcceptedInvitees() }).filter({ return $0.accessLevel == 2 }).map({ return $0.readValueOfUserId()})
        Dictionary(grouping: self.readAllAttendees(), by: { $0.readEmail() }).forEach({ (email, socialAttendees) in
            if let firstAttendee = socialAttendees.first {
                otherUserList.append(OtherUser(attendees: firstAttendee, deletable: false))
            }
        })
        let emailIds = otherUserList.compactMap({ return $0.email.isEmpty ? nil : $0.email })
        self.updateAttendeeStatusIfOrganizer(otherUserList: &otherUserList)
        otherUserList += self.readAllInviteesIncludingLoginUser().filter({ return !emailIds.contains($0.readValueOfEmail()) }).map({ return OtherUser(invitee: $0, deletable: !calendarInvitees.contains($0.readValueOfUserId())) })
        return otherUserList.filter({ user in
            let createrValue = self.readSocialCalendarEventCreatorEmail()
            if createrValue == user.email || createrValue == user.phone { return false }
            return true
        })
    }
    
    func saveTagsOffline(_ tags: [String]) {
        DatabasePlanItTags().insertTags(tags, for: self)
        self.isPending = true
        self.managedObjectContext?.saveContext()
    }
    
    func updateAttendeeStatusIfOrganizer( otherUserList: inout [OtherUser]) {
        guard let socialCalendarEmail = self.readEventCalendar()?.readValueOfSocialAccountEmail(), self.isSocialEvent else { return }
        if let matchIndex = otherUserList.map({ $0.email }).firstIndex(where: { (email) -> Bool in
            email == socialCalendarEmail
        }), otherUserList[matchIndex].sharedStatus != 1  {
            otherUserList[matchIndex].sharedStatus = self.readSocialResponseStatus() ? 1 : 0
        }
    }
    
    func readAllAttachments() -> [PlanItEventAttachment] {
        if let attachments = self.attachments, let eventAttachments = Array(attachments) as? [PlanItEventAttachment] {
            return eventAttachments
        }
        return []
    }
    
    func readAllChildEvents() -> [PlanItEvent] {
        if let childEvents = self.child, let eventSubItems = Array(childEvents) as? [PlanItEvent] {
            return eventSubItems.filter({ return $0.status != 2 })
        }
        return []
    }
    
    func saveDeleteStatus(_ deletedStatus: Double, hardSave: Bool) {
        //0: Active, 1: Deleted, 2: cancelled, 3: force
        if (deletedStatus == 3 && self.readValueOfEventId().isEmpty) || ((deletedStatus == 1 || deletedStatus == 2) && self.readValueOfEventId().isEmpty && self.parent == nil) {
            self.deleteItSelf(with: hardSave)
        }
        else {
            self.isPending = true
            self.status = deletedStatus
            if hardSave { try? self.managedObjectContext?.save() }
        }
    }
    
    @discardableResult func deleteAllChildEvents(with type: RecursiveEditOption) -> [String] {
        var deletedEvent: [String] = []
        switch type {
        case .allFutureEvent:
            if let currentRecurringEndDate = self.readRecurrenceEndDate() {
                self.readAllChildEvents().forEach({
                    if let originalCreatedDate = $0.readOrginalStartDateTime(), originalCreatedDate > currentRecurringEndDate {
                        if !$0.readValueOfEventId().isEmpty {
                            deletedEvent.append($0.readValueOfEventId())
                        }
                        else {
                            deletedEvent.append($0.readValueOfAppEventId())
                        }
                        $0.saveDeleteStatus(3, hardSave: false)
                    }
                })
            }
        case .allEventInTheSeries:
            self.readAllChildEvents().forEach({
                if !$0.readValueOfEventId().isEmpty {
                    deletedEvent.append($0.readValueOfEventId())
                }
                else {
                    deletedEvent.append($0.readValueOfAppEventId())
                }
                $0.saveDeleteStatus(3, hardSave: false)
            })
        default: break
        }
        return deletedEvent
    }
    
    func deleteReminder(withHardSave status: Bool = true) {
        guard let deletedReminder = self.reminder else { return }
        self.reminder = nil
        deletedReminder.deleteItSelf(withHardSave: status)
    }
    
    func deleteAllInvitees() {//Offline
        let allInvitees = self.readAllEventInvitees()
        self.removeFromInvitees(self.invitees ?? [])
        allInvitees.forEach({ self.managedObjectContext?.delete($0) })
    }
    
    func deleteAllInternalInvitees() {
        let deletedInvitees = self.readAllEventInvitees().filter({ return !$0.isOther })
        self.removeFromInvitees(NSSet(array: deletedInvitees))
        deletedInvitees.forEach({ self.managedObjectContext?.delete($0) })
    }
    
    func deleteAllExternalInvitees() {
        let deletedInvitees = self.readAllEventInvitees().filter({ return $0.isOther })
        self.removeFromInvitees(NSSet(array: deletedInvitees))
        deletedInvitees.forEach({ self.managedObjectContext?.delete($0) })
    }
    
    func deleteAllTags() {
        let allTags = self.readAllTags()
        self.removeFromTags(self.tags ?? [])
        allTags.forEach({ self.managedObjectContext?.delete($0) })
    }
    
    func deleteAllAttendees() {
        let allAttendees = self.readAllAttendees()
        self.removeFromAttendees(self.attendees ?? [])
        allAttendees.forEach({ self.managedObjectContext?.delete($0) })
    }
    
    func deleteAllAttachments() {
        let allAttachments = self.readAllAttachments()
        self.removeFromAttachments(self.attachments ?? [])
        allAttachments.forEach({ self.managedObjectContext?.delete($0) })
    }
    
    func deleteAllEventCalendars() {
        let allCalendars = self.readAllEventCalendars()
        self.removeFromCalendars(self.calendars ?? [])
        allCalendars.forEach({ self.managedObjectContext?.delete($0) })
    }
    
    func deleteAllEventNotifyCalendars() {
        let allCalendars = self.readAllEventNotifyCalendars()
        self.removeFromNotifyCalendars(self.notifyCalendars ?? [])
        allCalendars.forEach({ self.managedObjectContext?.delete($0) })
    }
    
    func deleteItSelf(with hardSave: Bool = true) {
        self.managedObjectContext?.delete(self)
        if hardSave { try? self.managedObjectContext?.save() }
    }
    
    func createStringForWebView() -> String {
        var htmlString = """
        <header><meta name='viewport' content='width=device-width, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, user-scalable=no'></header>
        """
        if self.bodyContentType == "html" {
            htmlString += "\(self.readValueOfEventDescription())"
        }
        if let html = self.htmlLink, !html.isEmpty  {
            htmlString += """
            <p style="color: #4485b8;"><span style="text-decoration: underline;"><span style="color: #808080; text-decoration: underline;">Html Link:</span></span></p>
            <ul>
            <li style="color: #4485b8;">
            """
            htmlString += "\(html)"
            htmlString += """
            </li>
            </ul>
            <p></p>
            """
        }
        return htmlString
    }
    
    func createInvitees() -> [[String: Any]] {
        guard let user =  Session.shared.readUser() else { return [] }
        var userIds = self.readAllInvitees().filter({ return !$0.readValueOfUserId().isEmpty }).map({ return ["userId": "\($0.userId)"] })
        userIds.append(["userId": user.readValueOfUserId()])
        let emails = self.readAllInvitees().filter({ return $0.readValueOfUserId().isEmpty && !$0.readValueOfEmail().isEmpty }).compactMap({ return ["email": $0.readValueOfEmail()] })
        let phones = self.readAllInvitees().filter({ return $0.readValueOfUserId().isEmpty  && !$0.readValueOfPhone().isEmpty}).compactMap({ return ["phone": $0.readValueOfPhone(), "countryCode": user.readValueOfCountryCode()] })
        return userIds + emails + phones
    }
    
    func createTags() -> [String] {
        return self.readAllTags().compactMap({ $0.tag })
    }
    
    func readConferenceData() -> String {
        var entryPointsDatas: String = Strings.empty
        if !self.readFullConferenceData().isEmpty {
            let conferenceData = self.readConferenceData(self.readFullConferenceData())
            if let entryPoints = conferenceData["entryPoints"] as? [[String: Any]] {
                entryPointsDatas += self.setConferenceData(conferenceType: .phone, entryPoints: entryPoints)
                entryPointsDatas += self.setConferenceData(conferenceType: .sip, entryPoints: entryPoints)
                entryPointsDatas += self.setConferenceData(conferenceType: .video, entryPoints: entryPoints)
            }
        }
        else if !self.readconferenceURL().isEmpty {
            entryPointsDatas += "\(self.readconferenceURL())\n\n\n"
        }
        return entryPointsDatas
    }
    
    private func readConferenceData(_ conferenceString: String) -> [String: Any] {
        let data = conferenceString.data(using: .utf8)!
        do {
            if let jsonArray = try JSONSerialization.jsonObject(with: data, options : .allowFragments) as? [String: Any] { return jsonArray }
            else { return [:] }
        } catch _ as NSError { return [:] }
    }
    
    private func setConferenceData(conferenceType: ConferenceType, entryPoints: [[String: Any]]) -> String {
        var conferenceData: String = Strings.empty
        if let phoneEntryPoint = entryPoints.filter({ data in
            if let type = data["entryPointType"] as? String, type == conferenceType.rawValue {
                return true
            }
            return false
        }).first {
            if let label = phoneEntryPoint["label"] as? String {
                conferenceData = label+"\n"
            }
            if conferenceType == .phone, let label = phoneEntryPoint["label"] as? String {
                conferenceData = label+"\n"
            }
            if conferenceType == .video, let label = phoneEntryPoint["uri"] as? String {
                conferenceData = label+"\n"
            }
            if let accessCode = phoneEntryPoint["accessCode"] as? String {
                conferenceData += "ID: "+accessCode+"\n"
            }
            if let passcode = phoneEntryPoint["passcode"] as? String {
                conferenceData += "Passcode: "+passcode+"\n"
            }
        }
        return conferenceData.isEmpty ? conferenceData : conferenceData+"\n\n"
    }
    
    func createTextForPrediction() -> String {
        var text: String = ""
        text += self.readValueOfEventName()
        text += self.readLocationString().isEmpty ? Strings.empty : ", "+self.readLocationString()
        text += (self.readValueOfEventDescription().isEmpty || self.readValueOfEventDescription().filter ({ !$0.isWhitespace }).isHtml()) ? Strings.empty : ", "+self.readValueOfEventDescription()
        return text
    }    
}
