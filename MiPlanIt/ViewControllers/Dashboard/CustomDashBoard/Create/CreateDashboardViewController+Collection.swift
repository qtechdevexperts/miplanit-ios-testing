//
//  CreateDashboardViewController+Collection.swift
//  MiPlanIt
//
//  Created by Aneesh Asokan on 23/11/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation
extension CreateDashboardViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.showAddedTags.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifier.collectionViewTagCell, for: indexPath) as! CustomDashboardTagCollectionViewCell
        cell.configureCell(tag: self.showAddedTags[indexPath.row], delegate: self)
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemSize = self.showAddedTags[indexPath.row].stringtag.size(withAttributes: [NSAttributedString.Key.font : UIFont(name: Fonts.SFUIDisplayRegular, size: 15)!])
        return CGSize(width: (itemSize.width < 60 ? 60 : itemSize.width)+40, height: 36)
    }
}
