//
//  ShoppingItemDetailViewController+Collection.swift
//  MiPlanIt
//
//  Created by Febin Paul on 23/12/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation
import UIKit

extension ShoppingItemDetailViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.shopItemDetailModel.attachments.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifier.shoppingAttachmentCell, for: indexPath) as! ShoppingAttachmentCollectionViewCell
        cell.configCell(attachment: self.shopItemDetailModel.attachments[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.collectionViewAttachments.frame.width, height: self.collectionViewAttachments.frame.height)
    }
}
