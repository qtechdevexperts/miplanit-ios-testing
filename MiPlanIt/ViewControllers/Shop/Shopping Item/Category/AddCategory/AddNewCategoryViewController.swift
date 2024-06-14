//
//  AddNewCategoryViewController.swift
//  MiPlanIt
//
//  Created by Febin Paul on 08/11/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

protocol AddNewCategoryViewControllerDelegate: class {
    func addNewCategoryViewController(_ addNewCategoryViewController: AddNewCategoryViewController, add category: PlanItShopMainCategory)
    func addNewCategoryViewController(_ addNewCategoryViewController: AddNewCategoryViewController, update category: PlanItShopMainCategory)
}

class AddNewCategoryViewController: UIViewController {
    
    var updateShopCategory: PlanItShopMainCategory?
    weak var delegate: AddNewCategoryViewControllerDelegate?
    
    @IBOutlet weak var textfieldCategoryName: UITextField!
    @IBOutlet weak var buttonAdd: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.initilizeCategory()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        IQKeyboardManager.shared.enable = true
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        IQKeyboardManager.shared.enable = false
    }
    
    @IBAction func closeCategoryClicked(_ sender: UIButton) {
        self.dismiss(animated: false, completion: nil)
    }
    
    @IBAction func addButtonClicked(_ sender: UIButton) {
        if self.validateCategory() {
            self.updateShopCategory != nil ? self.updateCategoryToServerUsingNetwotk() : self.saveCategoryToServerUsingNetwotk()
        }
        else {
            self.showAlertWithAction(message: Message.createCategoryDuplicate, title: Message.warning, items: [Message.cancel], callback: { index in
            })
        }
    }
    
    @IBAction func onCategoryTextChanges(_ sender: UITextField) {
        self.buttonAdd.backgroundColor = (sender.text ?? Strings.empty).isEmpty ? UIColor(red: 222/255, green: 222/255, blue: 222/255, alpha: 1.0) : .gray
    }
    
}
