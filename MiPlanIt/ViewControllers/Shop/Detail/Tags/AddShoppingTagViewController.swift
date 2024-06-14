//
//  AddShoppingTagViewController.swift
//  MiPlanIt
//
//  Created by Febin Paul on 21/05/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

protocol AddShoppingTagViewControllerDelegate: class {
    func addShoppingTagViewController(_ viewController: AddShoppingTagViewController, updated tags: [String])
}

class AddShoppingTagViewController: AddActivityTagViewController {
    
     weak var delegate: AddShoppingTagViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.tagActivityType = .shopping
    }
    
    @IBAction func backButtonTouched(_ sender: Any) {
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction override func saveButtonTouched(_ sender: Any) {
        self.view.endEditing(true)
        DatabasePlanItSuggustionTags().insertShoppingTags(self.titles, of: self.tagActivityType )
        self.delegate?.addShoppingTagViewController(self, updated: titles)
        self.navigationController?.popViewController(animated: true)
    }

}
