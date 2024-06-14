//
//  AddNewCategoryViewController+Callback.swift
//  MiPlanIt
//
//  Created by Febin Paul on 09/11/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

extension AddNewCategoryViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}
