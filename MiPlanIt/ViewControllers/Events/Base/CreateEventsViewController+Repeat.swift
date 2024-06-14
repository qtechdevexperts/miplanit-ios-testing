//
//  CreateEventsViewController+RepeatDropDownDelegate.swift
//  MiPlanIt
//
//  Created by Febin Paul on 14/04/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

extension CreateEventsViewController: RepeatViewControllerDelegate {
    func repeatViewController(_ repeatViewController: RepeatViewController, recurrenceRule: String) {
        self.eventModel.recurrence = recurrenceRule
        self.setRepeatTitle(rule: recurrenceRule)
    }
}
