//
//  ShopAttachmentPopUp+Collection.swift
//  MiPlanIt
//
//  Created by Febin Paul on 22/02/21.
//  Copyright © 2021 Arun. All rights reserved.
//

import Foundation
import UIKit

extension ShopAttachmentPopUp: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.shopListItemCellModel.planItShopListItem.readAttachments().count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifier.shopAttachmentCell, for: indexPath) as! ShopAttachmentPopUpCell
        cell.configCell(self.shopListItemCellModel, index: indexPath)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.viewCollectionContainer.frame.size.width, height: self.viewCollectionContainer.frame.size.height)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let page = Int(scrollView.contentOffset.x) / Int(scrollView.frame.width)
        self.pageControl.currentPage = page
    }
}
