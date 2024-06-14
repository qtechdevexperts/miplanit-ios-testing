//
//  ShoppingItemAddCell.swift
//  MiPlanIt
//
//  Created by Aneesh Asokan on 06/05/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

protocol ShoppingItemAddCellDelegate: class {
    func shoppingItemAddCellRequestForNewProduct(_ shoppingItemAddCell: ShoppingItemAddCell)
}

class ShoppingItemAddCell: UITableViewCell {
    
    weak var delegate: ShoppingItemAddCellDelegate?
    @IBOutlet weak var buttonAddItem: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction func addButtonClicked(_ sender: UIButton) {
        self.delegate?.shoppingItemAddCellRequestForNewProduct(self)
    }
}
