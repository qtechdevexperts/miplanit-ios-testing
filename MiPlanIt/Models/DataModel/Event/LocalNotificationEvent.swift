//
//  LocalNotificationEvent.swift
//  MiPlanIt
//
//  Created by Arun Aniyappan on 22/01/21.
//  Copyright © 2021 Arun. All rights reserved.
//

import Foundation

class LocalNotificationEvent {
    
    let reminderDate: Date
    let availableDate: Date
    let availableDateTime: Date
    let planItEvent: PlanItEvent
    
    init(withReminderDate date: Date, existingDate: Date, actualDate: Date, event: PlanItEvent) {
        self.planItEvent = event
        self.reminderDate = date
        self.availableDate = existingDate
        self.availableDateTime = actualDate
    }
}
