//
//  DropDownOptionsCell.swift
//  MiPlanIt
//
//  Created by MS Nischal on 20/03/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

class DropDownOptionsCell: UITableViewCell {
    
    @IBOutlet weak var labelOptionTitle: UILabel!
    @IBOutlet weak var imageViewOptionIcon: UIImageView!
    @IBOutlet weak var viewUpperBorder: UIView!
    @IBOutlet weak var imageViewTick: UIImageView?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func configureCell(item: DropDownItem, indexPath: IndexPath) {
        if (self.imageViewTick != nil) {
            self.imageViewTick!.isHidden = item.isSelected == false
        }
        self.labelOptionTitle.text = item.title
        
        self.labelOptionTitle.font = UIFont(name: item.isSelected ? Fonts.SFUIDisplayMedium : Fonts.SFUIDisplayRegular, size: 18)!
        self.viewUpperBorder.isHidden = indexPath.row == 0
        self.labelOptionTitle.isEnabled = item.isEnabled
        self.imageViewOptionIcon.alpha = item.isEnabled ? 1 : 0.5
        self.imageViewOptionIcon.isHidden = !item.isImageType
        if item.isImageType {
            self.imageViewOptionIcon.image = UIImage(imageLiteralResourceName: item.image)
            self.imageViewOptionIcon.tintColor = .white
            self.imageViewOptionIcon.contentMode = .left
        }
    }
}

