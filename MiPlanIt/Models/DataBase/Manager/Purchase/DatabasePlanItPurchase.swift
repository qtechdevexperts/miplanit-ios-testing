//
//  DatabasePlanItPurchase.swift
//  MiPlanIt
//
//  Created by Aneesh Asokan on 07/05/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation
import CoreData

class DatabasePlanItPurchase: DataBaseManager {
    
    func insertOrUpdatePurchase(_ data: [[String: Any]], using context: NSManagedObjectContext? = nil) {
        guard !data.isEmpty else { return }
        let objectContext = context ?? self.mainObjectContext
        let localPurchases = self.readSpecificPurchasesWithData(purchases: data, using: objectContext)
        for purchase in data {
            let purchaseId = purchase["purchaseId"] as? Double ?? 0
            let appPurchaseId = purchase["appPurchaseId"] as? String ?? Strings.empty
            let purchaseEntity = localPurchases.filter({ return ($0.purchaseId == purchaseId && purchaseId != 0) || ($0.appPurchaseId == appPurchaseId && !appPurchaseId.isEmpty) }).first ?? self.insertNewRecords(Table.planItPurchase, context: objectContext) as! PlanItPurchase
            purchaseEntity.purchaseId = purchaseId
            purchaseEntity.amount = purchase["amountPaid"] as? String
            purchaseEntity.location = purchase["location"] as? String
            if let date = purchase["dateOfPurchase"] as? String {
                purchaseEntity.billDate = date.stringToDate(formatter: DateFormatters.MMDDYYYY)
            }
            else {
                purchaseEntity.billDate = nil
            }
            purchaseEntity.storeName = purchase["storeName"] as? String
            purchaseEntity.productName = purchase["productName"] as? String
            purchaseEntity.paymentTypeId = String(purchase["paymentMode"] as? Int ?? 1)
            purchaseEntity.paymentDescription = purchase["paymentDescription"] as? String ?? Strings.empty
            purchaseEntity.purchaseDescription = purchase["notes"] as? String
            purchaseEntity.currencySymbol = purchase["currencySymbol"] as? String
            purchaseEntity.purchaseCategoryType = purchase["purchaseCategory"] as? Double ?? 1
            purchaseEntity.appPurchaseId = appPurchaseId
            purchaseEntity.userId = Session.shared.readUserId()
            purchaseEntity.isPending = false
            if let createdAt = purchase["createdAt"] as? String, let date = createdAt.stringToDate(formatter: DateFormatters.MMDDYYYYHMMSSA, timeZone: TimeZone(abbreviation: "UTC")!) {
                purchaseEntity.createdAt = date
            }
            if let modifiedAt = purchase["modifiedAt"] as? String, let date = modifiedAt.stringToDate(formatter: DateFormatters.MMDDYYYYHMMSSA, timeZone: TimeZone(abbreviation: "UTC")!) {
                purchaseEntity.modifiedAt = date
            }
            if let cardDetails = purchase["cardInfo"] as? [String: Any] {
                DatabasePlanItPurchaseCard().insertCard(cardDetails, for: purchaseEntity, using: objectContext)
            }
            if let createdBy = purchase["createdBy"] as? [String: Any] {
                DatabasePlanItCreator().insertPurchase(purchaseEntity, creator: createdBy, using: objectContext)
            }
            if let tags = purchase["tags"] as? [String] {
                DatabasePlanItTags().insertTags(tags, for: purchaseEntity, using: objectContext)
            }
            if let attachments = purchase["attachments"] as? [[String: Any]] {
                DatabasePlanItUserAttachment().insertAttachments(attachments, for: purchaseEntity, using: objectContext)
            }
        }
    }
    
