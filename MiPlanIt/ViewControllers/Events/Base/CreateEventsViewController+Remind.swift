//
//  CreateEventsViewController+RemindDropDownDelegate.swift
//  MiPlanIt
//
//  Created by Febin Paul on 14/04/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

extension CreateEventsViewController: ReminderBaseViewControllerDelegate {
    
    func reminderBaseViewController(_ reminderBaseViewController: ReminderBaseViewController, reminderValue: ReminderModel) {
        self.eventModel.remindValue = reminderValue
        self.updateRemindMeTitle()
    }
    
    func reminderBaseViewControllerBackClicked(_ reminderBaseViewController: ReminderBaseViewController) {
    }
}
