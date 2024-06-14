//
//  NotificationShopTagsViewController.swift
//  MiPlanIt
//
//  Created by Febin Paul on 15/12/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

protocol NotificationShopTagsViewControllerDelegate: class {
    func notificationShopTagsViewController(_ viewController: NotificationShopTagsViewController, updated tags: [String])
}

class NotificationShopTagsViewController: AddActivityTagViewController {
    
    weak var delegate: NotificationShopTagsViewControllerDelegate?

    override func viewDidLoad() {
        self.tagActivityType = .task
        self.canAddTag = false
        super.viewDidLoad()
    }
    
    @IBAction func backButtonTouched(_ sender: Any) {
        self.view.endEditing(true)
        self.dismiss(animated: true, completion: nil)
    }
}
