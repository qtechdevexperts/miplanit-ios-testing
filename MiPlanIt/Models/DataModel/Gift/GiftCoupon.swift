//
//  GiftCoupon.swift
//  MiPlanIt
//
//  Created by Arun on 08/05/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

class GiftCoupon {
    
    var couponAppId = Strings.empty
    var couponServerId = Strings.empty
    var couponName = Strings.empty
    var couponAmount = Strings.empty
    var couponCode = Strings.empty
    var couponId = Strings.empty
    var issuedBy = Strings.empty
    var recievedFrom = Strings.empty
    var expiryDate = Strings.empty
    var redeemedDate = Strings.empty
    var couponDescription = Strings.empty
    var currencySymbol = Strings.empty
    var tags: [String] = ["Coupons & Gifts"]
    var attachments: [UserAttachment] = []
    var couponDataType: CouponDataType = .gift
    var giftOwnerId: String?
    var ownerUserId: String?
    
    init() {
    }
    init(with planItGiftCoupon: PlanItGiftCoupon) {
        self.couponServerId = planItGiftCoupon.readGiftCouponId().cleanValue()
        self.couponCode = planItGiftCoupon.readCouponCode()
        self.couponName = planItGiftCoupon.readCouponName()
        self.couponAmount = planItGiftCoupon.readCouponAmount()
        self.couponId = planItGiftCoupon.readCouponID()
        self.issuedBy = planItGiftCoupon.readIssuedBy()
        self.recievedFrom = planItGiftCoupon.readReceivedFrom()
        self.expiryDate = planItGiftCoupon.readExpiryDate()
        self.redeemedDate = planItGiftCoupon.readRedeemDate()
        self.couponDescription = planItGiftCoupon.readDescription()
        self.tags = planItGiftCoupon.readAllTags().compactMap({ return $0.tag})
        let ownerIdValue = planItGiftCoupon.createdBy?.readValueOfUserId()
        self.ownerUserId = ownerIdValue
        self.attachments  = planItGiftCoupon.readAllAttachments().map({ return UserAttachment(with: $0, type: .giftCoupon, ownerId: ownerIdValue) })
        self.currencySymbol = planItGiftCoupon.readCurrencySymbol()
        self.couponAppId = planItGiftCoupon.readAppGiftCouponID()
        self.couponDataType = planItGiftCoupon.readCategoryCouponType()
        self.giftOwnerId = planItGiftCoupon.createdBy?.readValueOfUserId()
    }
    func addTag(_ tag: String) {
        self.tags.append(tag)
    }
    
    func removeTagAtIndex(_ index: Int) {
        self.tags.remove(at: index)
    }
    
    func removeTag(_ tag: String) {
        self.tags.removeAll(where: { return $0 == tag })
    }
    
    func addAttachement(_ attachment: UserAttachment) {
        self.attachments.append(attachment)
    }
    
    func removeAttachementAtIndex(_ index: Int) {
        self.attachments.remove(at: index)
    }
    
    func removeAttachement(_ attachment: UserAttachment) {
        self.attachments.removeAll(where: { return $0 == attachment })
    }
    
    func getAttachmentCount() -> Int {
        return self.attachments.count
    }
    
    func setCouponDataType(_ type: CouponDataType) {
        self.couponDataType = type
    }
    
    func readCategoryTypeName() -> String {
        return self.couponDataType == .gift ? Strings.giftcards : Strings.giftcoupons
    }
    
    func readCategoryTypeValue() -> Double {
        return self.couponDataType == .gift ? 1.0 : 2.0
    }
    
    func setExpiryDate(date: Date) {
        self.expiryDate = date.stringFromDate(format: DateFormatters.YYYYHMMMHDD)
    }
    
    func createRequestParameter() -> [String: Any] {
        var requestParameter: [String: Any] = [:]
        if !self.couponServerId.isEmpty && self.couponServerId != "0" {
            requestParameter["couponId"] = self.couponServerId
        }
        requestParameter["appCouponId"] = self.couponAppId == Strings.empty ?  UUID().uuidString :  self.couponAppId
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
        requestParameter["billattachments"] = self.attachments.compactMap({ return Int($0.identifier) })
        requestParameter["tags"] = self.tags
        requestParameter["currencySymbol"] = self.currencySymbol == Strings.empty ? self.readCurrencySymbol() : self.currencySymbol
        requestParameter["couponDataType"] = self.couponDataType == .gift ? 1 : 2
        return requestParameter
    }
    
    func readCurrencySymbol() -> String {
        let currencyFormatter = NumberFormatter()
        currencyFormatter.usesGroupingSeparator = true
        currencyFormatter.numberStyle = .currency
        currencyFormatter.locale = Locale.current
        return currencyFormatter.currencySymbol
    }
    
    func createTextForPrediction() -> String {
        var text: String = ""
        text += self.couponName
        text += self.couponDescription.isEmpty ? Strings.empty : ", "+self.couponDescription
        text += self.couponCode.isEmpty ? Strings.empty : ", "+self.couponCode
        text += self.issuedBy.isEmpty ? Strings.empty : ", "+self.issuedBy
        text += self.recievedFrom.isEmpty ? Strings.empty : ", "+self.recievedFrom
        return text
    }
}
