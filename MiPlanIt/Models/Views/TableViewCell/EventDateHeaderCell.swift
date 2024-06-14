//
//  EventDateHeaderCell.swift
//  MiPlanIt
//
//  Created by Febin Paul on 16/09/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

class EventDateHeaderCell: UITableViewCell {

    @IBOutlet weak var labelEventDate: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configCell(date: Date?) {
        self.labelEventDate.text = date?.stringFromDate(format: DateFormatters.EEEDDHMMMHYYY) ?? Strings.empty
    }
    
    func configCellData(dataItem: Any) {
        if dataItem is [DashboardEventItem] {
            self.labelEventDate.text = "Events"
        }
        else if dataItem is [DashboardToDoItem] {
            self.labelEventDate.text = "To Do"
        }
        else if dataItem is [DashboardShopListItem] {
            self.labelEventDate.text = "Shopping"
        }
        else if dataItem is [DashboardGiftItem] {
            self.labelEventDate.text = "Coupons & Gifts"
        }
        else if dataItem is [DashboardPurchaseItem] {
            self.labelEventDate.text = "Receipts & Bills"
        }
    }

}
