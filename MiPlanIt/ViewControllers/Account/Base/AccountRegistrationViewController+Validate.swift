//
//  AccountRegistrationViewController+Validate.swift
//  MiPlanIt
//
//  Created by Nikhil RajG on 17/03/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

extension AccountRegistrationViewController: UITextFieldDelegate {
    
    func isContainsAnyErrorHint() -> Bool {
        return self.viewsHints.map({$0.isErrorHint}).contains(true)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.scrollView.layoutIfNeeded()
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField == self.textFieldPassword, let password = self.textFieldPassword.text, (password.isEmpty || !self.isContainsAnyErrorHint()) {
            self.setPasswordHintView(show: false)
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == self.textFieldPassword {
            self.setPasswordHintView(show: true)
            self.validatePasswordHint()
        }
    }
    
    func validatePasswordHint() {
        guard let string = self.textFieldPassword.text else {
            return
        }
        self.updatePasswordHintUI(with: string.checkPasswordValidation())
    }
    
    func updatePasswordHintUI(with hints: [PasswordHintNames]) {
        if hints.isEmpty {
            self.changeViewHint(0, status: nil)
            return
        }
        for eachHint in hints {
            switch eachHint {
            case .contains8Charecter(let status):
                self.changeViewHint(0, status: status)
            case .containsSpecialCharecter(let status):
                self.changeViewHint(2, status: status)
            case .containsNumber(let status):
                self.changeViewHint(1, status: status)
            case .containsUppercase(let status):
                self.changeViewHint(3, status: status)
            case .containsLowercase(let status):
                self.changeViewHint(4, status: status)
            }
        }
    }
    
    func changeViewHint(_ index: Int, status: Bool?) {
        guard let statusHint = status else {
            for (index, eachHint) in self.viewsHints.enumerated() {
                eachHint.setDefaultView(with: index)
            }
            return
        }
        statusHint ? self.viewsHints[index].setRightView() : self.viewsHints[index].setWrongView()
    }
    
    func setPasswordHintView(show: Bool) {
        self.constraintPasswordHintHeight.constant = show ? 122 : 0
        if show { self.scrollView.contentOffset.y +=  100.0 }
        self.scrollView.layoutIfNeeded()
        self.viewPasswordHint.isHidden = !show
    }
    
    func validateMandatoryFields() -> Bool {
        self.view.endEditing(true)
        var userNameStatus = false
        var passwordStatus = false
        var phoneEmailStatus = false
        var confirmPasswordStatus = false
        do {
           userNameStatus = try self.textFieldName.validateTextWithType(.username)
        } catch {
            guard let validationError = error as? ValidationError else { return false }
            self.textFieldName.showError(validationError.message, animated: true)
        }
        do {
            phoneEmailStatus = try self.textFieldMobileOrPhone.validateTextWithType(self.buttonPhoneSelection.isSelected ? .phoneNumber : .email)
        } catch {
            guard let validationError = error as? ValidationError else { return false }
            self.textFieldMobileOrPhone.showError(validationError.message, animated: true)
        }
        do {
            passwordStatus = try self.textFieldPassword.validateTextWithType(.password)
        } catch {
            guard let validationError = error as? ValidationError else { return false }
            self.textFieldPassword.showError(validationError.message, animated: true)
        }
        do {
            confirmPasswordStatus = try self.textFieldConfirm.validateTextWithType(.password)
        } catch {
            guard let validationError = error as? ValidationError else { return false }
            self.textFieldConfirm.showError(validationError.message, animated: true)
        }
        if self.textFieldPassword.text != self.textFieldConfirm.text, passwordStatus, confirmPasswordStatus {
            confirmPasswordStatus = false
            self.textFieldConfirm.showError(Message.passwordMismatch, animated: true)
        }
        if passwordStatus && self.isContainsAnyErrorHint() {
            passwordStatus = false
            self.textFieldPassword.showError(Strings.empty, animated: true)
        }
        return userNameStatus && passwordStatus && phoneEmailStatus && confirmPasswordStatus
    }
    
}
