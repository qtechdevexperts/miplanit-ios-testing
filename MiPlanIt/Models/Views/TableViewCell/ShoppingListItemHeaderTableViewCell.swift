//
//  ShoppingListItemHeaderTableViewCell.swift
//  MiPlanIt
//
//  Created by Febin Paul on 07/04/21.
//  Copyright © 2021 Arun. All rights reserved.
//

import UIKit

class ShoppingListItemHeaderTableViewCell: UITableViewCell {

    @IBOutlet weak var labelCategoryName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configCell(categoryName: String) {
        self.labelCategoryName.text = categoryName.uppercased()
    }

}
