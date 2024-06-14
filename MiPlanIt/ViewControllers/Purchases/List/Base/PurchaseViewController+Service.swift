//
//  PurchaseViewController+Service.swift
//  MiPlanIt
//
//  Created by Aneesh Asokan on 07/05/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

extension PurchaseViewController {
    
    func createServiceToFetchUsersData() {
        guard let user = self.requestUserPurchaseDataIfNeeded() else { return }
        PurchaseService().fetchUsersPurchaseServerData(user, callback: { result, serviceDetection, error in
            if result, serviceDetection.isContainedSpecificServiceData(.purchase) {
                self.readAllUserPurchasesUsingFilterCriteria()
            }
            if self.refreshControl.isRefreshing {
                self.refreshControl.endRefreshing()
            }
        })
    }
}
