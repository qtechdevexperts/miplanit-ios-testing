//
//  OfflineTriggerShareLink.swift
//  MiPlanIt
//
//  Created by Febin Paul on 22/04/21.
//  Copyright © 2021 Arun. All rights reserved.
//

import Foundation

extension Session {
    
    func sendShareLinkToServer(_ finished: @escaping () -> ()) {
        let allPendingShareList = DatabasePlanItShareLink().readAllPendingShareLink()
        if allPendingShareList.isEmpty {
            self.sendDeleteShareLinkToServer(finished)
        }
        else {
            self.startShareLinkSending(allPendingShareList) {
                self.sendDeleteShareLinkToServer(finished)
            }
        }
    }
    
    private func startShareLinkSending(_ shareLinkLists: [PlanItShareLink], atIndex: Int = 0, finished: @escaping () -> ()) {
        if atIndex < shareLinkLists.count {
            self.sendShareLinkToServer(shopList: shareLinkLists[atIndex], at: atIndex, result: { index in
                self.startShareLinkSending(shareLinkLists, atIndex: index + 1, finished: finished)
            })
        }
        else {
            finished()
        }
    }
    
    private func sendShareLinkToServer(shopList: PlanItShareLink, at index: Int, result: @escaping (Int) -> ()) {
        CalendarService().addShareLink(shareLink: MiPlanitShareLink(shopList)) { (response, error) in
            result(index)
        }
    }
    
    func sendDeleteShareLinkToServer(_ finished: @escaping () -> ()) {
        let pendingDeletedShareList = DatabasePlanItShareLink().readAllPendingDeletedShareLink()
        if pendingDeletedShareList.isEmpty {
            finished()
        }
        else {
            self.startDeletedShareLinkListSending(pendingDeletedShareList) {
                finished()
            }
        }
    }
    
    private func startDeletedShareLinkListSending(_ shareLinkLists: [PlanItShareLink], atIdex: Int = 0, finished: @escaping () -> ()) {
        if atIdex < shareLinkLists.count {
            self.sendDeletedShareLinkListToServer(shareLink: shareLinkLists[atIdex], at: atIdex, result: { index in
                self.startDeletedShareLinkListSending(shareLinkLists, atIdex: index + 1, finished: finished)
            })
        }
        else {
            finished()
        }
    }
    
    private func sendDeletedShareLinkListToServer(shareLink: PlanItShareLink, at index: Int, result: @escaping (Int) -> ()) {
        if shareLink.readEventShareLinkId() != 0.0 {
            CalendarService().deleteEventShareLink(shareLink) { (shareLink, error) in
                result(index)
            }
        }
        else if !shareLink.readEventAppShareLinkId().isEmpty {
            shareLink.deleteOffline()
        }
        result(index)
    }
    
}
