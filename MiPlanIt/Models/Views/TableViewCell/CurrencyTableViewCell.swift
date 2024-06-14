//
//  CurrencyTableViewCell.swift
//  MiPlanIt
//
//  Created by Aneesh Asokan on 20/01/21.
//  Copyright © 2021 Arun. All rights reserved.
//

import UIKit

class CurrencyTableViewCell: UITableViewCell {

    @IBOutlet weak var labelOptionTitle: UILabel!
    @IBOutlet weak var labelCode: UILabel!
    @IBOutlet weak var viewUpperBorder: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func configureCell(item: [String:String], indexPath: IndexPath, isSelected: Bool) {
        self.labelOptionTitle.text = item["name"]
        self.labelCode.text = item["code"]?.getLocalCurrencySymbol()
//        self.labelOptionTitle.backgroundColor = isSelected ? UIColor(named: "todoItemBg") : UIColor(named: "grayMT")
        self.contentView.backgroundColor = isSelected ? UIColor(named: "todoItemBg") : UIColor(named: "grayMT")
        self.viewUpperBorder.isHidden = indexPath.row == 0
    }

}
