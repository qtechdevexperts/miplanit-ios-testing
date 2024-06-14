//
//  ShoppingAttachmentCollectionViewCell.swift
//  MiPlanIt
//
//  Created by Febin Paul on 23/12/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

class ShoppingAttachmentCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageViewAttachment: UIImageView!
    
    func configCell(attachment: UserAttachment) {
        if attachment.data != nil {
            self.imageViewAttachment.image = UIImage(data: attachment.data)
        }
        else if !attachment.url.isEmpty  {
            self.imageViewAttachment.pinImageFromURL(URL(string: attachment.url), placeholderImage: UIImage(named: Strings.shoppingDefaultIcon))
        }
    }
}
