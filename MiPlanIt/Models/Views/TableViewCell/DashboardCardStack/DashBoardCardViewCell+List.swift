//
//  CardViewDemoViewCell+List.swift
//  SwipeCards
//
//  Created by Febin Paul on 28/09/20.
//  Copyright © 2020 Febin Paul. All rights reserved.
//

import Foundation
import UIKit

extension DashBoardCardViewCell: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.cardView?.cardItemData.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return self.readCell(tableView, cellForRowAt: indexPath)
    }
    
    func readCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)  -> UITableViewCell {
        switch self.cardView.dashboardCard.dashBoardTitle {
        case .event:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellEvent", for: indexPath) as! DashboardCardViewEventCell
            if let event = self.cardView.cardItemData[indexPath.row] as? DashboardEventItem {
                cell.configCell(event: event, index: indexPath, dateSection: self.cardView.activeDateSection)
            }
            return cell
        case .toDo:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellToDo", for: indexPath) as! DashboardCardViewToDoCell
            
            if let todo = self.cardView.cardItemData[indexPath.row] as? DashboardToDoItem {
                cell.configCell(todo: todo, index: indexPath, dateSection: self.cardView.activeDateSection)
            }
            return cell
        case .purchase:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellPurchase", for: indexPath) as! DashboardCardViewPurchaseCell
            if let purchase = self.cardView.cardItemData[indexPath.row] as? DashboardPurchaseItem {
                cell.configCell(purchase: purchase, index: indexPath)
            }
            return cell
        case .shopping:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellShopListItem", for: indexPath) as! DashboardCardViewShopListItemCell
            if let shopListItem = self.cardView.cardItemData[indexPath.row] as? DashboardShopListItem {
                cell.configCell(shopListItem: shopListItem, index: indexPath)
            }
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellGiftCard", for: indexPath) as! DashboardCardViewGiftCell
            if let gift = self.cardView.cardItemData[indexPath.row] as? DashboardGiftItem {
                cell.configCell(gift: gift, index: indexPath, dateSection: self.cardView.activeDateSection)
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.delegate?.dashBoardCardViewCell(self, selectedItem: self.cardView.cardItemData[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        
        if let items = self.cardView?.cardItemData, items.count > 0 {
            switch self.cardView?.cardItemData[0] {
            case is DashboardEventItem:
                return tableView.frame.size.height - 72
            case is DashboardToDoItem:
                return tableView.frame.size.height - 74
            case is DashboardShopListItem:
                return tableView.frame.size.height - 72
            case is DashboardGiftItem:
                return tableView.frame.size.height - 77
            case is DashboardPurchaseItem:
                return tableView.frame.size.height - 72
            default:
                return 0.1
            }
        }
        return 0.1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.1
    }
}
