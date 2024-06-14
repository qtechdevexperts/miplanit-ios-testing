//
//  AddGiftCouponsViewController+Service.swift
//  MiPlanIt
//
//  Created by Arun on 08/05/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

extension AddGiftCouponsViewController {
    
    func createWebServiceToUploadAttachment(_ attachement: UserAttachment) {
        UserService().uploadAttachement(attachement, callback: { response, error in
            if let _ = response {
                self.startPendingUploadOfAttachment()
            }
            else {
                let message = error ?? Message.unknownError
                self.buttonSaveGiftCoupon.stopAnimation()
                self.performSegue(withIdentifier: Segues.toMessageScreen, sender: [Message.error, message])
            }
        })
    }
    
    func createServiceToAddGiftCoupon() {
        GiftCouponService().addGiftCoupon(self.giftCouponModel, callback: { response, error in
            if let result = response {
                //MARK: - Tick Animation
                self.buttonSaveGiftCoupon.clearButtonTitleForAnimation()
                self.buttonSaveGiftCoupon.stopAnimation(animationStyle: .normal, revertAfterDelay: 0) {
                    self.buttonSaveGiftCoupon.showTickAnimation { (results) in
                        self.navigationController?.popViewController(animated: true)
                        if self.giftCouponModel.couponServerId.isEmpty {
                            self.delegate?.addGiftCouponsViewController!(self, createdNewGiftCoupon: result)
                        }
                        else {
                            self.delegate?.addGiftCouponsViewController!(self, updatedGiftCoupon: result)
                        }
                    }
                }
            }
            else {
                self.buttonSaveGiftCoupon.stopAnimation(animationStyle: .shake, revertAfterDelay: 0) {
                    let message = error ?? Message.unknownError
                    self.performSegue(withIdentifier: Segues.toMessageScreen, sender: [Message.error, message])
                }
            }
        })
    }
}
