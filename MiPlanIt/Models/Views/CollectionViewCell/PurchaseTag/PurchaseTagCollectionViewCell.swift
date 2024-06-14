//
//  PurchaseTagCollectionViewCell.swift
//  MiPlanIt
//
//  Created by Febin Paul on 08/04/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

protocol PurchaseTagCollectionViewCellDelegate: class {
    func purchaseTagCollectionViewCell(_ cell: PurchaseTagCollectionViewCell, removeItemAtIndexPath indexPath: IndexPath)
}

class PurchaseTagCollectionViewCell: UICollectionViewCell {
    
    var indexPath: IndexPath!
    weak var delegate: PurchaseTagCollectionViewCellDelegate?
    
    //MARK:-IBOutlet
    @IBOutlet weak var labelTag: UILabel!
    
    func configureCell(index: IndexPath, text: String, vc: PurchaseTagCollectionViewCellDelegate) {
        self.delegate = vc
        self.indexPath = index
        self.labelTag.text = text
    }
    
    //MARK:-IBAction
    @IBAction func removeTagClicked(_ sender: UIButton) {
        self.delegate?.purchaseTagCollectionViewCell(self, removeItemAtIndexPath: self.indexPath)
    }
}
