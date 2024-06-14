//
//  GiftFilterViewController.swift
//  MiPlanIt
//
//  Created by Aneesh Asokan on 03/05/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

protocol GiftFilterViewControllerDelegate: class {
    func giftFilterViewController(_ viewController: GiftFilterViewController, filters: [Filter])
}

class GiftFilterViewController: UIViewController {
    
    @IBOutlet weak var txtfldCouponName: FloatingTextField!
    @IBOutlet weak var txtfldCouponCode: FloatingTextField!
    @IBOutlet weak var txtfldCouponID: FloatingTextField!
    @IBOutlet weak var txtfldReceivedFrom: FloatingTextField!
    @IBOutlet weak var txtfldIssuedBy: FloatingTextField!
    @IBOutlet weak var buttonCouponName: UIButton!
    @IBOutlet weak var buttonCouponCode: UIButton!
    @IBOutlet weak var buttonCouponID: UIButton!
    @IBOutlet weak var buttonReceivedFrom: UIButton!
    @IBOutlet weak var buttonIssuedBy: UIButton!
    @IBOutlet weak var buttonResetFilter: UIButton!
    var selectedButtonTag: Int = 0
    weak var delegate: GiftFilterViewControllerDelegate?
    var giftCoupons: [PlanItGiftCoupon] = [] {
        didSet {
            
        }
    }
    var selectedFilters: [Filter] = [] {
        didSet {
            
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateResetButtonStatus()
        self.updateExistingFilters()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func backButtonClicked(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func applyButtonClicked(_ sender: UIButton) {
        let filters = self.getFiltersFromTextFields()
        self.delegate?.giftFilterViewController(self, filters: filters)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func resetButtonClicked(_ sender: UIButton) {
        self.delegate?.giftFilterViewController(self, filters: [])
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func dropdownButtonClicked(_ sender: UIButton) {
        self.view.endEditing(true)
        self.selectedButtonTag = sender.tag
        self.performSegue(withIdentifier: Segues.toFilterDropDown, sender: sender)
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.destination {
        case is FilterDropDownViewController:
        let filterDropDownViewController = segue.destination as! FilterDropDownViewController
        filterDropDownViewController.dropDownOptions = self.getValuesForDropDown(sender: sender as! UIButton)
        filterDropDownViewController.delegate = self
        default: break
        }
        
    }

}
