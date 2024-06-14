//
//  AddGiftCouponsViewController+Offline.swift
//  MiPlanIt
//
//  Created by Febin Paul on 02/12/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation


extension AddGiftCouponsViewController {
    
    func saveGiftCouponToServerUsingNetwotk(_ giftCoupon: GiftCoupon) {
        if SocialManager.default.isNetworkReachable() {
            self.startUploadAttachment()
        }
        else {
            let planItGiftCoupon = DatabasePlanItGiftCoupon().insertOfflineGiftCoupon(giftCoupon)
            self.navigationController?.popViewController(animated: true)
            if giftCoupon.couponServerId.isEmpty {
                self.delegate?.addGiftCouponsViewController!(self, createdNewGiftCoupon: planItGiftCoupon)
            }
            else {
                self.delegate?.addGiftCouponsViewController!(self, updatedGiftCoupon: planItGiftCoupon)
            }
        }
    }
}
