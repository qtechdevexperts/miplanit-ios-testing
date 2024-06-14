//
//  UserSelectionBaseViewController+Search.swift
//  MiPlanIt
//
//  Created by Nikhil RajG on 08/04/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

extension UserSelectionBaseViewController: UITextFieldDelegate {
   
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func searchUsersListWithText(_ text: String?) {
        let searchText = text ?? Strings.empty
        self.buttonCloseSearch.isHidden = searchText.isEmpty
        if searchText.isEmpty {
            self.filteredUsers = self.readAllBalanceUsers().filter({ !$0.readIdentifier().isEmpty })
        }
        else {
            self.filteredUsers = self.calenderUsers.allUsers.filter({ return !self.calenderUsers.selectedUsers.contains($0) && ($0.name.range(of: searchText, options: .caseInsensitive) != nil || $0.email.range(of: searchText, options: .caseInsensitive) != nil || $0.phone.range(of: searchText, options: .caseInsensitive) != nil) })
        }
        self.collectionViewAllUser?.reloadData()
    }
}
