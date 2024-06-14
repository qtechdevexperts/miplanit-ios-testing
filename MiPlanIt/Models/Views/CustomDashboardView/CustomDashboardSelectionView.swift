//
//  CouponStatusSelectionView.swift
//  MiPlanIt
//
//  Created by Nikhil RajG on 28/04/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

protocol CustomDashboardSelectionViewDelegate: AnyObject {
    func customDashboardSelectionView(_ view: CustomDashboardSelectionView, withSelectedOption option: CustomDashboard)
}

class CustomDashboardSelectionView: UIView {
    
    weak var delegate: CustomDashboardSelectionViewDelegate?
    var isCustomDashboard: Bool = false {
        didSet {
            self.collectionView.reloadData()
        }
    }

    @IBOutlet weak var collectionView: UICollectionView!
    
    var customDashboards: [CustomDashboard] = [] {
        didSet {
            self.collectionView.reloadData()
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        self.customDashboards = [CustomDashboard(title: "Today", icon: "today1", isSelected: true, type: DashBoardSection.today),CustomDashboard(title: "Tomorrow", icon: "tomorrow1", type: DashBoardSection.tomorrow),CustomDashboard(title: "This Week", icon: "thisWeek1", type: DashBoardSection.week),CustomDashboard(title: "Upcoming", icon: "all1", type: DashBoardSection.all)]
    }
}

extension CustomDashboardSelectionView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {


     func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.customDashboards.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: Int(collectionView.frame.size.width) / self.customDashboards.count, height: 70)
    }
    
     func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifier.cell, for: indexPath) as! DashboardCollectionViewCell
        cell.configureCell(self.customDashboards[indexPath.row])
        return cell
    }
 
     func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.customDashboards.forEach({ $0.isSelected = false })
        self.customDashboards[indexPath.row].isSelected = true
        self.collectionView.reloadData()
        self.delegate?.customDashboardSelectionView(self, withSelectedOption: self.customDashboards[indexPath.row])
        collectionView.scrollToItem(at: indexPath, at: .left, animated: true)
    }
}
