//
//  PaymentTypeViewController.swift
//  MiPlanIt
//
//  Created by Aneesh Asokan on 02/05/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

protocol PaymentTypeViewControllerDelegate: class {
    func paymentTypeViewController(_ viewController: PaymentTypeViewController, selectedPayement payment: Int, with details: PurchaseCard?)
    func paymentTypeViewController(_ viewController: PaymentTypeViewController, selectedPayement payment: Int, with details: String)
}

class PaymentTypeViewController: UIViewController {
    
    var selectedPayment: Int!
    var selctedCard: PurchaseCard?
    var savedCards: [UserPaymentOption] = []
    var paymentDescription: String = Strings.empty
    weak var delegate: PaymentTypeViewControllerDelegate?
    @IBOutlet weak var buttonIsCash: UIButton!
    @IBOutlet weak var buttonIsCard: UIButton!
    @IBOutlet weak var buttonAddCard: UIButton!
    @IBOutlet weak var txtCardName: FloatingTextField!
    @IBOutlet weak var txtCardNumber: FloatingTextField!
    @IBOutlet weak var viewNewCard: UIView!
    @IBOutlet weak var imageTickMarkCard: UIImageView!
    @IBOutlet weak var imageTickMarkCash: UIImageView!
    @IBOutlet weak var imageTickMarkOther: UIImageView!
    @IBOutlet weak var tableViewCards: UITableView!
    @IBOutlet weak var viewAddCards: UIView!
    @IBOutlet weak var viewSavedCards: UIView!
    @IBOutlet weak var viewAddDesc: UIView!
    @IBOutlet weak var txtDescription: FloatingTextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.readAllPaymentCards()
        self.initialiseUIComponents()
        // Do any additional setup after loading the view.
    }
    

    @IBAction func backButtonClicked(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func selectpaymentType(_ sender: UIButton) {
        self.selectPaymentTypeWith(sender)
    }
    
    @IBAction func addNewCard(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        self.viewNewCard.isHidden = !sender.isSelected
        if self.viewNewCard.isHidden {
            self.txtCardName.text = Strings.empty
            self.txtCardNumber.text = Strings.empty
        }
    }
    
    @IBAction func doneButtonClicked(_ sender: Any) {
        self.updatePaymentType()
    }
}
