//
//  RepeatMultiSelectionDropDownController+List.swift
//  MiPlanIt
//
//  Created by Febin Paul on 23/06/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation


extension RepeatMultiSelectionDropDownController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.readHeightForCell()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dropDownItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellRepeatMultiSelect", for: indexPath) as! RepeatMultiSelectCell
        cell.configCell(item: self.dropDownItems[indexPath.row], index: indexPath, isSelected: self.isValueSelected(index: indexPath))
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? RepeatMultiSelectCell {
            self.setDidSelect(indexPath: indexPath, cell: cell)
            self.tableViewDropDownOptions.reloadData()
        }
    }
    
    func setDidSelect(indexPath: IndexPath, cell: RepeatMultiSelectCell) {
        guard let frequecy = self.repeatModel?.frequency else {
            return
        }
        if cell.buttonSelect.isSelected {
            if self.itemSelectedDropDown.count == 1 {
                return
            }
            if frequecy.dropDownType == .eEveryWeek, let arrayDropDown = self.dropDownItems as? [DropDownItem] {
                self.itemSelectedDropDown.removeAll { (dropDownItem) -> Bool in
                    if let item = dropDownItem as? DropDownItem {
                        return item.dropDownType == arrayDropDown[cell.index.row].dropDownType
                    }
                    return false
                }
            }
            else if frequecy.dropDownType == .eEveryMonth, let arrayDropDown = self.dropDownItems as? [Int] {
                self.itemSelectedDropDown.removeAll { (dropDownItem) -> Bool in
                    if let item = dropDownItem as? Int {
                        return item == arrayDropDown[cell.index.row]
                    }
                    return false
                }
            }
        }
        else {
            if frequecy.dropDownType == .eEveryMonth {
                self.itemSelectedDropDown.removeAll()
            }
            self.itemSelectedDropDown.append(self.dropDownItems[cell.index.row])
        }
    }
    
    func isValueSelected(index: IndexPath) -> Bool {
        guard let frequecy = self.repeatModel?.frequency else {
            return false
        }
        if frequecy.dropDownType == .eEveryWeek, let arrayDropDown = self.dropDownItems as? [DropDownItem], let selectedItem = self.itemSelectedDropDown as? [DropDownItem] {
            let containsText = selectedItem.contains { (item) -> Bool in
                return item.dropDownType == arrayDropDown[index.row].dropDownType
            }
            return containsText
        }
        else if frequecy.dropDownType == .eEveryMonth, let arrayDropDown = self.dropDownItems as? [Int], let selectedItem = self.itemSelectedDropDown as? [Int] {
            let containsText = selectedItem.contains { (item) -> Bool in
                return item == arrayDropDown[index.row]
            }
            return containsText
        }
        return false
        
    }
}
