//
//  LoginViewController+AWS.swift
//  MiPlanIt
//
//  Created by Arun on 24/03/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

extension LoginViewController {
    
    func sendUserLoginToAWSServer() {
        guard let password = self.textFieldPassword.text else { return }
        self.buttonLogin.startAnimation()
        AWSRequest().signInWithAWS(username: self.readUserAccountName(), password: password) { (awsResponse, error) in
            if let response  = awsResponse, response.status == .success {
                let socialUser = SocialUser(withAWS: response, phoneCode: self.readSelectedCountryCodeOfPhone())
                self.createServiceToLoginUser(socialUser)
            }
            else if let error = error {
                self.buttonLogin.stopAnimation(animationStyle: .shake, revertAfterDelay: 0) {
                    self.validateLoginButtonWithStatus(error.code == ConfigureKeys.awsErrorKey)
                    self.performSegue(withIdentifier: Segues.toMessageScreen, sender: [Message.error, error.message])
                }
            }
        }
    }
    
    func sendOTPToAWSServerUsingUserName() {
        self.buttonVerifyUser.startAnimation()
        AWSRequest().resendSignUpCode(username: self.readUserAccountName()) { (awsResponse, error) in
            if let response = awsResponse, response.status == .success {
                self.buttonVerifyUser.stopAnimation(animationStyle: .normal, revertAfterDelay: 0) {
                    self.performSegue(withIdentifier: Segues.toVerifyOTP, sender: self)
                }
            }
            else if let error = error {
                self.buttonVerifyUser.stopAnimation(animationStyle: .shake, revertAfterDelay: 0) {
                    self.buttonVerifyUser.showTickAnimation { (result) in
                        self.performSegue(withIdentifier: Segues.toMessageScreen, sender: [Message.error, error.message])
                    }
                }
            }
        }
    }
}
