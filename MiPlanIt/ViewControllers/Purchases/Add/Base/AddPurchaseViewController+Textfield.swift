//
//  AddPurchaseViewController+Textfield.swift
//  MiPlanIt
//
//  Created by Febin Paul on 15/04/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation
import UIKit
import IQKeyboardManagerSwift


extension AddPurchaseViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        IQKeyboardManager.shared.enableAutoToolbar = true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        IQKeyboardManager.shared.enableAutoToolbar = false
        guard let text = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !text.isEmpty else { return }
        switch textField {
        case self.txtfldProductName:
            self.purchaseModel.setProductName(text)
        case self.txtfldStoreName:
            self.purchaseModel.setStoreName(text)
        case self.textFieldLocation:
            _=self.purchaseModel.setLocation(text)
        case self.txtfldPrice:
            self.purchaseModel.setAmount(text)
        default: break
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func validateInputFields() -> Bool {
        self.view.endEditing(true)
        var productNameStatus = false
//        var storeLocationStatus = false
        var amountStatus = false
        var billDateStatus = false
        var storeName = false
        do {
           productNameStatus = try self.txtfldProductName.validateTextWithType(.productName)
        } catch {
            guard let validationError = error as? ValidationError else { return false }
            self.txtfldProductName.showError(validationError.message, animated: true)
        }
//        do {
//            storeLocationStatus = try self.textFieldLocation.validateTextWithType(.location)
//        } catch {
//            guard let validationError = error as? ValidationError else { return false }
//            self.textFieldLocation.showError(validationError.message, animated: true)
//        }
        do {
            storeName = try self.txtfldStoreName.validateTextWithType(.storeName)
        } catch {
            guard let validationError = error as? ValidationError else { return false }
            self.txtfldStoreName.showError(validationError.message, animated: true)
        }
        do {
            amountStatus = try self.txtfldPrice.validateTextWithType(.amount)
        } catch {
            guard let validationError = error as? ValidationError else { return false }
            self.txtfldPrice.showError(validationError.message, animated: true)
        }
        
        do {
            billDateStatus = try self.labelBillDate.validateTextWithType(.billDate)
        } catch {
            guard let validationError = error as? ValidationError else { return false }
            self.viewBillBorder.backgroundColor = .red
            self.labelBillDateError.isHidden = validationError.message.isEmpty
        }
        
        return productNameStatus /*&& storeLocationStatus */&& amountStatus && billDateStatus && storeName
    }
}

extension AddPurchaseViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        IQKeyboardManager.shared.enableAutoToolbar = true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        IQKeyboardManager.shared.enableAutoToolbar = false
        self.purchaseModel.purchaseDescription = textView.text
    }
}
