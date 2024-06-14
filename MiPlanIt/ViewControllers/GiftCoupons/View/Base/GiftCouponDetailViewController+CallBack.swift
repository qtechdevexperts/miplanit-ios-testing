//
//  GiftCouponDetailViewController+CallBack.swift
//  MiPlanIt
//
//  Created by Aneesh Asokan on 09/05/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation
extension GiftCouponDetailViewController: AddGiftCouponsViewControllerDelegate {
    
    func addGiftCouponsViewController(_ viewController: AddGiftCouponsViewController, updatedGiftCoupon giftCoupon: PlanItGiftCoupon) {
        self.isModified = true
        self.planItGiftCoupon = giftCoupon
        self.initialiseUIComponents()
    }
}
