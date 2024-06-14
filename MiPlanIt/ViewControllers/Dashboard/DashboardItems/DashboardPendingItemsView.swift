//
//  DashboardPendingItemsView.swift
//  MiPlanIt
//
//  Created by fsadmin on 02/09/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

class DashboardPendingItemsView: UIView {

    var dashBoardItemData: [DashboardPendingItem] = []
    var selectedIndex = 0
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelPendingCount: UILabel!
}

extension DashboardPendingItemsView : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return self.dashBoardItemData[selectedIndex].itemData.count
        return self.dashBoardItemData.count > 0 ? 5 : 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.dashBoardItemData[self.selectedIndex].title == "Events" {
            self.labelTitle.text = "Events"
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellEvent", for: indexPath)
            return cell
        } else if self.dashBoardItemData[self.selectedIndex].title == "To Do" {
            self.labelTitle.text = "To Do"
            let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.cell, for: indexPath)
            
            return cell
        } else if self.dashBoardItemData[self.selectedIndex].title == "Shopping" {
            self.labelTitle.text = "Shopping"
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellShopping", for: indexPath)
            return cell
        } else if self.dashBoardItemData[self.selectedIndex].title == "Receipts & Bills"{
            self.labelTitle.text = "Receipts & Bills"
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellPurchase", for: indexPath)
            return cell
        }
        else {
            self.labelTitle.text = "Coupons & Gifts"
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellGiftCard", for: indexPath)
            return cell
        }
    }
}


class DashboardPendingItem {
    var title: String
    var itemData: [Any]
    
    init(itemName: String, itemData: [Any]) {
        self.title = itemName
        self.itemData = itemData
    }
}
