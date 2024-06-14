//
//  ShopListItemViewDetails+Callback.swift
//  MiPlanIt
//
//  Created by Febin Paul on 15/12/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

extension ShopListItemViewDetails: AttachmentListViewControllerDelegate{
    
    func attachmentListViewController(_ viewController: AttachmentListViewController, updated items: [UserAttachment]) {
        
    }
}


extension ShopListItemViewDetails: NotificationShopTagsViewControllerDelegate {
    
    func notificationShopTagsViewController(_ viewController: NotificationShopTagsViewController, updated tags: [String]) {
        
    }
}
