//
//  AddPurchaseViewController+Collection.swift
//  MiPlanIt
//
//  Created by Aneesh Asokan on 30/04/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation
extension AddPurchaseViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.purchaseModel.tags.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == self.purchaseModel.tags.count {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifier.purchaseAddTagCollectionViewCell,
            for: indexPath) as! PurchaseAddTagCollectionViewCell
            cell.configureCell(vc: self)
            return cell
        }
        else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifier.purchaseTagCollectionViewCell, for: indexPath) as! PurchaseTagCollectionViewCell
            cell.configureCell(index: indexPath, text: self.purchaseModel.tags[indexPath.row], vc: self)
            return cell
        }
    }
}
