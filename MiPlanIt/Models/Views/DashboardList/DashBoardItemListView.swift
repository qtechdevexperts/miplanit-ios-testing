//
//  DashBoardView.swift
//  MiPlanIt
//
//  Created by Febin Paul on 21/09/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

protocol DashBoardItemListViewDelegate: class {
    func dashBoardItemListView(_ DashBoardView: DashBoardItemListView, selectedItem: Any)
}

class DashBoardItemListView: UIView {
    
    var dashBordItem: DashboardItems! {
        didSet {
            let group = Dictionary(grouping: self.dashBordItem.items) { (item) -> Date? in
                if let object = item as? DashboardEventItem {
                    return object.start.initialHour()
                }
                else if let object = item as? DashboardToDoItem {
                    if let actualDueDate = object.actualDate {
                        return actualDueDate
                    }
                    return nil
                }
                else if let object = item as? DashboardPurchaseItem {
                    return object.bilDateTime.initialHour()
                }
                else if let object = item as? DashboardShopListItem {
                    if let actualDueDate = object.actualDueDate {
                        return actualDueDate
                    }
                    return nil
                }
                else if let object = item as? DashboardGiftItem {
                    return object.exipryDate
                }
                else { return nil }
            }
            
            let items = group.compactMap { (dateEvent) in
                return DaysItems(date: dateEvent.key, items: dateEvent.value)
            }
            let dateItems = items.filter({ $0.date != nil }).sorted(by: {
                if let firstDate = $0.date, let secondDate = $1.date {
                    return firstDate < secondDate
                }
                return false
            })
            let nilDateItems = items.filter({ $0.date == nil })
            self.groupedItems = dateItems + nilDateItems
        }
    }
    var isCustomDashboard: Bool = false
    var groupedItems: [DaysItems] = []
    var dateSection: DashBoardSection = .today // today, tomorrow, week, all 
    weak var delegate: DashBoardItemListViewDelegate?
    var isLoading: Bool = false
    @IBOutlet weak var viewBG: UIView!
    var collectionViewRowIndex: Int! {
        didSet {
            self.isLoading = false
            self.tableView.reloadData()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.scrollToPosition()
                self.tableView.layoutIfNeeded()
            }
        }
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
