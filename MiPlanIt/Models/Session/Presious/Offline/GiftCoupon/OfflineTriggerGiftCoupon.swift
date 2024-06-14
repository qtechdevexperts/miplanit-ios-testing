//
//  OfflineTriggerGiftCoupon.swift
//  MiPlanIt
//
//  Created by Febin Paul on 01/12/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation


extension Session {
    
    func sendPendingGiftAttachmentsToServer(finished: @escaping () -> ()) {
        let pendingAttachments = DatabasePlanItUserAttachment().readAllPendingAttachements().filter({ $0.giftCoupon != nil })
        if pendingAttachments.isEmpty {
            finished()
        }
        else {
            self.uploadPendingGiftAttachmentsToServer(pendingAttachments, finished: finished)
        }
    }
    
    func uploadPendingGiftAttachmentsToServer(_ attachments: [PlanItUserAttachment], at index: Int = 0, finished: @escaping () -> ()) {
        guard index < attachments.count else { finished(); return }
        let ownerIdValue = attachments[index].giftCoupon?.createdBy?.readValueOfUserId() ?? Strings.empty
        let convertedAttachment = UserAttachment(with: attachments[index], type: .giftCoupon, ownerId: ownerIdValue)
        UserService().uploadAttachement(convertedAttachment, callback: { attachment, _ in
            if let result = attachment {
                attachments[index].saveGiftAttachmentIdentifier(result.identifier)
            }
            self.uploadPendingGiftAttachmentsToServer(attachments, at: index + 1, finished: finished)
        })
    }
    
    func sendGiftCouponToServer(_ finished: @escaping () -> ()) {
        let allPendingGift = DatabasePlanItGiftCoupon().readAllPendingGiftCoupon()
        if allPendingGift.isEmpty {
            self.sendDeleteGiftCouponToServer(finished)
        }
        else {
            self.startGiftCouponSending(allPendingGift) {
                finished()
            }
        }
    }
    
    private func startGiftCouponSending(_ giftCoupons: [PlanItGiftCoupon], atIndex: Int = 0, finished: @escaping () -> ()) {
        if atIndex < giftCoupons.count {
            self.sendGiftCouponToServer(giftCoupon: giftCoupons[atIndex], at: atIndex) { (index) in
                self.startGiftCouponSending(giftCoupons, atIndex: index + 1, finished: finished)
            }
        }
        else {
            finished()
        }
    }
    
    private func sendGiftCouponToServer(giftCoupon: PlanItGiftCoupon, at index: Int, result: @escaping (Int) -> ()) {
        GiftCouponService().addGiftCoupon(GiftCoupon(with: giftCoupon)) { (response, error) in
            result(index)
        }
    }
    
    func sendDeleteGiftCouponToServer(_ finished: @escaping () -> ()) {
        let pendingDeletedGift = DatabasePlanItGiftCoupon().readAllPendingDeletedGiftCoupon()
        if pendingDeletedGift.isEmpty {
            finished()
        }
        else {
            self.startDeletedGiftCouponSending(pendingDeletedGift) {
                finished()
            }
        }
    }
    
    private func startDeletedGiftCouponSending(_ giftCoupon: [PlanItGiftCoupon], atIdex: Int = 0, finished: @escaping () -> ()) {
        if atIdex < giftCoupon.count {
            self.sendDeletedGiftCouponToServer(giftCoupon: giftCoupon[atIdex], at: atIdex, result: { index in
                self.startDeletedGiftCouponSending(giftCoupon, atIdex: index + 1, finished: finished)
            })
        }
        else {
            finished()
        }
    }
    
    private func sendDeletedGiftCouponToServer(giftCoupon: PlanItGiftCoupon, at index: Int, result: @escaping (Int) -> ()) {
        GiftCouponService().deleteGiftCoupon(giftCoupon) { (status, error) in
            result(index)
        }
    }


}
