//
//  ListEventShareLinkViewController+Offline.swift
//  MiPlanIt
//
//  Created by Febin Paul on 29/03/21.
//  Copyright © 2021 Arun. All rights reserved.
//

import Foundation


extension ListEventShareLinkViewController {
    
    func deleteShareLinkToServerUsingNetwotk(_ shareLink: PlanItShareLink, cell: EventShareLinkTableViewCell?) {
        guard !self.apiCallInProgress else { return }
        if SocialManager.default.isNetworkReachable() && !shareLink.isPending {
            self.createServiceToDeleteUsersShareList(shareLink: shareLink, cell: cell)
        }
        else {
            shareLink.deleteOffline()
            self.removeSharedLinkList(shareLink)
        }
    }
}
