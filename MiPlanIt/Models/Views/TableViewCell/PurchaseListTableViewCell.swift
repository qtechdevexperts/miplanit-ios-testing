//
//  PurchaseListTableViewCell.swift
//  MiPlanIt
//
//  Created by Aneesh Asokan on 29/04/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

class PurchaseListTableViewCell: UITableViewCell {
    
    var indexPath: IndexPath!
    
    @IBOutlet weak var labelPurchaseName: UILabel!
    @IBOutlet weak var labelStoreName: UILabel!
    @IBOutlet weak var labelDate: UILabel!
    @IBOutlet weak var labelType: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func configurePurchase(_ purchase: PlanItPurchase, atIndexPath indexPath: IndexPath) {
        self.labelStoreName.text = purchase.readStoreNameWithDefault()
        self.labelPurchaseName.text = purchase.readProductName()
        self.labelDate.text = purchase.readBillDate()
        self.labelType.text = purchase.readPurchaseCategoryType()
    }
}
