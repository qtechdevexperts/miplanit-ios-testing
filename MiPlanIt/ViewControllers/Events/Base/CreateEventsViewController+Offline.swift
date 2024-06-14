//
//  CreateEventsViewController+Offline.swift
//  MiPlanIt
//
//  Created by Arun on 14/10/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

extension CreateEventsViewController {
    
    func saveEventToServerUsingNetwotk() {
        if SocialManager.default.isNetworkReachable(), !self.eventModel.isPendingCalendars(), !eventModel.isPendingParentEvent(), !self.eventModel.isPendingEvent() {
            self.callCreateEventService()
        }
        else {
            let eventCreated = DatabasePlanItEvent().insertNewOfflinePlanItEvent(self.eventModel)
            Session.shared.registerUserEventLocationNotification()
            self.navigationController?.popViewController(animated: true)
            self.delegate?.createEventsViewController(self, addedEvents: eventCreated.0, deletedChilds: eventCreated.1, toCalendars: self.eventModel.calendars)
        }
    }
}