    func insertOrUpdatePurchase(_ data: [String: Any]) -> PlanItPurchase {
        let purchaseId = data["purchaseId"] as? Double ?? 0
        let purchaseEntity = self.readSpecificPurchasesWithData(purchases: [data]).first ?? self.insertNewRecords(Table.planItPurchase, context: self.mainObjectContext) as! PlanItPurchase
        purchaseEntity.purchaseId = purchaseId
        purchaseEntity.amount = data["amountPaid"] as? String
        purchaseEntity.location = data["location"] as? String
        if let date = data["dateOfPurchase"] as? String {
            purchaseEntity.billDate = date.stringToDate(formatter: DateFormatters.MMDDYYYY)
        }
        else {
            purchaseEntity.billDate = nil
        }
        purchaseEntity.storeName = data["storeName"] as? String
        purchaseEntity.productName = data["productName"] as? String
        purchaseEntity.paymentTypeId = String(data["paymentMode"] as? Int ?? 1)
        purchaseEntity.paymentDescription = data["paymentDescription"] as? String ?? Strings.empty
        purchaseEntity.purchaseDescription = data["notes"] as? String
        purchaseEntity.currencySymbol = data["currencySymbol"] as? String
        purchaseEntity.purchaseCategoryType = data["purchaseCategory"] as? Double ?? 1
        purchaseEntity.userId = Session.shared.readUserId()
        if let createdAt = data["createdAt"] as? String, let date = createdAt.stringToDate(formatter: DateFormatters.MMDDYYYYHMMSSA, timeZone: TimeZone(abbreviation: "UTC")!) {
            purchaseEntity.createdAt = date
        }
        if let modifiedAt = data["modifiedAt"] as? String, let date = modifiedAt.stringToDate(formatter: DateFormatters.MMDDYYYYHMMSSA, timeZone: TimeZone(abbreviation: "UTC")!) {
            purchaseEntity.modifiedAt = date
        }
        if let cardDetails = data["cardInfo"] as? [String: Any] {
            DatabasePlanItPurchaseCard().insertCard(cardDetails, for: purchaseEntity, using: self.mainObjectContext)
        }
        if let createdBy = data["createdBy"] as? [String: Any] {
            DatabasePlanItCreator().insertPurchase(purchaseEntity, creator: createdBy, using: self.mainObjectContext)
        }
        if let tags = data["tags"] as? [String] {
            DatabasePlanItTags().insertTags(tags, for: purchaseEntity, using: self.mainObjectContext)
        }
        if let attachments = data["billattachments"] as? [[String: Any]] {
            DatabasePlanItUserAttachment().insertAttachments(attachments, for: purchaseEntity, using: self.mainObjectContext)
        }
        self.mainObjectContext.saveContext()
        return purchaseEntity
    }
    
    func insertOfflineGiftPurchase(_ purchase: Purchase) -> PlanItPurchase {
        let purchaseEntity = purchase.planItPurchase ?? self.insertNewRecords(Table.planItPurchase, context: self.mainObjectContext) as! PlanItPurchase
        purchaseEntity.appPurchaseId = purchaseEntity.appPurchaseId ?? UUID().uuidString
        purchaseEntity.amount = purchase.amount
        purchaseEntity.location = purchase.location
        purchaseEntity.billDate = purchase.billDate
        purchaseEntity.storeName = purchase.storeName
        purchaseEntity.productName = purchase.productName
        purchaseEntity.paymentTypeId = String(purchase.paymentTypeId)
        purchaseEntity.paymentDescription = purchase.paymentDescription 
        purchaseEntity.purchaseDescription = purchase.purchaseDescription
        purchaseEntity.currencySymbol = purchase.currencySymbol
        purchaseEntity.purchaseCategoryType = purchase.readPurchaseCategoryTypeValue()
        purchaseEntity.isPending = true
        purchaseEntity.userId = Session.shared.readUserId()
        purchaseEntity.createdAt = Date()
        purchaseEntity.modifiedAt = Date()
        DatabasePlanItTags().insertTags(purchase.tags, for: purchaseEntity, using: self.mainObjectContext)
        DatabasePlanItUserAttachment().insertAttachments(purchase.attachments, for: purchaseEntity, using: self.mainObjectContext)
        if let purchaseCard = purchase.paymentCard {
            DatabasePlanItPurchaseCard().insertCard(purchaseCard, for: purchaseEntity, using: self.mainObjectContext)
        }
        self.mainObjectContext.saveContext()
        return purchaseEntity
    }
    
