//
//  ForgotPasswordViewController+Action.swift
//  MiPlanIt
//
//  Created by Febin Paul on 23/03/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

extension ForgotPasswordViewController {
    
    func sendOTPToAWSServerUsingUserName() {
        self.buttonVerificationCode.startAnimation()
        AWSRequest().forgotPasswordWithAWS(username: self.readUserAccountName()) { (awsResponse, error) in
            if let response = awsResponse, response.status == .success {
                self.buttonVerificationCode.stopAnimation(animationStyle: .normal, revertAfterDelay: 0) {
                    self.performSegue(withIdentifier: Segues.toUpdatePassword, sender: self)
                }
            }
            else if let error = error {
                self.buttonVerificationCode.stopAnimation(animationStyle: .shake, revertAfterDelay: 0) {
                    self.performSegue(withIdentifier: Segues.toMessageScreen, sender: [Message.error, error.message])
                }
            }
        }
    }
}


extension ForgotPasswordViewController: CountrySelectionViewControllerDelegate {
    
    func countrySelectionViewController(_ viewController: CountrySelectionViewController, selectedCode: String) {
        self.buttonCountryCode.setTitle("+\(selectedCode)", for: .normal)
    }
}
