//
//  PurchaseDetailDashboardCell.swift
//  MiPlanIt
//
//  Created by Febin Paul on 09/10/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

class PurchaseDetailDashboardCell: UITableViewCell {
    
    var index: IndexPath!
    var redColorFont: UIColor = UIColor(red: 243/255, green: 119/255, blue: 91/255, alpha: 1.0)
    var normalColorFont: UIColor = UIColor(red: 118/255, green: 136/255, blue: 150/255, alpha: 1.0)
    
    @IBOutlet weak var labelPurchaseItemName: UILabel!
    @IBOutlet weak var labelPurchaseBillDate: UILabel!
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var labelType: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configCell(purchase: DashboardPurchaseItem, index: IndexPath) {
        self.index = index
        self.labelPurchaseItemName.text = purchase.title
        let billDate = purchase.bilDateTime.stringFromDate(format: DateFormatters.EEEDDMMMYYYY)
        let billDateTitle: String = Strings.billDate
        if purchase.bilDateTime.initialHour() == Date().initialHour() {
            self.labelPurchaseBillDate.text = billDateTitle + "Today"
        }
        else {
            self.labelPurchaseBillDate.text = billDateTitle + billDate
        }
        self.labelType.text = purchase.planItPurchase?.readPurchaseCategoryType() ?? Strings.bills
    }

}
