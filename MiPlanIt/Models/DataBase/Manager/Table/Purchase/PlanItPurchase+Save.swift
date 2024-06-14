//
//  PlanItPurchase+Save.swift
//  MiPlanIt
//
//  Created by Arun on 08/05/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

extension PlanItPurchase {
    
    func readStoreName() -> String {
        return self.storeName ?? Strings.empty
    }
    
    func readStoreNameWithDefault() -> String {
        if let store = self.storeName, !store.isEmpty {
            return store
        }
        return Strings.notspecified
    }
    
    func readPurchaseId() -> Double {
        return self.purchaseId
    }
    
    func readAppPurchaseId() -> String {
        return self.appPurchaseId ?? Strings.empty
    }
    
    func readProductName() -> String {
        return self.productName ?? Strings.empty
    }
    
    func readLocation() -> String { return self.location ?? Strings.empty }
    
    func readLocationName() -> String {
        let locatinData = (self.location ?? Strings.empty).split(separator: Strings.locationSeperator)
        if let locationName = locatinData.first {
            return String(locationName)
        }
        return Strings.empty
    }
    
    func readAmount() -> String {
        let amount = (self.amount ?? Strings.empty)
        return amount.isEmpty ? "0.0" : amount
    }
    
    func readDescription() -> String {
        return self.purchaseDescription ?? Strings.empty
    }
    
    func readCreatedDate() -> Date {
        return self.createdAt ?? Date()
    }
    
    func readBillDate() -> String {
        return self.billDate?.stringFromDate(format: DateFormatters.EEEDDMMMYYYY) ?? Strings.empty
    }
    
    func readBillDateTime() -> Date? {
        return self.billDate
    }
    
    func readPaymentType() -> String {
        return self.paymentTypeId ?? Strings.empty
    }
    
    func readPaymentDescription() -> String {
        return self.paymentDescription ?? Strings.empty
    }
    
    func readPurchaseCategoryType() -> String {
        return self.purchaseCategoryType == 1 ? Strings.bills : Strings.receipts
    }
    
    func readCardName() -> String {
        return self.card?.cardName ?? Strings.empty
    }
    
    func readCardNumber() -> String {
        return self.card?.cardNumber ?? Strings.empty
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
    
    func deleteAllTags() {
        let allTags = self.readAllTags()
        self.removeFromTags(self.tags ?? [])
        allTags.forEach({ self.managedObjectContext?.delete($0) })
    }
    
    func deleteOffline() {
        let context = self.managedObjectContext
        self.isPending = true
        self.deleteStatus = true
        try? context?.save()
    }
    
    func deleteAllPurchaseAttachments(forceRemove: Bool) {
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
        if self.readPurchaseId() != 0.0 {
            requestParameter["purchaseId"] = self.purchaseId
        }
        requestParameter["amountPaid"] = self.amount
        requestParameter["location"] = self.readLocation()
        requestParameter["dateOfPurchase"] = self.billDate
        requestParameter["paymentMode"] = self.paymentTypeId
        requestParameter["paymentDescription"] = self.paymentDescription
        requestParameter["notes"] = self.purchaseDescription
        requestParameter["productName"] = self.productName
        requestParameter["storeName"] = self.storeName
        requestParameter["tags"] = self.tags
        requestParameter["billattachments"] = self.readAllAttachments().map({ $0.readAttachmentId() })
        requestParameter["cardInfo"] = self.readPaymentType()
        requestParameter["currencySymbol"] = self.currencySymbol == Strings.empty ? self.readCurrencySymbol() : self.currencySymbol
        requestParameter["purchaseCategory"] = self.purchaseCategoryType
        return requestParameter
    }
}
