//
//  UserSelectionBaseViewController+Collection.swift
//  MiPlanIt
//
//  Created by Febin Paul on 18/05/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

extension  UserSelectionBaseViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if collectionView == self.collectionViewAllUser {
            guard let text = self.textFieldSearchUser.text, text.isEmpty else { return 1 }
            return self.sectionedUser.count
        }
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.collectionViewAllUser {
            guard let text = self.textFieldSearchUser.text, !text.isEmpty else { return self.sectionedUser[section].count }
            return (self.filteredUsers.isEmpty && text.validateEmail()) ? 1 : self.filteredUsers.count
        }
        else {
           return self.calenderUsers.selectedUsers.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == self.collectionViewAllUser {
            guard let text = self.textFieldSearchUser.text, !text.isEmpty else { return CGSize(width: self.collectionViewAllUser.frame.width, height: 60.0) }
            return CGSize(width: self.collectionViewAllUser.frame.width, height: 60.0)
        }
        else {
            return CGSize(width: self.collectionViewSelectedUser.frame.width, height: 60.0)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return self.readCollectionView(collectionView, cellForItemAt: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == self.collectionViewAllUser {
            if let text = self.textFieldSearchUser.text, self.filteredUsers.isEmpty, text.validateEmail() {
                let newUser = CalendarUser(text)
                if self.containsSameUser(user: newUser, onNewEmail: true) { return }
                self.calenderUsers.insertNewUser( CalendarUser(text))
                self.refreshUsersView(index: indexPath)
            }
            else {
                if let text = self.textFieldSearchUser.text, text.isEmpty {
                    if self.containsSameUser(user: self.sectionedUser[indexPath.section][indexPath.row]) { return }
                    self.calenderUsers.insertNewUser(self.sectionedUser[indexPath.section][indexPath.row])
                }
                else {
                    if self.containsSameUser(user: self.filteredUsers[indexPath.row]) { return }
                    self.calenderUsers.insertNewUser(self.filteredUsers[indexPath.row])
                }
                self.refreshUsersView(index: indexPath)
            }
            if let searchText = self.textFieldSearchUser.text, !searchText.isEmpty {
                self.clearSearchButtonClicked(buttonCloseSearch)
            }
            self.textFieldSearchUser.resignFirstResponder()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            let reusableview = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: CellIdentifier.assignUserHeaderView, for: indexPath) as! AssignUserHeaderView
            reusableview.labelHeader.text = indexPath.section == 0 ? Strings.suggustedUsers : Strings.otherUsers
            return reusableview
        default: return UICollectionReusableView()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if collectionView != self.collectionViewAllUser { return .zero }
        if let searchText = self.textFieldSearchUser.text, !searchText.isEmpty {
            return .zero
        }
        return self.sectionedUser[section].isEmpty ? .zero : CGSize(width: collectionView.frame.width, height: 50)
    }
    
    fileprivate func containsSameUser(user: CalendarUser, onNewEmail: Bool = false) -> Bool {
        if onNewEmail, self.calenderUsers.selectedUsers.contains(where: { return $0.email == user.email }) {
            return true
        }
        guard self.calenderUsers.selectedUsers.contains(where: { return $0.readIdentifier() == user.readIdentifier() }) else { return false }
        return true
    }
    
    func readCollectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.collectionViewAllUser {
            var cell: UICollectionViewCell!
            if  let text = self.textFieldSearchUser.text, self.filteredUsers.isEmpty, text.validateEmail() {
                if let inviteesCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifier.addInviteesListCell, for: indexPath) as? InviteesCollectionViewCell {
                    cell = inviteesCollectionViewCell
                    inviteesCollectionViewCell.configureCell(newInviteeId: text)
                }
            }
            else {
                if let searchText = self.textFieldSearchUser.text, searchText.isEmpty {
                    if let inviteesCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: !(self.textFieldSearchUser.text ?? Strings.empty).isEmpty ? CellIdentifier.listInviteesCell : CellIdentifier.userImageCell, for: indexPath) as? InviteesCollectionViewCell {
                        cell = inviteesCollectionViewCell
                        inviteesCollectionViewCell.configureCell(calendarUser: self.sectionedUser[indexPath.section][indexPath.row], index: indexPath, delegate: self)
                    }
                }
                else {
                    if let inviteesCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: !(self.textFieldSearchUser.text ?? Strings.empty).isEmpty ? CellIdentifier.listInviteesCell : CellIdentifier.userImageCell, for: indexPath) as? InviteesCollectionViewCell {
                        cell = inviteesCollectionViewCell
                        inviteesCollectionViewCell.configureCell(calendarUser: self.filteredUsers[indexPath.row], index: indexPath, delegate: self)
                    }
                }
            }
            if !self.containUIDragInteraction(cell.interactions) {
                let dragInteraction = UIDragInteraction(delegate: self)
                dragInteraction.isEnabled = true
                cell.addInteraction(dragInteraction)
                if let longPressRecognizer = cell.gestureRecognizers?.compactMap({ $0 as? UILongPressGestureRecognizer}).first {
                    longPressRecognizer.minimumPressDuration = Numbers.longPressDelay
                }
            }
            return cell
        }
        else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifier.userImageCell, for: indexPath) as! InviteesCollectionViewCell
            if indexPath.row < self.calenderUsers.selectedUsers.count {
                cell.configureCell(calendarUser: self.calenderUsers.selectedUsers[indexPath.row], index: indexPath, delegate: self)
            }
            else {
                cell.configureCellReset()
            }
            return cell
        }
    }
        
    func containUIDragInteraction(_ interations: [UIInteraction]) -> Bool {
        for eachInteraction in interations {
            if eachInteraction is UIDragInteraction {
                return true
            }
        }
        return false
    }
}
