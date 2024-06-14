//
//  LocalNotification.swift
//  MiPlanIt
//
//  Created by Arun on 23/04/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation
import CoreData
import UserNotifications

extension Session {
    
    func reRegisterUserLocationNotification() {
        if Session.shared.readUser()?.readNotificationPerformDate() != Date().initialHour() {
            self.registerUserLocationNotification()
        }
    }
    
    func registerUserLocationNotification() {
        Session.shared.readUser()?.saveNotificationPerformDate(Date().initialHour())
        UNUserNotificationCenter.current().getNotificationSettings { (notificationSettings) in
            DispatchQueue.main.async {
                if notificationSettings.authorizationStatus == .authorized {
                    self.registerUserRemainigEventsNotifications(Session.shared.readUserId(), with: [.new, .registered, .recurrent])
                    self.registerUserRemainingTaskNotifications(Session.shared.readUserId(), with: [.new, .registered, .recurrent])
                    self.registerUserRemainigShopingListItemNotifications(Session.shared.readUserId(), with: [.new, .registered, .recurrent])
                }
            }
        }
    }
    
    func registerUserEventLocationNotification() {
        UNUserNotificationCenter.current().getNotificationSettings { (notificationSettings) in
            DispatchQueue.main.async {
                if notificationSettings.authorizationStatus == .authorized {
                    self.registerUserRemainigEventsNotifications(Session.shared.readUserId(), with: [.new, .registered, .recurrent])
                }
            }
        }
    }
    
    func registerUserTodoLocationNotification() {
        UNUserNotificationCenter.current().getNotificationSettings { (notificationSettings) in
            DispatchQueue.main.async {
                if notificationSettings.authorizationStatus == .authorized {
                    self.registerUserRemainingTaskNotifications(Session.shared.readUserId(), with: [.new, .registered, .recurrent])
                }
            }
        }
    }
    
    func registerUserShopingListItemLocationNotification() {
        UNUserNotificationCenter.current().getNotificationSettings { (notificationSettings) in
            DispatchQueue.main.async {
                if notificationSettings.authorizationStatus == .authorized {
                    self.registerUserRemainigShopingListItemNotifications(Session.shared.readUserId(), with: [.new, .registered, .recurrent])
                }
            }
        }
    }
    
    private func registerUserRemainigEventsNotifications(_ user: String, with types: [LocalNotificationType]) {
        let databasePlantEvent = DatabasePlanItEvent()
        databasePlantEvent.readUser(user, allPendingRemindMeEventsUsingType: types, completionHandler: { events in
            let eventsId: [String] = events.map({ return LocalNotificationMethod.event.rawValue + $0.readValueOfNotificationId() })
            self.removeExistingLocalNotifications(eventsId) {
                databasePlantEvent.privateObjectContext.perform {
                    let monthlySortedLimitedEvents = events.flatMap({ return self.manipulateEventsToFindReminderDate($0) }).sorted(by: { return $0.reminderDate < $1.reminderDate }).prefix(30)
                    monthlySortedLimitedEvents.forEach({ self.manipulateUserEvent($0) })
                    databasePlantEvent.privateObjectContext.saveContext()
                }
            }
        })
    }
    
    private func manipulateEventsToFindReminderDate(_ event: PlanItEvent) -> [LocalNotificationEvent] {
        let minDate = Date().initialHour()
        let maxDate = Date().initialHour().addMonth(n: 1).adding(days: 1)
        var localNotificationEvents: [LocalNotificationEvent] = []
        let availableDates = event.readAllAvailableDates(from: minDate, to: maxDate)
        for date in availableDates where event.status == 0 {
            let exactStartTime = event.readStartDateTimeFromDate(date)
            guard let reminderDate = event.readReminderIntervalsFromStartDate(exactStartTime), reminderDate.compare(Date()) == .orderedDescending else {
                if !event.isRecurrence { event.remindMe = LocalNotificationType.expired.rawValue; continue }
                guard let recurrenceEndDate = event.readRecurrenceEndDate(), recurrenceEndDate.compare(Date()) == .orderedAscending else { continue }
                event.remindMe = LocalNotificationType.expired.rawValue; continue }
            localNotificationEvents.append(LocalNotificationEvent(withReminderDate: reminderDate, existingDate: date, actualDate: exactStartTime, event: event))
        }
        return localNotificationEvents
    }
    
