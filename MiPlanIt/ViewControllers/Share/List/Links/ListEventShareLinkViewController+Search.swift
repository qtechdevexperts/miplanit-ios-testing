//
//  ListEventShareLinkViewController+Search.swift
//  MiPlanIt
//
//  Created by Febin Paul on 31/03/21.
//  Copyright © 2021 Arun. All rights reserved.
//


extension ListEventShareLinkViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) ?? Strings.empty
        if self.filterCriteria == nil {
            self.searchListUsingText(text: currentText, baseArray: self.allShareLinks)
        }
        else {
            self.showListBasedOnFilterCriteria(searchText: currentText)
        }
        return true
    }
}
