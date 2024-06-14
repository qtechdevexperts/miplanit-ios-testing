//
//  DashBoardItemListView+Action.swift
//  MiPlanIt
//
//  Created by Febin Paul on 13/10/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

extension DashBoardItemListView {
    
    func isAllSectionEvent() -> Bool {
        return self.dateSection == .all && self.dashBordItem.type == .event
    }
    
    func scrollToPosition() {
        var frame = CGRect.zero
        frame.size.height = .leastNormalMagnitude
        self.tableView.tableHeaderView = UIView(frame: frame)
        guard self.dateSection == .today else { return }
         if let item = groupedItems.first {
            if let object = item.items as? [DashboardEventItem] {
                let totalCells = self.tableView.numberOfRows(inSection: 0)
                if let index = object.firstIndex(where: { (item) -> Bool in
                    item.start >= Date()
                }), index < totalCells {
                    self.tableView.scrollToRow(at: IndexPath(row: index, section: 0), at: .top, animated: false)
                }
                else if let index = object.firstIndex(where: { (item) -> Bool in
                    item.end >= Date()
                }), index < totalCells {
                    self.tableView.scrollToRow(at: IndexPath(row: index, section: 0), at: .top, animated: false)
                }
                else if totalCells > 0{
                    self.tableView.scrollToRow(at: IndexPath(row: totalCells - 1, section: 0), at: .top, animated: true)
                }
            }
            else if let object = item.items as? [DashboardToDoItem] {
                if let index = object.firstIndex(where: { (item) -> Bool in
                    item.initialDate.initialHour() == Date().initialHour()
                }), index < self.tableView.numberOfRows(inSection: 0) {
                    self.tableView.scrollToRow(at: IndexPath(row: index, section: 0), at: .top, animated: false)
                }
            }
            else if let object = item.items as? [DashboardPurchaseItem] {
                if let index = object.firstIndex(where: { (item) -> Bool in
                    item.createdDate.initialHour() == Date().initialHour()
                }), index < self.tableView.numberOfRows(inSection: 0) {
                    self.tableView.scrollToRow(at: IndexPath(row: index, section: 0), at: .top, animated: false)
                }
            }
            else if let object = item.items as? [DashboardGiftItem] {
                if let index = object.firstIndex(where: { (item) -> Bool in
                    item.createdDate.initialHour() == Date().initialHour()
                }), index < self.tableView.numberOfRows(inSection: 0) {
                    self.tableView.scrollToRow(at: IndexPath(row: index, section: 0), at: .top, animated: false)
                }
            }
            else if let object = item.items as? [DashboardShopListItem] {
                if let index = object.firstIndex(where: { (item) -> Bool in
                    item.duedate.initialHour() == Date().initialHour()
                }), index < self.tableView.numberOfRows(inSection: 0) {
                    self.tableView.scrollToRow(at: IndexPath(row: index, section: 0), at: .top, animated: false)
                }
            }
        }
    }
}
