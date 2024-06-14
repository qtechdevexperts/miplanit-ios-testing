//
//  EventTagViewController.swift
//  MiPlanIt
//
//  Created by Febin Paul on 21/05/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

protocol AddEventTagViewControllerDelegate: class {
    func addEventTagViewController(_ viewController: AddEventTagViewController, updated tags: [String])
}

class AddEventTagViewController: AddActivityTagViewController {
    
    weak var delegate: AddEventTagViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.tagActivityType = .event
    }
    
    @IBAction func backButtonTouched(_ sender: Any) {
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction override func saveButtonTouched(_ sender: Any) {
        super.saveButtonTouched(sender)
        self.view.endEditing(true)
        DatabasePlanItSuggustionTags().insertShoppingTags(self.titles, of: self.tagActivityType)
        self.delegate?.addEventTagViewController(self, updated: titles)
        self.navigationController?.popViewController(animated: true)
    }

}
