//
//  EventTagCollectionViewCell.swift
//  MiPlanIt
//
//  Created by Febin Paul on 08/04/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

protocol EventTagCollectionViewCellDelegate: class {
    func eventTagCollectionViewCell(_ cell: EventTagCollectionViewCell, removeItemAtIndexPath indexPath: IndexPath)
}

class EventTagCollectionViewCell: UICollectionViewCell {
    
    var indexPath: IndexPath!
    weak var delegate: EventTagCollectionViewCellDelegate?
    
    //MARK:-IBOutlet
    @IBOutlet weak var labelTag: UILabel!
    
    func configureCell(index: IndexPath, text: String, vc: EventTagCollectionViewCellDelegate) {
        self.delegate = vc
        self.indexPath = index
        self.labelTag.text = text
    }
    
    func setTag(_ text: String) {
        self.labelTag.text = text
    }
    
    //MARK:-IBAction
    @IBAction func removeTagClicked(_ sender: UIButton) {
        self.delegate?.eventTagCollectionViewCell(self, removeItemAtIndexPath: self.indexPath)
    }
}
