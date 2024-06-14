//
//  ShoppingHeaderTableViewCell.swift
//  MiPlanIt
//
//  Created by Aneesh Asokan on 21/12/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

class ShoppingHeaderTableViewCell: UITableViewCell {

    @IBOutlet weak var labelHeader: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func configCell(category: String) {
        self.labelHeader.text = category
    }

}
