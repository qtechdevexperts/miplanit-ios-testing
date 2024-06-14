//
//  ReOrderCategoryViewController+List.swift
//  MiPlanIt
//
//  Created by Febin Paul on 28/04/21.
//  Copyright © 2021 Arun. All rights reserved.
//

import Foundation
import UIKit

extension ReOrderCategoryViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.shopListCategory.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.mainCategoryCell, for: indexPath) as! ShopMainCategoryTableViewCell
        cell.configCell(section: self.shopListCategory[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let itemToMove = self.shopListCategory[sourceIndexPath.row]
        self.shopListCategory.remove(at: sourceIndexPath.row)
        self.shopListCategory.insert(itemToMove, at: destinationIndexPath.row)
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
       return .none
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
}
