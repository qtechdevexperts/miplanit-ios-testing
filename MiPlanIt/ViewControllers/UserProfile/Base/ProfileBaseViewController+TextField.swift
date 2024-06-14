//
//  ProfileBaseViewController+TextField.swift
//  MiPlanIt
//
//  Created by MS Nischal on 19/03/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

extension ProfileBaseViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        IQKeyboardManager.shared.enableAutoToolbar = false
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        IQKeyboardManager.shared.enableAutoToolbar = textField.keyboardType == .phonePad
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return true
    }
    
    func validateMandatoryFields() -> Bool {
        self.view.endEditing(true)
        var emailStatus = false
        var phoneStatus = false
        var userNameStatus = false
        do {
            userNameStatus = try self.textFieldName.validateTextWithType(.username)
        } catch {
            guard let validationError = error as? ValidationError else { return false }
            self.textFieldName.showError(validationError.message, animated: true)
        }
        do {
            if let emailText = self.textFieldEmail.text, !emailText.isEmpty {
                emailStatus = try self.textFieldEmail.validateTextWithType(.email)
            } else { emailStatus = true }
        } catch {
            guard let validationError = error as? ValidationError else { return false }
            self.textFieldEmail.showError(validationError.message, animated: true)
        }
        do {
            if let phoneText = self.textFieldPhone.text, !phoneText.isEmpty {
                phoneStatus = try self.textFieldPhone.validateTextWithType(.phoneNumber)
            } else { phoneStatus = true }
        } catch {
            guard let validationError = error as? ValidationError else { return false }
            self.textFieldPhone.showError(validationError.message, animated: true)
        }
        return emailStatus && phoneStatus && userNameStatus
    }
}
