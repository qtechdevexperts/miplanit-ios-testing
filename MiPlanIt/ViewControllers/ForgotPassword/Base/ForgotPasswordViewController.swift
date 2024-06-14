//
//  ForgotPasswordViewController.swift
//  MiPlanIt
//
//  Created by MS Nischal on 17/03/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

class ForgotPasswordViewController: UIViewController {
    
    //MARK: - Outlets
    @IBOutlet weak var buttonVerificationCode: ProcessingButton!
    @IBOutlet weak var textFieldUsername: FloatingTextField!
    @IBOutlet weak var buttonCountryCode: UIButton!
    @IBOutlet weak var buttonLoginSelection: UIButton!
    @IBOutlet weak var widthConstraintOfCountryCode: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.readDefaultCountryCodeOfPhone()
        buttonVerificationCode.setType(type: .primary)
    }
    
    @IBAction func buttonVerificationCodeTouched(_ sender: UIButton) {
        if self.validateMandatoryFields() {
            self.sendOTPToAWSServerUsingUserName()
        }
    }
    
    @IBAction func closeButtonTouched(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func loginSelectionButtonClicked(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        self.showOrHidePhoneCountryCode(sender.isSelected)
        self.showOrHidePhoneEmailSection(sender.isSelected)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.destination {
        case is MessageViewController:
            let messageViewController = segue.destination as! MessageViewController
            messageViewController.caption = (sender as? [String])?.first
            messageViewController.errorDescription = (sender as? [String])?.last
        case is UpdatePasswordViewController:
        let updatePasswordViewController =  segue.destination as! UpdatePasswordViewController
        updatePasswordViewController.username = self.readUserAccountName()
        updatePasswordViewController.countryCode = self.readSelectedCountryCodeOfPhone()
        case is CountrySelectionViewController:
            let countrySelectionViewController =  segue.destination as! CountrySelectionViewController
            countrySelectionViewController.delegate = self
        default:
            break
        }
    }
}
