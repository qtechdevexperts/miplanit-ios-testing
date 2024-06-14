//
//  GiftCouponsViewController+Service.swift
//  MiPlanIt
//
//  Created by Arun on 09/05/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

extension GiftCouponsViewController {
    
    func createServiceToFetchUsersData() {
        guard let user = self.requestUserGiftDataIfNeeded() else { return }
        GiftCouponService().fetchUsersGiftServerData(user, callback: { result, serviceDetection, error in
            if result, serviceDetection.isContainedSpecificServiceData(.gift) {
               self.readAllUserGiftCouponsUsingFilterCriteria()
            }
            if self.refreshControl.isRefreshing {
                self.refreshControl.endRefreshing()
            }
        })
    }
}
