//
//  CouponStatusSelectionView.swift
//  MiPlanIt
//
//  Created by Nikhil RajG on 28/04/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

protocol CouponStatusSelectionViewDelegate: class {
    func couponStatusSelectionView(_ view: CouponStatusSelectionView, withSelectedOption option: CouponStatus)
}

class CouponStatusSelectionView: UIView {
    
    weak var delegate: CouponStatusSelectionViewDelegate?

    @IBOutlet weak var collectionView: UICollectionView!
    
    var couponStatuses: [CouponStatus] = [] {
        didSet {
            self.collectionView.reloadData()
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        self.couponStatuses = [CouponStatus(title: "Active", type: .active, isSelected: true, icon: "active1"),
                               CouponStatus(title: "Redeemed", type: .redeemed, icon: "redeemed1"),
                               CouponStatus(title: "Expired", type: .expired, icon: "expired1")]
    }
    
    func clearSelection() {
        self.couponStatuses.forEach { (model) in
            model.isSelected = false
        }
    }
}

extension CouponStatusSelectionView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {


     func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.couponStatuses.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width:collectionView.bounds.width / 3 , height:70)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
     func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifier.cell, for: indexPath) as! CouponStatusCollectionCell
        cell.configureCell(self.couponStatuses[indexPath.row])
        return cell
    }
 
     func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.couponStatuses.forEach({ $0.isSelected = false })
        self.couponStatuses[indexPath.row].isSelected = true
        self.collectionView.reloadData()
        self.delegate?.couponStatusSelectionView(self, withSelectedOption: self.couponStatuses[indexPath.row])
        collectionView.scrollToItem(at: indexPath, at: .left, animated: true)
//        if indexPath.row > 2 {
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
//                collectionView.selectItem(at: IndexPath(item: indexPath.row-3, section: 0), animated: false, scrollPosition: .left)
//                self.clearSelection()
//                self.couponStatuses[indexPath.row-3].isSelected = true
//                self.collectionView.reloadData()
//                collectionView.scrollToItem(at: IndexPath(item: indexPath.row-3, section: 0), at: .left, animated: false)
//            }
//        }
    }
}
