//
//  DashBoardViewController+Table.swift
//  MiPlanIt
//
//  Created by Aneesh Asokan on 19/05/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

extension DashBoardViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.cellDashboardItem, for: indexPath) as! DashboardItemTableViewCell
        cell.configureCustomDashboardItem(atIndexPath: indexPath)
        return cell
    }
}

extension DashBoardViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let page = Int(scrollView.contentOffset.x) / Int(scrollView.frame.width)
        self.pageControl.currentPage = page
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifier.cell, for: indexPath) as! DashboardItemsCollectionViewCell
        cell.configureCell(dashBoardItem:  self.dashboardItems[indexPath.row], activeSection: self.activeDashBoardSection)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.size.width/2 - 10
        let height = collectionView.frame.size.height/2 - 8
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if !self.isFindingData(index: indexPath.row) {
            self.performSegue(withIdentifier: Segues.toListDetail, sender: (self.dashboardItems, indexPath.row))
        }
    }
}

