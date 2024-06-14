//
//  UserSelectionBaseViewController+Drag.swift
//  MiPlanIt
//
//  Created by Febin Paul on 18/05/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation
import UIKit

extension UserSelectionBaseViewController: UIDragInteractionDelegate {

    func dragInteraction(_ interaction: UIDragInteraction, itemsForBeginning session: UIDragSession) -> [UIDragItem] {
        guard let inviteeCell = interaction.view as? InviteesCollectionViewCell, let calendarUser = inviteeCell.calenderUser as? CalendarUser, let indexPath = self.collectionViewAllUser.indexPath(for: inviteeCell) else {
            return []
        }
        
        let attributes = self.collectionViewAllUser.layoutAttributesForItem(at: indexPath)
        let frameInWindow = self.collectionViewAllUser.convert(attributes!.frame, to: nil)
        
        self.inviteesDragView = InviteesDragView(calenderUser: calendarUser , frame: CGRect(x: frameInWindow.minX, y: frameInWindow.minY-50, width: 200, height: 100), profileImage: inviteeCell.imageViewProfilePic?.image, index: indexPath)
        self.view.addSubview(self.inviteesDragView)
        let container = ViewContainer(view: self.inviteesDragView)
        let provider = NSItemProvider(object: container)
        let item = UIDragItem(itemProvider: provider)
        item.localObject = container.view
        
        return [item]
    }

    func dragInteraction(_ interaction: UIDragInteraction, previewForLifting item: UIDragItem, session: UIDragSession) -> UITargetedDragPreview? {
        guard let inviteesDragView = item.localObject as? InviteesDragView else { return nil }
        
        inviteesDragView.layoutSubviews()
        let previewImageView = UIImageView(image: UIImage(view: inviteesDragView))
        
        previewImageView.contentMode = .scaleAspectFit
        previewImageView.frame = inviteesDragView.bounds

        let center = CGPoint(x: self.inviteesDragView.bounds.midX, y: self.inviteesDragView.bounds.midY)
        let target = UIDragPreviewTarget(container: self.inviteesDragView, center: center)
        self.inviteesDragView.removeFromSuperview()
        return UITargetedDragPreview(view: previewImageView, parameters: UIDragPreviewParameters(), target: target)
    }
    
    func dragInteraction(_ interaction: UIDragInteraction, sessionDidMove session: UIDragSession) {
        self.inviteesDragView.removeFromSuperview()
    }
    
    func dragInteraction(_ interaction: UIDragInteraction, item: UIDragItem, willAnimateCancelWith animator: UIDragAnimating) {
        self.inviteesDragView.removeFromSuperview()
    }
}

