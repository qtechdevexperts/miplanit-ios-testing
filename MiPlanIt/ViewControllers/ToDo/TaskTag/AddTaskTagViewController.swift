//
//  AddTaskTagViewController.swift
//  MiPlanIt
//
//  Created by Febin Paul on 21/05/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

protocol AddTaskTagViewControllerDelegate: class {
    func addTaskTagViewController(_ viewController: AddTaskTagViewController, updated tags: [String])
}

class AddTaskTagViewController: AddActivityTagViewController {
    
    weak var delegate: AddTaskTagViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.tagActivityType = .task
    }
    
    @IBAction func backButtonTouched(_ sender: Any) {
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction override func saveButtonTouched(_ sender: Any) {
        self.view.endEditing(true)
        DatabasePlanItSuggustionTags().insertShoppingTags(self.titles, of: self.tagActivityType)
        self.delegate?.addTaskTagViewController(self, updated: titles)
        self.navigationController?.popViewController(animated: true)
    }
}
