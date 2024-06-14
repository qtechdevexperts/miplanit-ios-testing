//
//  DashboardCardViewPurchaseCell.swift
//  MiPlanIt
//
//  Created by Febin Paul on 03/10/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

class DashboardCardViewPurchaseCell: UITableViewCell {
    
    @IBOutlet weak var labelPurchaseName: UILabel!
    @IBOutlet weak var labelBillDate: UILabel!
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
        self.labelPurchaseName.text = purchase.title
        let billDateTitle: String = Strings.billDate
        let billdate = purchase.bilDateTime.initialHour() == Date().initialHour() ? "Today" : purchase.bilDateTime.stringFromDate(format: DateFormatters.EEEDDMMMYYYY)
        self.labelBillDate.text = billdate.isEmpty ? Strings.empty : (billDateTitle + billdate)
        self.labelType.text = purchase.planItPurchase?.readPurchaseCategoryType() ?? Strings.bills
    }

}
