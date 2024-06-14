//
//  ShopSubCategoryTableViewCell.swift
//  MiPlanIt
//
//  Created by Febin Paul on 13/11/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

protocol ShopSubCategoryTableViewCellDelegate: class {
    
    func shopSubCategoryTableViewCell(_ shopSubCategoryTableViewCell: ShopSubCategoryTableViewCell, onSelect flag: Bool)
}

class ShopSubCategoryTableViewCell: UITableViewCell {
    
    var index: IndexPath!
    weak var delegate: ShopSubCategoryTableViewCellDelegate?
    var subCategory: ShopListItemSubCategoryListOption!
    
    @IBOutlet weak var buttonSelection: UIButton!
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var viewSelection: UIView!
    
    @IBAction func selectionButtonClickes(_ sender: UIButton) {
        self.delegate?.shopSubCategoryTableViewCell(self, onSelect: sender.isSelected)
    }
    
    @IBAction func itemSelectionButtonClicked(_ sender: UIButton) {
        self.buttonSelection.isSelected = !self.buttonSelection.isSelected
        self.delegate?.shopSubCategoryTableViewCell(self, onSelect: self.buttonSelection.isSelected)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func configCell(index: IndexPath, subCategory: ShopListItemSubCategoryListOption, delegate: ShopSubCategoryTableViewCellDelegate) {
        self.index = index
        self.delegate = delegate
        self.viewSelection.isHidden = !subCategory.isSelected
        self.subCategory = subCategory
        self.labelName.text = subCategory.subCategory.readCategoryName()
    }
    
}
