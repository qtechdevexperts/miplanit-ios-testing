//
//  PricingViewController.swift
//  MiPlanIt
//
//  Created by Febin Paul on 04/02/21.
//  Copyright © 2021 Arun. All rights reserved.
//

import UIKit
import StoreKit
//qweqwe
protocol PricingViewControllerDelegate: class {
    func pricingViewController(_ pricingViewController: PricingViewController, purchaseStatus: Bool)
}

class PricingViewController: SwipeDrawerViewController {
    
    var activeProduct: SKProduct?
    var activeProduct2: SKProduct?
    var priceFormat: String?
    var priceFormat2: String?
    var isAlreadySubscribed: Bool = false
    var isAlreadySubscribed2: Bool = false
    weak var delegate: PricingViewControllerDelegate?
    
    @IBOutlet weak var viewTest: UIView!
    @IBOutlet weak var btnMenu: UIButton!
    @IBOutlet weak var buttonClose: UIButton!
    @IBOutlet weak var buttonRestore: ProcessingButton!
    @IBOutlet weak var viewGradientLayer1: UIView!
    @IBOutlet weak var viewButtonGradientLayer: UIView!
    @IBOutlet weak var labelBuyTopName: UILabel!
    @IBOutlet weak var labelBuyTopName2: UILabel!
    @IBOutlet weak var labelBuyBottomName: UILabel!
    @IBOutlet weak var labelBuyBottomName2: UILabel!
    @IBOutlet weak var activityIndicatorPrice: UIActivityIndicatorView!
    @IBOutlet weak var activityIndicatorPrice2: UIActivityIndicatorView!
    @IBOutlet weak var labelTopPriceCaption: UILabel!
    @IBOutlet weak var viewPriceContainer: UIView!
    @IBOutlet weak var viewPriceContainer2: UIView!
    @IBOutlet weak var buttonPurchase: ProcessingButton!
    @IBOutlet weak var buttonPurchase2: ProcessingButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.setView()
        self.intiatePricingProducts()
        self.autoRenewSubscription()


    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.initiateView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    override func viewWillAppear(_ animated: Bool) {
        btnMenu.isHidden = isMenu == true ? true:false
        buttonClose.isHidden = isMenu == true ? false:true
    }
    
    @IBAction func restoreButtonClicked(_ sender: UIButton) {
        self.buttonRestore.startAnimation()
        InAppPurchase.shared.restoreInAppPurchase { (status, date, transactionIdExist, error) in
            DispatchQueue.main.async {
                if transactionIdExist ?? false {
                    self.switchTransactionToUser(onPurchase: false)
                }
                else if let purchaseStatusFlag = status, purchaseStatusFlag {
                    self.donePurchaseUpdateButton(sender as! ProcessingButton, expiryDate: date)
                }
                else {
                    self.cancelPurchaseUpdateButton(with: error, button: sender as! ProcessingButton)
                }
            }
        }
    }
    
    @IBAction func buyButtonClicked(_ sender: UIButton) {
        showAlertWithTwoButtons(inViewController: self, title: "Alert!", message: "Are You sure to buy Yearly Subscription?") {
            guard let skProduct = self.activeProduct, let priceFormat = self.priceFormat else { return }
            self.showPricingLoader()
            InAppPurchase.shared.purchaseProduct(skProduct, format: priceFormat) { (response, date, transactionIdExist, error) in
                DispatchQueue.main.async {
                    if transactionIdExist ?? false {
                        self.switchTransactionToUser(onPurchase: true)
                    }
                    else if let status = response, status {
                        self.donePurchaseUpdateButton(sender as! ProcessingButton, expiryDate: date)
                    }
                    else {
                        self.cancelPurchaseUpdateButton(with: error, button: sender as! ProcessingButton)
                    }
                }
            }
        }
    }
    
    @IBAction func btnPurchaseMonthlySubscriptionClicked(_ sender: UIButton) {
        showAlertWithTwoButtons(inViewController: self, title: "Alert!", message: "Are You sure to buy Monthly Subscription?") {
            guard let skProduct2 = self.activeProduct2, let priceFormat2 = self.priceFormat2 else { return }
            self.showPricingLoader2()
            InAppPurchase.shared.purchaseProduct(skProduct2, format: priceFormat2) { (response, date, transactionIdExist, error) in
                DispatchQueue.main.async {
                    if transactionIdExist ?? false {
                        self.switchTransactionToUser2(onPurchase: true)
                    }
                    else if let status = response, status {
                        self.donePurchaseUpdateButton2(sender as! ProcessingButton, expiryDate: date)
                    }
                    else {
                        self.cancelPurchaseUpdateButton2(with: error, button: sender as! ProcessingButton)
                    }
                }
            }
        }
    }
    
    
    @IBAction func privacyPolicyTapped(_ sender: UIButton) {
        self.openURL(URL(string: Strings.privacyPolicyLink))
    }
    
    @IBAction func termsConditionsTapped(_ sender: UIButton) {
        self.openURL(URL(string: Strings.termsLink))
    }
    
    @IBAction func closeButtonClicked(_ sender: UIButton) {
        isMenu = false
        Session.shared.updateInitialPricingPopUp(with: true)
        self.dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.destination {
        case is MessageViewController:
            let messageViewController = segue.destination as! MessageViewController
            messageViewController.caption = (sender as? [String])?.first
            messageViewController.errorDescription = (sender as? [String])?.last
        default: break
        }
    }
    
}
