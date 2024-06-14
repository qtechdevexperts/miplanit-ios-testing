//
//  DashBoardView+List.swift
//  MiPlanIt
//
//  Created by Febin Paul on 21/09/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation
import UIKit

extension DashBoardItemListView: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.groupedItems.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.groupedItems[section].items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return self.configTableCellIn(indexPath, tableView: tableView)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if self.isCustomDashboard && self.dateSection == .all { return 0.1 }
        if self.dateSection != .all && self.dateSection != .week  { return 0.1 }
        else { return self.groupedItems[section].date == nil ? 20.0 : 50.0 }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == self.groupedItems.count - 1 && self.groupedItems[section].items.count > 0 {
            switch self.groupedItems[section].items[0] {
            case is DashboardEventItem:
                return tableView.frame.size.height - 88.5
            case is DashboardToDoItem:
                return tableView.frame.size.height - 90
            case is DashboardShopListItem:
                return tableView.frame.size.height - 93.5
            case is DashboardGiftItem:
                return tableView.frame.size.height - 75
            case is DashboardPurchaseItem:
                return tableView.frame.size.height - 68.5
            default:
                return 0.1
            }
        }
        return 0.1
    }
    
    func configTableCellIn(_ indexPath: IndexPath, tableView: UITableView) -> UITableViewCell {
        switch self.collectionViewRowIndex {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "eventCell", for: indexPath) as! EventsDetailDashboardCell
            if let events = self.groupedItems[indexPath.section].items[indexPath.row] as? DashboardEventItem {
                cell.configCell(event: events, index: indexPath, dateSection: self.dateSection)
            }
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "toDoCell", for: indexPath) as! ToDoDetailDashboardCell
            if let toDoItem = self.groupedItems[indexPath.section].items[indexPath.row] as? DashboardToDoItem {
                cell.configCell(todo: toDoItem, index: indexPath, dateSection: self.dateSection)
            }
            return cell
        case 2:
            let cell =  tableView.dequeueReusableCell(withIdentifier: "shopListItemCell", for: indexPath) as! ShopListItemDetailDashboardCell
            if let purchase = self.groupedItems[indexPath.section].items[indexPath.row] as? DashboardShopListItem {
                cell.configCell(shopListItem: purchase, index: indexPath)
            }
            return cell
        case 3:
            let cell =  tableView.dequeueReusableCell(withIdentifier: "giftCell", for: indexPath) as! GiftDetailDashboardCell
            if let gift = self.groupedItems[indexPath.section].items[indexPath.row] as? DashboardGiftItem {
                cell.configCell(gift: gift, index: indexPath)
            }
            return cell
        default:
            let cell =  tableView.dequeueReusableCell(withIdentifier: "purchaseCell", for: indexPath) as! PurchaseDetailDashboardCell
            if let purchase = self.groupedItems[indexPath.section].items[indexPath.row] as? DashboardPurchaseItem {
                cell.configCell(purchase: purchase, index: indexPath)
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if self.isCustomDashboard && self.dateSection == .all { return nil }
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.dateHeaderCell) as! EventDateHeaderCell
        cell.configCell(date: self.groupedItems[section].date)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
         self.delegate?.dashBoardItemListView(self, selectedItem: self.groupedItems[indexPath.section].items[indexPath.row])
    }
    
}
 
