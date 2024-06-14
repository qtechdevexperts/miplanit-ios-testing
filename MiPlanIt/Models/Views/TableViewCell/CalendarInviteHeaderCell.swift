//
//  CalendarInviteHeaderCell.swift
//  MiPlanIt
//
//  Created by Nikhil RajG on 11/04/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

class CalendarInviteHeaderCell: UITableViewCell {
    
    @IBOutlet weak var labelHeader: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundView?.backgroundColor = .clear
    }
}
