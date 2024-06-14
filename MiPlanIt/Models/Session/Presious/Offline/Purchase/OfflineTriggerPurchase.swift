//
//  OfflineTriggerPurchase.swift
//  MiPlanIt
//
//  Created by Febin Paul on 01/12/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation


extension Session {
    
    func sendPendingPurchaseAttachmentsToServer(finished: @escaping () -> ()) {
        let pendingAttachments = DatabasePlanItUserAttachment().readAllPendingAttachements().filter({ $0.purchase != nil })
        if pendingAttachments.isEmpty {
            finished()
        }
        else {
            self.uploadPendingAttachmentsToServer(pendingAttachments, finished: finished)
        }
    }
    
    func uploadPendingAttachmentsToServer(_ attachments: [PlanItUserAttachment], at index: Int = 0, finished: @escaping () -> ()) {
        guard index < attachments.count else { finished(); return }
        let ownerIdValue = attachments[index].purchase?.createdBy?.readValueOfUserId() ?? Strings.empty
        let convertedAttachment = UserAttachment(with: attachments[index], type: .purchase, ownerId: ownerIdValue)
        UserService().uploadAttachement(convertedAttachment, callback: { attachment, _ in
            if let result = attachment {
                attachments[index].savePurchasettachmentIdentifier(result.identifier)
            }
            self.uploadPendingAttachmentsToServer(attachments, at: index + 1, finished: finished)
        })
    }
    
    func sendPurchaseToServer(_ finished: @escaping () -> ()) {
        let allPendingPurchase = DatabasePlanItPurchase().readAllPendingPurchases()
        if allPendingPurchase.isEmpty {
            self.sendDeletePurchaseToServer(finished)
        }
        else {
            self.startPurchaseSending(allPendingPurchase) {
                finished()
            }
        }
    }
    
    private func startPurchaseSending(_ purchases: [PlanItPurchase], atIndex: Int = 0, finished: @escaping () -> ()) {
        if atIndex < purchases.count {
            self.sendPurchaseToServer(purchase: purchases[atIndex], at: atIndex) { (index) in
                self.startPurchaseSending(purchases, atIndex: index + 1, finished: finished)
            }
        }
        else {
            finished()
        }
    }
    
    private func sendPurchaseToServer(purchase: PlanItPurchase, at index: Int, result: @escaping (Int) -> ()) {
        PurchaseService().addPurchase(Purchase(with: purchase)) { (response, error) in
            result(index)
        }
    }
    
    func sendDeletePurchaseToServer(_ finished: @escaping () -> ()) {
        let pendingDeletedpurchase = DatabasePlanItPurchase().readAllPendingDeletedPurchase()
        if pendingDeletedpurchase.isEmpty {
            finished()
        }
        else {
            self.startDeletedPurchaseSending(pendingDeletedpurchase) {
                finished()
            }
        }
    }
    
    private func startDeletedPurchaseSending(_ purchases: [PlanItPurchase], atIdex: Int = 0, finished: @escaping () -> ()) {
        if atIdex < purchases.count {
            self.sendDeletedPurchaseToServer(purchase: purchases[atIdex], at: atIdex, result: { index in
                self.startDeletedPurchaseSending(purchases, atIdex: index + 1, finished: finished)
            })
        }
        else {
            finished()
        }
    }
    
    private func sendDeletedPurchaseToServer(purchase: PlanItPurchase, at index: Int, result: @escaping (Int) -> ()) {
        PurchaseService().deletePurchase(purchase) { (status, error) in
            result(index)
        }
    }
}
