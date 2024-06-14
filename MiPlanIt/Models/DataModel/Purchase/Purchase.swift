//
//  Purchase.swift
//  MiPlanIt
//
//  Created by Arun on 07/05/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

class Purchase {
    
    var appPurchaseId = Strings.empty
    var purchaseId = Strings.empty
    var productName = Strings.empty
    var storeName = Strings.empty
    var location = Strings.empty
    var amount = Strings.empty
    var paymentTypeId: Int = 2
    var paymentDescription: String = Strings.empty
    var billDate: Date?
    var purchaseDescription = Strings.empty
    var paymentCard: PurchaseCard?
    var tags: [String] = ["Receipts & Bills"]
    var attachments: [UserAttachment] = []
    var locationSeperator: Character = Strings.locationSeperator
    var currencySymbol = Strings.empty
    var isPending: Bool = false
    var placeLatitude: Double?
    var placeLongitude: Double?
    var planItPurchase: PlanItPurchase?
    var purchaseDataType: PurchaseDataType = .bill
    var ownerUserId: String?
    
    init() { }
    
    init(with planitPurchase: PlanItPurchase) {
        self.purchaseId = planitPurchase.readPurchaseId().cleanValue()
        self.productName = planitPurchase.readProductName()
        self.storeName = planitPurchase.readStoreName()
        _=self.setLocation(planitPurchase.readLocation())
        self.amount = planitPurchase.readAmount()
        self.paymentTypeId = Int(planitPurchase.readPaymentType()) ?? 2
        self.paymentDescription = planitPurchase.readPaymentDescription()
        self.billDate = planitPurchase.readBillDateTime()
        self.purchaseDescription = planitPurchase.readDescription()
        self.tags = planitPurchase.readAllTags().compactMap({ return $0.tag})
        let ownerIdValue = planitPurchase.createdBy?.readValueOfUserId()
        self.ownerUserId = ownerIdValue
        self.attachments = planitPurchase.readAllAttachments().map({ return UserAttachment(with: $0, type: .purchase, ownerId: ownerIdValue) })
        self.paymentCard = PurchaseCard(with: planitPurchase.readCardName(), number: planitPurchase.readCardNumber())
        self.currencySymbol = planitPurchase.readCurrencySymbol()
        self.appPurchaseId = planitPurchase.readAppPurchaseId()
        self.isPending = planitPurchase.isPending
        self.purchaseDataType = planitPurchase.purchaseCategoryType == 1 ? .bill : .receipt
        self.planItPurchase = planitPurchase
    }
    
    func readPaymentCaption() -> String {
        return self.paymentTypeId == 1 ? Strings.card : self.paymentTypeId == 2 ? Strings.cash : Strings.other
    }
    
    func readPurchaseCategoryTypeValue() -> Double {
        return self.purchaseDataType == .bill ? 1 : 2
    }
    
    
    func savePayment(_ payment: Int, card: PurchaseCard? = nil) {
        self.paymentTypeId = payment
        self.paymentCard = card
    }
    
    func savePaymentOther(_ payment: Int, description: String) {
        self.paymentTypeId = payment
        self.paymentDescription = description
        self.paymentCard = nil
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
    
    func getAttachmentCount() -> Int {
        return  self.attachments.count
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
    
    func setBiilDate(date: Date) {
        self.billDate = date
    }
    
    func resetLocation() {
        self.location = Strings.empty
        self.placeLatitude = nil
        self.placeLongitude = nil
    }
    
    func setStoreName(_ name: String) {
        self.storeName = name
    }
    
    func setProductName(_ name: String) {
        self.productName = name
    }
    
    func setAmount(_ amount: String)  {
        self.amount = amount
    }
    
    func setLocation(_ location: String) -> String {
        let locatinData = location.split(separator: self.locationSeperator)
        if let locationName = locatinData.first {
            self.location = String(locationName)
        }
        if locatinData.count > 2 {
            self.placeLatitude = Double(locatinData[1])
            self.placeLongitude = Double(locatinData[2])
        }
        return self.location
    }
    
    func setLocationFromMap(locationName: String, latitude: Double?, longitude: Double?) -> String {
        self.location = locationName
        self.placeLatitude = latitude
        self.placeLongitude = longitude
        return self.location
    }
    
    func createLocationParamValue() -> String {
        var locationParam = self.location
        if let latitude = self.placeLatitude, let longitude = self.placeLongitude  {
            locationParam += String(Strings.locationSeperator)+String(latitude)+String(Strings.locationSeperator)+String(longitude)
        }
        return locationParam
    }
    
    func createRequestParameter() -> [String: Any] {
        var requestParameter: [String: Any] = [:]
        if !self.purchaseId.isEmpty && self.purchaseId != "0" {
            requestParameter["purchaseId"] = self.purchaseId
        }
        requestParameter["appPurchaseId"] = self.appPurchaseId
        requestParameter["amountPaid"] = self.amount
        requestParameter["location"] = self.createLocationParamValue()
        requestParameter["dateOfPurchase"] = self.billDate == nil ? Strings.empty : self.billDate?.stringFromDate(format: DateFormatters.YYYYHMMMHDD)
        requestParameter["paymentMode"] = self.paymentTypeId
        requestParameter["paymentDescription"] = self.paymentDescription
        requestParameter["notes"] = self.purchaseDescription
        requestParameter["productName"] = self.productName
        requestParameter["storeName"] = self.storeName
        requestParameter["tags"] = self.tags
        requestParameter["billattachments"] = self.attachments.compactMap({ return Int($0.identifier) })
        requestParameter["cardInfo"] = self.paymentTypeId == 1 ? self.getCardInfo() : nil
        requestParameter["currencySymbol"] = self.currencySymbol == Strings.empty ? self.readCurrencySymbol() : self.currencySymbol
        requestParameter["purchaseCategory"] = self.purchaseDataType == .bill ? 1 : 2
        return requestParameter
    }
    
    func readPurchaseTypeName() -> String {
        return self.purchaseDataType == .bill ? Strings.bills : Strings.receipts
    }
    
    func setPurchaseDataType(_ type: PurchaseDataType) {
        self.purchaseDataType = type
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
        text += self.storeName
        text += self.location.isEmpty ? Strings.empty : ", "+self.location
        text += self.purchaseDescription.isEmpty ? Strings.empty : ", "+self.purchaseDescription
        text += self.productName.isEmpty ? Strings.empty : ", "+self.productName
        text += self.readPaymentCaption().isEmpty ? Strings.empty : ", "+self.readPaymentCaption()
        return text
    }
    
    func getCardInfo() -> [String: Any]? {
        guard let card = self.paymentCard else { return nil }
        return ["cardname": card.cardName, "cardno": card.cardNumber]
    }
    
    func categoryTag() -> [String] {
        var tags: [String] = []
        tags.append(self.purchaseDataType == .bill ? Strings.bills : Strings.receipts)
        return tags
    }
}
