//
//  ViewEventViewController+Offline.swift
//  MiPlanIt
//
//  Created by Arun Aniyappan on 26/11/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

extension ViewEventViewController {
    
    func saveCancelEventToServerUsingNetwotk(_ event: PlanItEvent, type: RecursiveEditOption) {
        if SocialManager.default.isNetworkReachable(), !event.isMainCalendarPending() {
            self.createWebServiceToCancelEvent(event, request: self.createDeleteRequestForEvent(type), deleteType: type)
        }
        else {
            let eventDeleted = DatabasePlanItEvent().cancelOfflinePlanItEvent(event, date: self.dateEvent.startDate, type: type)
            Session.shared.registerUserEventLocationNotification()
            self.navigationController?.popViewController(animated: true)
            self.deleteEventsFromModifiedList(eventDeleted.0)
            self.delegate?.viewEventViewController(self, deleted: eventDeleted.0, deletedChilds: eventDeleted.1, withType: type)
        }
    }
    
    func saveDeleteEventToServerUsingNetwotk(_ event: PlanItEvent, type: RecursiveEditOption) {
        if SocialManager.default.isNetworkReachable(), !event.isMainCalendarPending(), !event.isPending {
            self.createWebServiceToDeleteEvent(event, request: self.createDeleteRequestForEvent(type), deleteType: type)
        }
        else {
            let eventDeleted = DatabasePlanItEvent().deleteOfflinePlanItEvent(event, date: self.dateEvent.startDate, type: type)
            Session.shared.registerUserEventLocationNotification()
            self.navigationController?.popViewController(animated: true)
            self.deleteEventsFromModifiedList(eventDeleted.0)
            self.delegate?.viewEventViewController(self, deleted: eventDeleted.0, deletedChilds: eventDeleted.1, withType: type)
        }
    }
    
    func updateTagToServerUsingNetwotk(tags: [String]) {
        if SocialManager.default.isNetworkReachable() {
            if let planItEvent = self.eventPlanOtherObject as? PlanItEvent, planItEvent.isMainCalendarPending() {
                self.saveTagOffline(tags)
                return
            }
            self.createWebServiceToUpdateTag(tags)
        }
        else {
            self.saveTagOffline(tags)
        }
    }
    
    func saveTagOffline(_ tags: [String]) {
        if let planItEvent = self.eventPlanOtherObject as? PlanItEvent {
            planItEvent.saveTagsOffline(tags)
            self.addModifiedEventsToMain([planItEvent])
            self.updateTagUI(tags: planItEvent.readAllTags().map({ $0.readTag() }) )
        }
        else if let otherUserEvent = self.eventPlanOtherObject as? OtherUserEvent {
            otherUserEvent.saveOtherUserTag(tags)
            self.addModifiedEventsToMain([otherUserEvent])
            self.updateTagUI(tags: otherUserEvent.tags)
        }
    }
}
