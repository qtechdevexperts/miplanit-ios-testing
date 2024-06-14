//
//  GiftCouponDetailViewController+Actions.swift
//  MiPlanIt
//
//  Created by Aneesh Asokan on 09/05/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation
import Lottie
extension GiftCouponDetailViewController {
    func initialiseUIComponents() {
        let attachments = self.planItGiftCoupon.readAllAttachments()
        self.labelAttachmentCount.text = "\(attachments.count)"
        self.labelAttachmentCount.isHidden = attachments.isEmpty
         self.labelCouponName.text = self.planItGiftCoupon.readCouponName()
        self.labelCouponCode.text = "Code: " + self.planItGiftCoupon.readCouponCode()
        self.labelCouponID.text = "ID: " + self.planItGiftCoupon.readCouponID()
        self.labelReceivedFrom.text = self.planItGiftCoupon.readReceivedFrom()
        self.labelIssuedBy.text = self.planItGiftCoupon.readIssuedByWithDefault()
        self.labelDescription.text = self.planItGiftCoupon.readDescription()
        self.labelAmount.text = "\(self.planItGiftCoupon.readCurrencySymbol())\(self.planItGiftCoupon.readCouponAmount())"
        self.labelBillDate.text = self.planItGiftCoupon.readExpiryDateTime()?.stringFromDate(format: DateFormatters.EEEEMMMDDYYYY)
        self.labelCategory.text = self.planItGiftCoupon.readCategoryCouponTypeName()
        if !self.planItGiftCoupon.readRedeemDate().isEmpty {
            self.buttonRedeem.setTitle("Redeemed", for: .normal)
            self.buttonRedeem.isUserInteractionEnabled = false
            self.buttonEdit.isHidden = true
        }
        else if !self.planItGiftCoupon.readExpiryDate().isEmpty, self.checkExpired(expiryDate: self.planItGiftCoupon.readExpiryDate()) {
            self.buttonRedeem.setTitle("Expired", for: .normal)
            self.buttonRedeem.isUserInteractionEnabled = false
//            self.buttonEdit.isHidden = true
        }
        else {
            self.buttonRedeem.setTitle("Mark as Redeemed", for: .normal)
        }
        self.showTagsCount()
    }
    
    func appShareGiftCard() {
        let giftData = GiftCardView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 200, height: 160)))
        giftData.setUpData(self.planItGiftCoupon)
        giftData.layoutIfNeeded()
        let imageShare = [ giftData.asImage() ]
        let activityViewController = UIActivityViewController(activityItems: imageShare , applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    func showTagsCount() {
        let tag = self.planItGiftCoupon.readAllTags()
        self.labelTagCount.text = "\(tag.count)"
        self.labelTagCount.isHidden = tag.isEmpty
    }
    
    func updateButtonTitleWithColor() {
        UIView.animate(withDuration: 0.2, animations: {
            for view in self.buttonRedeem.subviews {
                if view.isKind(of: LottieAnimationView.self) {
                    view.center = CGPoint(x: view.center.x - self.buttonRedeem.frame.size.width/3, y: view.center.y)
                }
            }
        }) { (result) in
            self.buttonRedeem.setTitle("Redeemed", for: .normal)
            self.buttonRedeem.setTitleColor(UIColor.init(red: 86/255.0, green: 173/255.0, blue: 189/255.0, alpha: 1.0), for: .normal)
        }
    }
    
    func checkExpired(expiryDate: String) -> Bool {
        return expiryDate.checkExpiry() == "Expired"
    }
    
    func markAsRedeem() {
        if self.buttonRedeem.currentTitle == "Mark as Redeemed" {
            self.showAlertWithAction(message: Message.redeemGiftCoupnConfirmation, title: Message.confirm, items: [Message.yes, Message.no], callback: { index in
                if index == 0 {
                    self.redeemGiftCouponToServerUsingNetwotk()
                }
            })
        }
        
    }
    
    func deleteGiftCoupon() {
        self.showAlertWithAction(message: Message.deleteGiftCoupnConfirmation, title: Message.confirm, items: [Message.yes, Message.no], callback: { index in
            if index == 0 {
                self.deleteGiftCouponToServerUsingNetwotk()
            }
        })
    }
}
