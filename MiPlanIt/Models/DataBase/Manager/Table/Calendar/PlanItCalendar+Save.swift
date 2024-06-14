//
//  PlanItCalendar+Save.swift
//  MiPlanIt
//
//  Created by Arun on 08/04/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation
import PINRemoteImage

extension PlanItCalendar {
    
    func readValueOfCalendarId() -> String { return self.calendarId == 0 ? Strings.empty : self.calendarId.cleanValue() }
    func readValueOfAppCalendarId() -> String { return self.appCalendarId ?? Strings.empty }
    func readValueOfSocialCalendarId() -> String { return self.socialCalendarId ?? Strings.empty }
    func readValueOfParentCalendarId() -> String { return self.parentCalendarId.cleanValue() }
    func readValueOfCalendarType() -> String { return self.calendarType.cleanValue() }
    func readValueOfCalendarTypeLabel() -> String { return self.calendarTypeLabel ?? Strings.empty }
    func isSocialCalendar() -> Bool { return self.calendarType != 0 }
    func readValueOfColorCode() -> String { return self.calendarColorCode ?? Strings.empty }
    func readValueOfCalendarImage() -> String { return self.calendarImage ?? Strings.empty }
    func readValueOfCalendarImageData() -> Data? { return self.calendarImageData }
    func readValueOfSocialAccountEmail() -> String { return (self.socialAccountEmail ?? Strings.empty).isEmpty ? (self.socialAccountName ?? Strings.empty) : self.socialAccountEmail ?? Strings.empty }
    func readValueOfSocialAccountName() -> String { return self.socialAccountName ?? Strings.empty }
    
    func isOwnersCalendar() -> Bool {
        return self.createdBy?.readValueOfUserId() == Session.shared.readUserId()
    }
    
    func readOwnerUserId() -> String {
        self.createdBy?.readValueOfUserId() ?? Strings.empty
    }
    
    func readValueOfOrginalCalendarName() -> String {
        return self.calendarName ?? Strings.empty
    }
    
    func readValueOfCalendarName() -> String {
        var name = (Session.shared.readUser()?.readValueOfName() ?? Strings.empty)
        name = !name.isEmpty ? (name + "'s") : name
        return self.parentCalendarId == 0.0 ? (name + " " + (self.calendarName ?? Strings.empty)) : self.calendarName ?? Strings.empty
    }
    
    func readAllUserCalendarInvitees() -> [PlanItInvitees] {
        if let bInvitees = self.invitees, let localInvitees = Array(bInvitees) as? [PlanItInvitees] {
            return localInvitees
        }
        return []
    }
    
    func readAllCalendarSharedUser() -> [PlanItInvitees] {
        if let bInvitees = self.sharedUser, let localInvitees = Array(bInvitees) as? [PlanItInvitees] {
            return localInvitees
        }
        return []
    }
    
    func readAllCalendarInvitees() -> [PlanItInvitees] {
        let calendars = self.readAllUserCalendarInvitees()
        return !self.isOwnersCalendar() ? calendars : calendars.filter({ return $0.readValueOfUserId() != Session.shared.readUserId() && !$0.isNotifyCalendar})
    }
    
    func readAllNotifyCalendarInvitees() -> [PlanItInvitees] {
        return self.readAllUserCalendarInvitees().filter({ return $0.readValueOfUserId() != Session.shared.readUserId() && $0.isNotifyCalendar })
    }
    
    func readAllAcceptedInvitees() -> [PlanItInvitees] {
        return self.readAllUserCalendarInvitees().filter({ return $0.sharedStatus == 1 && $0.readValueOfUserId() != Session.shared.readUserId() && !$0.isNotifyCalendar })
    }
    
    func deleteAllExternalInvitees() {
        let deletedInvitees = self.readAllUserCalendarInvitees().filter({ return $0.isOther })
        self.removeFromInvitees(NSSet(array: deletedInvitees))
        deletedInvitees.forEach({ self.managedObjectContext?.delete($0) })
    }
    
    func deleteAllInvitees() {
        let allInvitees = self.readAllUserCalendarInvitees().filter({ return !$0.isOther })
        self.removeFromInvitees(self.invitees ?? [])
        allInvitees.forEach({ self.managedObjectContext?.delete($0) })
    }
    
