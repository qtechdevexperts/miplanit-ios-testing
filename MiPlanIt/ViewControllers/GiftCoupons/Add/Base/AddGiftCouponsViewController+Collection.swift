//
//  AddPurchaseViewController+Collection.swift
//  MiPlanIt
//
//  Created by Aneesh Asokan on 30/04/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

extension AddGiftCouponsViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.giftCouponModel.tags.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == self.giftCouponModel.tags.count {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifier.giftCouponAddTagCollectionViewCell,
            for: indexPath) as! GiftCouponAddTagCollectionViewCell
            cell.configureCell(vc: self)
            return cell
        }
        else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifier.giftCouponTagCollectionViewCell, for: indexPath) as! GiftCouponTagCollectionViewCell
            cell.configureCell(index: indexPath, text: self.giftCouponModel.tags[indexPath.row], vc: self)
            return cell
        }
    }
}
