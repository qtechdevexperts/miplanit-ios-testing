//
//  GiftCouponTagCollectionViewCell.swift
//  MiPlanIt
//
//  Created by Febin Paul on 08/04/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

protocol GiftCouponTagCollectionViewCellDelegate: class {
    func giftCouponTagCollectionViewCell(_ cell: GiftCouponTagCollectionViewCell, removeItemAtIndexPath indexPath: IndexPath)
}

class GiftCouponTagCollectionViewCell: UICollectionViewCell {
    
    var indexPath: IndexPath!
    weak var delegate: GiftCouponTagCollectionViewCellDelegate?
    
    //MARK:-IBOutlet
    @IBOutlet weak var labelTag: UILabel!
    
    func configureCell(index: IndexPath, text: String, vc: GiftCouponTagCollectionViewCellDelegate) {
        self.delegate = vc
        self.indexPath = index
        self.labelTag.text = text
    }
    
    //MARK:-IBAction
    @IBAction func removeTagClicked(_ sender: UIButton) {
        self.delegate?.giftCouponTagCollectionViewCell(self, removeItemAtIndexPath: self.indexPath)
    }
}
