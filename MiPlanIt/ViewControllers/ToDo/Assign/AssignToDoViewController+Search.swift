//
//  AssignViewController+Search.swift
//  MiPlanIt
//
//  Created by Febin Paul on 10/07/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

extension AssignToDoViewController: UITextFieldDelegate {
   
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        textField.returnKeyType = ((textField.text?.isEmpty ?? Strings.empty.isEmpty || (range.length == 1 && range.location == 0)) && string.isEmpty) ? .default : .done
        textField.reloadInputViews()
        return true
    }
    
    @objc func searchUsersListWithText(_ text: String?) {
        let searchText = text ?? Strings.empty
//        self.buttonCloseSearch.isHidden = searchText.isEmpty
        self.labelSuggustedUser.isHidden = !searchText.isEmpty
        let allBalanceUsers = self.readAllBalanceUsers()
        if searchText.isEmpty {
            self.filteredUsers = allBalanceUsers.map({ AssignUser(calendarUser: $0) })
        }
        else {
            self.filteredUsers = allBalanceUsers.filter({ return $0.name.range(of: searchText, options: .caseInsensitive) != nil || $0.email.range(of: searchText, options: .caseInsensitive) != nil || $0.phone.range(of: searchText, options: .caseInsensitive) != nil }).map({ AssignUser(calendarUser: $0) })
        }
        self.viewNewEmail.isHidden = !(self.filteredUsers.isEmpty && searchText.validateEmail())
        if self.filteredUsers.isEmpty && searchText.validateEmail() {
            self.labelNewEmail.text = searchText
        }
        self.collectionView?.reloadData()
    }
}

