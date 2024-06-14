//
//  GiftCardView.swift
//  MiPlanIt
//
//  Created by Febin Paul on 28/12/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

import UIKit

class GiftCardView: UIView {
    
    let kCONTENT_XIB_NAME = "GiftCardView"
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var labelCategory: UILabel!
    @IBOutlet weak var labelGiftName: UILabel!
    @IBOutlet weak var labelCode: UILabel!
    @IBOutlet weak var labelId: UILabel!
    @IBOutlet weak var labelIssuedBy: UILabel!
    @IBOutlet weak var expiresOn: UILabel!
    @IBOutlet weak var viewCode: UIView!
    @IBOutlet weak var viewID: UIView!
    @IBOutlet weak var viewIssuedBy: UIView!
    @IBOutlet weak var viewExpiresOn: UIView!
    @IBOutlet weak var labelAmount: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed(kCONTENT_XIB_NAME, owner: self, options: nil)
        contentView.fixInView(self)
    }
    
    func setUpData(_ planItGiftCoupon: PlanItGiftCoupon) {
        self.labelCategory.text = planItGiftCoupon.readCategoryCouponTypeName()
        self.labelGiftName.text = planItGiftCoupon.readCouponName()
        self.labelCode.text = "Code: " + planItGiftCoupon.readCouponCode()
        self.labelId.text = "ID: " + planItGiftCoupon.readCouponID()
        self.labelIssuedBy.text = "Issued by: " + planItGiftCoupon.readIssuedBy()
        self.expiresOn.text = "Expires on: " + self.readExpiryEndDate(planItGiftCoupon.readExpiryDateTime())
        self.viewCode.isHidden = planItGiftCoupon.readCouponCode().isEmpty
        self.viewID.isHidden = planItGiftCoupon.readCouponID().isEmpty
        self.viewIssuedBy.isHidden = planItGiftCoupon.readIssuedBy().isEmpty
        self.viewExpiresOn.isHidden = planItGiftCoupon.readExpiryDate().isEmpty
        self.labelAmount.text = "Amount: " + planItGiftCoupon.readCurrencySymbol() + planItGiftCoupon.readCouponAmount()
    }
    
    func readExpiryEndDate(_ date: Date?) -> String {
        return date?.stringFromDate(format: DateFormatters.DDSMMMSYYYY) ?? Strings.empty
    }

}
