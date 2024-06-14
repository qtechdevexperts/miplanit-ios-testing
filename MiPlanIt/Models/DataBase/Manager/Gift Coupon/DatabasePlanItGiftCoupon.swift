//
//  DatabasePlanItGiftCoupon.swift
//  MiPlanIt
//
//  Created by Arun on 09/05/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

import CoreData

class DatabasePlanItGiftCoupon: DataBaseManager {
    
    func insertOrUpdateGiftCoupon(_ data: [[String: Any]], using context: NSManagedObjectContext? = nil) {
        guard !data.isEmpty else { return }
        let objectContext = context ?? self.mainObjectContext
        let localGiftCoupons = self.readGiftCouponWithData(giftCoupons: data, using: objectContext)
        for gift in data {
            let giftCouponId = gift["couponId"] as? Double ?? 0
            let appGiftCouponId = gift["appCouponId"] as? String ?? Strings.empty
            let giftCouponEntity = localGiftCoupons.filter({ return ($0.couponServerId == giftCouponId && giftCouponId != 0) || ($0.appGiftCouponId == appGiftCouponId && !appGiftCouponId.isEmpty)}).first ?? self.insertNewRecords(Table.planItGiftCoupon, context: objectContext) as! PlanItGiftCoupon
            giftCouponEntity.appGiftCouponId = gift["appCouponId"] as? String
            giftCouponEntity.couponServerId = gift["couponId"] as? Double ?? 0
            giftCouponEntity.couponDescription = gift["description"] as? String
            giftCouponEntity.issuedBy = gift["offeredAt"] as? String
            giftCouponEntity.couponName = gift["title"] as? String
            giftCouponEntity.couponAmount = gift["couponAmount"] as? String
            giftCouponEntity.recievedFrom = gift["receivedFrom"] as? String
            giftCouponEntity.couponCode = gift["couponCode"] as? String
            giftCouponEntity.couponId = gift["couponAddtId"] as? String
            giftCouponEntity.createdAt = gift["createdAt"] as? String
            giftCouponEntity.modifiedAt = gift["modifiedAt"] as? String
            giftCouponEntity.redeemedDate = gift["redeemedDate"] as? String
            giftCouponEntity.currencySymbol = gift["currencySymbol"] as? String
            giftCouponEntity.couponDataType = gift["couponDataType"] as? Double ?? 0.0
            giftCouponEntity.appGiftCouponId = appGiftCouponId
            giftCouponEntity.userId = Session.shared.readUserId()
            giftCouponEntity.isPending = false
            if let validTill = gift["validTill"] as? String, let date = validTill.stringToDate(formatter: DateFormatters.MMDDYYYYHMMSSA) {
                giftCouponEntity.expiryDate = date
            }
            if let createdBy = gift["createdBy"] as? [String: Any] {
                DatabasePlanItCreator().insertGiftCoupon(giftCouponEntity, creator: createdBy, using: objectContext)
            }
            if let tags = gift["tags"] as? [String] {
                DatabasePlanItTags().insertTags(tags, for: giftCouponEntity, using: objectContext)
            }
            if let attachments = gift["attachments"] as? [[String: Any]] {
                DatabasePlanItUserAttachment().insertAttachments(attachments, for: giftCouponEntity, using: objectContext)
            }
        }
    }
    
