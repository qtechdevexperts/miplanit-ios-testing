//
//  GiftDetailDashboardCell.swift
//  MiPlanIt
//
//  Created by Febin Paul on 08/10/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

class GiftDetailDashboardCell: UITableViewCell {
    
    var index: IndexPath!
    
    @IBOutlet weak var labelGiftName: UILabel!
    @IBOutlet weak var labelCreatedDate: UILabel!
    @IBOutlet weak var labelIssuedBy: UILabel!
    @IBOutlet weak var labelExpiryDate: UILabel!
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var viewExpiry: UIView!
    @IBOutlet weak var labelType: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configCell(gift: DashboardGiftItem, index: IndexPath) {
        self.index = index
        self.labelGiftName.text = gift.title
        //self.labelIssuedBy.text = gift.readIssuedBy()
        self.labelType.text = gift.planItGiftCoupon?.readCategoryCouponTypeName()
        self.viewExpiry.isHidden = gift.exipryDate == nil
        if let expiryDate = gift.exipryDate, expiryDate.initialHour() == Date().initialHour() {
            self.labelExpiryDate.text = Strings.expiresToday
        }
        else if let expiryDate = gift.exipryDate, expiryDate.initialHour() < Date().initialHour() {
            self.labelExpiryDate.text = "Expired on \(expiryDate.stringFromDate(format: DateFormatters.EEEDDMMMYYYY) )"
        }
        else if let expiryDate = gift.exipryDate {
            self.labelExpiryDate.text = "Expires on \(expiryDate.stringFromDate(format: DateFormatters.EEEDDMMMYYYY) )"
        }
    }

}
