//
//  ForgotPasswordViewController+TextField.swift
//  MiPlanIt
//
//  Created by MS Nischal on 17/03/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

extension ForgotPasswordViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) ?? ""
        self.buttonVerificationCode.isEnabled = !currentText.isEmpty
        self.buttonVerificationCode.backgroundColor = currentText.isEmpty ? #colorLiteral(red: 0.8588235294, green: 0.8588235294, blue: 0.8588235294, alpha: 1) : #colorLiteral(red: 86/255.0, green: 173/255.0, blue: 189/255.0, alpha: 1.0)
        return true
    }
    
    func validateMandatoryFields() -> Bool {
        self.view.endEditing(true)
        let validationType: ValidatorType = self.buttonLoginSelection.isSelected ? .email : .phoneNumber
        do {
            return try self.textFieldUsername.validateTextWithType(validationType)
        }
        catch {
            guard let validationError = error as? ValidationError else { return false }
            self.textFieldUsername.showError(validationError.message, animated: true)
            return false
        }
    }
}
