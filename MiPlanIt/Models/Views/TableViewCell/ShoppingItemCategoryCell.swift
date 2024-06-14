//
//  ShoppingItemCategoryCell.swift
//  MiPlanIt
//
//  Created by Aneesh Asokan on 06/05/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

class ShoppingItemCategoryCell: UITableViewCell {

    @IBOutlet weak var labelHeader: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configureCategoryHeader(_ category: ShopCategory) {
        self.labelHeader.text = category.prodCatName
    }
}
