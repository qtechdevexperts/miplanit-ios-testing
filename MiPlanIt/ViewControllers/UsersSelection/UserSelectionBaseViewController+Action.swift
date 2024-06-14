//
//  UserSelectionBaseViewController+Action.swift
//  MiPlanIt
//
//  Created by Nikhil RajG on 09/04/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

extension UserSelectionBaseViewController {
    
    func initialiseUIComponent() {
        self.labelTitle?.text = self.readPageTitle()
        self.labelTableHeader.text = self.readTableTitle()
        self.textFieldSearchUser.placeholder = self.readPlaceHolder()
        let dropInteractionUserSelected = UIDropInteraction(delegate: self)
        self.collectionViewSelectedUser.addInteraction(dropInteractionUserSelected)
        self.textFieldSearchUser.attributedPlaceholder = Strings.addUsers.attributedPlaceholder(subtext: Strings.placeHolderSubString)
    }
    
    @objc func contactFetchedConpleted(_ notify: Notification) {
        DispatchQueue.main.async {
            self.calenderUsers.allUsers = Session.shared.allContactUser
            self.stopContactFetching()
            self.refreshUsersView()
        }
    }
    
    func readAllBalanceUsers() -> [CalendarUser] {
        return self.calenderUsers.allUsers.filter({ return !self.calenderUsers.selectedUsers.contains($0) })
    }
    
    func refreshUsersView(index: IndexPath? = nil, whileRemoving: Bool = false) {
        let allBalanceUsers = self.readAllBalanceUsers()
        if let searchText = self.textFieldSearchUser.text, !searchText.isEmpty {
            self.filteredUsers = allBalanceUsers.filter({ return ($0.name.range(of: searchText, options: .caseInsensitive) != nil || $0.email.range(of: searchText, options: .caseInsensitive) != nil || $0.phone.range(of: searchText, options: .caseInsensitive) != nil) })
        }
        else {
            self.filteredUsers = allBalanceUsers.filter({ !$0.readIdentifier().isEmpty })
        }
        if let indexPath = index, self.filteredUsers.count > 0 {
            self.collectionViewAllUserRemoval(at: indexPath)
        }
        else if whileRemoving {
            self.collectionViewAllUserReload()
        }
        else {
            self.collectionViewAllUser?.reloadData()
        }
        self.cellectionViewSelectedUserChange()
        self.labelNoUserSelected?.isHidden = !self.calenderUsers.selectedUsers.isEmpty
    }
    
    func collectionViewAllUserRemoval(at index: IndexPath?) {
        self.collectionViewAllUser?.reloadData()
    }
    
    func collectionViewAllUserReload() {
        self.collectionViewAllUser.performBatchUpdates({
            UIView.animate(withDuration: 0.8, delay: 0.0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.9, options: UIView.AnimationOptions.curveEaseInOut, animations: {
                if self.sectionedUser.count > 1 && self.collectionViewAllUser.numberOfSections > 0 {
                    (self.collectionViewAllUser.numberOfSections > 1) ? self.collectionViewAllUser.reloadSections([0, 1]) : self.collectionViewAllUser.reloadSections(IndexSet(integer: 0))
                }
            }, completion: nil)
        }, completion: nil)
    }
    
    func cellectionViewSelectedUserChange() {
        guard self.collectionViewSelectedUser.numberOfSections > 0 else { return }
        self.collectionViewSelectedUser.performBatchUpdates({
            UIView.animate(withDuration: 0.8, delay: 0.0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.9, options: UIView.AnimationOptions.curveEaseInOut, animations: {
                self.collectionViewSelectedUser.reloadSections(IndexSet(integer: 0))
            }, completion: nil)
        }, completion: nil)
    }
}
