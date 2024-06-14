//
//  CreateEventsViewController+Collection.swift
//  MiPlanIt
//
//  Created by Febin Paul on 08/04/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation
import UIKit

extension CreateEventsViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.titles.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == self.titles.count {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifier.eventAddTagCollectionViewCell,
            for: indexPath) as! EventAddTagCollectionViewCell
            cell.configureCell(vc: self)
            return cell
        }
        else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifier.eventTagCollectionViewCell, for: indexPath) as! EventTagCollectionViewCell
            cell.configureCell(index: indexPath, text: titles[indexPath.row], vc: self)
            return cell
        }
    }
}
