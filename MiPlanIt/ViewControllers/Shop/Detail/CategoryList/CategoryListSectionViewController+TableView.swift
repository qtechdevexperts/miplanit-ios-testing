//
//  CategoryListSectionViewController+TableView.swift
//  MiPlanIt
//
//  Created by Febin Paul on 13/11/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation
import UIKit

extension CategoryListSectionViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.categoryItems.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.categoryItems[section].isExpanded ? self.categoryItems[section].shopSubCategory.count : 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.subCategoryCell, for: indexPath) as! ShopSubCategoryTableViewCell
        cell.configCell(index: indexPath, subCategory: self.categoryItems[indexPath.section].shopSubCategory[indexPath.row], delegate: self)
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.mainCategoryCell) as! ShopMainCategoryTableViewCell
        cell.configCell(section: section, mainCategory: self.categoryItems[section], delegate: self)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50.0
    }
    
}
