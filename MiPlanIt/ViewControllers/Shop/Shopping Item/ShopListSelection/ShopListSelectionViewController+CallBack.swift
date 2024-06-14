//
//  ShopListSelectionViewController+CallBack.swift
//  MiPlanIt
//
//  Created by Febin Paul on 13/11/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation


extension ShopListSelectionViewController: ShopListSelectionTableViewCellDelegate {
    
    func shopListSelectionTableViewCell(_ shopListSelectionTableViewCell: ShopListSelectionTableViewCell, onSelect index: IndexPath) {
        self.allShopListSelectionOptions.forEach({ $0.isSelected = false })
        self.allShopListSelectionOptions[index.row].isSelected = true
        self.currentShopList = self.allShopListSelectionOptions[index.row].shopList
        self.tableView.reloadData()
    }
    
}
