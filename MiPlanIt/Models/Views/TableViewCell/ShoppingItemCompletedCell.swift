//
//  ShoppingItemCompletedCell.swift
//  MiPlanIt
//
//  Created by Aneesh Asokan on 06/05/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

class ShoppingItemCompletedCell: UITableViewCell {

    @IBOutlet weak var labelItemName: UILabel!
    
    @IBOutlet weak var labelQuantity: UILabel!
        
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureProduct(_ product: ShopProduct) {
        self.labelItemName.text = product.itemName
        self.labelQuantity.text = product.quantity
    }

}
