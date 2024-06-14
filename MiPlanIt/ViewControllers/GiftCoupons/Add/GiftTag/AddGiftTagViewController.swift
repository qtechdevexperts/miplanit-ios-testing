//
//  AddGiftTagViewController.swift
//  MiPlanIt
//
//  Created by Febin Paul on 21/05/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

protocol AddGiftTagViewControllerDelegate: class {
    func addGiftTagViewController(_ viewController: AddGiftTagViewController, updated tags: [String])
}

class AddGiftTagViewController: AddActivityTagViewController {

    weak var delegate: AddGiftTagViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.tagActivityType = .gift
    }
    
    @IBAction func backButtonTouched(_ sender: Any) {
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction override func saveButtonTouched(_ sender: Any) {
        self.view.endEditing(true)
        
        DatabasePlanItSuggustionTags().insertShoppingTags(self.titles, of: self.tagActivityType)
        self.delegate?.addGiftTagViewController(self, updated: titles)
        self.navigationController?.popViewController(animated: true)
    }
}
