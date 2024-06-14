//
//  InviteUsersViewController+Drop.swift
//  MiPlanIt
//
//  Created by Febin Paul on 19/05/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit
import Foundation
import MobileCoreServices

extension InviteUsersViewController: UIDropInteractionDelegate {

    func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
        return session.hasItemsConforming(toTypeIdentifiers: [kUTTypeImage as String]) && session.items.count == 1
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        let operation: UIDropOperation
        operation = session.localDragSession == nil ? .copy : .move
        return UIDropProposal(operation: operation)
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        guard let inviteesDragView = session.items.first?.localObject as? InviteesDragView else {
            return
        }
        if let collectionView = interaction.view as? UICollectionView {
            if collectionView == self.collectionViewFullPartiaAccessUser, !self.calendarUserAlreadySelected(user: inviteesDragView.calenderUser) {
                self.calendar.insertNewUser(inviteesDragView.calenderUser, toFullAcess: true)
            }
            self.refreshMiPlanItUsersView(index: inviteesDragView.indexPath, inFullAccess: collectionView == self.collectionViewFullPartiaAccessUser)
        }
    }
}
