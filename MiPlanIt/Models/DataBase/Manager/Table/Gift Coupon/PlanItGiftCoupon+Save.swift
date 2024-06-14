//
//  PlanItGiftCoupon+Save.swift
//  MiPlanIt
//
//  Created by Arun on 09/05/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

extension PlanItGiftCoupon {

    func readGiftCouponId() -> Double {
        return self.couponServerId
    }
    
    func readCouponID() -> String {
        return self.couponId ?? Strings.empty
    }
    func readAppGiftCouponID() -> String {
        return self.appGiftCouponId ?? Strings.empty
    }
    func readCouponCode() -> String {
        return self.couponCode ?? Strings.empty
    }
    func readCouponName() -> String {
        return self.couponName ?? Strings.empty
    }
    func readCouponAmount() -> String {
        let amount = (self.couponAmount ?? Strings.empty)
        return amount.isEmpty ? "0.0" : amount
    }
    func readDescription() -> String {
        return self.couponDescription ?? Strings.empty
    }
    func readIssuedBy() -> String {
        return self.issuedBy ?? Strings.empty
    }
    func readIssuedByWithDefault() -> String {
        if let issued = self.issuedBy, !issued.isEmpty {
            return issued
        }
        return Strings.notspecified
    }
    func readReceivedFrom() -> String {
        return self.recievedFrom ?? Strings.empty
    }
    
    func showExipryDate() -> String {
        return self.readExpiryDateTime()?.stringFromDate(format: DateFormatters.MMDDYYYYHMMSSA) ?? Strings.empty
    }
    func readExpiryDate() -> String {
        return self.expiryDate?.stringFromDate(format: DateFormatters.MMDDYYYYHMMSSA) ?? Strings.empty
    }
    
    func readExpiryDateOffline() -> String {
        return self.expiryDate?.stringFromDate(format: DateFormatters.YYYYHMMMHDD) ?? Strings.empty
    }
    
    func readRedeemDate() -> String {
        return self.redeemedDate ?? Strings.empty
    }
    
    func readCreatedDate() -> Date {
        return self.createdAt?.stringToDate(formatter: DateFormatters.MMDDYYYYHMMSSA, timeZone: TimeZone(abbreviation: "UTC")!) ?? Date()
    }
    
    func readExpiryDateTime() -> Date? {
        return self.expiryDate
    }
    
    func readAllTags() -> [PlanItTags] {
        if let tags = self.tags, let eventTags = Array(tags) as? [PlanItTags] {
            return eventTags
        }
        return []
    }
    
    func readAllAttachments() -> [PlanItUserAttachment] {
        if let bAttachments = self.attachments, let purchaseAttachments = Array(bAttachments) as? [PlanItUserAttachment] {
            return purchaseAttachments
        }
        return []
    }
    
    func readCouponTypeValue() -> Double {
        return self.couponDataType
    }
    
    func readCategoryCouponType() -> CouponDataType {
        return self.couponDataType == 1.0 ? .gift : .coupon
    }
    
    func readCategoryCouponTypeName() -> String {
        return self.couponDataType == 1.0 ? Strings.giftcards : Strings.giftcoupons
    }
    
    func deleteAllTags() {
        let allTags = self.readAllTags()
        self.removeFromTags(self.tags ?? [])
        allTags.forEach({ self.managedObjectContext?.delete($0) })
    }
    
    func deleteAllGiftCouponAttachments(forceRemove: Bool) {
        if forceRemove {
            let allAttachments = self.readAllAttachments()
            self.removeFromAttachments(self.attachments ?? [])
            allAttachments.forEach({ self.managedObjectContext?.delete($0) })
        }
        else {
            let allAttachments = self.readAllAttachments().filter({ return !$0.isPending })
            self.removeFromAttachments(NSSet(array: allAttachments))
            allAttachments.forEach({ self.managedObjectContext?.delete($0) })
        }
    }
    
    func deleteOffline() {
        let context = self.managedObjectContext
        self.isPending = true
        self.deleteStatus = true
        try? context?.save()
    }
    
    func updateRedeemedOffline() {
        let context = self.managedObjectContext
        self.isPending = true
        self.redeemedDate = Date().stringFromDate(format: DateFormatters.MMDDYYYYHMMSSA)
        try? context?.save()
    }
    
    func deleteItSelf() {
        let context = self.managedObjectContext
        context?.delete(self)
        try? context?.save()
    }
    
    func readCurrencySymbol() -> String {
        return self.currencySymbol ?? Strings.empty
    }
    
    func makeRequestParameter() -> [String: Any] {
        var requestParameter: [String: Any] = [:]
        if self.couponServerId != 0.0 {
            requestParameter["couponId"] = self.couponServerId
        }
        requestParameter["title"] = self.couponName
        requestParameter["couponCode"] = self.couponCode
        requestParameter["couponAmount"] = self.couponAmount
        requestParameter["couponAddtId"] = self.couponId
        requestParameter["offeredAt"] = self.issuedBy
        requestParameter["receivedFrom"] = self.recievedFrom
        requestParameter["validTill"] = self.expiryDate
        requestParameter["description"] = self.couponDescription
        requestParameter["validfrom"] = ""
        requestParameter["redeemedDate"] = ""
        requestParameter["billattachments"] = self.readAllAttachments().map({ $0.readAttachmentId() })
        requestParameter["tags"] = self.tags
        requestParameter["currencySymbol"] = self.currencySymbol == Strings.empty ? self.readCurrencySymbol() : self.currencySymbol
        requestParameter["couponDataType"] = self.couponDataType
        return requestParameter
    }
}
