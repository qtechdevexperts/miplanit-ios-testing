//
//  DatabasePlanItData.swift
//  MiPlanIt
//
//  Created by Arun on 08/04/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

class DatabasePlanItData: DataBaseManager {
    
    func insertPlanItUserDataForCalendar(_ data: [String: Any], callback: @escaping (String, [ServiceDetection]) -> ()) {
        self.privateObjectContext.perform {
            var serviceDetection: [ServiceDetection] = []
            if let calendars = data["calendars"] as? [[String: Any]], !calendars.isEmpty {
                let calendarIds = calendars.compactMap({ return $0["calendarId"] as? Double })
                serviceDetection.append(.newCalendar(calendars: calendarIds))
                DatabasePlanItCalendar().insertPlanItCalendars(calendars, using: self.privateObjectContext)
                self.privateObjectContext.saveContext()
            }
            Session.shared.saveUsersCalendarOnlyDataFetching(false)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: Notifications.usersCalendarOnlyDataFetched), object: false)
            if let removedCalendarIds = data["removedCalendarIds"] as? [Double], !removedCalendarIds.isEmpty {
                Session.shared.removeCalendarNotifications(removedCalendarIds)
                serviceDetection.append(.calendarDeleted(calendars: removedCalendarIds))
                DatabasePlanItCalendar().removePlanItCalendars(removedCalendarIds, using: self.privateObjectContext)
                DatabasePlanItEvent().removedPlantItEventsFromCalendar(removedCalendarIds, using: self.privateObjectContext)
            }
            if let events = data["events"] as? [[String: Any]], !events.isEmpty {
                var eventIds = events.compactMap({ return $0["eventId"] as? Double })
                let childs = events.flatMap({ return ($0["child"] as? [[String: Any]] ?? [])})
                childs.forEach({ if let childId = $0["eventId"] as? Double { eventIds.append(childId) }; if let parentId = $0["movedPrEventId"] as? Double, parentId != 0 { eventIds.append(parentId) } })
                serviceDetection.append(.newEvent(events: eventIds))
                DatabasePlanItEvent().insertPlanItEvents(events, using: self.privateObjectContext)
            }
            if let removedEvents = data["removedEvents"] as? [Double], !removedEvents.isEmpty {
                Session.shared.removeEventNotifications(removedEvents)
                serviceDetection.append(.eventDeleted(events: removedEvents))
                DatabasePlanItEvent().removedPlantItEvents(removedEvents, using: self.privateObjectContext)
            }
            self.privateObjectContext.saveContext()
            DispatchQueue.main.async {
                if serviceDetection.isContainedSpecificServiceData(.calendar) {
                    Session.shared.loadFastestCalendars()
                    Session.shared.loadFastestEvents()
                    Session.shared.registerUserEventLocationNotification()
                }
                callback(data["lastSyncDate"] as? String ?? Strings.empty, serviceDetection)
            }
        }
    }
    
    func insertPlanItUserDataForShareLink(_ data: [String: Any], callback: @escaping (String, [ServiceDetection]) -> ()) {
        self.privateObjectContext.perform {
            var serviceDetection: [ServiceDetection] = []
            if let newEventShareLinkList = data["userBookings"] as? [[String: Any]], !newEventShareLinkList.isEmpty {
                serviceDetection.append(.eventShareLink)
                DatabasePlanItShareLink().insertPlanItShareLinks(newEventShareLinkList, using: self.privateObjectContext)
            }
            if let deletedShareLinkLists = data["DeletedBookingIDs"] as? [Double], !deletedShareLinkLists.isEmpty {
                serviceDetection.append(.eventShareLinkDeleted)
                DatabasePlanItShareLink().removedPlantItEventShareLink(deletedShareLinkLists, using: self.privateObjectContext)
            }
            self.privateObjectContext.saveContext()
            DispatchQueue.main.async {
                callback(data["lastSyncDate"] as? String ?? Strings.empty, serviceDetection)
            }
        }
    }
    
    func insertPlanItUserDataForTodo(_ data: [String: Any], callback: @escaping (String, [ServiceDetection]) -> ()) {
        self.privateObjectContext.perform {
            var serviceDetection: [ServiceDetection] = []
            if let newToDoList = data["toDoList"] as? [[String: Any]], !newToDoList.isEmpty {
                serviceDetection.append(.todo)
                DataBasePlanItTodoCategory().insertPlanItToDoCategory(newToDoList, using: self.privateObjectContext)
            }
            
            if let deletedToDoLists = data["deletedToDoLists"] as? [Double], !deletedToDoLists.isEmpty {
                serviceDetection.append(.todoDeleted)
                DataBasePlanItTodoCategory().removedPlantItCategories(deletedToDoLists, using: self.privateObjectContext)
            }
            
            self.privateObjectContext.saveContext()
            DispatchQueue.main.async {
                if serviceDetection.isContainedSpecificServiceData(.todo) {
                    Session.shared.registerUserTodoLocationNotification()
                }
                callback(data["lastSyncDate"] as? String ?? Strings.empty, serviceDetection)
            }
        }
    }
    
    func insertPlanItUserDataForPurchase(_ data: [String: Any], callback: @escaping (String, [ServiceDetection]) -> ()) {
        self.privateObjectContext.perform {
            var serviceDetection: [ServiceDetection] = []
            
            if let purchases = data["userPurchase"] as? [[String: Any]], !purchases.isEmpty {
                serviceDetection.append(.newPurchase)
                DatabasePlanItPurchase().insertOrUpdatePurchase(purchases, using: self.privateObjectContext)
            }
            
            if let removedPurchses = data["removedPurchases"] as? [Double], !removedPurchses.isEmpty {
                serviceDetection.append(.purchaseDeleted)
                DatabasePlanItPurchase().removePlanItPurchases(removedPurchses, using: self.privateObjectContext)
            }
            self.privateObjectContext.saveContext()
            DispatchQueue.main.async {
                callback(data["lastSyncDate"] as? String ?? Strings.empty, serviceDetection)
            }
        }
    }
    
    func insertPlanItUserDataForGift(_ data: [String: Any], callback: @escaping (String, [ServiceDetection]) -> ()) {
        self.privateObjectContext.perform {
            var serviceDetection: [ServiceDetection] = []
            
            if let giftCoupons = data["userGiftCoupon"] as? [[String: Any]], !giftCoupons.isEmpty {
                serviceDetection.append(.newGiftCoupon)
                DatabasePlanItGiftCoupon().insertOrUpdateGiftCoupon(giftCoupons, using: self.privateObjectContext)
            }
            
            if let removedGiftCoupons = data["removedGiftCoupons"] as? [Double], !removedGiftCoupons.isEmpty {
                serviceDetection.append(.giftCouponDeleted)
                DatabasePlanItGiftCoupon().removePlanItGiftCoupons(removedGiftCoupons, using: self.privateObjectContext)
            }
            
            self.privateObjectContext.saveContext()
            DispatchQueue.main.async {
                callback(data["lastSyncDate"] as? String ?? Strings.empty, serviceDetection)
            }
        }
    }
    
    func insertPlanItUserDataForEventNotification(_ data: String, callback: @escaping ([ServiceDetection]) -> ()) {
        self.privateObjectContext.perform {
            var serviceDetection: [ServiceDetection] = []
            if let gzipBytes = Data(base64Encoded: data), gzipBytes.isGzipped, let decompressedData = try? gzipBytes.gunzipped(), let eventData = try? JSONSerialization.jsonObject(with: decompressedData, options: []) as? [String: Any] {
                if let events = eventData["events"] as? [[String: Any]], !events.isEmpty {
                    var eventIds: [Double] = []
                    events.forEach({ if let eventId = $0["eventId"] as? Double { eventIds.append(eventId) }; if let parentId = $0["movedPrEventId"] as? Double, parentId != 0 { eventIds.append(parentId) } })
                    serviceDetection.append(.newEvent(events: eventIds))
                    DatabasePlanItEvent().insertPlanItEventsFromNotification(events, using: self.privateObjectContext)
                    Session.shared.hiddenEventFlagFromNotification = true
                }
                if let removedEvents = eventData["removedEvents"] as? [Double], !removedEvents.isEmpty {
                    Session.shared.removeEventNotifications(removedEvents)
                    serviceDetection.append(.eventDeleted(events: removedEvents))
                    DatabasePlanItEvent().removedPlantItEvents(removedEvents, using: self.privateObjectContext)
                }
            }
            self.privateObjectContext.saveContext()
            DispatchQueue.main.async {
                if serviceDetection.isContainedSpecificServiceData(.calendar) {
                    Session.shared.loadFastestEvents()
                    Session.shared.registerUserEventLocationNotification()
                }
                callback(serviceDetection)
            }
        }
    }
    
    func readAllMiPlanItMembers(completionHandler: @escaping ([CalendarUser]) -> ()) {
        self.privateObjectContext.perform {
            var users: [CalendarUser] = []
            var addedUsers: [String] = [Session.shared.readUserId()]
            
            let contactUsers: [CalendarUser] = DatabasePlanItContacts().readAllUsersContact(using: self.privateObjectContext).compactMap({ user in
            if addedUsers.contains(user.readUserId()) || user.readUserId().isEmpty { return nil }
            else { addedUsers.append(user.readUserId()); return CalendarUser(user)  } })
            users.append(contentsOf: contactUsers)
            
            let creatorUsers: [CalendarUser] = DatabasePlanItCreator().readAllUserCreator(using: self.privateObjectContext).compactMap({ user in
                if addedUsers.contains(user.readValueOfUserId()) || user.readValueOfUserId().isEmpty { return nil }
                else { addedUsers.append(user.readValueOfUserId()); return CalendarUser(user, conversionNeeded: false)  } })
            users.append(contentsOf: creatorUsers)
            
            let modifierUsers: [CalendarUser] = DatabasePlanItModifier().readAllUserModifier(using: self.privateObjectContext).compactMap({ user in
                if addedUsers.contains(user.readValueOfUserId()) || user.readValueOfUserId().isEmpty { return nil }
                else { addedUsers.append(user.readValueOfUserId()); return CalendarUser(user, conversionNeeded: false)  } })
            users.append(contentsOf: modifierUsers)
            
            let inviteesUsers: [CalendarUser] = DatabasePlanItInvitees().readAllUserInvitees(using: self.privateObjectContext).compactMap({ user in
                if addedUsers.contains(user.readValueOfUserId()) || user.readValueOfUserId().isEmpty { return nil }
                else { addedUsers.append(user.readValueOfUserId()); return CalendarUser(user, conversionNeeded: false)  } })
            users.append(contentsOf: inviteesUsers)
            
            completionHandler(users)
        }
    }
}
