//
//  ContentVC+Callback.swift
//  MiPlanIt
//
//  Created by Febin Paul on 28/10/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation


extension ContentVC : ShopMasterItemCellDelegate {
    
    func shopMasterItemCell(_ shopMasterItemCell: ShopMasterItemCell, customQuantity: String) {
        self.delegate?.contentVCDelegate(self, customQuantity: customQuantity)
    }
    
    func shopMasterItemCell(_ shopMasterItemCell: ShopMasterItemCell, addQuantity: String) {
        self.shopMasterItems[shopMasterItemCell.index.row].itemSelected = false
        self.collectionView?.reloadData()
        self.collectionView?.contentOffset = .zero
        self.delegate?.contentVCDelegate(self, addShopItem: self.shopMasterItems[shopMasterItemCell.index.row])
    }
    
    func shopMasterItemCell(_ shopMasterItemCell: ShopMasterItemCell, onEdit: IndexPath) {
        self.collectionView?.contentOffset = CGPoint(x: 0, y: shopMasterItemCell.frame.minY)
    }
}
