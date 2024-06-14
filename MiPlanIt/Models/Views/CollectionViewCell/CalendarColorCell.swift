//
//  CalendarColorCell.swift
//  MiPlanIt
//
//  Created by Febin Paul on 03/06/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

class CalendarColorCell: UICollectionViewCell {
    
    @IBOutlet weak var buttonColor: UIButton!
    
    func configColor(calendarColor: CalendarColor) {
        self.buttonColor.setImage(UIImage(named: calendarColor.colorCode.colorCodeImageName), for: .normal)
        self.buttonColor.setImage(UIImage(named: calendarColor.colorCode.colorCodeImageNameSelected), for: .selected)
        self.buttonColor.isSelected = calendarColor.isSelected
    }
    
}
