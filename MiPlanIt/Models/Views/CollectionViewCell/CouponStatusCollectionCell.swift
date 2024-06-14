//
//  CouponStatusCollectionCell.swift
//  MiPlanIt
//
//  Created by Aneesh Asokan on 03/05/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

class CouponStatusCollectionCell: UICollectionViewCell {
    @IBOutlet weak var labelCouponStataus: UILabel!
    @IBOutlet weak var dashboardIcon: UIButton!
    @IBOutlet weak var viewSelection: UIView!
    
    func configureCell(_ status: CouponStatus) {
        self.labelCouponStataus.text = status.title
        self.dashboardIcon.setImage(UIImage(named: status.icon), for: .normal)
        self.dashboardIcon.setImage(UIImage(named: status.icon+"sel"), for: .selected)
        self.dashboardIcon.isSelected = status.isSelected
        self.viewSelection.backgroundColor = !status.isSelected ? UIColor.clear : UIColor.init(red: 255/255.0, green: 76/255.0, blue: 122/255.0, alpha: 1.0)
    }
}
