//
//  PaymentTypeViewController+Textfield.swift
//  MiPlanIt
//
//  Created by Aneesh Asokan on 13/05/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

extension PaymentTypeViewController: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == self.txtCardNumber, let text = self.txtCardNumber.text, text.isEmpty {
            self.txtCardNumber.text = "XXXX-XXXX-XXXX-"
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == self.txtCardNumber {
            IQKeyboardManager.shared.enableAutoToolbar = true
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == self.txtCardNumber {
            IQKeyboardManager.shared.enableAutoToolbar = false
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        _ = textField == self.txtCardName ? self.txtCardNumber.becomeFirstResponder() : textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard textField == self.txtCardNumber else {
            return true
        }
        let newPosition = textField.endOfDocument
        textField.selectedTextRange = textField.textRange(from: newPosition, to: newPosition)
        let minLength = 15
        let maxLength = 19
        let currentString: NSString = textField.text! as NSString
        let newString: NSString =
            currentString.replacingCharacters(in: range, with: string) as NSString
        return newString.length <= maxLength && newString.length >= minLength
    }
}
