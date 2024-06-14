//
//  ViewEventViewController+Service.swift
//  MiPlanIt
//
//  Created by Febin Paul on 28/04/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

extension ViewEventViewController {
    
    func createWebServiceToCancelEvent(_ event: PlanItEvent, request: [String: Any], deleteType: RecursiveEditOption) {
        let cachedImage = self.buttonDelete.image(for: .normal)
        self.buttonDelete.clearButtonTitleForAnimation()
        self.buttonDelete.startAnimation()
        CalendarService().cancelEvent(event, request: request, deleteType: deleteType, isOtherUser: self.isOtherUserType()) { (status, response, deletedEvents, error) in
            if status {
                self.buttonDelete.stopAnimation(animationStyle: .normal, revertAfterDelay: 0) {
                    self.buttonDelete.showTickAnimation { (result) in
                        self.navigationController?.popViewController(animated: true)
                        if let otherUserEvent = response as? [OtherUserEvent] {
                            self.deleteEventsFromModifiedList(otherUserEvent)
                            self.delegate?.viewEventViewController(self, deleted: otherUserEvent, deletedChilds: deletedEvents, withType: deleteType)
                        }
                        if let otherUserEvent = self.eventPlanOtherObject as? OtherUserEvent {
                            self.deleteEventsFromModifiedList([otherUserEvent])
                            self.delegate?.viewEventViewController(self, deleted: [otherUserEvent], deletedChilds: deletedEvents, withType: deleteType)
                        }
                        else if let planItEvent = response as? [PlanItEvent] {
                            self.deleteEventsFromModifiedList(planItEvent)
                            self.delegate?.viewEventViewController(self, deleted: planItEvent, deletedChilds: deletedEvents, withType: deleteType)
                        }
                        else {
                            self.deleteEventsFromModifiedList([event])
                            self.delegate?.viewEventViewController(self, deleted: [event], deletedChilds: deletedEvents, withType: deleteType)
                        }
                    }
                }
            }
            else {
                let message = error ?? Message.unknownError
                self.buttonDelete.stopAnimation(animationStyle: .shake, revertAfterDelay: 0) {
                    self.buttonDelete.setImage(cachedImage, for: .normal)
                    self.performSegue(withIdentifier: Segues.toMessageScreen, sender: [Message.error, message])
                }
            }
        }
    }
    
    func createWebServiceToDeleteEvent(_ event: PlanItEvent, request: [String: Any], deleteType: RecursiveEditOption) {
        let cachedImage = self.buttonDelete.image(for: .normal)
        self.buttonDelete.clearButtonTitleForAnimation()
        self.buttonDelete.startAnimation()
        CalendarService().deleteEvent(event, request: request, deleteType: deleteType, isOtherUser: self.isOtherUserType()) { (status, response, deletedEvents, error) in
            if status {
                self.buttonDelete.stopAnimation(animationStyle: .normal, revertAfterDelay: 0) {
                    self.buttonDelete.showTickAnimation { (result) in
                        self.navigationController?.popViewController(animated: true)
                        if let otherUserEvent = response as? [OtherUserEvent] {
                            self.deleteEventsFromModifiedList(otherUserEvent)
                            self.delegate?.viewEventViewController(self, deleted: otherUserEvent, deletedChilds: deletedEvents, withType: deleteType)
                        }
                        if let otherUserEvent = self.eventPlanOtherObject as? OtherUserEvent {
                            self.deleteEventsFromModifiedList([otherUserEvent])
                            self.delegate?.viewEventViewController(self, deleted: [otherUserEvent], deletedChilds: deletedEvents, withType: deleteType)
                        }
                        else if let planItEvent = response as? [PlanItEvent] {
                            self.deleteEventsFromModifiedList(planItEvent)
                            self.delegate?.viewEventViewController(self, deleted: planItEvent, deletedChilds: deletedEvents, withType: deleteType)
                        }
                        else {
                            self.deleteEventsFromModifiedList([event])
                            self.delegate?.viewEventViewController(self, deleted: [event], deletedChilds: deletedEvents, withType: deleteType)
                        }
                    }
                }
            }
            else {
                let message = error ?? Message.unknownError
                self.buttonDelete.stopAnimation(animationStyle: .shake, revertAfterDelay: 0) {
                    self.buttonDelete.setImage(cachedImage, for: .normal)
                    self.performSegue(withIdentifier: Segues.toMessageScreen, sender: [Message.error, message])
                }
            }
        }
    }
    
    func createWebServiceToUpdateTag(_ tags: [String]) {
        self.buttonTag.startAnimation()
        self.labelTagCount.isHidden = true
        let eventModel = self.createEventModelForEditEvent(withType: .default)
        eventModel.tags = tags
        CalendarService().addEvent(event: eventModel, isUpdateTagsOnly: true) { response, deletedEvents, error in
            if let result = response {
                if let planItEvent = self.eventPlanOtherObject as? PlanItEvent {
                    self.addModifiedEventsToMain([planItEvent])
                }
                else if let otherUserEvent = self.eventPlanOtherObject as? OtherUserEvent {
                    self.addModifiedEventsToMain([otherUserEvent])
                }
                self.buttonTag.stopAnimation(animationStyle: .normal, revertAfterDelay: 0) {
                    if let planItEvent = result.first as? PlanItEvent {
                        self.updateTagUI(tags: planItEvent.readAllTags().map({ $0.readTag() }) )
                    }
                    else if let otherUserEvent = result.first as? OtherUserEvent {
                        self.updateTagUI(tags: otherUserEvent.tags)
                    }
                }
            }
            else {
                self.buttonTag.stopAnimation(animationStyle: .shake, revertAfterDelay: 0) {
                    let message = error ?? Message.unknownError
                    self.performSegue(withIdentifier: Segues.toMessageScreen, sender: [Message.error, message])
                }
            }
        }
    }
}
