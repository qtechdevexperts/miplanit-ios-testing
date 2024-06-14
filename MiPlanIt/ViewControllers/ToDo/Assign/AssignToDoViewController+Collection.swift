//
//  AssignViewController+Collection.swift
//  MiPlanIt
//
//  Created by Febin Paul on 10/07/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

extension AssignToDoViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let searchText = self.textFieldSearchUser.text, searchText.isEmpty {
            return self.sectionedUser[section].count
        }
        guard let text = self.textFieldSearchUser.text, self.filteredUsers.isEmpty, text.validateEmail() else { return self.filteredUsers.count }
        return 0
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if let searchText = self.textFieldSearchUser.text, !searchText.isEmpty {
            return 1
        }
        return self.sectionedUser.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifier.assignUserCollectionViewCell, for: indexPath) as! AssignUserCollectionViewCell
        if let searchText = self.textFieldSearchUser.text, searchText.isEmpty {
            cell.configCell(index: indexPath, delegate: self, assignUser: self.sectionedUser[indexPath.section][indexPath.row], isSelected: self.isUserSelected(assignUser: self.sectionedUser[indexPath.section][indexPath.row]))
        }
        else {
            cell.configCell(index: indexPath, delegate: self, assignUser: self.filteredUsers[indexPath.row], isSelected: self.isUserSelected(assignUser: self.filteredUsers[indexPath.row]))
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.collectionView.frame.width, height: 60.0)
    }
    
    @objc func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            let reusableview = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: CellIdentifier.assignUserHeaderView, for: indexPath) as! AssignUserHeaderView
            reusableview.labelHeader.text = indexPath.section == 0 ? Strings.suggustedUsers : Strings.otherUsers
            return reusableview
        default: return UICollectionReusableView()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if let searchText = self.textFieldSearchUser.text, !searchText.isEmpty {
            return .zero
        }
        return CGSize(width: collectionView.frame.width, height: 50)
    }
    
}
