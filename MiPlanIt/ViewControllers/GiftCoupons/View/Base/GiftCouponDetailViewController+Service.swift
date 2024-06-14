//
//  GiftCouponDetailViewController+Service.swift
//  MiPlanIt
//
//  Created by Aneesh Asokan on 09/05/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation
extension GiftCouponDetailViewController {

    func callWebServiceForDeleteGiftCoupon() {
        let cachedImage   = self.buttonDelete.image(for: .normal)
        self.buttonDelete.clearButtonTitleForAnimation()
        self.buttonDelete.startAnimation()
        GiftCouponService().deleteGiftCoupon(self.planItGiftCoupon, callback: { (response, error) in
            if response == true {
                self.buttonDelete.stopAnimation(animationStyle: .normal, revertAfterDelay: 0) {
                    //MARK: - Tick Animation
                    self.buttonDelete.showTickAnimation { (result) in
                        self.isModified = false
                        self.navigationController?.popViewController(animated: true)
                        self.delegate?.giftCouponDetailViewController(self, deletedGiftCoupon: self.planItGiftCoupon)
                    }
                }
            }
            else {
                self.buttonDelete.stopAnimation(animationStyle: .shake, revertAfterDelay: 0) {
                    let message = error ?? Message.unknownError
                    self.buttonDelete.setImage(cachedImage, for: .normal)
                    self.performSegue(withIdentifier: Segues.toMessageScreen, sender: [Message.error, message])
                    
                }
            }
        })
    }
    
    func callWebServiceForRedeemGiftCoupon() {
        self.buttonRedeem.startAnimation()
        GiftCouponService().redeemGiftCoupon(self.planItGiftCoupon, callback: { (response, error) in
            if response != nil {
                self.buttonRedeem.clearButtonTitleForAnimation()
                self.buttonRedeem.stopAnimation(animationStyle: .normal, revertAfterDelay: 0) {
                    self.buttonRedeem.showTickAnimation(borderOnly: true, completion: { (result) in
                        self.updateButtonTitleWithColor()
                        self.isModified = true
                        self.initialiseUIComponents()
                    })
                }
                
            }
            else {
                let message = error ?? Message.unknownError
                self.buttonRedeem.stopAnimation(animationStyle: .shake, revertAfterDelay: 0) {
                    self.performSegue(withIdentifier: Segues.toMessageScreen, sender: [Message.error, message])
                }
            }
        })
    }
    
}