    private func manipulateUserEvent(_ event: LocalNotificationEvent) {
        let calendar = Calendar(identifier: .gregorian)
        let triggerDate = calendar.dateComponents([.day, .month, .year, .hour, .minute, .second], from: event.reminderDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        let timeInString = event.availableDateTime.stringFromDate(format: DateFormatters.HMMAEEEMMMDDYYYY)
        let content = UNMutableNotificationContent()
        content.title = event.planItEvent.readValueOfEventName()
        content.body = event.planItEvent.readLocation().isEmpty ? "@ \(timeInString)" : "@\(timeInString)\n📌\(event.planItEvent.readLocation())"
        content.sound = UNNotificationSound.default
        content.userInfo = ["type": "Event", "id": event.planItEvent.eventId, "date": event.availableDate]
        event.planItEvent.notifiedDate = event.availableDateTime
        if !event.planItEvent.isRecurrence { event.planItEvent.remindMe = LocalNotificationType.registered.rawValue }
        else { event.planItEvent.remindMe = LocalNotificationType.recurrent.rawValue }
        let calendarId = event.planItEvent.readEventCalendar()?.calendarId.cleanValue() ?? Strings.empty
        let request = UNNotificationRequest(identifier: LocalNotificationMethod.event.rawValue + event.planItEvent.readValueOfNotificationId() + "-" + "\(event.availableDate.timeIntervalSince1970)-\(calendarId)", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: { error in
            if let error = error  {
                debugPrint(error)
            }
            else {
//                    debugPrint("Sheduled")
            }
        })
    }
    
    func registerUserRemainingTaskNotifications(_ user: String, with types: [LocalNotificationType]) {
        let dataBasePlanItTodo = DataBasePlanItTodo()
        dataBasePlanItTodo.readUser(user, allPendingRemindMeTodosUsingType: types, completionHandler: { todos in
            let todoIds: [String] = todos.map({ return LocalNotificationMethod.todo.rawValue + $0.readValueOfNotificationId() })
            self.removeExistingLocalNotifications(todoIds) {
                dataBasePlanItTodo.privateObjectContext.perform {
                    let monthlySortedLimitedTodos = todos.flatMap({ return self.manipulateTodosToFindReminderDate($0) }).sorted(by: { return $0.reminderDate < $1.reminderDate }).prefix(15)
                    monthlySortedLimitedTodos.forEach({ self.manipulateUserTodo($0) })
                    dataBasePlanItTodo.privateObjectContext.saveContext()
                }
            }
        })
    }
    
    private func manipulateTodosToFindReminderDate(_ todo: PlanItTodo) -> [LocalNotificationTodo] {
        guard !todo.readDeleteStatus(), !todo.completed else { todo.remindMe = LocalNotificationType.expired.rawValue; return [] }
        let minDate = Date().initialHour()
        let maxDate = Date().initialHour().addMonth(n: 1).adding(days: 1)
        var localNotificationTodos: [LocalNotificationTodo] = []
        let availableDates = todo.readAllAvailableDates(from: minDate, to: maxDate)
        for date in availableDates {
            guard let reminderDate = todo.readReminderIntervalsFromStartDate(date), reminderDate.compare(Date()) == .orderedDescending else {
                if !todo.isRecurrenceTodo() { todo.remindMe = LocalNotificationType.expired.rawValue; continue }
                guard let recurrenceEndDate = todo.readRecurrenceEndDate(), recurrenceEndDate.compare(Date()) == .orderedAscending else { continue }
                todo.remindMe = LocalNotificationType.expired.rawValue; continue }
            localNotificationTodos.append(LocalNotificationTodo(withReminderDate: reminderDate, existingDate: date, todo: todo))
        }
        return localNotificationTodos
    }

    private func manipulateUserTodo(_ todo: LocalNotificationTodo) {
        let calendar = Calendar(identifier: .gregorian)
        let triggerDate = calendar.dateComponents([.day, .month, .year, .hour, .minute, .second], from: todo.reminderDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        let timeInString = todo.availableDate.stringFromDate(format: DateFormatters.EEEMMMDDYYYY)
        let content = UNMutableNotificationContent()
        content.title = todo.planItTodo.readToDoTitle()
        content.body = "Due on \(timeInString)"
        content.sound = UNNotificationSound.default
        content.userInfo = ["type": "Todo", "id": todo.planItTodo.todoId]
        todo.planItTodo.notifiedDate = todo.availableDate
        if !todo.planItTodo.isRecurrenceTodo() { todo.planItTodo.remindMe = LocalNotificationType.registered.rawValue }
        else { todo.planItTodo.remindMe = LocalNotificationType.recurrent.rawValue }
        let request = UNNotificationRequest(identifier: LocalNotificationMethod.todo.rawValue + todo.planItTodo.readValueOfNotificationId() + "-" + "\(todo.availableDate.timeIntervalSince1970)", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: { error in
            if let error = error  {
                debugPrint(error)
            }
            else {
//                    debugPrint("Sheduled")
            }
        })
    }
    
    private func registerUserRemainigShopingListItemNotifications(_ user: String, with types: [LocalNotificationType]) {
        let databasePlantShopingListItem = DatabasePlanItShopListItem()
        databasePlantShopingListItem.readUser(user, allPendingRemindMeShopingListItemsUsingType: types, completionHandler: { shopingListItems in
            let shopingListItemIds: [String] = shopingListItems.map({ return LocalNotificationMethod.shopping.rawValue + $0.readValueOfNotificationId() })
            self.removeExistingLocalNotifications(shopingListItemIds) {
                databasePlantShopingListItem.privateObjectContext.perform {
                    let monthlySortedLimitedShopListItems = shopingListItems.flatMap({ return self.manipulateShopListItemToFindReminderDate($0) }).sorted(by: { return $0.reminderDate < $1.reminderDate }).prefix(15)
                    monthlySortedLimitedShopListItems.forEach({ self.manipulateUserShopingListItem($0, using: databasePlantShopingListItem.privateObjectContext) })
                    databasePlantShopingListItem.privateObjectContext.saveContext()
                }
            }
        })
    }
    
    private func manipulateShopListItemToFindReminderDate(_ shopingListItem: PlanItShopListItems) -> [LocalNotificationShopListItem] {
        guard !shopingListItem.readDeleteStatus(), !shopingListItem.isCompletedLocal else { shopingListItem.remindMe = LocalNotificationType.expired.rawValue; return [] }
        let minDate = Date().initialHour()
        let maxDate = Date().initialHour().addMonth(n: 1).adding(days: 1)
        var localNotificationShopListItems: [LocalNotificationShopListItem] = []
        let availableDates = shopingListItem.readAllAvailableDates(from: minDate, to: maxDate)
        for date in availableDates {
            guard let reminderDate = shopingListItem.readReminderIntervalsFromStartDate(date), reminderDate.compare(Date()) == .orderedDescending else {
                shopingListItem.remindMe = LocalNotificationType.expired.rawValue; continue }
            localNotificationShopListItems.append(LocalNotificationShopListItem(withReminderDate: reminderDate, existingDate: date, shopListItem: shopingListItem))
        }
        return localNotificationShopListItems
    }
    
    private func manipulateUserShopingListItem(_ shopingListItem: LocalNotificationShopListItem, using context: NSManagedObjectContext) {
        let calendar = Calendar(identifier: .gregorian)
        let triggerDate = calendar.dateComponents([.day, .month, .year, .hour, .minute, .second], from: shopingListItem.reminderDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        let timeInString = shopingListItem.availableDate.stringFromDate(format: DateFormatters.EEEMMMDDYYYY)
        let content = UNMutableNotificationContent()
        content.title = (shopingListItem.planItShopListItem.isShopCustomItem ? DatabasePlanItShopItems().readSpecificUserShopItem([shopingListItem.planItShopListItem.shopItemId], using: context).first?.readItemName() : DatabasePlanItShopItems().readSpecificMasterShopItem([shopingListItem.planItShopListItem.shopItemId], using: context).first?.readItemName()) ?? Strings.empty
        content.body = "Due on \(timeInString)"
        content.sound = UNNotificationSound.default
        content.userInfo = ["type": "ShopingListItem", "id": shopingListItem.planItShopListItem.shopListItemId]
        shopingListItem.planItShopListItem.notifiedDate = shopingListItem.availableDate
        shopingListItem.planItShopListItem.remindMe = LocalNotificationType.registered.rawValue
        let request = UNNotificationRequest(identifier: LocalNotificationMethod.shopping.rawValue + shopingListItem.planItShopListItem.readValueOfNotificationId() + "-" + "\(shopingListItem.availableDate.timeIntervalSince1970)", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: { error in
            if let error = error  {
                debugPrint(error)
            }
            else {
//                    debugPrint("Sheduled")
            }
        })
    }
    
    func removeNotification(_ identifier: String) {
        self.removeExistingLocalNotifications([identifier])
    }
    
    func removeShoppingNotifications(_ identifiers: [String]) {
        self.removeExistingLocalNotifications(identifiers)
    }
    
    func removeEventNotifications(_ identifiers: [Double]) {
        let eventIds = identifiers.map({ return LocalNotificationMethod.event.rawValue + $0.cleanValue() })
        self.removeExistingLocalNotifications(eventIds)
    }
    
    func removeCalendarNotification(_ calendar: String) {
        self.removeExistingCalendarLocalNotifications([calendar])
    }
    
    func removeCalendarNotifications(_ calendars: [Double]) {
        let calendarIds = calendars.map({ return $0.cleanValue() })
        self.removeExistingCalendarLocalNotifications(calendarIds)
    }
    
    //MARK: Remove Using Calendar
    private func removeExistingCalendarLocalNotifications(_ identifiers: [String], completion: (() -> ())? = nil) {
        self.removeExistingCalendarDeliveredNotifications(identifiers) {
            self.removeExistingCalendarPendingNotifications(identifiers) {
                completion?()
            }
        }
    }
    
    func removeExistingCalendarDeliveredNotifications(_ identifiers: [String], completion: @escaping (() -> ())) {
        UNUserNotificationCenter.current().getDeliveredNotifications(completionHandler: { notifications in
            for notification in notifications {
                if identifiers.contains(where: notification.request.identifier.hasSuffix) {
                    UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [notification.request.identifier])
                }
            }
            completion()
        })
    }
    
    func removeExistingCalendarPendingNotifications(_ identifiers: [String], completion: @escaping (() -> ())) {
        UNUserNotificationCenter.current().getPendingNotificationRequests(completionHandler: { notifications in
            for notification in notifications {
                if identifiers.contains(where: notification.identifier.hasSuffix) {
                    UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [notification.identifier])
                }
            }
            completion()
        })
    }
        
    //MARK: Remove Using Id
    private func removeExistingLocalNotifications(_ identifiers: [String], completion: (() -> ())? = nil) {
        self.removeExistingDeliveredNotifications(identifiers) {
            self.removeExistingPendingNotifications(identifiers) {
                completion?()
            }
        }
    }
    
    func removeExistingDeliveredNotifications(_ identifiers: [String], completion: @escaping (() -> ())) {
        UNUserNotificationCenter.current().getDeliveredNotifications(completionHandler: { notifications in
            for notification in notifications {
                if identifiers.contains(where: notification.request.identifier.hasPrefix) {
                    UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [notification.request.identifier])
                }
            }
            completion()
        })
    }
    
