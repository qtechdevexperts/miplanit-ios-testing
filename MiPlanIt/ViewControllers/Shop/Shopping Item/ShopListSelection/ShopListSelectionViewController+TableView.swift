//
//  ShopListSelectionViewController+TableView.swift
//  MiPlanIt
//
//  Created by Febin Paul on 13/11/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation
import UIKit

extension ShopListSelectionViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.allShopListSelectionOptions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.shopListSelectionCell, for: indexPath) as! ShopListSelectionTableViewCell
        cell.configCell(index: indexPath, delegate: self, shopListItem: self.allShopListSelectionOptions[indexPath.row])
        return cell
    }
    
    
}
