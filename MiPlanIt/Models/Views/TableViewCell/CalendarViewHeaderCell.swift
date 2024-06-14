//
//  CalendarViewHeaderCell.swift
//  MiPlanIt
//
//  Created by Febin Paul on 29/04/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

class CalendarViewHeaderCell: UICollectionReusableView {

    @IBOutlet weak var labelHeaderCell: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configureHeaderWithType(_ isFullAccess: Bool) {
        self.labelHeaderCell.text = isFullAccess ? Strings.fullAccess : Strings.particalAccess
    }
}
