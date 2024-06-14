//
//  ToDoCategoryListHeaderViewCell.swift
//  MiPlanIt
//
//  Created by Febin Paul on 05/08/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

class ToDoCategoryListHeaderViewCell: UITableViewCell {
    
    @IBOutlet weak var labelHeader: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func configCell(category: TodoListCategory) {
        self.labelHeader.text = category.title
    }

}
