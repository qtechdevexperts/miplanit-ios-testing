//
//  InviteUsersViewController+Action.swift
//  MiPlanIt
//
//  Created by Nikhil RajG on 11/04/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

extension InviteUsersViewController {
    
    func initialiseUIComponents() {
        self.lottieLoaderAnimation.backgroundBehavior = .pauseAndRestore
        let dropInteractionFullAccessUser = UIDropInteraction(delegate: self)
        self.collectionViewFullPartiaAccessUser.addInteraction(dropInteractionFullAccessUser)
//        let dropInteractionPartialAccessUser = UIDropInteraction(delegate: self)
        //self.collectionViewPartialAccessUser.addInteraction(dropInteractionPartialAccessUser)
        self.textFieldSearchUser.attributedPlaceholder = Strings.addUsers.attributedPlaceholder(subtext: Strings.placeHolderSubString)
        self.viewFullAccess.isHidden = true
    }
    
    @objc func contactFetchedConpleted(_ notify: Notification) {
        DispatchQueue.main.async {
            self.calendar.allUsers = Session.shared.allContactUser
            self.refreshMiPlanItUsersView()
            self.stopContactLoaderAnimations()
        }
    }
    
    func startContactLoaderAnimations() {
        self.viewFetchContact.isHidden = false
        self.textFieldSearchUser.isEnabled = false
        self.lottieLoaderAnimation.loopMode = .loop
        self.lottieLoaderAnimation.play()
    }
    
    func stopContactLoaderAnimations() {
        self.viewFetchContact.isHidden = true
        self.textFieldSearchUser.isEnabled = true
        if self.lottieLoaderAnimation.isAnimationPlaying { self.lottieLoaderAnimation.stop() }
    }
    
    func readAllBalanceMiPlanItUser() -> [CalendarUser] {
        return self.calendar.allUsers.filter({ return !(self.calendar.fullAccesUsers.contains($0) ||
            self.calendar.partailAccesUsers.contains($0)) })
    }
    
    func refreshMiPlanItUsersView(index: IndexPath? = nil, whileRemoving: Bool = false, inFullAccess: Bool = true) {
        let allBalanceUsers = self.readAllBalanceMiPlanItUser()
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
        if inFullAccess {
            self.collectionViewFullPartiaAccessUser?.reloadData()
//            self.cellectionViewFullAccessUserChange()
        }
        else {
            self.cellectionViewPartialAccessAccessUserChange()
        }
        DispatchQueue.main.asyncAfter(deadline: .now()+0.2) {
            self.viewFullAccess.isHidden = false
            self.labelNoInviteesAdded?.isHidden = !self.calendar.sortedFullPartialUsers.isEmpty
        }
    }
    
    func collectionViewAllUserRemoval(at index: IndexPath?) {
        self.collectionViewAllUser?.reloadData()
    }
    
    func collectionViewAllUserReload() {
        self.collectionViewAllUser.performBatchUpdates({
            UIView.animate(withDuration: 0.8, delay: 0.0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.9, options: UIView.AnimationOptions.curveEaseInOut, animations: {
                (self.sectionedUser.count > 1 && self.collectionViewAllUser.numberOfSections > 1) ? self.collectionViewAllUser.reloadSections([0, 1]) : self.collectionViewAllUser.reloadSections(IndexSet(integer: 0))
            }, completion: nil)
        }, completion: nil)
    }
    
    func cellectionViewFullAccessUserChange() {
        self.collectionViewFullPartiaAccessUser.performBatchUpdates({
            UIView.animate(withDuration: 0.8, delay: 0.0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.9, options: UIView.AnimationOptions.curveEaseInOut, animations: {
                self.collectionViewFullPartiaAccessUser.reloadSections(IndexSet(integer: 0))
            }, completion: nil)
        }, completion: nil)
    }
    
    func cellectionViewPartialAccessAccessUserChange() {
//        self.collectionViewPartialAccessUser.performBatchUpdates({
//            UIView.animate(withDuration: 0.8, delay: 0.0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.9, options: UIView.AnimationOptions.curveEaseInOut, animations: {
//                self.collectionViewPartialAccessUser.reloadSections(IndexSet(integer: 0))
//            }, completion: nil)
//        }, completion: nil)
    }
    
    func showSelectionUserInfo(_ user: InviteesCollectionViewCell) {
        guard user.imageViewProfilePic != nil, (user.calenderUser is PlanItInvitees || user.calenderUser is CalendarUser) else { return }
        self.performSegue(withIdentifier: "showInfoPopUp", sender: user)
    }
    
    func calendarUserAlreadySelected(user: CalendarUser) -> Bool {
        return self.calendar.sortedFullPartialUsers.contains(where: { return $0 == user })
    }
    
    @objc func changeToFullOrVisible(index: Int) {
        if let user = self.calendar.partailAccesUsers.first(where: { $0 == self.calendar.sortedFullPartialUsers[index] }) {
            self.calendar.insertNewUser(user, toFullAcess: true)
            self.calendar.partailAccesUsers.removeAll(where: { $0 == user })
        }
    }
    
    @objc func changeToPartialOrNonVisible(index: Int) {
        if let user = self.calendar.fullAccesUsers.first(where: { $0 == self.calendar.sortedFullPartialUsers[index] }) {
            self.calendar.insertNewUser(user, toPartialAcess: true)
            self.calendar.fullAccesUsers.removeAll(where: { $0 == user })
        }
    }

}

