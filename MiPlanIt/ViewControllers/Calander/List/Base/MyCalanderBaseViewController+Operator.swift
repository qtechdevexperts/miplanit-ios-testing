//
//  MyCalanderBaseViewController+Operator.swift
//  MiPlanIt
//
//  Created by Arun on 01/09/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

extension MyCalanderBaseViewController {
    
    func manageUsersEventIntialValues() {
        self.isForwardOtherSynchronisationStarted = true
        self.allEvents.removeAll(where: { return !$0.isOwnersEvent })
        self.viewCalendarList.isHidden = self.segmentedControl.selectedSegmentIndex == 2
        self.labelOtherUsersCount.isHidden = true
        Session.shared.saveOthersCalendarAccessed(false)
    }
    
    func manageOthersEventIntialValues() {
        self.isForwardOtherSynchronisationStarted = false
        self.allEvents.removeAll(where: { return !$0.isOwnersEvent })
        self.collectedOthersMaxMonth = Date().startOfMonth
        self.viewCalendarList.isHidden = self.segmentedControl.selectedSegmentIndex == 2
        self.labelOtherUsersCount.text = "+\(self.otherUsers.count)"
        self.labelOtherUsersCount.isHidden = false
        self.viewCalendarList.reloadCalendarListWith(self.otherUsers, enableEventColor: true)
        let isContainParentCalendar = self.selectedCalanders.contains(where: { return $0.parentCalendarId == 0 })
        Session.shared.saveOthersCalendarAccessed(isContainParentCalendar)
        self.startForwardOthersEventsAsynchronisation()
    }
    
    func refreshCalendarIfNeeded() {
        if self.selectedMonth.addMonth(n: 1) == self.collectedMaxMonth || self.selectedMonth.addMonth(n: 2) == self.collectedMaxMonth || self.selectedMonth.addMonth(n: 1) == self.collectedOthersMaxMonth || (self.selectedMonth.addMonth(n: -1) == self.collectedMinMonth && self.selectedMonth != Date().startOfMonth) {
            self.allAvailableCalendars = self.getAvailableCalendars()
            self.refreshEvents()
            self.hideEventLoadingIndicator()
        }
    }
    
    func refreshEvents() {
        if self.calendarType == .OtherUser {
            self.readEventsOfOtherUsers()
        }
        else {
            self.readEventsFromSelectedCalendar()
        }
        self.updateEventCalendarIcon(on: Date(), of: self.eventsForCalendar())
    }
    
    func backGroundReFindingIsNeed() {
        self.isForwardReSynchronisationNeeded = true
        self.isBackwardReSynchronisationNeeded = true
        self.isForwardOtherReSynchronisationNeeded = true
    }
    
    func manipulateUserEventsAsynchronously() {
        if !self.isImportHappened {
            self.forcefullyStopEventSynchronisation(false)
            self.startForwardEventsAsynchronisation()
            self.startBackwardEventsAsynchronisation()
            self.startForwardOthersEventsAsynchronisation()
        }
    }
    
    func forcefullyStopEventSynchronisation(_ status: Bool) {
        self.isForceFullyStoppedBackgroundProcess = status
    }
    
    func refreshCalendarScreenWithUpdates(_ serviceDetection: [ServiceDetection]) {
        if self.isImportHappened {
            self.isImportHappened = false
            if !self.isForceFullyStoppedBackgroundProcess {
                self.manipulateUserEventsAsynchronously()
            }
        }
        else {
            if serviceDetection.isContainedSpecificServiceData(.calendar) {
                self.backGroundReFindingIsNeed()
                for detected in serviceDetection {
                    switch detected {
                    case .newCalendar(let calendars):
                        self.addNewCalendars(calendars)
                    case .calendarDeleted(let calendars):
                        self.deleteSpecificCalendars(calendars)
                    case .newEvent(let events):
                        self.addNewEvents(events)
                    case .eventDeleted(let events):
                        self.deleteSpecificEvents(events)
                    default: break
                    }
                }
            }
        }
        self.calendarView.reloadData()
    }
    
