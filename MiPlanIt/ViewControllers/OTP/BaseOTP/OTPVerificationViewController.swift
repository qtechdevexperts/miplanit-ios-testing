//
//  OTPVerificationViewController.swift
//  MiPlanIt
//
//  Created by Febin Paul on 17/03/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

class OTPVerificationViewController: UIViewController {
    
    var username: String!
    var countryCode: String!

    //MARK: - Outlets
    @IBOutlet weak var labelHeaderCaption: UILabel!
    @IBOutlet weak var buttonSendOTP: ProcessingButton!
    @IBOutlet var textFieldOTP: [OTPTextField]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.manageScreenHeaderTitle()
//        buttonSendOTP.setType(type: .primary)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        IQKeyboardManager.shared.enableAutoToolbar = true
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        IQKeyboardManager.shared.enableAutoToolbar = false
        super.viewWillDisappear(animated)
    }
    
    //MARK: - Override
    func sendOTPToAwsServer() {
        
    }
    
    func reSendOTPToAwsServer() {
        
    }
    
    func incompleteOTPFields() {
        self.textFieldOTP.forEach({ if $0.text == Strings.empty { $0.showError(nil, animated: true) } })
    }
    
    //MARK: IBActions
    @IBAction func backButtonClicked(_ sender: Any) {
        self.backToPreviousScreen()
    }
    
    func backToPreviousScreen() {
        
    }
    
    @IBAction func resendOTP(_ sender: Any) {
        self.reSendOTPToAwsServer()
    }
    
    @IBAction func submitOTP(_ sender: Any) {
        if self.containsAnyEmptyOTPField() {
            self.sendOTPToAwsServer()
        }
        else {
            self.incompleteOTPFields()
        }
    }
}
