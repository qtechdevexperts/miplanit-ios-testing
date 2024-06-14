//
//  CountryCodeCell.swift
//  MiPlanIt
//
//  Created by Nikhil RajG on 17/03/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

class CountryCodeCell: UITableViewCell {
    
    @IBOutlet weak var imageViewCountryFlag: UIImageView!
    
    @IBOutlet weak var labelCountryName: UILabel!
    
    @IBOutlet weak var labelCountryCode: UILabel!
    
    func configure(data country: Country) {
        self.labelCountryName.text = country.name
        self.labelCountryCode.text = "(\(country.phone))"
        self.imageViewCountryFlag.image = UIImage(named: country.icon)
    }
}

