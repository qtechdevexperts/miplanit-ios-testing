//
//  CountrySelectionViewController+Delegate.swift
//  MiPlanIt
//
//  Created by Nikhil RajG on 17/03/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

extension CountrySelectionViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let searchText = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) ?? Strings.empty
        if searchText.isEmpty {
            self.showingCountries = self.countries
        }
        else {
            let searchResult = self.countries.filter({ return $0.name.range(of: searchText, options: .caseInsensitive) != nil || $0.code.range(of: searchText, options: .caseInsensitive) != nil})
            self.showingCountries = searchResult
        }
        return true
    }
}
