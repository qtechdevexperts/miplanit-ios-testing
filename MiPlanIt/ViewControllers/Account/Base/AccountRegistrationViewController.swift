//
//  AccountRegistrationViewController.swift
//  MiPlanIt
//
//  Created by Nikhil RajG on 16/03/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

class AccountRegistrationViewController: UIViewController {
        
    // MARK:- Outlets
    @IBOutlet weak var buttonSignUp: ProcessingButton!
    @IBOutlet weak var buttonCountryCode: UIButton!
    @IBOutlet weak var buttonEmailSelection: UIButton!
    @IBOutlet weak var buttonPhoneSelection: UIButton!
    @IBOutlet weak var textFieldName: FloatingTextField!
    @IBOutlet weak var textFieldPassword: FloatingTextField!
    @IBOutlet weak var textFieldConfirm: FloatingTextField!
    @IBOutlet weak var textFieldMobileOrPhone: FloatingTextField!
    @IBOutlet weak var widthConstraintOfCountryCode: NSLayoutConstraint!
    @IBOutlet weak var viewCountryHolder: UIView!
    @IBOutlet weak var buttonFBUser: UIButton!
    @IBOutlet weak var buttonGoogleUser: UIButton!
    @IBOutlet weak var buttonTwitterUser: UIButton!
    @IBOutlet weak var viewPasswordHint: UIView!
    @IBOutlet weak var constraintPasswordHintHeight: NSLayoutConstraint!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet var viewsHints: [PasswordHintView]!
    @IBOutlet weak var buttonAppleUser: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initializeView()
        buttonSignUp.setType(type: .primary)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.view.isUserInteractionEnabled = true
        super.viewWillAppear(animated)
    }
    
    
    // MARK:- IBAction
    
    @IBAction func passwordEditChanges(_ sender: UITextField) {
        self.validatePasswordHint()
    }
    
    
    @IBAction func backButtonClicked(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func signUpButtonClicked(_ sender: UIButton) {
        if self.validateMandatoryFields() {
            self.showAlertWithAction(message: Message.signUpConfirm(self.readUserAccountName()), title: Message.confirm, items: [Message.yes, Message.no], callback: { index in
                if index == 0 {
                    self.textFieldPassword.hideError(true)
                    self.textFieldConfirm.hideError(true)
                    self.callWebServiceForUserAlreadyExist()
                }
            })
        }
    }
    
    @IBAction func socialLoginButtonClicked(_ sender: UIButton) {
        guard let userType = UserType(rawValue: sender.tag) else { return }
        self.registerUserWithSocial(userType)
    }
    
    @IBAction func emailButtonClicked(_ sender: UIButton) {
        sender.isSelected = true
        self.buttonPhoneSelection.isSelected = false
        self.showOrHidePhoneCountryCode(true)
        self.showOrHidePhoneEmailSection(true)
    }
    
    @IBAction func phoneNumberButtonClicked(_ sender: UIButton) {
        sender.isSelected = true
        self.buttonEmailSelection.isSelected = false
        self.showOrHidePhoneCountryCode(false)
        self.showOrHidePhoneEmailSection(false)
    }
    
    @IBAction func passwordShowOrHideButtonTouched(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        self.textFieldPassword.isSecureTextEntry = !sender.isSelected
    }
    
    @IBAction func confirmPasswordShowOrHideButtonTouched(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        self.textFieldConfirm.isSecureTextEntry = !sender.isSelected
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.destination {
        case is CountrySelectionViewController:
            let countrySelectionViewController =  segue.destination as! CountrySelectionViewController
            countrySelectionViewController.delegate = self
        case is RegisterOTPVerificationViewController:
            let registerOTPVerificationViewController =  segue.destination as! RegisterOTPVerificationViewController
            registerOTPVerificationViewController.username = self.readUserAccountName()
            registerOTPVerificationViewController.password = self.textFieldPassword.text
            registerOTPVerificationViewController.countryCode = self.readSelectedCountryCodeOfPhone()
        case is MessageViewController:
            let messageViewController = segue.destination as! MessageViewController
            messageViewController.caption = (sender as? [String])?.first
            messageViewController.errorDescription = (sender as? [String])?.last
        default:
            break
        }
    }
}
