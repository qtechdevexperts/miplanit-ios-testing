//
//  AssignViewController+Callback.swift
//  MiPlanIt
//
//  Created by Febin Paul on 10/07/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

extension AssignToDoViewController: AssignUserCollectionViewCellDelegate {
    
    func assignUserCollectionViewCellDelegate(_ AssignUserCollectionViewCell: AssignUserCollectionViewCell, didSelect index: IndexPath) {
        if let searchText = self.textFieldSearchUser.text, !searchText.isEmpty {
            // fetch from filteredUsers array
            if let selectedUserIndex = self.filteredUsers.firstIndex(where: { (user) -> Bool in
                return user.selectedFlag
            }) {
                self.filteredUsers[selectedUserIndex].selectedFlag = false
            }
            self.selectedUser = self.filteredUsers[index.row]
        }
        else {
            // fetch from sectioned array
            for (index, users) in self.sectionedUser.enumerated() {
                if let selectedUserIndex = users.firstIndex(where: { (user) -> Bool in
                    return user.selectedFlag
                }) {
                    self.sectionedUser[index][selectedUserIndex].selectedFlag = false
                    break
                }
            }
            self.selectedUser = self.sectionedUser[index.section][index.row]
        }
        self.collectionView.reloadData()
        self.assigneSelectedAction()
    }
}
