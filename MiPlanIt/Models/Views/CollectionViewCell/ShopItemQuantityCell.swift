//
//  ShopItemQuantityCell.swift
//  MiPlanIt
//
//  Created by Febin Paul on 05/11/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

class ShopItemQuantityCell: UICollectionViewCell {
    
    @IBOutlet weak var labelQuantity: UILabel!
    
    func configCell(quantity: String) {
        self.labelQuantity.text = quantity
    }
}
