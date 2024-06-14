//
//  GiftCouponDetailViewController+Offline.swift
//  MiPlanIt
//
//  Created by Febin Paul on 02/12/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation


extension GiftCouponDetailViewController {
    
    func deleteGiftCouponToServerUsingNetwotk() {
        if SocialManager.default.isNetworkReachable() && !self.planItGiftCoupon.isPending {
            self.callWebServiceForDeleteGiftCoupon()
        }
        else {
            self.planItGiftCoupon.deleteOffline()
            self.navigationController?.popViewController(animated: true)
            self.delegate?.giftCouponDetailViewController(self, deletedGiftCoupon: self.planItGiftCoupon)
        }
    }
    
    func redeemGiftCouponToServerUsingNetwotk() {
        if SocialManager.default.isNetworkReachable() && !self.planItGiftCoupon.isPending {
            self.callWebServiceForRedeemGiftCoupon()
        }
        else {
            self.planItGiftCoupon.updateRedeemedOffline()
            self.buttonRedeem.clearButtonTitleForAnimation()
            self.buttonRedeem.showTickAnimation(borderOnly: true, completion: { (result) in
                self.updateButtonTitleWithColor()
                self.isModified = true
                self.initialiseUIComponents()
            })
        }
    }
}
