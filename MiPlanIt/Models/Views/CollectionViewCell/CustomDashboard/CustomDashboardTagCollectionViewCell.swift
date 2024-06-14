//
//  CustomDashboardTagCollectionViewCell.swift
//  MiPlanIt
//
//  Created by Aneesh Asokan on 23/11/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

protocol CustomDashboardTagCollectionViewCellDelegate: AnyObject {
    func customDashboardTagCollectionViewCell(_ customDashboardTagCollectionViewCell: CustomDashboardTagCollectionViewCell, select status: Bool)
}

class CustomDashboardTagCollectionViewCell: UICollectionViewCell {
    
    var dashboardTag: DashboardTag!
    weak var delegate: CustomDashboardTagCollectionViewCellDelegate?
    
    @IBOutlet weak var buttonTag: UIButton!
    
    @IBAction func tagbuttonClicked(_ sender: UIButton) {
        self.dashboardTag.isSelected = !sender.isSelected
        self.delegate?.customDashboardTagCollectionViewCell(self, select: self.dashboardTag.isSelected)
    }
    
    func configureCell(tag: DashboardTag, delegate: CustomDashboardTagCollectionViewCellDelegate) {
        self.dashboardTag = tag
        self.delegate = delegate
        self.buttonTag.setTitle(tag.stringtag, for: .normal)
        self.buttonTag.isSelected = tag.isSelected
        self.updateTagButton()
    }
    
    func updateTagButton() {
        self.buttonTag.backgroundColor = self.buttonTag.isSelected ? UIColor.init(red: 1.0, green: 163/255.0, blue: 68/255.0, alpha: 1.0) : .clear
        self.buttonTag.bordorWidth = self.buttonTag.isSelected ? 0 : 0.5
    }
    
    
}
