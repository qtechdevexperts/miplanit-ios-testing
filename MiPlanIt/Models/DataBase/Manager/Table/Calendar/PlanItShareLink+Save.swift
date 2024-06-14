//
//  PlanItShareLink+Save.swift
//  MiPlanIt
//
//  Created by Febin Paul on 27/03/21.
//  Copyright © 2021 Arun. All rights reserved.
//

import Foundation


extension PlanItShareLink {
    
    func readEventAppShareLinkId() -> String { return self.appShareLinkId ?? Strings.empty }
    func readEventShareLinkId() -> Double { return self.shareLinkId }
    func readEventName() -> String { return self.eventName ?? Strings.empty }
    func readWarning() -> String { return self.warningMessage ?? Strings.empty }
    func weekEndExcluded() -> Bool { return !(self.excludedWeekDays ?? Strings.empty).isEmpty }
    func readLocation() -> String { return self.location ?? Strings.empty }
    func readDescription() -> String { return self.eventDescription ?? Strings.empty }
    func readStartDateTimeTimeSlot() -> Date { return self.startDateTime ?? Date() }
    func readEndDateTimeTimeSlot() -> Date { return self.endDateTime ?? Date() }
    func readInviteeEmail() -> String { return self.readAllShareLinkInvitees().first?.readValueOfEmail() ?? Strings.empty }
    func readFirstReminder() -> PlanItReminder? {
        if let reminders = self.reminder, let localReminders = Array(reminders) as? [PlanItReminder] {
            return localReminders.first
        }
        return nil
    }
    func readCreatedDate() -> String {
        var createdDate = Strings.empty
        if let date = self.createdAt?.stringFromDate(format: DateFormatters.EEEEMMMDDYYYY) {
            createdDate = "Created on: \(date)"
        }
        return createdDate
    }
    func readStatus() -> String {
        if let expired = self.isEpired() {
            return expired ? "Expired" : "Active"
        }
        return "InActive"
    }
    func isInActive() -> Bool {
        return self.linkExpiry == nil
    }
    func isEpired() -> Bool? {
        if let linkExpiry = self.linkExpiry {
            return linkExpiry <  Date() || self.isLinkShared()
        }
        return nil
    }
    func isLinkShared() -> Bool {
        return self.readAllShareLinkInvitees().contains(where: { return $0.sharedStatus == 1 })
    }
    
    func readPlaceLatLong() -> (Double, Double)? {
        let locatinData = self.readLocation().split(separator: Strings.locationSeperator)
        if locatinData.count > 2, let latitude = Double(locatinData[1]), let longitude = Double(locatinData[2]) {
            return (latitude, longitude)
        }
        return nil
    }
    
    
    func deleteAllInvitees() {
        let deletedInvitees = self.readAllShareLinkInvitees()
        self.removeFromInvitees(NSSet(array: deletedInvitees))
        deletedInvitees.forEach({ self.managedObjectContext?.delete($0) })
    }
    
    func readAllShareLinkInvitees() -> [PlanItInvitees] {
        if let bInvitees = self.invitees, let localInvitees = Array(bInvitees) as? [PlanItInvitees] {
            return localInvitees
        }
        return []
    }
    
    func deleteAllTags() {
        let allTags = self.readTags()
        self.removeFromTags(self.tags ?? [])
        allTags.forEach({ self.managedObjectContext?.delete($0) })
    }
    
    func deleteAllCalendars() {
        let allCalendars = self.readAllCalendars()
        self.removeFromCalendars(self.calendars ?? [])
        allCalendars.forEach({ self.managedObjectContext?.delete($0) })
    }
    
    func readAllAvailableCalendars(includingParent parent: Bool = false) -> [PlanItCalendar] {
        let selectedCalendars = self.readAllCalendars().map({ return $0.calendarId })
        let selectedAppCalendars = self.readAllCalendars().compactMap({ return $0.appCalendarId })
        return DatabasePlanItCalendar().readCalendersUsingId(selectedCalendars, appCalendarIds: selectedAppCalendars, includingParent: parent)
    }
    
    func readAllCalendars()  -> [PlanItEventShareLinkCalendar] {
        if let calendars = self.calendars, let allCalendars = Array(calendars) as? [PlanItEventShareLinkCalendar] {
            return allCalendars
        }
        return []
    }
    
    func deleteAllReminder() {
        let allReminders = self.readAllReminders()
        self.removeFromReminder(self.reminder ?? [])
        allReminders.forEach({ self.managedObjectContext?.delete($0) })
    }
    
    func readTags() -> [PlanItTags] {
        if let tags = self.tags, let shopTags = Array(tags) as? [PlanItTags] {
            return shopTags
        }
        return []
    }
    
    func readAllReminders() -> [PlanItReminder] {
        if let remind = self.reminder, let reminders = Array(remind) as? [PlanItReminder] {
            return reminders
        }
        return []
    }
    
    func deleteOffline() {
        let context = self.managedObjectContext
        if self.shareLinkId != 0 {
            self.isPending = true
            self.deleteStatus = true
        }
        else {
            context?.delete(self)
        }
        try? context?.save()
    }
    
    func updateShareLinkWithWarning(_ warningMsg: String) {
        self.warningMessage = warningMsg
        try? self.managedObjectContext?.save()
    }
}
