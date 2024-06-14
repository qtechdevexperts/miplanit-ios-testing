//
//  ContentVC+Action.swift
//  MiPlanIt
//
//  Created by Febin Paul on 05/11/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

extension ContentVC {
    
    func initilizeUIComponent() {
        self.updateItemWithSearch()
    }
    
    func updateListOrder(_ comparisonResult: ComparisonResult) {
        switch comparisonResult {
        case .orderedAscending:
            self.showMasterItems.sort { (item1, item2) -> Bool in
                item1.itemName.localizedCaseInsensitiveCompare(item2.itemName) == .orderedAscending
            }
        default:
            self.showMasterItems.sort { (item1, item2) -> Bool in
                item1.itemName.localizedCaseInsensitiveCompare(item2.itemName) == .orderedDescending
            }
        }
        self.collectionView?.reloadData()
    }
    
    func resetCollectionData() {
        self.showMasterItems.forEach { (item) in
            item.itemSelected = false
        }
        self.collectionView?.reloadData()
    }
    
    func updateItemWithSearch() {
        if !self.searchText.isEmpty {
            self.showMasterItems = self.shopMasterItems.filter({ $0.itemName.lowercased().contains(self.searchText.lowercased()) })
            self.delegate?.contentVCDelegate(self, noSearchData: self.showMasterItems.isEmpty)
            return
        }
        self.showMasterItems = self.shopMasterItems
    }
    
    func updateMultiSellectedArray() {
        self.multiSelectedShopItems = self.showMasterItems.filter({ $0.itemSelected })
    }
    
    func resetScrollOffset() {
        self.collectionView?.setContentOffset(.zero, animated: false)
    }
    
}