    func startForwardEventsAsynchronisation() {
        guard let date = self.collectedMaxMonth, Date().startOfTheMonth().monthBetweenDate(toDate: date) < self.forwardCounter, !self.isForceFullyStoppedBackgroundProcess, !self.isForwardSynchronisationStarted else { return }
        self.isForwardSynchronisationStarted = true
        self.isForwardReSynchronisationNeeded = false
        self.manipulateNextEvents(date, result: { dateEvents in
            DispatchQueue.main.async {
                if !self.isForwardReSynchronisationNeeded {
                    self.allEvents += dateEvents
                    self.collectedMaxMonth = date.addMonth(n: 1)
                }
                self.isForwardSynchronisationStarted = false
                self.startForwardEventsAsynchronisation()
            }
        })
    }
    
    func startBackwardEventsAsynchronisation() {
        guard let date = self.collectedMinMonth, date.monthBetweenDate(toDate: Date().startOfTheMonth()) < self.forwardCounter, !self.isForceFullyStoppedBackgroundProcess, !self.isBackwardSynchronisationStarted else { return }
        self.isBackwardSynchronisationStarted = true
        self.isBackwardReSynchronisationNeeded = false
        self.manipulatePreviousEvents(date, result: { dateEvents in
            DispatchQueue.main.async {
                if !self.isBackwardReSynchronisationNeeded {
                    self.allEvents += dateEvents
                    self.collectedMinMonth = date.addMonth(n: -1)
                }
                self.isBackwardSynchronisationStarted = false
                self.startBackwardEventsAsynchronisation()
            }
        })
    }
    
    func startForwardOthersEventsAsynchronisation() {
        guard let date = self.collectedOthersMaxMonth, self.calendarType == .OtherUser, Date().startOfTheMonth().monthBetweenDate(toDate: date) < self.forwardCounter, !self.isForceFullyStoppedBackgroundProcess, !self.isForwardOtherSynchronisationStarted else { return }
        self.isForwardOtherSynchronisationStarted = true
        self.isForwardOtherReSynchronisationNeeded = false
        self.manipulateOthersNextEvents(date, result: { dateEvents in
            DispatchQueue.main.async {
                if !self.isForwardOtherReSynchronisationNeeded && self.collectedOthersMaxMonth == date {
                    self.allEvents += dateEvents
                    self.collectedOthersMaxMonth = date.addMonth(n: 1)
                }
                self.isForwardOtherSynchronisationStarted = false
                self.startForwardOthersEventsAsynchronisation()
            }
        })
    }
    
    func manipulateOthersNextEvents(_ date: Date, result: @escaping ([Event]) -> ()) {
        let startOfMonth = date.startOfTheMonth()
        let endOfMonth = date.endOfTheMonth().adding(seconds: -1)
        DispatchQueue.global(qos: .userInitiated).async {
            var dateEvents: [Event] = []
            let allOtherEvents: [OtherUserEvent] = self.otherUsers.flatMap({ $0.readAllOtherEventsFrom(start: startOfMonth, end: endOfMonth) })
            allOtherEvents.forEach({ self.manipulateUserEvent($0, start: startOfMonth, end: endOfMonth, to: &dateEvents) })
            result(dateEvents)
        }
    }
    
    func manipulateNextEvents(_ date: Date, result: @escaping ([Event]) -> ()) {
        let startOfMonth = date.startOfTheMonth()
        let endOfMonth = date.endOfTheMonth().adding(seconds: -1)
        let databasePlanItEvent = DatabasePlanItEvent()
        databasePlanItEvent.readAllEventsUsingQueueFrom(startOfMonth: startOfMonth, endOfMonth: endOfMonth, result: { allUserEvents in
            var dateEvents: [Event] = []
            allUserEvents.forEach({ self.manipulateUserEvent($0, start: startOfMonth, end: endOfMonth, converter: databasePlanItEvent, to: &dateEvents) })
            result(dateEvents)
        })
    }
    
    func manipulateEvents(_ from: Date, to: Date, eventIds: [Double], result: @escaping ([Event], [Double]) -> ()) {
        let databasePlanItEvent = DatabasePlanItEvent()
        databasePlanItEvent.readSpecificEventsUsingQueue(startOfMonth: from, endOfMonth: to, eventIds: eventIds, result: { allUserEvents in
            var dateEvents: [Event] = []
            allUserEvents.forEach({ self.manipulateUserEvent($0, start: from, end: to, converter: databasePlanItEvent, to: &dateEvents) })
            result(dateEvents, eventIds)
        })
    }
    
