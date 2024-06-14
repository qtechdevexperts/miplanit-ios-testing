//
//  RepeatDropDownBaseViewController+List.swift
//  MiPlanIt
//
//  Created by Febin Paul on 05/05/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

extension RepeatDropDownBaseViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.readHeightForCell()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dropDownItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.dropDownCell, for: indexPath) as! RepeatDropDownOptionCell
        cell.configureCell(item: self.dropDownItems[indexPath.row], indexPath: indexPath, selecteDropDown: self.itemSelectionDropDown)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        self.itemSelectionDropDown = self.dropDownItems[indexPath.row]
        guard let selectionDropDown = self.itemSelectionDropDown else {
            return
        }
        self.showOrHideDropDownOptions(false)
        self.sendSelectedOption(RepeatDropDown(dropDownItem: selectionDropDown))
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.26) {
            self.dismiss(animated: false, completion: nil)
        }
    }
}