    func removePlanItPurchases(_ purchases: [Double], using context: NSManagedObjectContext? = nil) {
        let objectContext = context ?? self.mainObjectContext
        let localPurchases = self.readSpecificPurchases(purchases, using: objectContext)
        localPurchases.forEach({ objectContext.delete($0) })
    }
    
    func readSpecificPurchasesWithData(purchases: [[String: Any]], using context: NSManagedObjectContext? = nil) -> [PlanItPurchase] {
        let objectContext = context ?? self.mainObjectContext
        let purchaseIds = purchases.compactMap({ return $0["purchaseId"] as? Double })
        let appPurchaseIds: [String] = purchases.compactMap({ if let appPurchaseId = $0["appPurchaseId"] as? String, !appPurchaseId.isEmpty { return appPurchaseId } else { return nil } })
        let predicate = NSPredicate(format: "userId == %@ AND (purchaseId IN %@ OR appPurchaseId IN %@)", Session.shared.readUserId(), purchaseIds, appPurchaseIds)
         return self.readRecords(fromCoreData: Table.planItPurchase, predicate: predicate, context: objectContext) as! [PlanItPurchase]
    }
    
    private func readSpecificPurchases(_ purchases: [Double], using context: NSManagedObjectContext? = nil) -> [PlanItPurchase] {
        let objectContext = context ?? self.mainObjectContext
        let predicate = NSPredicate(format: "userId == %@ AND purchaseId IN %@", Session.shared.readUserId(), purchases)
        return self.readRecords(fromCoreData: Table.planItPurchase, predicate: predicate, context: objectContext) as! [PlanItPurchase]
    }
    
    private func readSpecificAppPurchases(_ purchasesAppId: String, using context: NSManagedObjectContext? = nil) -> [PlanItPurchase] {
        if purchasesAppId.isEmpty { return [] }
        let objectContext = context ?? self.mainObjectContext
        let predicate = NSPredicate(format: "userId == %@ AND appPurchaseId == %@", Session.shared.readUserId(), purchasesAppId)
        return self.readRecords(fromCoreData: Table.planItPurchase, predicate: predicate, context: objectContext) as! [PlanItPurchase]
    }
    
    func readAllPurchasList() -> [PlanItPurchase] {
        let predicate = NSPredicate(format: "userId == %@ AND deleteStatus == NO", Session.shared.readUserId())
        return self.readRecords(fromCoreData: Table.planItPurchase, predicate: predicate, sortDescriptor: ["modifiedAt"], ascending: false, context: self.mainObjectContext) as! [PlanItPurchase]
    }
    
    func readAllPendingPurchases(using context: NSManagedObjectContext? = nil) -> [PlanItPurchase] {
        let objectContext = context ?? self.mainObjectContext
        let predicate = NSPredicate(format: "userId == %@ AND isPending == YES", Session.shared.readUserId())
        return self.readRecords(fromCoreData: Table.planItPurchase, predicate: predicate, context: objectContext) as! [PlanItPurchase]
    }
    
    func readAllPendingDeletedPurchase(using context: NSManagedObjectContext? = nil) -> [PlanItPurchase] {
        let objectContext = context ?? self.mainObjectContext
        let predicate = NSPredicate(format: "userId == %@ AND deleteStatus == YES AND isPending == YES", Session.shared.readUserId())
        return self.readRecords(fromCoreData: Table.planItPurchase, predicate: predicate, context: objectContext) as! [PlanItPurchase]
    }
    
    func readAllFuturePurchasListUsingQueue(startOfMonth: Date, endOfMonth: Date, result: @escaping ([PlanItPurchase]) -> ()) {
        self.privateObjectContext.perform {
            let start = startOfMonth as NSDate
            let end = endOfMonth as NSDate
            let predicate = NSPredicate(format: "userId == %@ AND billDate >= %@ AND billDate <= %@ AND  deleteStatus == NO", Session.shared.readUserId(), start, end)
            let purchases = self.readRecords(fromCoreData: Table.planItPurchase, predicate: predicate, sortDescriptor: ["billDate"], ascending: false, context: self.privateObjectContext) as! [PlanItPurchase]
            result(purchases)
        }
    }
}