    func insertOrUpdateGiftCoupon(_ data: [String: Any]) -> PlanItGiftCoupon {
        let giftCouponId = data["couponId"] as? Double ?? 0
        let giftCouponEntity = self.readGiftCouponWithData(giftCoupons: [data]).first ?? self.insertNewRecords(Table.planItGiftCoupon, context: self.mainObjectContext) as! PlanItGiftCoupon
        giftCouponEntity.appGiftCouponId = data["appCouponId"] as? String
        giftCouponEntity.couponServerId = giftCouponId
        giftCouponEntity.couponDescription = data["description"] as? String
        giftCouponEntity.issuedBy = data["offeredAt"] as? String
        giftCouponEntity.couponName = data["title"] as? String
        giftCouponEntity.couponAmount = data["couponAmount"] as? String
        giftCouponEntity.recievedFrom = data["receivedFrom"] as? String
        giftCouponEntity.couponCode = data["couponCode"] as? String
        giftCouponEntity.couponId = data["couponAddtId"] as? String
        giftCouponEntity.createdAt = data["createdAt"] as? String
        giftCouponEntity.redeemedDate = data["redeemedDate"] as? String
        giftCouponEntity.modifiedAt = data["modifiedAt"] as? String
        giftCouponEntity.currencySymbol = data["currencySymbol"] as? String
        giftCouponEntity.couponDataType = data["couponDataType"] as? Double ?? 0.0
        giftCouponEntity.isPending = false
        giftCouponEntity.userId = Session.shared.readUserId()
        if let validTill = data["validTill"] as? String, let date = validTill.stringToDate(formatter: DateFormatters.MMDDYYYYHMMSSA) {
            giftCouponEntity.expiryDate = date
        }
        if let createdBy = data["createdBy"] as? [String: Any] {
            DatabasePlanItCreator().insertGiftCoupon(giftCouponEntity, creator: createdBy, using: self.mainObjectContext)
        }
        if let tags = data["tags"] as? [String] {
            DatabasePlanItTags().insertTags(tags, for: giftCouponEntity, using: self.mainObjectContext)
        }
        if let attachments = data["billattachments"] as? [[String: Any]] {
            DatabasePlanItUserAttachment().insertAttachments(attachments, for: giftCouponEntity, using: self.mainObjectContext)
        }
        self.mainObjectContext.saveContext()
        return giftCouponEntity
    }
    
    func insertOfflineGiftCoupon(_ giftCoupon: GiftCoupon) -> PlanItGiftCoupon {
        let giftCouponEntity = self.readSpecificAppGiftCoupons(giftCoupon.couponAppId).first ?? self.insertNewRecords(Table.planItGiftCoupon, context: self.mainObjectContext) as! PlanItGiftCoupon
        giftCouponEntity.appGiftCouponId = giftCouponEntity.appGiftCouponId ?? UUID().uuidString
        giftCouponEntity.couponName = giftCoupon.couponName
        giftCouponEntity.couponDescription = giftCoupon.couponDescription
        giftCouponEntity.issuedBy = giftCoupon.issuedBy
        giftCouponEntity.couponAmount = giftCoupon.couponAmount
        giftCouponEntity.recievedFrom = giftCoupon.recievedFrom
        giftCouponEntity.couponCode = giftCoupon.couponCode
        giftCouponEntity.couponId = giftCoupon.couponId
        giftCouponEntity.redeemedDate = giftCoupon.redeemedDate
        giftCouponEntity.currencySymbol = giftCoupon.currencySymbol
        giftCouponEntity.couponDataType = giftCoupon.readCategoryTypeValue()
        giftCouponEntity.userId = Session.shared.readUserId()
        giftCouponEntity.isPending = true
        if let date = giftCoupon.expiryDate.stringToDate(formatter: DateFormatters.YYYYHMMMHDD) {
            giftCouponEntity.expiryDate = date
        }
        else if let date = giftCoupon.expiryDate.stringToDate(formatter: DateFormatters.MMDDYYYYHMMSSA) {
            giftCouponEntity.expiryDate = date
        }
        giftCouponEntity.createdAt = Date().stringFromDate(format: DateFormatters.MMDDYYYYHMMSSA)
        giftCouponEntity.modifiedAt = Date().stringFromDate(format: DateFormatters.MMDDYYYYHMMSSA)
        DatabasePlanItTags().insertTags(giftCoupon.tags, for: giftCouponEntity, using: self.mainObjectContext)
        DatabasePlanItUserAttachment().insertAttachments(giftCoupon.attachments, for: giftCouponEntity, using: self.mainObjectContext)
        self.mainObjectContext.saveContext()
        return giftCouponEntity
    }
        
    func removePlanItGiftCoupons(_ giftCoupons: [Double], using context: NSManagedObjectContext? = nil) {
        let objectContext = context ?? self.mainObjectContext
        let localGiftCoupons = self.readSpecificGiftCoupons(giftCoupons, using: objectContext)
        localGiftCoupons.forEach({ objectContext.delete($0) })
    }
    
