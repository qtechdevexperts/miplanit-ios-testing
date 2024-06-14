//
//  UpdatePasswordViewController.swift
//  MiPlanIt
//
//  Created by MS Nischal on 17/03/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

class UpdatePasswordViewController: OTPVerificationViewController {
    
    // MARK:- Outlets
    @IBOutlet weak var textFieldNewPassword: FloatingTextField!
    @IBOutlet weak var textFieldConfirmPassword: FloatingTextField!
    @IBOutlet weak var buttonResetPassword: ProcessingButton!
    @IBOutlet var viewsHints: [PasswordHintView]!
    @IBOutlet weak var constraintPasswordHintHeight: NSLayoutConstraint!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var viewPasswordHint: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buttonResetPassword.setType(type: .primary)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.textFieldOTP.forEach({ $0.text = Strings.empty })
        super.viewWillAppear(animated)
    }
    
    // MARK:- IBAction
    @IBAction func passwordShowOrHideButtonTouched(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        self.textFieldNewPassword.isSecureTextEntry = !sender.isSelected
    }
    
    @IBAction func confirmPasswordShowOrHideButtonTouched(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        self.textFieldConfirmPassword.isSecureTextEntry = !sender.isSelected
    }
    
    @IBAction func passwordEditChanges(_ sender: UITextField) {
        self.validatePasswordHint()
    }
    
    override func reSendOTPToAwsServer() {
        self.sendOTPToAWSServerUsingUserName()
    }
    
    override func backToPreviousScreen() {
        self.navigationController?.popViewController(animated: true)
    }
    
    override func incompleteOTPFields() {
        super.incompleteOTPFields()
        _ = self.validateMandatoryFields()
    }
    
    override func sendOTPToAwsServer() {
        if self.validateMandatoryFields() {
            self.sendNewPasswordToAWSServer()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.destination {
        case is MessageViewController:
            let messageViewController = segue.destination as! MessageViewController
            messageViewController.caption = (sender as? [String])?.first
            messageViewController.errorDescription = (sender as? [String])?.last
        default:
            break
        }
    }
}
