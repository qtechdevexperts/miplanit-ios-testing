//
//  ShareMiPlaniTCalendarViewController.swift
//  MiPlanIt
//
//  Created by Aneesh Asokan on 13/07/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

protocol ShareMiPlaniTCalendarViewControllerDelegate: class {
    func shareMiPlaniTCalendarViewController(_ shareMiPlaniTCalendarViewController: ShareMiPlaniTCalendarViewController, onIndex: IndexPath, selected invitees: CalendarInvitees)
}

class ShareMiPlaniTCalendarViewController: InviteUsersViewController {
    
    var selectedCalendarIndex: IndexPath!
    weak var delegateShare: ShareMiPlaniTCalendarViewControllerDelegate?
    var planItCalendar: PlanItCalendar!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.delegate = self
    }
    
    override func readCollectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
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
                cell.configureVisibilityCell(calendarUser: self.calendar.sortedFullPartialUsers[indexPath.row], index: indexPath, accessType: .full, delegate: self)
            }
            else {
                cell.configureCellReset()
            }
            return cell
        }
    }
    
    override func changeToFullOrVisible(index: Int) {
        if let user = self.calendar.partailAccesUsers.first(where: { $0 == self.calendar.sortedFullPartialUsers[index] }) {
            self.calendar.insertNewVisibilityUser(user, visible: true)
            self.calendar.partailAccesUsers.removeAll(where: { $0 == user })
        }
    }
    
    override func changeToPartialOrNonVisible(index: Int) {
        if let user = self.calendar.fullAccesUsers.first(where: { $0 == self.calendar.sortedFullPartialUsers[index] }) {
            self.calendar.insertNewVisibilityUser(user, nonVisible: true)
            self.calendar.fullAccesUsers.removeAll(where: { $0 == user })
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard collectionView == self.collectionViewAllUser else {
            return
        }
        if let text = self.textFieldSearchUser.text, !text.isEmpty {
            if self.filteredUsers.isEmpty, text.validateEmail() {
                let user = CalendarUser(text)
                if !self.calendarUserAlreadySelected(user: user) {
                    self.calendar.insertNewVisibilityUser(user, visible: true)
                }
            }
            else if !self.calendarUserAlreadySelected(user: self.filteredUsers[indexPath.row]) {
                self.calendar.insertNewVisibilityUser(self.filteredUsers[indexPath.row], visible: true)
            }
            self.textFieldSearchUser.resignFirstResponder()
        }
        else if !self.calendarUserAlreadySelected(user: self.sectionedUser[indexPath.section][indexPath.row]) {
                self.calendar.insertNewVisibilityUser(self.sectionedUser[indexPath.section][indexPath.row], visible: true)
        }
        self.refreshMiPlanItUsersView(index: indexPath, inFullAccess: true)
    }
}
extension ShareMiPlaniTCalendarViewController: InviteUsersViewControllerDelegate {
    
    func inviteUsersViewController(_ viewController: InviteUsersViewController, selected invitees: CalendarInvitees) {
        self.delegateShare?.shareMiPlaniTCalendarViewController(self, onIndex: self.selectedCalendarIndex, selected: invitees)
    }
}
