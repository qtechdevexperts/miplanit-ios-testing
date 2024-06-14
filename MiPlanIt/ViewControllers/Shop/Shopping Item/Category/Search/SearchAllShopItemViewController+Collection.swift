//
//  SearchAllShopItemViewController+Collection.swift
//  MiPlanIt
//
//  Created by Febin Paul on 05/11/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation
import UIKit

extension SearchAllShopItemViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.showItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "itemCell", for: indexPath) as! ShopMasterItemCell
        cell.configCell(index: indexPath, masterItem: self.showItems[indexPath.row], delegate: self)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenWidth = UIScreen.main.bounds.size.width - 20
        let scaleFactor = (screenWidth / 3) - 5
        return CGSize(width: scaleFactor, height: scaleFactor)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        self.showItems.forEach({
//            $0.itemSelected = false
//        })
//        self.showItems[indexPath.row].itemSelected = true
//        self.currentSelectedShopItem = self.showItems[indexPath.row]
//        self.collectionView.reloadData()
//        self.viewQuantityOption.enablQuantityOption(shopItem: self.showItems[indexPath.row])
        self.collectionView.contentOffset = .zero
        let shopItem = self.showItems[indexPath.row]
        shopItem.quantity = "1"
        self.confirmationCheckOnAdd(shopItem: shopItem)
    }
}
