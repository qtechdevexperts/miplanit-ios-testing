//
//  LocalNotificationShopListItem.swift
//  MiPlanIt
//
//  Created by Arun Aniyappan on 22/01/21.
//  Copyright © 2021 Arun. All rights reserved.
//

import Foundation

class LocalNotificationShopListItem {
    
    let reminderDate: Date
    let availableDate: Date
    let planItShopListItem: PlanItShopListItems
    
    init(withReminderDate date: Date, existingDate: Date, shopListItem: PlanItShopListItems) {
        self.planItShopListItem = shopListItem
        self.reminderDate = date
        self.availableDate = existingDate
    }
}
