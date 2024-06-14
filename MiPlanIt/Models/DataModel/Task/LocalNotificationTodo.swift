//
//  LocalNotificationTodo.swift
//  MiPlanIt
//
//  Created by Arun Aniyappan on 22/01/21.
//  Copyright © 2021 Arun. All rights reserved.
//

import Foundation

class LocalNotificationTodo {
    
    let reminderDate: Date
    let availableDate: Date
    let planItTodo: PlanItTodo
    
    init(withReminderDate date: Date, existingDate: Date, todo: PlanItTodo) {
        self.planItTodo = todo
        self.reminderDate = date
        self.availableDate = existingDate
    }
}
