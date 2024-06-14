//
//  GiftFilterViewController.swift
//  MiPlanIt
//
//  Created by Aneesh Asokan on 03/05/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit
protocol PurchaseFilterViewControllerDelegate: class {
    func purchaseFilterViewController(_ viewController: PurchaseFilterViewController, filters: [Filter])
}

class PurchaseFilterViewController: UIViewController {
    
    @IBOutlet weak var txtfldProductName: FloatingTextField!
    @IBOutlet weak var txtfldStoreName: FloatingTextField!
    @IBOutlet weak var txtfldAddress: FloatingTextField!
    @IBOutlet weak var txtfldPaymentType: FloatingTextField!
    @IBOutlet weak var buttonProductName: UIButton!
    @IBOutlet weak var buttonStoreName: UIButton!
    @IBOutlet weak var buttonAddress: UIButton!
    @IBOutlet weak var buttonPaymentType: UIButton!
    @IBOutlet weak var buttonResetFilter: UIButton!
    var selectedButtonTag: Int = 0
    weak var delegate: PurchaseFilterViewControllerDelegate?
    var purchases: [PlanItPurchase] = [] {
        didSet {
            
        }
    }
    
    var selectedFilters: [Filter] = [] {
        didSet {
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        txtfldPaymentType.isUserInteractionEnabled = false
        self.updateResetButtonStatus()
        self.updateExistingFilters()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func backButtonClicked(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func applyButtonClicked(_ sender: UIButton) {
        let filters = self.getFiltersFromTextFields()
        self.delegate?.purchaseFilterViewController(self, filters: filters)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func resetButtonClicked(_ sender: UIButton) {
        self.delegate?.purchaseFilterViewController(self, filters: [])
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func dropdownButtonClicked(_ sender: UIButton) {
        self.view.endEditing(true)
        self.selectedButtonTag = sender.tag
        self.performSegue(withIdentifier: Segues.toPurchaseFilterDropDown, sender: sender)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.destination {
        case is PurchaseFilterDropDownViewController:
        let filterDropDownViewController = segue.destination as! PurchaseFilterDropDownViewController
        filterDropDownViewController.dropDownOptions = self.getValuesForDropDown(sender: sender as! UIButton)
        filterDropDownViewController.delegate = self
        default: break
        }
        
    }
    
}
