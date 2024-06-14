//
//  NotificationToDoTagViewController.swift
//  MiPlanIt
//
//  Created by Febin Paul on 04/08/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

protocol NotificationToDoTagViewControllerDelegate: class {
    func notificationToDoTagViewController(_ viewController: NotificationToDoTagViewController, updated tags: [String])
}

class NotificationToDoTagViewController: AddActivityTagViewController {
    
    weak var delegate: NotificationToDoTagViewControllerDelegate?

    override func viewDidLoad() {
        self.tagActivityType = .task
        self.canAddTag = false
        super.viewDidLoad()        
    }
    
    @IBAction func backButtonTouched(_ sender: Any) {
        self.view.endEditing(true)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction override func saveButtonTouched(_ sender: Any) {
        self.view.endEditing(true)
        DatabasePlanItSuggustionTags().insertShoppingTags(self.titles, of: self.tagActivityType)
        self.delegate?.notificationToDoTagViewController(self, updated: titles)
        self.dismiss(animated: true, completion: nil)
    }
}
