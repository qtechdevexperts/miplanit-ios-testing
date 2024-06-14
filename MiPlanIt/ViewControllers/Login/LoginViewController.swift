//
//  LoginViewController.swift
//  MiPlanIt
//
//  Created by Febin Paul on 16/03/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
     //MARK: - Outlets
    @IBOutlet weak var textFieldUsername: FloatingTextField!
    @IBOutlet weak var textFieldPassword: FloatingTextField!
    @IBOutlet weak var buttonLogin: ProcessingButton!
    @IBOutlet weak var buttonVerifyUser: ProcessingButton!
    @IBOutlet weak var buttonFBUser: UIButton!
    @IBOutlet weak var buttonGoogleUser: UIButton!
    @IBOutlet weak var buttonTwitterUser: UIButton!
    @IBOutlet weak var buttonCountryCode: UIButton!
    @IBOutlet weak var buttonLoginSelection: UIButton!
    @IBOutlet weak var widthConstraintOfCountryCode: NSLayoutConstraint!
    @IBOutlet weak var buttonAppleUser: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initializeView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.view.isUserInteractionEnabled = true
        super.viewWillAppear(animated)
    }

    //MARK: - IBActions
    @IBAction func backButtonClicked(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func loginButtonClicked(_ sender: ProcessingButton) {
        if self.validateMandatoryFields() {
            self.sendUserLoginToAWSServer()
        }
    }
    
    @IBAction func verifyButtonClicked(_ sender: Any) {
        if self.validateMandatoryFields() {
            self.sendOTPToAWSServerUsingUserName()
        }
    }
    
    @IBAction func facebookLoginClicked(_ sender: UIButton) {
        self.startSocialIconAnimation(.facebook)
        SocialManager.default.loginFacebookFromViewController(self, using: ConfigureKeys.FBClientKey, result: self)
    }
    
    @IBAction func googleLoginClicked(_ sender: UIButton) {
        self.startSocialIconAnimation(.google)
        SocialManager.default.loginGoogleFromViewController(self, client: ConfigureKeys.googleClientKey, scopes: ServiceData.googleScope, result: self)
    }
    
    @IBAction func twitterLoginClicked(_ sender: UIButton) {
        self.startSocialIconAnimation(.twitter)
        SocialManager.default.twitterLoginWithConsumerKey(ConfigureKeys.twitterConsumerKey, secretKey: ConfigureKeys.twitterSecretKey, result: self)
    }
    
    @IBAction func appleLoginClicked(_ sender: UIButton) {
        self.startSocialIconAnimation(.apple)
        SocialManager.default.getAppleProviderID(result: self)
    }
    
    @IBAction func loginSelectionButtonClicked(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        self.showOrHidePhoneCountryCode(sender.isSelected)
        self.showOrHidePhoneEmailSection(sender.isSelected)
    }
    
    @IBAction func passwordVisibilityButtonClicked(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        self.textFieldPassword.isSecureTextEntry = !sender.isSelected
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.destination {
        case is RegisterOTPVerificationViewController:
            let registerOTPVerificationViewController =  segue.destination as! RegisterOTPVerificationViewController
            registerOTPVerificationViewController.username = self.readUserAccountName()
            registerOTPVerificationViewController.password = self.textFieldPassword.text
            registerOTPVerificationViewController.countryCode = self.readSelectedCountryCodeOfPhone()
        case is MessageViewController:
            let messageViewController = segue.destination as! MessageViewController
            messageViewController.caption = (sender as? [String])?.first
            messageViewController.errorDescription = (sender as? [String])?.last
        case is CountrySelectionViewController:
            let countrySelectionViewController =  segue.destination as! CountrySelectionViewController
            countrySelectionViewController.delegate = self
        default: break
        }
    }
}
