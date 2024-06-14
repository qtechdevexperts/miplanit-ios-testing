//
//  CurrencyCodeViewController+List.swift
//  MiPlanIt
//
//  Created by Aneesh Asokan on 20/01/21.
//  Copyright © 2021 Arun. All rights reserved.
//

import UIKit

extension CurrencyCodeViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 54.0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.searchDropDownItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.dropDownCell, for: indexPath) as! CurrencyTableViewCell
        let item = self.searchDropDownItems[indexPath.row]
        var isSelected = false
        if self.itemSelectionDropDown != nil {
            isSelected = (self.searchDropDownItems[indexPath.row]["code"] == self.itemSelectionDropDown?["code"])
        }
        cell.configureCell(item: item, indexPath: indexPath, isSelected: isSelected)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.itemSelectionDropDown = self.searchDropDownItems[indexPath.row]
        tableView.reloadData()
    }
}
