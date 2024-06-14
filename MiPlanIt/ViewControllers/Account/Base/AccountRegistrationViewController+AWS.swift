//
//  AccountRegistrationViewController+AWS.swift
//  MiPlanIt
//
//  Created by Arun on 24/03/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation
import Foundation
import AWSMobileClient

extension AccountRegistrationViewController {
    
    func sendNewUserRegistrationToAWSServer() {
        guard let name = self.textFieldName.text, let password = self.textFieldPassword.text else { return }
        AWSRequest().signUpWithAWS(username: self.readUserAccountName(), password: password, attributes: ["name": name]) { (awsResponse, error) in
            if let response = awsResponse, response.status == .success {
                self.buttonSignUp.stopAnimation(animationStyle: .normal, revertAfterDelay: 0) {
                    self.performSegue(withIdentifier: Segues.toVerifyOTP, sender: self)
                }
            }
            else if let error = error {
                if let type = error.errorType {
                    switch type {
                    case .usernameExists(_):
                        self.sendUserLoginToAWSServer()
                        return
                    default:
                        break
                    }
                }
                self.buttonSignUp.stopAnimation(animationStyle: .shake, revertAfterDelay: 0) {
                    self.performSegue(withIdentifier: Segues.toMessageScreen, sender: [Message.error, error.message])
                }
            }
        }
    }
    
    func sendUserLoginToAWSServer() {
        guard let password = self.textFieldPassword.text else { self.buttonSignUp.stopAnimation(); return }
        AWSRequest().signInWithAWS(username: self.readUserAccountName(), password: password) { (awsResponse, error) in
            if let response  = awsResponse, response.status == .success {
                let socialUser = SocialUser(withAWS: response, phoneCode: self.readSelectedCountryCodeOfPhone())
                self.createServiceToRegisterUser(socialUser, alreadyAnimating: true)
            }
            else if let error = error {
                if let type = error.errorType {
                    switch type {
                    case .userNotConfirmed(_):
                        self.sendOTPToAWSServerUsingUserName()
                        return
                    default:
                        break
                    }
                }
                self.buttonSignUp.stopAnimation(animationStyle: .shake, revertAfterDelay: 0) {
                    self.performSegue(withIdentifier: Segues.toMessageScreen, sender: [Message.error, error.message])
                }
            }
        }
    }
    
    func sendOTPToAWSServerUsingUserName() {
        AWSRequest().resendSignUpCode(username: self.readUserAccountName()) { (awsResponse, error) in
            if let response = awsResponse, response.status == .success {
                self.buttonSignUp.stopAnimation(animationStyle: .normal, revertAfterDelay: 0) {
                    self.performSegue(withIdentifier: Segues.toVerifyOTP, sender: self)
                }
            }
            else if let error = error {
                self.buttonSignUp.stopAnimation(animationStyle: .shake, revertAfterDelay: 0) {
                    self.performSegue(withIdentifier: Segues.toMessageScreen, sender: [Message.error, error.message])
                }
            }
        }
    }
}
