//
//  PlanItUserAttachment+Save.swift
//  MiPlanIt
//
//  Created by Arun on 09/05/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

extension PlanItUserAttachment {
    
    func readFileName() -> String {
        return self.file ?? Strings.empty
    }
    
    func readFilePath() -> String {
        return self.url ?? Strings.empty
    }
    
    func readAttachmentId() -> String {
        return self.identifier == 0 ? Strings.empty : self.identifier.cleanValue()
    }
    
    func readCreatedAt() -> String {
        return self.createdAt ?? Strings.empty
    }
    
    func readCreatedDate() -> Date {
        return self.readCreatedAt().stringToDate(formatter: DateFormatters.MMDDYYYYHMMSSA, timeZone: TimeZone(abbreviation: "UTC")!) ?? Date()
    }
    
    func saveTodoAttachmentIdentifier(_ value: String) {
        self.data = nil
        self.isPending = false
        self.todo?.isPending = true
        self.identifier = Double(value) ?? 0
        try? self.managedObjectContext?.save()
    }
    
    func saveShopListAttachmentIdentifier(_ value: String) {
        self.data = nil
        self.isPending = false
        self.shopListItem?.isPending = true
        self.identifier = Double(value) ?? 0
        try? self.managedObjectContext?.save()
    }
    
    func saveGiftAttachmentIdentifier(_ value: String) {
        self.data = nil
        self.isPending = false
        self.giftCoupon?.isPending = true
        self.identifier = Double(value) ?? 0
        try? self.managedObjectContext?.save()
    }
    
    func savePurchasettachmentIdentifier(_ value: String) {
        self.data = nil
        self.isPending = false
        self.purchase?.isPending = true
        self.identifier = Double(value) ?? 0
        try? self.managedObjectContext?.save()
    }
}
