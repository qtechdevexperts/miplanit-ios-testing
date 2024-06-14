//
//  AssignViewController+Action.swift
//  MiPlanIt
//
//  Created by Febin Paul on 10/07/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation


extension AssignToDoViewController {
    
    func initializeUIComponents() {
        self.lottieLoaderAnimation.backgroundBehavior = .pauseAndRestore
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture))
        swipeDown.direction = .down
        self.view.addGestureRecognizer(swipeDown)
    }
    
    @objc func contactFetchedConpleted(_ notify: Notification) {
        DispatchQueue.main.async {
            self.calenderUsers.allUsers = Session.shared.allContactUser
            self.stopContactFetching()
            self.refreshUsersView()
        }
    }
    
    func fillSelectedInvitees(user: OtherUser?) {
        if let otherUser = user {
            self.calenderUsers.selectedUsers = [CalendarUser(otherUser)]
        }
        else {
            self.calenderUsers.selectedUsers = []
        }
    }
    
    func readAllBalanceUsers() -> [CalendarUser] {
        return self.calenderUsers.allUsers.filter({ return !self.calenderUsers.selectedUsers.contains($0) })
    }
    
    @objc func refreshUsersView(index: IndexPath? = nil, whileRemoving: Bool = false) {
        let allBalanceUsers = self.readAllBalanceUsers()
        if let searchText = self.textFieldSearchUser.text, !searchText.isEmpty {
            self.filteredUsers = allBalanceUsers.filter({ return $0.name.range(of: searchText, options: .caseInsensitive) != nil || $0.email.range(of: searchText, options: .caseInsensitive) != nil || $0.phone.range(of: searchText, options: .caseInsensitive) != nil }).map({ AssignUser(calendarUser: $0) })
        }
        else {
            self.filteredUsers = allBalanceUsers.map({ AssignUser(calendarUser: $0) })
            let miplanitUser = allBalanceUsers.filter({ $0.userType == .miplanit }).filter({ !$0.readIdentifier().isEmpty })
            let contactUser = allBalanceUsers.filter({ $0.userType != .miplanit }).filter({ return !miplanitUser.contains($0) })
            self.sectionedUser.append(miplanitUser.map({ AssignUser(calendarUser: $0) }))
            self.sectionedUser.append(contactUser.map({ AssignUser(calendarUser: $0) }))
        }
        self.collectionView.reloadData()
    }
    
    func showOrHideDropDownOptions(_ show: Bool) {
        self.bottomDropDownConstraints.constant = show ? 0 : -(readHeightForDropDownView())
        self.view.setNeedsUpdateConstraints()
        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
    }
    
    func readHeightForDropDownView() -> CGFloat {
        return 500.0
    }
    
    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        self.showOrHideDropDownOptions(false)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.26) {
            self.dismiss(animated: false, completion: nil)
        }
    }
    
    func isUserSelected(assignUser: AssignUser) -> Bool {
        guard let selectedAssignUser = self.selectedUser else { return false }
        if !selectedAssignUser.calendarUser.userId.isEmpty && selectedAssignUser.calendarUser.userId != "0" {
            return assignUser.calendarUser.userId == selectedAssignUser.calendarUser.userId
        }
        if !assignUser.calendarUser.email.isEmpty {
            return assignUser.calendarUser.email == selectedAssignUser.calendarUser.email
        }
        else if !assignUser.calendarUser.phone.isEmpty {
            return assignUser.calendarUser.phone == selectedAssignUser.calendarUser.phone
        }
        return false
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            self.bottomDropDownConstraints.constant = keyboardRectangle.height/2
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        self.bottomDropDownConstraints.constant = 0
    }
    
    func startContactFetching() {
        self.viewFetchContact.isHidden = false
        self.textFieldSearchUser.isEnabled = false
        self.lottieLoaderAnimation.loopMode = .loop
        self.lottieLoaderAnimation.play()
    }
    
    func stopContactFetching() {
        self.viewFetchContact.isHidden = true
        self.textFieldSearchUser.isEnabled = true
        if self.lottieLoaderAnimation.isAnimationPlaying { self.lottieLoaderAnimation.stop() }
    }
    
    func assigneSelectedAction() {
        self.assignSelectedUser(self.selectedUser?.calendarUser)
    }
    
    func assignSelectedUser(_ calendarUser: CalendarUser?) {
        self.createServiceToCheckEmailNotExist(calendarUser?.readEmailOrPhone()) { (status, error) in
            if status {
                self.showOrHideDropDownOptions(false)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.26) {
                    self.dismiss(animated: false) {
                        self.delegate?.assignToDoViewController(self, selectedAssige: calendarUser, toDoItems: self.toDoItems)
                    }
                }
            }
            else {
                self.performSegue(withIdentifier: Segues.toMessageScreen, sender: [Message.error, error ?? Message.unknownError])
            }
        }
    }
}
