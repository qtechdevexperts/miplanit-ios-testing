//
//  NotificationEventTagViewController.swift
//  MiPlanIt
//
//  Created by Febin Paul on 20/08/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

protocol NotificationEventTagViewControllerDelegate: class {
    func notificationEventTagViewController(_ viewController: NotificationEventTagViewController, updated tags: [String])
}

class NotificationEventTagViewController: AddActivityTagViewController {
    
    weak var delegate: NotificationEventTagViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.tagActivityType = .event
    }
    
    @IBAction func backButtonTouched(_ sender: Any) {
        self.view.endEditing(true)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction override func saveButtonTouched(_ sender: Any) {
        super.saveButtonTouched(sender)
        self.view.endEditing(true)
        DatabasePlanItSuggustionTags().insertShoppingTags(self.titles, of: self.tagActivityType)
        self.delegate?.notificationEventTagViewController(self, updated: titles)
        self.dismiss(animated: true, completion: nil)
    }

}

