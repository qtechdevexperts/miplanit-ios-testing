//
//  ReminderOptionView.swift
//  MiPlanIt
//
//  Created by Febin Paul on 12/08/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

class ReminderOptionView: UIView {

    var reminderOption: ReminderOption!
    @IBOutlet weak var imageViewSelection: UIImageView!
    
    func setSelectionStatus(option: ReminderOption?) {
        guard let option = option else {
            self.imageViewSelection.isHidden = true
            return
        }
        self.imageViewSelection.isHidden = self.reminderOption != option
    }

}
