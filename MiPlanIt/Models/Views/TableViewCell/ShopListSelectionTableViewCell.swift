//
//  ShopListSelectionTableViewCell.swift
//  MiPlanIt
//
//  Created by Febin Paul on 13/11/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

protocol ShopListSelectionTableViewCellDelegate: class {
    func shopListSelectionTableViewCell(_ shopListSelectionTableViewCell: ShopListSelectionTableViewCell, onSelect index: IndexPath)
}


class ShopListSelectionTableViewCell: UITableViewCell {

    var index: IndexPath!
    weak var delegate: ShopListSelectionTableViewCellDelegate?
    
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var buttonSelection: UIButton!
    @IBOutlet weak var viewButtonSelection: UIView!
    
    @IBAction func onListSelect(_ sender: UIButton) {
        self.delegate?.shopListSelectionTableViewCell(self, onSelect: self.index)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configCell(index: IndexPath, delegate: ShopListSelectionTableViewCellDelegate, shopListItem: ShopListSelectionOption) {
        self.index = index
        self.delegate = delegate
        self.labelName.text = shopListItem.shopList.readShopListName()
        self.buttonSelection.isSelected = shopListItem.isSelected
        self.viewButtonSelection.isHidden = !shopListItem.isSelected
//        if !shopListItem.isSelected{
//            self.viewButtonSelection.backgroundColor = .red
//        }else{
//            self.viewButtonSelection.backgroundColor = .blue
//
//        }
    }

}