    func deleteAllExternalSharedUser() {
        let deletedInvitees = self.readAllCalendarSharedUser().filter({ return $0.isOther })
        self.removeFromInvitees(NSSet(array: deletedInvitees))
        deletedInvitees.forEach({ self.managedObjectContext?.delete($0) })
    }
    
    func deleteAllSharedUser() {
        let allSharedUser = self.readAllCalendarSharedUser()
        self.removeFromSharedUser(self.sharedUser ?? [])
        allSharedUser.forEach({ self.managedObjectContext?.delete($0) })
    }
    
    func deleteItSelf() {
        let context = self.managedObjectContext
        context?.delete(self)
        try? context?.save()
    }
    
    func isNotifyCalendar() -> Bool {
        return !self.readAllAcceptedInvitees().filter({ $0.readValueOfUserId() == Session.shared.readUser()?.readValueOfUserId() }).filter({ $0.isNotifyCalendar }).isEmpty
    }
    
    func saveCalendarImage(_ image: String) {
        self.calendarImage = image
        self.calendarImageData = nil
        if let profileURL = URL(string:image) {
            let orginal = PINRemoteImageManager.shared().cacheKey(for: profileURL, processorKey: nil)
            PINRemoteImageManager.shared().cache.removeObject(forKey: orginal)
            let rounded = PINRemoteImageManager.shared().cacheKey(for: profileURL, processorKey: "rounded")
            PINRemoteImageManager.shared().cache.removeObject(forKey: rounded)
        }
        try? self.managedObjectContext?.save()
    }
    
    func readModifiedDate() -> Date? {
        guard let modifiedDate = self.modifiedAt?.stringToDate(formatter: DateFormatters.MMDDYYYYHMMSSA, timeZone: TimeZone(abbreviation: "UTC")!) else {
            return nil
        }
        return modifiedDate
    }
    
    func readCalendarImage(isFromEventDetailView:Bool = false) -> (URL?, UIImage?)? {
        var savedimage: UIImage? = UIImage(named: Strings.defaultCalendaricon)
        if let image = self.readValueOfCalendarImageData(), let orginalImage = UIImage(data: image) {
            savedimage = orginalImage
        }
        switch self.readValueOfCalendarType() {
        case "1":
            if let image = self.readValueOfCalendarImageData(), let orginalImage = UIImage(data: image) {
                return (nil, orginalImage)
            }
            else if !self.readValueOfCalendarImage().isEmpty {
                return (URL(string: self.readValueOfCalendarImage()), savedimage)
            }
            else {
                return (nil, #imageLiteral(resourceName: "googleIcon"))
            }
        case "2":
            if let image = self.readValueOfCalendarImageData(), let orginalImage = UIImage(data: image) {
                return (nil, orginalImage)
            }
            else if  !self.readValueOfCalendarImage().isEmpty {
                return (URL(string: self.readValueOfCalendarImage()), savedimage)
            }
            else {
                return (nil, #imageLiteral(resourceName: "outlookIcon"))
            }
        case "3":
            if let image = self.readValueOfCalendarImageData(), let orginalImage = UIImage(data: image) {
                return (nil, orginalImage)
            }
            else if !self.readValueOfCalendarImage().isEmpty {
                return (URL(string: self.readValueOfCalendarImage()), savedimage)
            }
            else {
                if isFromEventDetailView{
                    return (nil, #imageLiteral(resourceName: "appleIcon"))
                }
                return (nil, #imageLiteral(resourceName: "appleIcon"))
            }
        default:
            if let image = self.readValueOfCalendarImageData(), let orginalImage = UIImage(data: image) {
                return (nil, orginalImage)
            }
            else if !self.readValueOfCalendarImage().isEmpty {
                let placeholderImage = self.parentCalendarId == 0 ? self.createdBy?.readValueOfFullName().shortStringImage() : savedimage
                return (URL(string: self.readValueOfCalendarImage()), placeholderImage)
            }
            else {
                let placeholderImage = self.parentCalendarId == 0 ? self.createdBy?.readValueOfFullName().shortStringImage() : savedimage
                return (URL(string: self.createdBy?.readValueOfProfileImage() ?? Strings.empty), placeholderImage)
            }
        }
    }

    func saveCalendarDeleteStatus(_ status: Bool) {
        self.deleteStatus = status
        try? self.managedObjectContext?.save()
    }
}
