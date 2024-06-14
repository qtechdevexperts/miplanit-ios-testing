//
//  RegisterOTPVerificationViewController+AWS.swift
//  MiPlanIt
//
//  Created by Arun on 24/03/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

extension RegisterOTPVerificationViewController {
    
    func sendOTPToAWSServerUsingUserName() {
        AWSRequest().resendSignUpCode(username: self.username) { (awsResponse, error) in
            if let response = awsResponse, response.status == .success {
                self.performSegue(withIdentifier: Segues.toMessageScreen, sender: [Message.success, Message.resendOTP])
            }
            else if let error = error {
                self.performSegue(withIdentifier: Segues.toMessageScreen, sender: [Message.error, error.message])
            }
        }
    }
    
    func verifyOTPWithAWSServer(_ otp: String) {
        self.buttonSendOTP.startAnimation()
        AWSRequest().confirmSignUpWithAWS(username: self.username, password: self.password, confirmationCode: otp) { (awsResponse, error) in
            if let response = awsResponse, response.status == .success {
                let socialUser = SocialUser(withAWS: response, phoneCode: self.countryCode)
                self.createServiceToRegisterUser(socialUser)
            }
            else if let error = error {
                self.buttonSendOTP.stopAnimation(animationStyle: .shake, revertAfterDelay: 0) {
                    self.performSegue(withIdentifier: Segues.toMessageScreen, sender: [Message.error, error.message])
                }
            }
        }
    }
}
