//
//  UserSelectionBaseViewController+Callback.swift
//  MiPlanIt
//
//  Created by Nikhil RajG on 08/04/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

extension UserSelectionBaseViewController: InviteesCollectionViewCellDelegate {
    func inviteesCollectionViewCell(_ inviteesCollectionViewCell: InviteesCollectionViewCell, changeAccess type: UserAccesType) {
        
    }
    
    
    func inviteesCollectionViewCell(_ inviteesCollectionViewCell: InviteesCollectionViewCell, showInfo onIndex: IndexPath?) {
        self.showSelectionUserInfo(inviteesCollectionViewCell)
    }

    func inviteesCollectionViewCell(_ inviteesCollectionViewCell: InviteesCollectionViewCell, removeCalendar onIndex: IndexPath?) {
        guard let index = onIndex, !self.sectionedUser.isEmpty else { return }
        self.calenderUsers.selectedUsers.remove(at: index.row)
        self.refreshUsersView(whileRemoving: true)
    }
}
