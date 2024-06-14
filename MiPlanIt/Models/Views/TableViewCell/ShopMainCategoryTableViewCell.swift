//
//  ShopMainCategoryTableViewCell.swift
//  MiPlanIt
//
//  Created by Febin Paul on 13/11/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

protocol ShopMainCategoryTableViewCellDelegate: class {
    
    func shopMainCategoryTableViewCell(_ shopMainCategoryTableViewCell: ShopMainCategoryTableViewCell, onExpand flag: Bool)
    func shopMainCategoryTableViewCell(_ shopMainCategoryTableViewCell: ShopMainCategoryTableViewCell, onSelect flag: Bool)
}

class ShopMainCategoryTableViewCell: UITableViewCell {
    
    var section: Int!
    weak var delegate: ShopMainCategoryTableViewCellDelegate?
    var mainCategory: ShopListItemCategoryListOption!
    
    @IBOutlet weak var buttonExpand: UIButton!
    @IBOutlet weak var buttonSelection: UIButton!
    
    @IBOutlet weak var imageViewCategory: UIImageView!
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var viewSelection: UIView!
    @IBOutlet weak var viewExpand: UIView!
    
    @IBAction func selectionButtonClickes(_ sender: UIButton) {
        self.buttonSelection.isSelected = !self.buttonSelection.isSelected
        self.delegate?.shopMainCategoryTableViewCell(self, onSelect: self.buttonSelection.isSelected)
    }
    
    @IBAction func expandButtonClickes(_ sender: UIButton) {
        self.buttonExpand.isSelected = !self.buttonExpand.isSelected
        self.delegate?.shopMainCategoryTableViewCell(self, onExpand: self.buttonExpand.isSelected)
    }
    
    @IBAction func itemSelectionButtonClicked(_ sender: UIButton) {
        if mainCategory.shopSubCategory.isEmpty {
            self.buttonSelection.isSelected = !self.buttonSelection.isSelected
            self.delegate?.shopMainCategoryTableViewCell(self, onSelect: self.buttonSelection.isSelected)
        }
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        if editing {
            for view in subviews where view.description.contains("Reorder") {
                for case let subview as UIImageView in view.subviews {
                   subview.image = UIImage(named: "icon_CalendarSwap.png")
                    subview.contentMode = .center
                }
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configCell(section: Int, mainCategory: ShopListItemCategoryListOption, delegate: ShopMainCategoryTableViewCellDelegate) {
        self.section = section
        self.delegate = delegate
        self.viewExpand.isHidden = mainCategory.shopSubCategory.isEmpty
        self.viewSelection.isHidden = !mainCategory.isSelected
        self.buttonSelection.isSelected = mainCategory.isSelected
        self.buttonExpand.isSelected = mainCategory.isExpanded
        self.mainCategory = mainCategory
        self.labelName.text = mainCategory.shopMainCategory.readCategoryName()
        self.imageViewCategory.image = UIImage(named: "default-category-image")
    }
    
    func configCell(section: ShopItemListSection) {
        self.labelName.text = section.readSectionName()
        self.imageViewCategory.image = UIImage(named: "default-category-image")
    }

}
