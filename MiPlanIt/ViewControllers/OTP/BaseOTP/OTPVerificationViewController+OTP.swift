//
//  OTPVerificationViewController+Delegate.swift
//  MiPlanIt
//
//  Created by Febin Paul on 17/03/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation
import UIKit


extension OTPVerificationViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if(textField.tag != 100) {
            guard let index = self.textFieldOTP.firstIndex(of: textField as! OTPTextField) else { return false }
            guard let currentText = textField.text, currentText.isEmpty, string.isEmpty else {
                self.textFieldOTP[index].text = string
                guard index + 1 < self.textFieldOTP.count, !string.isEmpty else { if index + 1 == self.textFieldOTP.count && !string.isEmpty { self.view.endEditing(true) };  return false }
                self.textFieldOTP[index + 1].becomeFirstResponder()
                return false }
            guard index - 1 >= 0 else { self.view.endEditing(true);  return false }
            self.textFieldOTP[index].text = Strings.empty
            self.textFieldOTP[index - 1].becomeFirstResponder()
            return false
        }
        return true
    }
}

extension OTPVerificationViewController: OTPTextFieldDelegate {
    
    func textField(_ textField: OTPTextField, with otp: String) {
        guard otp.count == 6 else { return }
        for index in 0 ..< otp.count { self.textFieldOTP[index].text = otp[index] }
    }
}
