//
//  AddActivityTagViewController+Table.swift
//  MiPlanIt
//
//  Created by Aneesh Asokan on 29/04/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

extension AddActivityTagViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.localTags.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.cellTagSelect, for: indexPath) as! TagListCell
        cell.configCell(tag: self.localTags[indexPath.row], index: indexPath, isSelected: self.titles.contains(self.localTags[indexPath.row].tag ?? Strings.empty))
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard self.canAddTag, let tag = self.localTags[indexPath.row].tag else {
            return
        }
        if let cell = tableView.cellForRow(at: indexPath) as? TagListCell, let cellTag = cell.labelTagName.text {
            cell.buttonSelect.isSelected ? self.titles.removeAll(where: {$0 == cellTag}) : self.titles.append(tag)
            cell.buttonSelect.isSelected = !cell.buttonSelect.isSelected
            self.tableViewTags.reloadData()
        }
    }
}
