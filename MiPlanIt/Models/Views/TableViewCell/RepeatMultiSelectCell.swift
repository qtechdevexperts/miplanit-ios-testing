//
//  RepeatMultiSelectCell.swift
//  MiPlanIt
//
//  Created by Febin Paul on 23/06/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation


class RepeatMultiSelectCell: UITableViewCell {
    
    var index: IndexPath!
    
    @IBOutlet weak var labelTagName: UILabel!
    @IBOutlet weak var buttonSelect: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configCell(item: Any, index: IndexPath, isSelected: Bool) {
        self.index = index
        if let dropDownItem = item as? DropDownItem {
            self.labelTagName.text =  dropDownItem.title
        }
        else if let value = item as? Int {
            self.labelTagName.text =  "\(value)"
        }
        self.buttonSelect.isSelected = isSelected
    }
}
