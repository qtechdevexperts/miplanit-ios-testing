//
//  ViewEventViewController+Callback.swift
//  MiPlanIt
//
//  Created by Arun on 07/05/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

extension ViewEventViewController: CreateEventsViewControllerDelegate {
    
    func createEventsViewController(_ viewController: CreateEventsViewController, addedEvents: [Any], deletedChilds: [String]?, toCalendars calendars: [UserCalendarVisibility]) {
        self.deletedEvents = deletedChilds
        if let planItEvents = addedEvents as? [PlanItEvent] {
            self.findLastCreatedEventsFromList(planItEvents, using: viewController.eventModel.startDate)
        }
        if let otherUserEvents = addedEvents as? [OtherUserEvent] {
            self.findLastCreatedEventsFromList(otherUserEvents, using: viewController.eventModel.startDate)
        }
        self.initialiseUIComponents()
    }
    
    func findLastCreatedEventsFromList(_ events: [PlanItEvent], using startDate: Date) {
        self.addModifiedEventsToMain(events)
        guard let event = self.eventPlanOtherObject as? PlanItEvent else { return }
        let allParentChildEvents = events + events.flatMap({ return $0.readAllChildEvents() }).filter({ return $0.status == 0 })
        let latestEvents = allParentChildEvents.filter({ return $0.readStartDateTime() == startDate })
        if let latestEvent = latestEvents.filter({ return $0.parent != nil }).first ?? latestEvents.first {
            self.eventPlanOtherObject = latestEvent
            self.dateEvent = DateSpecificEvent(with: latestEvent.readStartDateTime().initialHour())
        }
        else if let latestEvent = events.filter({ return $0.readValueOfEventId() == event.readValueOfEventId() }).first {
            self.eventPlanOtherObject = latestEvent
            self.dateEvent = DateSpecificEvent(with: latestEvent.readStartDateTime().initialHour())
        }
        else {
            self.eventPlanOtherObject = events.first
        }
    }
    
    func findLastCreatedEventsFromList(_ events: [OtherUserEvent], using startDate: Date) {
        self.addModifiedEventsToMain(events)
        guard let event = self.eventPlanOtherObject as? OtherUserEvent else { return }
        let allParentChildEvents = events + events.flatMap({ return $0.readAllChildEvents() }).filter({ return $0.status == 0 })
        let latestEvents = allParentChildEvents.filter({ return $0.readStartDateTime() == startDate })
        if let latestEvent = latestEvents.filter({ return $0.otherSubEvents.isEmpty }).first ?? latestEvents.first {
            self.eventPlanOtherObject = latestEvent
            self.dateEvent = DateSpecificEvent(with: latestEvent.readStartDateTime().initialHour())
        }
        else if let latestEvent = events.filter({ return $0.eventId == event.eventId }).first {
            self.eventPlanOtherObject = latestEvent
            self.dateEvent = DateSpecificEvent(with: latestEvent.readStartDateTime().initialHour())
        }
        else {
            self.eventPlanOtherObject = events.first
        }
    }
    
    func addModifiedEventsToMain(_ events: [PlanItEvent]) {
        guard let modifiedUserEvents = self.modifiedEvents as? [PlanItEvent] else { return }
        events.forEach({ event in
            if let index = modifiedUserEvents.firstIndex(where: { return $0.readValueOfEventId() == event.readValueOfEventId() }) {
                self.modifiedEvents[index] = event
            }
            else {
                self.modifiedEvents.append(event)
            }
        })
    }
    
    func addModifiedEventsToMain(_ events: [OtherUserEvent]) {
        guard let modifiedUserEvents = self.modifiedEvents as? [OtherUserEvent] else { return }
        events.forEach({ event in
            if let index = modifiedUserEvents.firstIndex(where: { return $0.eventId == event.eventId }) {
                self.modifiedEvents[index] = event
            }
            else {
                self.modifiedEvents.append(event)
            }
        })
    }
}


extension ViewEventViewController: AddEventTagViewControllerDelegate {
    
    func addEventTagViewController(_ viewController: AddEventTagViewController, updated tags: [String]) {
        self.updateTagToServerUsingNetwotk(tags: tags)
    }
}