    func removeExistingPendingNotifications(_ identifiers: [String], completion: @escaping (() -> ())) {
        UNUserNotificationCenter.current().getPendingNotificationRequests(completionHandler: { notifications in
            for notification in notifications {
                if identifiers.contains(where: notification.identifier.hasPrefix) {
                    UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [notification.identifier])
                }
            }
            completion()
        })
    }
    
    //MARK: - De-Register
    func deregisterUserLocalNotification(completionHandler: @escaping () -> ()) {
        self.deregisterUserEvents(Session.shared.readUserId())
        self.deregisterUserTasks(Session.shared.readUserId())
        self.deregisterUserShopingListItems(Session.shared.readUserId())
        completionHandler()
    }
    
    func deregisterUserEvents(_ user: String) {
        let databasePlantEvent = DatabasePlanItEvent()
        databasePlantEvent.readUser(user, allPendingRemindMeEventsUsingType: [.registered, .recurrent], completionHandler: { events in
            let eventsId = events.map({ return LocalNotificationMethod.event.rawValue + $0.readValueOfNotificationId() })
            self.removeExistingLocalNotifications(eventsId)
            events.forEach({ $0.notifiedDate = nil; $0.remindMe = LocalNotificationType.new.rawValue })
            databasePlantEvent.privateObjectContext.saveContext()
        })
    }
    
    func deregisterUserTasks(_ user: String) {
        let dataBasePlanItTodo = DataBasePlanItTodo()
        dataBasePlanItTodo.readUser(user, allPendingRemindMeTodosUsingType: [.registered, .recurrent], completionHandler: { todos in
            let todoIds = todos.map({ return LocalNotificationMethod.todo.rawValue + $0.readValueOfNotificationId() })
            self.removeExistingLocalNotifications(todoIds)
            todos.forEach({ $0.notifiedDate = nil; $0.remindMe = LocalNotificationType.new.rawValue })
            dataBasePlanItTodo.privateObjectContext.saveContext()
        })
    }
    
    func deregisterUserShopingListItems(_ user: String) {
        let databasePlanItShopListItem = DatabasePlanItShopListItem()
        databasePlanItShopListItem.readUser(user, allPendingRemindMeShopingListItemsUsingType: [.registered, .recurrent], completionHandler: { shopingListItems in
            let shopingListItemIds = shopingListItems.map({ return LocalNotificationMethod.shopping.rawValue + $0.readValueOfNotificationId() })
            self.removeExistingLocalNotifications(shopingListItemIds)
            shopingListItems.forEach({ $0.notifiedDate = nil; $0.remindMe = LocalNotificationType.new.rawValue })
            databasePlanItShopListItem.privateObjectContext.saveContext()
        })
    }
 
    //MARK: Private
    func registerLocalNotificationWithStatus(completionHandler: @escaping (_ authorizationStatus: UNAuthorizationStatus) -> ()) {
        UNUserNotificationCenter.current().getNotificationSettings { (notificationSettings) in
            if notificationSettings.authorizationStatus == .notDetermined {
                self.requestAuthorization(completionHandler: { (success) in
                    DispatchQueue.main.async {
                        completionHandler(success ? .authorized : .notDetermined)
                    }
                })
            }
            else {
                DispatchQueue.main.async {
                    completionHandler(notificationSettings.authorizationStatus)
                }
            }
        }
    }
    
    private func requestAuthorization(completionHandler: @escaping (_ success: Bool) -> ()) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (success, error) in
            if let error = error {
                print("Request Authorization Failed (\(error), \(error.localizedDescription))")
            }
            completionHandler(success)
        }
    }
}
