//
//  LoginViewController+textFieldDelegate.swift
//  MiPlanIt
//
//  Created by Febin Paul on 17/03/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

extension LoginViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        self.validateLoginButtonWithStatus(false)
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.textFieldUsername {
            self.textFieldPassword.becomeFirstResponder()
        }
        else {
            textField.resignFirstResponder()
        }
        return true
    }
    
    func validateMandatoryFields() -> Bool {
        self.view.endEditing(true)
        var userNameStatus = false
        var passWordStatus = false
        let userNameValidationType: ValidatorType = self.buttonLoginSelection.isSelected ? .email : .phoneNumber
        do {
            userNameStatus = try self.textFieldUsername.validateTextWithType(userNameValidationType)
        } catch {
            guard let validationError = error as? ValidationError else { return false }
            self.textFieldUsername.showError(validationError.message, animated: true)
        }
        do {
            passWordStatus = try self.textFieldPassword.validateTextWithType(.password)
        } catch {
            guard let validationError = error as? ValidationError else { return false }
            self.textFieldPassword.showError(validationError.message, animated: true)
        }
        return userNameStatus && passWordStatus
    }
    
    func validateLoginButtonWithStatus(_ status: Bool) {
        self.buttonLogin.isHidden = status
        self.buttonVerifyUser.isHidden = !status
    }
}
