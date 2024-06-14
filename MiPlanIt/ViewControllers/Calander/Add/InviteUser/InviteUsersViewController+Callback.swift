//
//  InviteUsersViewController+Callback.swift
//  MiPlanIt
//
//  Created by Nikhil RajG on 11/04/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

extension InviteUsersViewController: InviteesCollectionViewCellDelegate {
    
    func inviteesCollectionViewCell(_ inviteesCollectionViewCell: InviteesCollectionViewCell, changeAccess type: UserAccesType) {
        guard let index = inviteesCollectionViewCell.index?.row else {
            return
        }
        switch type {
        case .full:
            self.changeToFullOrVisible(index: index)
        case .partial:
            self.changeToPartialOrNonVisible(index: index)
        }
        self.collectionViewFullPartiaAccessUser.reloadData()
    }
    
    func inviteesCollectionViewCell(_ inviteesCollectionViewCell: InviteesCollectionViewCell, showInfo onIndex: IndexPath?) {
        //self.showSelectionUserInfo(inviteesCollectionViewCell)
    }
    
    func inviteesCollectionViewCell(_ inviteesCollectionViewCell: InviteesCollectionViewCell, removeCalendar onIndex: IndexPath?) {
        guard let accessType = inviteesCollectionViewCell.accessTypeCell, let index = onIndex else { return }
        if let userIndex = self.calendar.fullAccesUsers.firstIndex(where: { $0 == self.calendar.sortedFullPartialUsers[index.row] }) {
            self.calendar.fullAccesUsers.remove(at: userIndex)
        }
        else if let userIndex = self.calendar.partailAccesUsers.firstIndex(where: { $0 == self.calendar.sortedFullPartialUsers[index.row] }) {
            self.calendar.partailAccesUsers.remove(at: userIndex)
        }
        self.refreshMiPlanItUsersView(whileRemoving: true, inFullAccess: accessType == .full)
    }
}
