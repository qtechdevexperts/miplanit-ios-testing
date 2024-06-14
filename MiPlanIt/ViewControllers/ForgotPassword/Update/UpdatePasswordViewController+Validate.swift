//
//  UpdatePasswordViewController+TextField.swift
//  MiPlanIt
//
//  Created by MS Nischal on 17/03/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

extension UpdatePasswordViewController {
    
    func isContainsAnyErrorHint() -> Bool {
        return self.viewsHints.map({$0.isErrorHint}).contains(true)
    }
    
    func validateMandatoryFields() -> Bool {
        self.view.endEditing(true)
        var passWordStatus = false
        var confirmPassWordStatus = false
        do {
            passWordStatus = try self.textFieldNewPassword.validateTextWithType(.password)
        } catch {
            guard let validationError = error as? ValidationError else { return false }
            self.textFieldNewPassword.showError(validationError.message, animated: true)
        }
        do {
            confirmPassWordStatus = try self.textFieldConfirmPassword.validateTextWithType(.password)
        } catch {
            guard let validationError = error as? ValidationError else { return false }
            self.textFieldConfirmPassword.showError(validationError.message, animated: true)
        }
        if self.textFieldNewPassword.text != self.textFieldConfirmPassword.text, passWordStatus, confirmPassWordStatus {
            confirmPassWordStatus = false
            self.textFieldConfirmPassword.showError(Message.passwordMismatch, animated: true)
        }
        if passWordStatus && self.isContainsAnyErrorHint() {
            passWordStatus = false
            self.textFieldNewPassword.showError(Strings.empty, animated: true)
        }
        return passWordStatus && confirmPassWordStatus
    }
    
    override func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.scrollView.layoutIfNeeded()
        return super.textFieldShouldReturn(textField)
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField == self.textFieldNewPassword, let password = self.textFieldNewPassword.text, (password.isEmpty || !self.isContainsAnyErrorHint()) {
            self.setPasswordHintView(show: false)
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == self.textFieldNewPassword {
            self.setPasswordHintView(show: true)
            self.validatePasswordHint()
        }
    }
    
    func validatePasswordHint() {
        guard let string = self.textFieldNewPassword.text else {
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
}
