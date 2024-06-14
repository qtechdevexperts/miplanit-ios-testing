//
//  DashboardCollectionViewCell.swift
//  MiPlanIt
//
//  Created by Aneesh Asokan on 19/05/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

class DashboardCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var dashboardName: UILabel!
    @IBOutlet weak var dashboardIcon: UIButton!
    @IBOutlet weak var viewSelection: UIView!
    
    func configureCell(_ dashboard: CustomDashboard) {
        self.dashboardName.text = dashboard.title
        self.dashboardName.font = UIFont(name: dashboard.isSelected ? Fonts.SFUIDisplayMedium : Fonts.SFUIDisplayRegular, size: UIScreen.main.scale == 3 ? 15 : 14)!
        self.dashboardIcon.setImage(UIImage(named: dashboard.icon), for: .normal)
        self.dashboardIcon.setImage(UIImage(named: dashboard.icon+"sel"), for: .selected)
        self.dashboardIcon.isSelected = dashboard.isSelected
        self.viewSelection.backgroundColor = !dashboard.isSelected ? UIColor.clear : .grayLightPlus//UIColor.init(red: 255/255.0, green: 133/255.0, blue: 50/255.0, alpha: 1.0)
    }
}
