//
//  TagListCell.swift
//  MiPlanIt
//
//  Created by Aneesh Asokan on 06/05/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

class TagListCell: UITableViewCell {
    
    var index: IndexPath!
    
    @IBOutlet weak var labelTagName: UILabel!
    @IBOutlet weak var buttonSelect: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configCell(tag: PlanItSuggustionTags, index: IndexPath, isSelected: Bool) {
        self.index = index
        self.labelTagName.text = tag.tag
        self.buttonSelect.isSelected = isSelected
    }
}
