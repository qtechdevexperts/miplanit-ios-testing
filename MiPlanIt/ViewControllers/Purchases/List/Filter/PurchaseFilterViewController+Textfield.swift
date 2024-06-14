//
//  PurchaseFilterViewController+Textfield.swift
//  MiPlanIt
//
//  Created by Aneesh Asokan on 10/05/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation
import UIKit
import IQKeyboardManagerSwift

extension PurchaseFilterViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        let txtfld = textField as! FloatingTextField
        txtfld.dropDownInput = false
        IQKeyboardManager.shared.enableAutoToolbar = true
    }

    func textFieldDidEndEditing(_ textField: UITextField)
    {
        IQKeyboardManager.shared.enableAutoToolbar = false
    }
}
