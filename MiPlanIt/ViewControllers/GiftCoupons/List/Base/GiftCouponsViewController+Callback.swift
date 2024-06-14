//
//  GiftCouponsViewController+Callback.swift
//  MiPlanIt
//
//  Created by Arun on 09/05/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

extension GiftCouponsViewController: AddGiftCouponsViewControllerDelegate, GiftCouponDetailViewControllerDelegate {
    
    func addGiftCouponsViewController(_ viewController: AddGiftCouponsViewController, createdNewGiftCoupon giftCoupon: PlanItGiftCoupon) {
        self.readAllUserGiftCouponsUsingFilterCriteria()
    }
    
    func giftCouponDetailViewController(_ viewController: GiftCouponDetailViewController, updatedGiftCoupon giftCoupon: PlanItGiftCoupon) {
        if filterCriteria.isEmpty {
            self.showGiftCouponsBasedOnSearchCriteria()
        }
        else {
            self.showGiftCouponsBasedOnFilterCriteria()
        }
    }
    
    func giftCouponDetailViewController(_ viewController: GiftCouponDetailViewController, deletedGiftCoupon giftCoupon: PlanItGiftCoupon) {
        self.allGiftCoupons.removeAll(where: { return $0 == giftCoupon })
    }
}

extension GiftCouponsViewController: CouponStatusSelectionViewDelegate {
    
    func couponStatusSelectionView(_ view: CouponStatusSelectionView, withSelectedOption option: CouponStatus) {
        self.selectedCategory = option.type
        if filterCriteria.isEmpty {
            self.showGiftCouponsBasedOnSearchCriteria()
        }
        else {
            self.showGiftCouponsBasedOnFilterCriteria()
        }
    }
}

extension GiftCouponsViewController: GiftFilterViewControllerDelegate {
    
    func giftFilterViewController(_ viewController: GiftFilterViewController, filters: [Filter]) {
        self.filterCriteria = filters
        self.buttonFilter.isSelected = !filters.isEmpty
    }
}

