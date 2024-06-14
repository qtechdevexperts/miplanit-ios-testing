//
//  PurchaseListTableViewCell.swift
//  MiPlanIt
//
//  Created by Aneesh Asokan on 29/04/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

class GiftCouponListTableViewCell: UITableViewCell {
    
    @IBOutlet weak var labelVoucherName: UILabel!
    
    @IBOutlet weak var labelType: UILabel!
    
    @IBOutlet weak var labelIssuesBy: UILabel!
    
    @IBOutlet weak var labelDate: UILabel!
    
    @IBOutlet weak var buttonExpiryTime: UIButton!
    
    @IBOutlet weak var viewExpiryBorder: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

    func configureGiftCoupon(_ giftCoupon: PlanItGiftCoupon, atIndexPath indexPath: IndexPath) {
        var dateToDisplay = Strings.empty
        self.viewExpiryBorder.isHidden = false
        if let redeemDate = giftCoupon.redeemedDate, !redeemDate.isEmpty {
            dateToDisplay = "Redeemed on \(redeemDate.stringFrom(format: DateFormatters.MMDDYYYYHMMSSA, toFormat: DateFormatters.DDSMMMSYYYY))"
        }
        else if !giftCoupon.readExpiryDate().isEmpty {
            dateToDisplay = giftCoupon.readExpiryDate().checkExpiry()
        }
        else if giftCoupon.readExpiryDate().isEmpty {
            self.viewExpiryBorder.isHidden = true
        }
        self.labelDate.text = dateToDisplay
        self.labelVoucherName.text = giftCoupon.readCouponName()
        self.labelType.text = giftCoupon.readCategoryCouponTypeName()
        if dateToDisplay == "Expired" || dateToDisplay.contains("day") || dateToDisplay.contains("today") {
            self.labelDate.textColor = .red
            self.buttonExpiryTime.isSelected = true
            self.viewExpiryBorder.bordorColor = .red
        }
        else {
            self.labelDate.textColor = .white//UIColor(red: 54/255.0, green: 54/255.0, blue: 54/255.0, alpha: 1.0)
            self.buttonExpiryTime.isSelected = false
            self.viewExpiryBorder.bordorColor = UIColor(red: 226/255.0, green: 226/255.0, blue: 226/255.0, alpha: 1.0)
        }
    }
}