    func readGiftCouponWithData(giftCoupons: [[String: Any]], using context: NSManagedObjectContext? = nil) -> [PlanItGiftCoupon] {
        let objectContext = context ?? self.mainObjectContext
        let couponIds = giftCoupons.compactMap({ return $0["couponId"] as? Double })
        let appGiftCouponIds: [String] = giftCoupons.compactMap({ if let appCouponId = $0["appCouponId"] as? String, !appCouponId.isEmpty { return appCouponId } else { return nil } })
        let predicate = NSPredicate(format: "userId == %@ AND (couponServerId IN %@ OR appGiftCouponId IN %@)", Session.shared.readUserId(), couponIds, appGiftCouponIds)
         return self.readRecords(fromCoreData: Table.planItGiftCoupon, predicate: predicate, context: objectContext) as! [PlanItGiftCoupon]
    }
    
    private func readSpecificAppGiftCoupons(_ giftCouponsAppId: String, using context: NSManagedObjectContext? = nil) -> [PlanItGiftCoupon] {
        if giftCouponsAppId.isEmpty { return [] }
        let objectContext = context ?? self.mainObjectContext
        let predicate = NSPredicate(format: "userId == %@ AND appGiftCouponId == %@", Session.shared.readUserId(), giftCouponsAppId)
        return self.readRecords(fromCoreData: Table.planItGiftCoupon, predicate: predicate, context: objectContext) as! [PlanItGiftCoupon]
    }
    
    private func readSpecificGiftCoupons(_ giftCoupons: [Double], using context: NSManagedObjectContext? = nil) -> [PlanItGiftCoupon] {
        let objectContext = context ?? self.mainObjectContext
        let predicate = NSPredicate(format: "userId == %@ AND couponServerId IN %@", Session.shared.readUserId(), giftCoupons)
        return self.readRecords(fromCoreData: Table.planItGiftCoupon, predicate: predicate, context: objectContext) as! [PlanItGiftCoupon]
    }
    
    func readAllGiftCouponsList() -> [PlanItGiftCoupon] {
        let predicate = NSPredicate(format: "userId == %@ AND deleteStatus == NO", Session.shared.readUserId())
        return self.readRecords(fromCoreData: Table.planItGiftCoupon, predicate: predicate, sortDescriptor: ["modifiedAt"], ascending: false, context: self.mainObjectContext) as! [PlanItGiftCoupon]
    }
    
    func readAllPendingGiftCoupon(using context: NSManagedObjectContext? = nil) -> [PlanItGiftCoupon] {
        let objectContext = context ?? self.mainObjectContext
        let predicate = NSPredicate(format: "userId == %@ AND isPending == YES AND deleteStatus == NO", Session.shared.readUserId())
        return self.readRecords(fromCoreData: Table.planItGiftCoupon, predicate: predicate, sortDescriptor: ["modifiedAt"], ascending: false, context: objectContext) as! [PlanItGiftCoupon]
    }
    
    func readAllPendingDeletedGiftCoupon(using context: NSManagedObjectContext? = nil) -> [PlanItGiftCoupon] {
        let objectContext = context ?? self.mainObjectContext
        let predicate = NSPredicate(format: "userId == %@ AND deleteStatus == YES AND isPending == YES", Session.shared.readUserId())
        return self.readRecords(fromCoreData: Table.planItGiftCoupon, predicate: predicate, sortDescriptor: ["modifiedAt"], ascending: false, context: objectContext) as! [PlanItGiftCoupon]
    }

    
    func readAllFutureGiftCouponsListUsingQueue(startOfMonth: Date, endOfMonth: Date, anyItemsExist: Bool, result: @escaping ([PlanItGiftCoupon]) -> ()) {
        self.privateObjectContext.perform {
            let start = startOfMonth as NSDate
            let end = endOfMonth as NSDate
            let predicate = NSPredicate(format: "userId == %@ AND ((expiryDate >= %@ AND expiryDate <= %@) \(anyItemsExist ? "" : " OR expiryDate == nil" )) AND deleteStatus == NO", Session.shared.readUserId(), start, end)
            let giftCoupons = self.readRecords(fromCoreData: Table.planItGiftCoupon, predicate: predicate, sortDescriptor: ["modifiedAt"], ascending: false, context: self.privateObjectContext) as! [PlanItGiftCoupon]
            result(giftCoupons)
        }
    }
}
