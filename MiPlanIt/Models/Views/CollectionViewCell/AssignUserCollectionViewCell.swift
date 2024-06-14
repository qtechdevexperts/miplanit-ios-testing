//
//  AssignUserCollectionViewCell.swift
//  MiPlanIt
//
//  Created by Febin Paul on 10/07/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

protocol AssignUserCollectionViewCellDelegate: class {
    func assignUserCollectionViewCellDelegate(_ AssignUserCollectionViewCell: AssignUserCollectionViewCell, didSelect index: IndexPath)
}

class AssignUserCollectionViewCell: UICollectionViewCell {
    
    var index: IndexPath!
    weak var delegate: AssignUserCollectionViewCellDelegate?

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var buttonSelection: UIButton!
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var imageViewSelection: UIImageView!
    @IBOutlet weak var labelEmailOrPhone: UILabel!
    @IBOutlet weak var imageViewMiPlaniT: UIImageView?
    
    override func prepareForReuse() {
        self.imageViewMiPlaniT?.isHidden = true
    }
    
    @IBAction func selectionButtonClicked(_ sender: UIButton) {
        self.delegate?.assignUserCollectionViewCellDelegate(self, didSelect: self.index)
    }
    
    func configCell(index: IndexPath, delegate: AssignUserCollectionViewCellDelegate, assignUser: AssignUser, isSelected: Bool) {
        self.labelName.text = assignUser.calendarUser.name
        self.buttonSelection.isSelected = isSelected
        self.imageViewSelection.isHidden = !isSelected
        self.index = index
        self.delegate = delegate
        self.labelEmailOrPhone?.text = assignUser.calendarUser.userContainsEmailInPhoneContact ? assignUser.calendarUser.email : assignUser.calendarUser.phone
        self.labelEmailOrPhone?.isHidden = assignUser.calendarUser.isPrivate
         self.imageView.pinImageFromURL(URL(string: assignUser.calendarUser.profile), placeholderImage: assignUser.calendarUser.name.shortStringImage(1))
        self.imageViewMiPlaniT?.isHidden = assignUser.calendarUser.userType !=
        .miplanit
        self.layoutIfNeeded()
    }
}
