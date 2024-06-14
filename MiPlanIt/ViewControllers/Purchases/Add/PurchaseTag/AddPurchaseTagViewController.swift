//
//  AddPurchaseTagViewController.swift
//  MiPlanIt
//
//  Created by Febin Paul on 21/05/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

protocol AddPurchaseTagViewControllerDelegate: class {
    func addPurchaseTagViewController(_ viewController: AddPurchaseTagViewController, updated tags: [String])
}

class AddPurchaseTagViewController: AddActivityTagViewController {

    weak var delegate: AddPurchaseTagViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.tagActivityType = .purchase
    }
    
    @IBAction func backButtonTouched(_ sender: Any) {
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction override func saveButtonTouched(_ sender: Any) {
        self.view.endEditing(true)
        DatabasePlanItSuggustionTags().insertShoppingTags(self.titles, of: self.tagActivityType)
        self.delegate?.addPurchaseTagViewController(self, updated: titles)
        self.navigationController?.popViewController(animated: true)
    }


}
