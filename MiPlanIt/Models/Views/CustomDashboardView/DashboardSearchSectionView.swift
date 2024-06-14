//
//  DashboardSearchSectionView.swift
//  MiPlanIt
//
//  Created by Aneesh Asokan on 08/01/21.
//  Copyright © 2021 Arun. All rights reserved.
//

import UIKit

protocol DashboardSearchSectionViewDelegate: class {
    func dashboardSearchSectionView(_ view: DashboardSearchSectionView, withSelectedOption option: DashboardSectionView)
}

class DashboardSearchSectionView: UIView {
    
    weak var delegate: DashboardSearchSectionViewDelegate?

    @IBOutlet weak var collectionView: UICollectionView!
    
    var dashboardSections: [DashboardSectionView] = [] {
        didSet {
            self.collectionView.reloadData()
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        self.dashboardSections = [DashboardSectionView(title: "Events", icon: "event1", isSelected: true, dashboardSectionType: .event),DashboardSectionView(title: "To Do", icon: "event1", dashboardSectionType: .toDo),DashboardSectionView(title: "Shopping", icon: "shopping1", dashboardSectionType: .shopping),DashboardSectionView(title: "Coupons & Gifts", icon: "gift1", dashboardSectionType: .giftCard), DashboardSectionView(title: "Receipts & Bills", icon: "event1", dashboardSectionType: .purchase)]
    }
}

extension DashboardSearchSectionView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {


     func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dashboardSections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: Int(collectionView.frame.size.width) / 5, height: 87)
    }
    
     func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifier.cell, for: indexPath) as! DashboardSectionCollectionViewCell
        cell.configureCell(self.dashboardSections[indexPath.row])
        return cell
    }
 
     func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.dashboardSections.forEach({ $0.isSelected = false })
        self.dashboardSections[indexPath.row].isSelected = true
        self.collectionView.reloadData()
        self.delegate?.dashboardSearchSectionView(self, withSelectedOption: self.dashboardSections[indexPath.row])
        collectionView.scrollToItem(at: indexPath, at: .left, animated: true)
    }
}
