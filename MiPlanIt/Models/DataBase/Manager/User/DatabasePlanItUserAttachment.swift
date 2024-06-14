//
//  DatabasePlanItUserAttachment.swift
//  MiPlanIt
//
//  Created by Arun on 08/05/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation
import CoreData

class DatabasePlanItUserAttachment: DataBaseManager {
    
    func insertAttachments(_ attachments: [[String: Any]], for purchase: PlanItPurchase, using context: NSManagedObjectContext? = nil) {
        purchase.deleteAllPurchaseAttachments(forceRemove: false)
        let objectContext = context ?? self.mainObjectContext
        for attachment in attachments {
            let attachmentEntity = self.insertNewRecords(Table.planItUserAttachment, context: objectContext) as! PlanItUserAttachment
            attachmentEntity.user = Session.shared.readUserId()
            attachmentEntity.url = attachment["attachmentUrl"] as? String
            attachmentEntity.file = attachment["attachmentName"] as? String
            attachmentEntity.createdAt = attachment["createdAt"] as? String
            attachmentEntity.identifier = attachment["attachmentId"] as? Double ?? 0
            attachmentEntity.purchase = purchase
        }
    }
    
    func insertAttachments(_ attachments: [UserAttachment], for purchase: PlanItPurchase, using context: NSManagedObjectContext? = nil) {
        purchase.deleteAllPurchaseAttachments(forceRemove: true)
        let objectContext = context ?? self.mainObjectContext
        for attachment in attachments {
            let attachmentEntity = self.insertNewRecords(Table.planItUserAttachment, context: objectContext) as! PlanItUserAttachment
            attachmentEntity.user = Session.shared.readUserId()
            attachmentEntity.url = attachment.url
            attachmentEntity.file = attachment.file
            if !attachment.identifier.isEmpty, let convertedId = Double(attachment.identifier) {
                attachmentEntity.identifier = convertedId
            }
            if let data = attachment.data, !data.isEmpty {
                attachmentEntity.isPending = true
                attachmentEntity.data = data
            }
            attachmentEntity.purchase = purchase
        }
    }
    
    func insertAttachments(_ attachments: [[String: Any]], for giftCoupon: PlanItGiftCoupon, using context: NSManagedObjectContext? = nil) {
        giftCoupon.deleteAllGiftCouponAttachments(forceRemove: false)
        let objectContext = context ?? self.mainObjectContext
        for attachment in attachments {
            let attachmentEntity = self.insertNewRecords(Table.planItUserAttachment, context: objectContext) as! PlanItUserAttachment
            attachmentEntity.user = Session.shared.readUserId()
            attachmentEntity.url = attachment["attachmentUrl"] as? String
            attachmentEntity.file = attachment["attachmentName"] as? String
            attachmentEntity.createdAt = attachment["createdAt"] as? String
            attachmentEntity.identifier = attachment["attachmentId"] as? Double ?? 0
            attachmentEntity.giftCoupon = giftCoupon
        }
    }
    
    func insertAttachments(_ attachments: [UserAttachment], for giftCoupon: PlanItGiftCoupon, using context: NSManagedObjectContext? = nil) {
        giftCoupon.deleteAllGiftCouponAttachments(forceRemove: true)
        let objectContext = context ?? self.mainObjectContext
        for attachment in attachments {
            let attachmentEntity = self.insertNewRecords(Table.planItUserAttachment, context: objectContext) as! PlanItUserAttachment
            attachmentEntity.user = Session.shared.readUserId()
            attachmentEntity.url = attachment.url
            attachmentEntity.file = attachment.file
            if !attachment.identifier.isEmpty, let convertedId = Double(attachment.identifier) {
                attachmentEntity.identifier = convertedId
            }
            if let data = attachment.data, !data.isEmpty {
                attachmentEntity.isPending = true
                attachmentEntity.data = data
            }
            attachmentEntity.giftCoupon = giftCoupon
        }
    }
    