    func manipulatePreviousEvents(_ date: Date, result: @escaping ([Event]) -> ()) {
        let startOfMonth = date.startOfTheMonth()
        let endOfMonth = date.endOfTheMonth().adding(seconds: -1)
        let databasePlanItEvent = DatabasePlanItEvent()
        databasePlanItEvent.readAllEventsUsingQueueFrom(startOfMonth: startOfMonth, endOfMonth: endOfMonth, result: { allUserEvents in
            var dateEvents: [Event] = []
            allUserEvents.forEach({ self.manipulateUserEvent($0, start: startOfMonth, end: endOfMonth, converter: databasePlanItEvent, to: &dateEvents) })
            result(dateEvents)
        })
    }
    
    func manipulateUserEvent(_ event: PlanItEvent, start: Date, end: Date, converter: DatabasePlanItEvent, to dateEvents: inout [Event]) {
        let availableDates = event.readAllAvailableDates(from: start, to: end)
        availableDates.forEach({ date in
            let modelEvent = Event(with: event, startDate: date, converter: converter)
            if modelEvent.eventData != nil { dateEvents.append(modelEvent) }
        })
    }
    
    func manipulateUserEvent(_ event: PlanItEvent, start: Date, end: Date, to dateEvents: inout [Event]) {
        let availableDates = event.readAllAvailableDates(from: start, to: end)
        availableDates.forEach({ date in dateEvents.append(Event(with: event, startDate: date)) })
    }
    
    func manipulateUserEvent(_ event: OtherUserEvent, start: Date, end: Date, to dateEvents: inout [Event]) {
        let availableDates = event.readAllAvailableDates(from: start, to: end)
        availableDates.forEach({ date in if self.calendarType == .OtherUser { dateEvents.append(Event(with: event, startDate: date)) } })
    }
    
    //MARK: - Delete
    func delete(event: PlanItEvent, childs: [PlanItEvent], deletedChilds: [String], for date: DateSpecificEvent, with type: RecursiveEditOption) {
        switch type {
        case .default, .allEventInTheSeries:
            if event.readRecurringEventId().isEmpty || type == .allEventInTheSeries {
                self.deleteSpecificEvents(childs + [event], deletedChilds: deletedChilds)
            }
            else {
                self.deleteSpecificEvents(childs + [event], deletedChilds: deletedChilds, for: date)
            }
        case .allFutureEvent:
            self.deleteAllFutureEvents(childs + [event], deletedChilds: deletedChilds, from: date)
        case .thisPerticularEvent:
            self.deleteSpecificEvents(childs + [event], deletedChilds: deletedChilds, for: date)
        }
    }
    
    func deleteSpecificEvents(_ events: [PlanItEvent], deletedChilds: [String]) {
        self.allEvents.removeAll(where: { event in if let planitEvent = event.eventData as? PlanItEvent { return events.contains(planitEvent) || deletedChilds.contains(where: { return ($0 == event.eventId && !event.eventId.isEmpty) || ($0 == event.appEventId && !event.appEventId.isEmpty) }) } else { return false } })
        self.refreshEvents()
    }
    
    func deleteAllFutureEvents(_ events: [PlanItEvent], deletedChilds: [String], from date: DateSpecificEvent) {
        self.allEvents.removeAll(where: { event in if let planitEvent = event.eventData as? PlanItEvent { return (events.contains(planitEvent) || deletedChilds.contains(where: { return ($0 == event.eventId && !event.eventId.isEmpty) || ($0 == event.appEventId && !event.appEventId.isEmpty) }) ) && event.initialDate >= date.startDate } else { return false } })
        self.refreshEvents()
    }
    
    func deleteSpecificEvents(_ events: [PlanItEvent], deletedChilds: [String], for date: DateSpecificEvent) {
        self.allEvents.removeAll(where: { event in if let planitEvent = event.eventData as? PlanItEvent { return (events.contains(planitEvent) || deletedChilds.contains(where: { return ($0 == event.eventId && !event.eventId.isEmpty) || ($0 == event.appEventId && !event.appEventId.isEmpty) }) ) && event.initialDate == date.startDate } else { return false } })
        self.refreshEvents()
    }
    
