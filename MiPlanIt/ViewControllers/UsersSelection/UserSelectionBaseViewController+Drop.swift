//
//  UserSelectionBaseViewController+Drop.swift
//  MiPlanIt
//
//  Created by Febin Paul on 18/05/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit
import Foundation
import MobileCoreServices

extension UserSelectionBaseViewController: UIDropInteractionDelegate {

    func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
        return session.hasItemsConforming(toTypeIdentifiers: [kUTTypeImage as String]) && session.items.count == 1
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        let operation: UIDropOperation
        operation = session.localDragSession == nil ? .copy : .move
        return UIDropProposal(operation: operation)
    }

    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        guard let inviteesDragView = session.items.first?.localObject as? InviteesDragView else { return }
        if let collectionView = interaction.view as? UICollectionView, collectionView == self.collectionViewSelectedUser, !self.calenderUsers.selectedUsers.contains(where: { return $0.readIdentifier() == inviteesDragView.calenderUser.readIdentifier() }) {
            self.calenderUsers.insertNewUser(inviteesDragView.calenderUser)
            self.refreshUsersView(index: inviteesDragView.indexPath)
        }
    }
}