    func insertAttachments(_ attachments: [[String: Any]], for shopList: PlanItShopListItems, using context: NSManagedObjectContext? = nil) {
        shopList.deleteAllShopAttachments(forceRemove: false)
        let objectContext = context ?? self.mainObjectContext
        for attachment in attachments {
            let attachmentEntity = self.insertNewRecords(Table.planItUserAttachment, context: objectContext) as! PlanItUserAttachment
            attachmentEntity.user = Session.shared.readUserId()
            attachmentEntity.url = attachment["attachmentUrl"] as? String
            attachmentEntity.file = attachment["attachmentName"] as? String
            attachmentEntity.createdAt = attachment["createdAt"] as? String
            attachmentEntity.identifier = attachment["attachmentId"] as? Double ?? 0
            attachmentEntity.shopListItem = shopList
        }
    }
    
    func insertAttachments(_ attachments: [[String: Any]], for todo: PlanItTodo, using context: NSManagedObjectContext? = nil) {
        todo.deleteAllTodoAttachments(forceRemove: false)
        let objectContext = context ?? self.mainObjectContext
        todo.attachmentsCount = attachments.isEmpty ? Strings.empty : "\(attachments.count)"
        for attachment in attachments {
            let attachmentEntity = self.insertNewRecords(Table.planItUserAttachment, context: objectContext) as! PlanItUserAttachment
            attachmentEntity.isPending = false
            attachmentEntity.user = Session.shared.readUserId()
            attachmentEntity.url = attachment["attachmentUrl"] as? String
            attachmentEntity.file = attachment["attachmentName"] as? String
            attachmentEntity.createdAt = attachment["createdAt"] as? String
            attachmentEntity.identifier = attachment["attachmentId"] as? Double ?? 0
            attachmentEntity.todo = todo
        }
    }
    
    func insertAttachments(_ attachments: [UserAttachment], for todo: PlanItTodo, using context: NSManagedObjectContext? = nil) {
        todo.deleteAllTodoAttachments(forceRemove: true)
        let objectContext = context ?? self.mainObjectContext
        todo.attachmentsCount = attachments.isEmpty ? Strings.empty : "\(attachments.count)"
        for attachment in attachments {
            let attachmentEntity = self.insertNewRecords(Table.planItUserAttachment, context: objectContext) as! PlanItUserAttachment
            attachmentEntity.user = Session.shared.readUserId()
            attachmentEntity.url = attachment.url
            attachmentEntity.file = attachment.file
            if !attachment.identifier.isEmpty, let convertedId = Double(attachment.identifier) {
                attachmentEntity.identifier = convertedId
            }
            if let data = attachment.data, !data.isEmpty {
                attachmentEntity.isPending = true
                attachmentEntity.data = data
            }
            attachmentEntity.todo = todo
        }
    }
    
    func insertAttachments(_ attachments: [UserAttachment], for shopListItems: PlanItShopListItems, using context: NSManagedObjectContext? = nil) {
        shopListItems.deleteAllShopAttachments(forceRemove: true)
        let objectContext = context ?? self.mainObjectContext
        for attachment in attachments {
            let attachmentEntity = self.insertNewRecords(Table.planItUserAttachment, context: objectContext) as! PlanItUserAttachment
            attachmentEntity.user = Session.shared.readUserId()
            attachmentEntity.url = attachment.url
            attachmentEntity.file = attachment.file
            if !attachment.identifier.isEmpty, let convertedId = Double(attachment.identifier) {
                attachmentEntity.identifier = convertedId
            }
            if let data = attachment.data, !data.isEmpty {
                attachmentEntity.isPending = true
                attachmentEntity.data = data
            }
            attachmentEntity.shopListItem = shopListItems
        }
    }
    
    func readAllPendingAttachements(using context: NSManagedObjectContext? = nil) -> [PlanItUserAttachment] {
        let objectContext = context ?? self.mainObjectContext
        let predicate = NSPredicate(format: "user == %@ AND isPending == YES", Session.shared.readUserId())
        return self.readRecords(fromCoreData: Table.planItUserAttachment, predicate: predicate, context: objectContext) as! [PlanItUserAttachment]
    }
}