    func delete(event: OtherUserEvent, childs: [OtherUserEvent], deletedChilds: [String], for date: DateSpecificEvent, with type: RecursiveEditOption) {
        switch type {
        case .default, .allEventInTheSeries:
            if event.recurringEventId.isEmpty || type == .allEventInTheSeries {
                self.deleteSpecificEvents([event], deletedChilds: deletedChilds, from: event)
            }
            else {
                self.deleteSpecificEvents(childs + [event], deletedChilds: deletedChilds, for: date, from: event)
            }
        case .allFutureEvent:
            self.deleteAllFutureEvents(childs + [event], deletedChilds: deletedChilds, from: date, using: event)
        case .thisPerticularEvent:
            self.deleteSpecificEvents(childs + [event], deletedChilds: deletedChilds, for: date, from: event)
        }
    }
    
    func deleteSpecificEvents(_ events: [OtherUserEvent], deletedChilds: [String], from parent: OtherUserEvent) {
        if let user = self.otherUsers.filter({ return $0.userId == parent.userId }).first {
            user.events.removeAll(where: { event in return events.contains(where: { return $0.eventId == event.eventId }) || deletedChilds.contains(where: { return $0 == event.eventId }) })
        }
        self.allEvents.removeAll(where: { data in if let event = data.eventData as? OtherUserEvent { return events.contains(where: { return $0.eventId == event.eventId }) || deletedChilds.contains(where: { return ($0 == event.eventId && !event.eventId.isEmpty) || ($0 == data.appEventId && !data.appEventId.isEmpty) }) } else { return false } })
        self.refreshEvents()
    }
    
    func deleteAllFutureEvents(_ events: [OtherUserEvent], deletedChilds: [String], from date: DateSpecificEvent, using parent: OtherUserEvent) {
        if let user = self.otherUsers.filter({ return $0.userId == parent.userId }).first {
            events.forEach({ event in
                if let index = user.events.firstIndex(where: { return $0.eventId == event.eventId }) {
                    user.events[index] = event
                }
            })
        }
        self.allEvents.removeAll(where: { data in if let event = data.eventData as? OtherUserEvent { return ( events.contains(where: { return $0.eventId == event.eventId }) || deletedChilds.contains(where: { return ($0 == event.eventId && !event.eventId.isEmpty) || ($0 == data.appEventId && !data.appEventId.isEmpty) }) ) && data.initialDate >= date.startDate } else { return false } })
        self.refreshEvents()
    }
    
    func deleteSpecificEvents(_ events: [OtherUserEvent], deletedChilds: [String], for date: DateSpecificEvent, from parent: OtherUserEvent) {
        if let user = self.otherUsers.filter({ return $0.userId == parent.userId }).first {
            events.forEach({ event in
                if let index = user.events.firstIndex(where: { return $0.eventId == event.eventId }) {
                    user.events[index] = event
                }
            })
        }
        self.allEvents.removeAll(where: { data in if let event = data.eventData as? OtherUserEvent { return ( events.contains(where: { return $0.eventId == event.eventId }) || deletedChilds.contains(where: { return ($0 == event.eventId && !event.eventId.isEmpty) || ($0 == data.appEventId && !data.appEventId.isEmpty) }) ) && data.initialDate == date.startDate } else { return false } })
        self.refreshEvents()
    }
    
    func deleteSpecificCalendars(_ calendars: [PlanItCalendar]) {
        self.allEvents.removeAll(where: { if let calendar = $0.calendar { return calendars.contains(calendar)} else { return false } })
        self.refreshEvents()
    }
    
    //MARK: - Delete Bulk
    func deleteSpecificCalendars(_ calendarIds: [Double]) {
        self.allEvents.removeAll(where: { event in return calendarIds.contains( where: { event.calendarId == $0.cleanValue() }) })
        self.refreshEvents()
    }
    
    func deleteSpecificEvents(_ eventIds: [Double]) {
        self.allEvents.removeAll(where: { event in return eventIds.contains( where: { event.eventId == $0.cleanValue() }) })
        self.refreshEvents()
    }
    
