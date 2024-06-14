//
//  PlanItSilentEvent+Save.swift
//  MiPlanIt
//
//  Created by Febin Paul on 09/04/21.
//  Copyright © 2021 Arun. All rights reserved.
//

import Foundation

extension PlanItSilentEvent {
    
    func readValueOfCalendarType() -> String { return self.calendarType.cleanValue() }
    
    func deleteReminder(withHardSave status: Bool = true) {
        guard let deletedReminder = self.reminder else { return }
        self.reminder = nil
        deletedReminder.deleteItSelf(withHardSave: status)
    }
    
    func deleteItSelf(withHardSave status: Bool = true) {
        self.managedObjectContext?.delete(self)
        if status { try? self.managedObjectContext?.save() }
    }
    
    func readReminders() -> PlanItReminder? {
        return self.reminder
    }
}
