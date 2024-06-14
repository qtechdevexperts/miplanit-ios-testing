//
//  AddActivityTagViewController+Collection.swift
//  MiPlanIt
//
//  Created by Aneesh Asokan on 30/04/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

extension AddActivityTagViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.readNumberOfItemsInSection(collectionView)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return self.readCellForIndexPath(collectionView, cellForItemAt: indexPath)
    }
    
    func readNumberOfItemsInSection(_ collectionView: UICollectionView) -> Int {
        switch collectionView {
        case self.collectionView:
            return self.titles.count + (self.canAddTag ? 1 : 0)
        case self.predictionCollectionView:
            return self.predictionTitles.count
        default:
            return 0
        }
    }
    
    func readCellForIndexPath(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch collectionView {
        case self.collectionView:
            if indexPath.row == self.titles.count {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifier.activityAddTagCollectionViewCell,
                for: indexPath) as! ActivityAddTagCollectionViewCell
                cell.configureCell(vc: self)
                return cell
            }
            else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifier.activityTagCollectionViewCell, for: indexPath) as! ActivityTagCollectionViewCell
                cell.configureCell(index: indexPath, text: titles[indexPath.row], vc: self)
                return cell
            }
        case self.predictionCollectionView:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifier.activityPredictedTagCollectionViewCell, for: indexPath) as! ActivityTagCollectionViewCell
            cell.configureCell(index: indexPath, text: self.predictionTitles[indexPath.row].text, vc: self, disableCell: self.titles.contains(self.predictionTitles[indexPath.row].text))
            return cell
        default:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifier.activityTagCollectionViewCell, for: indexPath) as! ActivityTagCollectionViewCell
            return cell
        }
    }
}