    //MARK: - Update
    func updateUsersExistingEvents(_ events: [PlanItEvent], deletedChilds: [String]) {
        guard let startOfMonth = self.collectedMinMonth?.addMonth(n: 1), let endOfMonth = self.collectedMaxMonth?.adding(seconds: -1), endOfMonth > startOfMonth else { return }
        self.allEvents.removeAll(where: { event in if let planitEvent = event.eventData as? PlanItEvent { return (events.contains(planitEvent) || deletedChilds.contains(where: { return ($0 == event.eventId && !event.eventId.isEmpty) || ($0 == event.appEventId && !event.appEventId.isEmpty) }) ) && event.start >= startOfMonth && event.end <= endOfMonth } else { return false } })
        var dateEvents: [Event] = []
        let validEvents = events.filter({ return $0.status == 0 })
        validEvents.forEach({ self.manipulateUserEvent($0, start: startOfMonth, end: endOfMonth, to: &dateEvents) })
        self.allEvents += dateEvents
        self.refreshEvents()
    }
    
    func updateOtherExistingEvents(_ events: [OtherUserEvent], parent: OtherUserEvent, deletedChilds: [String]) {
        if let user = self.otherUsers.filter({ return $0.userId == parent.userId }).first {
            events.forEach({ event in
                if let index = user.events.firstIndex(where: { return $0.eventId == event.eventId }) {
                    user.events[index] = event
                }
                else {
                    user.events.append(event)
                }
            })
        }
        guard let startOfMonth = Date().startOfMonth, let endOfMonth = self.collectedOthersMaxMonth?.adding(seconds: -1), endOfMonth > startOfMonth else { return }
        self.allEvents.removeAll(where: { data in if let event = data.eventData as? OtherUserEvent { return (events.contains(where: { return $0.eventId == event.eventId }) || deletedChilds.contains(where: { return ($0 == event.eventId && !event.eventId.isEmpty) || ($0 == data.appEventId && !data.appEventId.isEmpty) }) ) && data.start >= startOfMonth && data.end <= endOfMonth } else { return false } })
        var dateEvents: [Event] = []
        let validEvents = events.filter({ return $0.status == 0 })
        validEvents.forEach({ self.manipulateUserEvent($0, start: startOfMonth, end: endOfMonth, to: &dateEvents) })
        self.allEvents += dateEvents
        self.refreshEvents()
    }
    
    //MARK: - New
    func addUsersNewEvents(_ events: [PlanItEvent], to calendars: [UserCalendarVisibility]) {
        guard let startOfMonth = self.collectedMinMonth?.addMonth(n: 1), let endOfMonth = self.collectedMaxMonth?.adding(seconds: -1), endOfMonth > startOfMonth else { return }
        var dateEvents: [Event] = []
        events.forEach({ self.manipulateUserEvent($0, start: startOfMonth, end: endOfMonth, to: &dateEvents) })
        self.allEvents += dateEvents
        let eventCalendars = calendars.map({ return $0.calendar })
        if self.selectedCalanders.contains(where: { return eventCalendars.contains($0) }) || self.selectedCalanders.contains(where: { return $0.parentCalendarId == 0}) {
            self.refreshEvents()
        }
    }
    
    //MARK: - New Bulk
    func addNewCalendars(_ calendarIds: [Double]) {
        if self.selectedCalanders.contains(where: { return calendarIds.contains($0.calendarId) }) {
            self.viewCalendarList.reloadCalendarListWith(self.selectedCalanders)
            self.refreshEvents()
        }
    }
    
    func addNewEvents(_ eventIds: [Double]) {
        guard let startOfMonth = self.collectedMinMonth?.addMonth(n: 1), let endOfMonth = self.collectedMaxMonth?.adding(seconds: -1), endOfMonth > startOfMonth else { return }
        guard !self.isNewEventSynchronisationStarted else {
            self.pendingNewEvents.append(contentsOf: eventIds)
            return }
        self.isNewEventSynchronisationStarted = true
        self.allEvents.removeAll(where: { event in return eventIds.contains( where: { event.eventId == $0.cleanValue() }) && event.start >= startOfMonth && event.end <= endOfMonth })
        self.manipulateEvents(startOfMonth, to: endOfMonth, eventIds: eventIds, result: { dateEvents, givenIds in
            DispatchQueue.main.async {
                if self.pendingNewEvents.isEmpty {
                    self.allEvents += dateEvents
                    self.refreshEvents()
                    self.isNewEventSynchronisationStarted = false
                }
                else {
                    let balanceEvents = givenIds.filter({ return !self.pendingNewEvents.contains($0) }) + self.pendingNewEvents
                    self.pendingNewEvents.removeAll()
                    self.isNewEventSynchronisationStarted = false
                    self.addNewEvents(balanceEvents)
                }
            }
        })
    }
}
