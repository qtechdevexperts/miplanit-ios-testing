//
//  ContentVC+Collection.swift
//  MiPlanIt
//
//  Created by Febin Paul on 28/10/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation
import UIKit

extension ContentVC: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.showMasterItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "itemCell", for: indexPath) as! ShopMasterItemCell
        cell.configCell(index: indexPath, masterItem: self.showMasterItems[indexPath.row], delegate: self)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenWidth = UIScreen.main.bounds.size.width - 20
        let scaleFactor = (screenWidth / 3) - 5
        return CGSize(width: scaleFactor, height: scaleFactor)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let selectedOption = self.shoppingListOptionType, (selectedOption != .categories && selectedOption != .subCategoryItsItems) {
            self.delegate?.contentVCDelegate(self, addShopItem: self.showMasterItems[indexPath.row])
            return
        }
//        self.showMasterItems.forEach({
//            $0.itemSelected = false
//        })
//        self.showMasterItems[indexPath.row].itemSelected = true
//        self.collectionView?.reloadData()
//        self.delegate?.contentVCDelegate(self, selectedItem: self.showMasterItems[indexPath.row])
//        self.enableItemQuantity()
        
        let shopItem = self.showMasterItems[indexPath.row]
        shopItem.quantity = "1"
        self.delegate?.contentVCDelegate(self, addShopItem: shopItem)
    }
    
}
