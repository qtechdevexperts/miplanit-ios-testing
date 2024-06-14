//
//  UpdatePasswordViewController+Action.swift
//  MiPlanIt
//
//  Created by MS Nischal on 17/03/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

extension UpdatePasswordViewController {
    
    func sendNewPasswordToAWSServer() {
        guard let newPassword = self.textFieldNewPassword.text else { return }
        self.buttonResetPassword.startAnimation()
        AWSRequest().confirmForgotPasswordWithAWS(username: self.username, newPassword: newPassword, confirmationCode: self.getOTPCode()) { (awsresponse, error) in
            if let response = awsresponse, response.status == .success {
                self.forceSignOutUserFromAWSServer()
            }
            else if let error = error {
                self.buttonResetPassword.stopAnimation(animationStyle: .shake, revertAfterDelay: 0) {
                    self.performSegue(withIdentifier: Segues.toMessageScreen, sender: [Message.error, error.message])
                }
            }
        }
    }
    
    func forceSignOutUserFromAWSServer() {
        AWSRequest().signOutAWS(callback: { _, _ in
            self.buttonResetPassword.clearButtonTitleForAnimation()
            self.buttonResetPassword.stopAnimation(animationStyle: .normal, revertAfterDelay: 0) {
                self.buttonResetPassword.showTickAnimation { (result) in
                    self.navigationController?.popToRootViewController(animated: true)
                }
            }
        })
    }
    
    func sendOTPToAWSServerUsingUserName() {
        AWSRequest().forgotPasswordWithAWS(username: self.username) { (awsResponse, error) in
            if let response = awsResponse, response.status == .success {
                self.performSegue(withIdentifier: Segues.toMessageScreen, sender: [Message.success, Message.resendOTP])
            }
            else if let error = error {
                self.performSegue(withIdentifier: Segues.toMessageScreen, sender: [Message.error, error.message])
            }
        }
    }
}
