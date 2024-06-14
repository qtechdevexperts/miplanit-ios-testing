//
//  InviteUsersViewController+Search.swift
//  MiPlanIt
//
//  Created by Nikhil RajG on 11/04/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

extension InviteUsersViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func searchUsersListWithText(_ text: String?) {
        let searchText = text ?? Strings.empty
        self.buttonClearSearch.isHidden = searchText.isEmpty
        if searchText.isEmpty {
            self.filteredUsers = self.readAllBalanceMiPlanItUser().filter({ !$0.readIdentifier().isEmpty })
        }
        else {
            let searchResult = self.readAllBalanceMiPlanItUser().filter({ return $0.name.range(of: searchText, options: .caseInsensitive) != nil || $0.email.range(of: searchText, options: .caseInsensitive) != nil || $0.phone.range(of: searchText, options: .caseInsensitive) != nil })
            self.filteredUsers = searchResult
        }
        self.collectionViewAllUser.reloadData()
    }
}
