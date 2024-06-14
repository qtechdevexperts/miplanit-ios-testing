//
//  CreateEventsViewController+Service.swift
//  MiPlanIt
//
//  Created by Febin Paul on 16/04/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation


extension CreateEventsViewController {
    
    func callCreateEventService() {
        self.buttonSaveEvent.startAnimation()
        CalendarService().addEvent(event: self.eventModel, callback: { response, deletedEvents, error in
            if let result = response {
                self.buttonSaveEvent.clearButtonTitleForAnimation()
                self.buttonSaveEvent.stopAnimation(animationStyle: .normal, revertAfterDelay: 0) {
                    self.buttonSaveEvent.showTickAnimation { (results) in
                        self.navigationController?.popViewController(animated: true)
                        if let planItEvents = result as? [PlanItEvent] {
                            self.delegate?.createEventsViewController(self, addedEvents: planItEvents, deletedChilds: deletedEvents, toCalendars: self.eventModel.calendars)
                        }
                        else if let otherUserEvents = result as? [OtherUserEvent] {
                            self.delegate?.createEventsViewController(self, addedEvents: otherUserEvents, deletedChilds: deletedEvents, toCalendars: self.eventModel.calendars)
                        }
                    }
                }
            }
            else {
                self.buttonSaveEvent.stopAnimation(animationStyle: .shake, revertAfterDelay: 0) {
                    let message = error ?? Message.unknownError
                    self.performSegue(withIdentifier: Segues.toMessageScreen, sender: [Message.error, message])
                }
            }
        })
    }
    
    func callServiceToFetchCalendarUserDetails() {
        let allAcceptedInvitees = self.eventModel.calendars.flatMap({ return $0.calendar.readAllAcceptedInvitees() })
        guard !allAcceptedInvitees.isEmpty || self.eventModel.calendars.contains(where: { return $0.calendar.createdBy?.readValueOfUserId() != Session.shared.readUserId() }) else { self.eventModel.invitees.forEach({ $0.isDeletable = true }); return }
        if SocialManager.default.isNetworkReachable() {
            self.startFindingInvitees()
            CalendarService().fetchOtherUserEvents(allAcceptedInvitees, of: self.eventModel.calendars, callback: { response, error in
                self.stopFindingInvitees()
                self.updateOtherUserStatus(otherUsers: response)
            })
        }
        else {
            allAcceptedInvitees.forEach({ (invitees) in
                self.eventModel.invitees.append(OtherUser(invitee: invitees))
            })
            self.buttonInvitees.setTitle("\(self.eventModel.invitees.count) \(self.eventModel.invitees.count > 1 ? "people" : "person")", for: .normal)
            self.updateInviteeStatus()
        }
    }
    
    func callServiceToFetchEventInviteeUserDetails() {
        guard !self.eventModel.invitees.isEmpty else { return }
        if SocialManager.default.isNetworkReachable() {
            self.startFindingInvitees()
            CalendarService().fetchOtherUserEvents(self.eventModel.invitees.compactMap({ return CalendarUser($0) }), callback: { response, error in
                self.stopFindingInvitees()
                self.updateOtherUserStatus(otherUsers: response)
            })
        }
        else {
            self.buttonInvitees.setTitle("\(self.eventModel.invitees.count) \(self.eventModel.invitees.count > 1 ? "people" : "person")", for: .normal)
            self.updateInviteeStatus()
        }
    }
    
    func updateOtherUserStatus(otherUsers: [OtherUser]?) {
        if let result = otherUsers {
            self.eventModel.invitees.forEach({ $0.isDeletable = true })
            result.forEach({ event in
                if let index = self.eventModel.invitees.firstIndex(where: { return $0.userId == event.userId && !event.userId.isEmpty }) {
                self.eventModel.invitees[index] = event
            }
            else if let index = self.eventModel.invitees.firstIndex(where: { return $0.email == event.email && !event.email.isEmpty }) {
                self.eventModel.invitees[index] = event
            }
            else if let index = self.eventModel.invitees.firstIndex(where: { return $0.phone == event.phone && !event.phone.isEmpty }) {
                self.eventModel.invitees[index] = event
            }
            else {
                if let calendar = self.eventModel.calendars.first, let creator = calendar.calendar.createdBy, event.userId == creator.readValueOfUserId()  {
                    event.isDeletable = false
                }
                self.eventModel.invitees.insert(event, at: 0)
                }
            })
            self.buttonInvitees.setTitle("\(self.eventModel.invitees.count) \(self.eventModel.invitees.count > 1 ? "people" : "person")", for: .normal)
            self.updateInviteeStatus()
        }
    }
}
