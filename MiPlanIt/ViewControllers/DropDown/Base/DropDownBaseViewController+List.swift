//
//  DropDownBaseViewController+List.swift
//  MiPlanIt
//
//  Created by MS Nischal on 20/03/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

extension DropDownBaseViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.readHeightForCell()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dropDownItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.dropDownCell, for: indexPath) as! DropDownOptionsCell
        let item = self.dropDownItems[indexPath.row]
        if self.itemSelectionDropDown != nil {
            item.isSelected = (self.dropDownItems[indexPath.row].title == self.itemSelectionDropDown?.title)
        }
        cell.configureCell(item: item, indexPath: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.itemSelectionDropDown = self.dropDownItems[indexPath.row]
        guard let selectionDropDown = self.itemSelectionDropDown else {
            return
        }
        self.showOrHideDropDownOptions(false)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.26) {
            self.dismiss(animated: false) {
                self.sendSelectedOption(selectionDropDown)
            }
        }
    }
}
