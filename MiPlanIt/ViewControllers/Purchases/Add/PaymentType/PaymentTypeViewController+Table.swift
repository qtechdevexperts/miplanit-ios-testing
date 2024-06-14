//
//  PaymentTypeViewController+Table.swift
//  MiPlanIt
//
//  Created by Aneesh Asokan on 02/05/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

extension PaymentTypeViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.savedCards.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.cellCardSelected, for: indexPath) as! SavedCardCell
        cell.configureCell(item: self.savedCards[indexPath.row], indexPath: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard !self.imageTickMarkCard.isHidden else { return }
        self.savedCards.forEach({$0.isSelected = false})
        self.savedCards[indexPath.row].isSelected = !self.savedCards[indexPath.row].isSelected
        self.tableViewCards.reloadData()
    }
}

