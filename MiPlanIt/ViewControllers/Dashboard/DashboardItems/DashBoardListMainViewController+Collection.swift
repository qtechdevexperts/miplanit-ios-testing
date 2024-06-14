//
//  DashBoardListMainViewController+Collection.swift
//  MiPlanIt
//
//  Created by Febin Paul on 21/09/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation
import UIKit

extension DashBoardListMainViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 7
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionCell", for: indexPath) as! DashBoardListCell
        let row = indexPath.row == 0 ? 4 : indexPath.row < 6 ? indexPath.row - 1 : 0
        cell.configCell(indexPath: row, dashBoardItem: self.dashboardItems[row], section: self.dashBoardSection, delegate: self, isCustomDashboard: self.isCustomDashboard, overDue: self.overDueToDo.count)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.viewListContainer.frame.width, height: self.viewListContainer.frame.height)
    }
    
    

}
