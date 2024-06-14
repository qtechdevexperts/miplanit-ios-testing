//
//  NotificationToDoViewController.swift
//  MiPlanIt
//
//  Created by Febin Paul on 05/08/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

protocol NotificationToDoRepeatViewControllerDelegate: class {
    func notificationToDoRepeatViewController(_ notificationToDoRepeatViewController: NotificationToDoRepeatViewController, recurrenceRule: String)
}


class NotificationToDoRepeatViewController: RepeatViewController {
    
    weak var notificationToDoRepeatDelegate: NotificationToDoRepeatViewControllerDelegate?
    
    override func backButtonClicked(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func applyButtonClicked(_ sender: UIButton) {
        super.applyButtonClicked(sender)
        self.dismiss(animated: true, completion: nil)
    }
    
}
