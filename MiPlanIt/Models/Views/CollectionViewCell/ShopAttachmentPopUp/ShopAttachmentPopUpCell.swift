//
//  ShopAttachmentPopUpCell.swift
//  MiPlanIt
//
//  Created by Febin Paul on 22/02/21.
//  Copyright © 2021 Arun. All rights reserved.
//

import UIKit

class ShopAttachmentPopUpCell: UICollectionViewCell {
    
    @IBOutlet weak var imageViewAttachment: UIImageView!
    
    func configCell(_ shopListItem: ShopListItemCellModel, index: IndexPath) {
        
        let planItUserAtachment = shopListItem.planItShopListItem.readAttachments()[index.row]
        
        if let attachmentdata = planItUserAtachment.data {
            self.imageViewAttachment.image = UIImage(data: attachmentdata)
        }
        else if let url = planItUserAtachment.url, !url.isEmpty  {
            self.imageViewAttachment.pinImageFromURL(URL(string: url), placeholderImage: UIImage(named: Strings.shoppingDefaultIcon))
        }
    }
}
