//
//  MasterSearchViewController+List.swift
//  MiPlanIt
//
//  Created by Febin Paul on 22/12/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation
import UIKit

extension MasterSearchViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let value = self.masterSearchItems[self.getSelectedSectionValue()] {
            return value.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return self.configTableCellIn(indexPath, tableView: tableView)
    }
    
    func configTableCellIn(_ indexPath: IndexPath, tableView: UITableView) -> UITableViewCell {
        switch self.masterSearchItems[self.getSelectedSectionValue()]?[indexPath.row] {
        case let events as DashboardEventItem:
            let cell = tableView.dequeueReusableCell(withIdentifier: "eventCell", for: indexPath) as! EventsDetailDashboardCell
            cell.configCell(event: events, index: indexPath, dateSection: .all)
            return cell
        case let toDoItem as DashboardToDoItem:
            let cell = tableView.dequeueReusableCell(withIdentifier: "toDoCell", for: indexPath) as! ToDoDetailDashboardCell
            cell.configCellOnSearch(todo: toDoItem, index: indexPath)
            return cell
        case let shop as DashboardShopListItem:
            let cell =  tableView.dequeueReusableCell(withIdentifier: "shopListItemCell", for: indexPath) as! ShopListItemDetailDashboardCell
            cell.configCell(shopListItem: shop, index: indexPath)
            return cell
        case let gift as DashboardGiftItem:
            let cell =  tableView.dequeueReusableCell(withIdentifier: "giftCell", for: indexPath) as! GiftDetailDashboardCell
            cell.configCell(gift: gift, index: indexPath)
            return cell
        case let purchase as DashboardPurchaseItem:
            let cell =  tableView.dequeueReusableCell(withIdentifier: "purchaseCell", for: indexPath) as! PurchaseDetailDashboardCell
            cell.configCell(purchase: purchase, index: indexPath)
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "eventCell", for: indexPath) as! EventsDetailDashboardCell
            return cell
        }
    }
    
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
////        guard let sectionData =  self.masterSearchItems[section] else {
////            return 0.0
////        }
//        return 5//sectionData.isEmpty ? 0.01 : 50.0
//    }
//
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
////        guard let sectionData = self.masterSearchItems[section], !sectionData.isEmpty  else {
////            return nil
////        }
////        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.dateHeaderCell) as! EventDateHeaderCell
////        cell.configCellData(dataItem: sectionData)
//        return nil
//    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let itemData = self.masterSearchItems[self.getSelectedSectionValue()]?[indexPath.row] else {
            return
        }
        self.openSelectedItem(itemData)
    }
    
}
