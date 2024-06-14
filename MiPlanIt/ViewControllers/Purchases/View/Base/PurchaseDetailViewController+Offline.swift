//
//  PurchaseDetailViewController+Offline.swift
//  MiPlanIt
//
//  Created by Febin Paul on 02/12/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation


extension PurchaseDetailViewController {
    
    func deletePurchaseToServerUsingNetwotk() {
        if SocialManager.default.isNetworkReachable() && !self.planitPurchase.isPending {
            self.callWebServiceForDeletePurchase()
        }
        else {
            self.planitPurchase.deleteOffline()
            self.navigationController?.popViewController(animated: true)
            self.delegate?.purchaseDetailViewController(self, deletedPurchase: self.planitPurchase)
        }
    }
}
