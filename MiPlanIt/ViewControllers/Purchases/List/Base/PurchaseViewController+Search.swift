//
//  PurchaseViewController+Search.swift
//  MiPlanIt
//
//  Created by Arun on 11/05/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

extension PurchaseViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) ?? Strings.empty
        if filterCriteria.isEmpty {
            self.searchPurchasesUsingText(text: currentText, baseArray: self.allPurchases)
        }
        else {
            self.showPurchaseBasedOnFilterCriteria(searchText: currentText)
        }
        return true
    }
}
