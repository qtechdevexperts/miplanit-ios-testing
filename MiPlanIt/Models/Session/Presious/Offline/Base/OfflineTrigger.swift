//
//  OfflineTrigger.swift
//  MiPlanIt
//
//  Created by Arun on 22/09/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

extension Session {
    
    func startOfflineSyncingTimer() {
        if self.offlineTimer == nil {
            self.offlineTimer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true, block: { _ in
                if SocialManager.default.isNetworkReachable() {
                    self.sendOfflineDataToServer()
                }
            })
        }
    }
    
    func stopOfflineSyncingTimer() {
        if self.offlineTimer != nil {
            self.offlineTimer?.invalidate()
            self.offlineTimer = nil
        }
    }
    
    private func sendOfflineDataToServer() {
        guard let user = Session.shared.readUser(), !self.readSyncingStarted() else { return }
        self.saveSyncingStarted(true)
        InAppPurchaseService().verifySubscriptionStatus(user: user) {
            self.startPendingProfileSynchronisation()
        }
    }
    
    func startPendingProfileSynchronisation() {
        self.saveProfileToServer {
            self.startPendingDashboardSynchronisation()
        }
    }
    
    func startPendingDashboardSynchronisation() {
        self.sendDashboardToServer {
            self.startPendingTodoCategorySynchronisation()
        }
    }
    
    func startPendingTodoCategorySynchronisation() {
        self.sendTodoCategoryToServer {
            self.startPendingTodoAttachmentSynchronisation()
        }
    }
    
    func startPendingTodoAttachmentSynchronisation() {
        self.sendPendingAttachmentsToServer(type: .task) {
            self.startPendingTodoSynchronisation()
        }
    }
    
    func startPendingTodoSynchronisation() {
        self.sendTodoToServer {
            self.startPendingTodoMovesSynchronisation()
        }
    }
    
    func startPendingTodoMovesSynchronisation() {
        self.sendTodoMovesToServer {
            self.startPendingCalendarSynchronisation()
        }
    }
    
    func startPendingCalendarSynchronisation() {
        self.sendCalendarsToServer {
            self.startPendingEventSynchronisation()
        }
    }
    
    func startPendingEventSynchronisation() {
        self.sendEventsToServer {
            self.startPendingGiftCouponAttachmentSynchronisation()
//            self.saveSyncingStarted(false)
        }
    }
    
    func startPendingGiftCouponAttachmentSynchronisation() {
        self.sendPendingGiftAttachmentsToServer {
            self.startPendingGiftCouponSynchronisation()
        }
    }
    
    func startPendingGiftCouponSynchronisation() {
        self.sendGiftCouponToServer {
            self.startPendingPurchaseAttachmentSynchronisation()
            //self.saveSyncingStarted(false)
        }
    }
    
    func startPendingPurchaseAttachmentSynchronisation() {
        self.sendPendingPurchaseAttachmentsToServer {
            self.startPendingPurchaseSynchronisation()
        }
    }
    
    func startPendingPurchaseSynchronisation() {
        self.sendPurchaseToServer {
            self.startPendingShopListSynchronisation()
            //self.saveSyncingStarted(false)
        }
    }
    
    func startPendingShopListSynchronisation() {
        self.sendShopListToServer {
            self.startPendingDeletedShopCategorySynchronisation()
        }
    }
    
    func  startPendingDeletedShopCategorySynchronisation() {
        self.sendDeletedShopUserCategoryToServer {
            self.startPendingShopCategorySynchronisation()
        }
    }
    
    func startPendingShopCategorySynchronisation() {
        self.sendShopUserCategoryToServer {
            self.startPendingShopListItemAttachmentSynchronisation()
        }
    }
    
    func startPendingShopListItemAttachmentSynchronisation() {
        self.sendPendingShopListItemAttachmentsToServer {
            self.startPendingShopListItemSynchronisation()
        }
    }
    
    func startPendingShopListItemSynchronisation() {
        self.sendShopListItemToServer {
            self.startPendingShopListItemMovesSynchronisation()
        }
    }
    
    func startPendingShopListItemMovesSynchronisation() {
        self.sendShopListItemMovesToServer {
            self.startPendingShopListItemCompletionStatusSynchronisation()
        }
    }
    
    func startPendingShopListItemCompletionStatusSynchronisation() {
        self.sendCompletionStatusShopListItemToServer {
            self.startPendingShopListItemFavoriteStatusSynchronisation()
        }
    }
    
    func startPendingShopListItemFavoriteStatusSynchronisation() {
        self.sendFavoriteStatusShopListItemToServer {
            self.startPendingShareLinksSynchronisation()
        }
    }
    
    func startPendingShareLinksSynchronisation() {
        self.sendShareLinkToServer {
            self.saveSyncingStarted(false)
        }
    }
}
