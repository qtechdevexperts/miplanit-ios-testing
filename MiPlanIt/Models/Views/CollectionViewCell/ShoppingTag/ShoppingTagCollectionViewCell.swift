//
//  ShoppingTagCollectionViewCell.swift
//  MiPlanIt
//
//  Created by Febin Paul on 08/04/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

protocol ActivityTagCollectionViewCellDelegate: class {
    func activityTagCollectionViewCell(_ cell: ActivityTagCollectionViewCell, removeItemAtIndexPath indexPath: IndexPath)
    func activityTagCollectionViewCell(_ cell: ActivityTagCollectionViewCell, addPredictedTag indexPath: IndexPath)
}

class ActivityTagCollectionViewCell: UICollectionViewCell {
    
    var indexPath: IndexPath!
    weak var delegate: ActivityTagCollectionViewCellDelegate?
    
    //MARK:-IBOutlet
    @IBOutlet weak var labelTag: UILabel!
    @IBOutlet weak var viewContainer: UIView?
    @IBOutlet weak var viewOverlay: UIView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.contentView.leftAnchor.constraint(equalTo: leftAnchor),
            self.contentView.rightAnchor.constraint(equalTo: rightAnchor),
            self.contentView.topAnchor.constraint(equalTo: topAnchor),
            self.contentView.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])
    }
    
    func configureCell(index: IndexPath, text: String, vc: ActivityTagCollectionViewCellDelegate, disableCell: Bool = false) {
        self.delegate = vc
        self.indexPath = index
        self.labelTag.text = text
        self.isUserInteractionEnabled = !disableCell
        self.viewOverlay?.isHidden = !disableCell
//        self.viewContainer?.backgroundColor = .gray
//        self.viewContainer?.backgroundColor = disableCell ? UIColor(red: 226/255, green: 88/255, blue: 90/255, alpha: 0.7) : UIColor(red: 226/255, green: 88/255, blue: 90/255, alpha: 1)
        self.viewContainer?.backgroundColor = disableCell ? .darkGray : .grayLight

    }
    
    //MARK:-IBAction
    @IBAction func removeTagClicked(_ sender: UIButton) {
        self.delegate?.activityTagCollectionViewCell(self, removeItemAtIndexPath: self.indexPath)
    }
    
    @IBAction func addPredictedTagClicked(_ sender: UIButton) {
        self.delegate?.activityTagCollectionViewCell(self, addPredictedTag: self.indexPath)
    }
}
