//
//  CreateEventsViewController+Textfield.swift
//  MiPlanIt
//
//  Created by Febin Paul on 15/04/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation
import UIKit
import IQKeyboardManagerSwift


extension AddGiftCouponsViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        IQKeyboardManager.shared.enableAutoToolbar = true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        IQKeyboardManager.shared.enableAutoToolbar = false
        guard let text = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) else { return }
        switch textField {
        case self.txtfldCouponName:
            self.giftCouponModel.couponName = text
        case self.txtfldCouponCode:
            self.giftCouponModel.couponCode = text
        case self.txtfldCouponID:
            self.giftCouponModel.couponId = text
        case self.txtfldIssuedBy:
            self.giftCouponModel.issuedBy = text
        case self.txtfldReceivedFrom:
            self.giftCouponModel.recievedFrom = text
        case self.txtfldAmount:
            self.giftCouponModel.couponAmount = text.isEmpty ? "0.0" : text
        default: break
        }
    }
    
    func validateInputFields() -> Bool {
        self.view.endEditing(true)
        var couponNameStatus = false
        do {
           couponNameStatus = try self.txtfldCouponName.validateTextWithType(.couponName)
        } catch {
            guard let validationError = error as? ValidationError else { return false }
            self.txtfldCouponName.showError(validationError.message, animated: true)
        }
        return couponNameStatus
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == txtfldCouponID{
            let currentText = txtfldCouponID.text ?? ""
            guard let stringRange = Range(range, in: currentText) else { return false }
            let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
            return updatedText.count <= 15
        }else{
            return true
        }

    }
}

extension AddGiftCouponsViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        IQKeyboardManager.shared.enableAutoToolbar = true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        IQKeyboardManager.shared.enableAutoToolbar = false
        self.giftCouponModel.couponDescription = textView.text
    }
}
