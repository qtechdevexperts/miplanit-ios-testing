//
//  InviteUsersViewController+Collection.swift
//  MiPlanIt
//
//  Created by Febin Paul on 19/05/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation
import UIKit

extension InviteUsersViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if collectionView == self.collectionViewAllUser {
            guard let text = self.textFieldSearchUser.text, text.isEmpty else { return 1 }
            return self.sectionedUser.count
        }
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView {
        case  self.collectionViewAllUser:
            guard let text = self.textFieldSearchUser.text, !text.isEmpty else { return self.sectionedUser[section].count }
            return (self.filteredUsers.isEmpty && text.validateEmail()) ? 1 : self.filteredUsers.count
        case self.collectionViewFullPartiaAccessUser:
            return self.calendar.sortedFullPartialUsers.count
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == self.collectionViewAllUser {
            guard let text = self.textFieldSearchUser.text, !text.isEmpty else { return CGSize(width: self.collectionViewAllUser.frame.width, height: 60.0) }
            return CGSize(width: self.collectionViewAllUser.frame.width, height: 60.0)
        }
        else if collectionView == self.collectionViewFullPartiaAccessUser {
            return CGSize(width: self.collectionViewFullPartiaAccessUser.frame.width, height: 60.0)
        }
        else {
            return CGSize(width: 50.0, height: 50.0)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return self.readCollectionView(collectionView, cellForItemAt: indexPath)
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard collectionView == self.collectionViewAllUser else {
            return
        }
        if let text = self.textFieldSearchUser.text, !text.isEmpty {
            if self.filteredUsers.isEmpty, text.validateEmail() {
                let user = CalendarUser(text)
                if !self.calendarUserAlreadySelected(user: user) {
                    self.calendar.insertNewUser(user, toFullAcess: true)
                }
            }
            else if !self.calendarUserAlreadySelected(user: self.filteredUsers[indexPath.row]) {
                self.calendar.insertNewUser(self.filteredUsers[indexPath.row], toFullAcess: true)
            }
            self.textFieldSearchUser.resignFirstResponder()
        }
        else if !self.calendarUserAlreadySelected(user: self.sectionedUser[indexPath.section][indexPath.row]) {
                self.calendar.insertNewUser(self.sectionedUser[indexPath.section][indexPath.row], toFullAcess: true)
        }
        self.refreshMiPlanItUsersView(index: indexPath, inFullAccess: true)
    }
    
    @objc func readCollectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch collectionView {
        case self.collectionViewAllUser:
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
        default:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifier.listInviteesCell, for: indexPath) as! InviteesCollectionViewCell
            if indexPath.row < self.calendar.sortedFullPartialUsers.count {
                cell.configureCell(calendarUser: self.calendar.sortedFullPartialUsers[indexPath.row], index: indexPath, accessType: .full, delegate: self)
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

