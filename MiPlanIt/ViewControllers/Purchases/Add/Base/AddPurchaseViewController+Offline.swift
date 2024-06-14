//
//  AddPurchaseViewController+Offline.swift
//  MiPlanIt
//
//  Created by Febin Paul on 02/12/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

extension AddPurchaseViewController {
    
    func savePurchaseToServerUsingNetwotk() {
        self.buttonSavePurchase.startAnimation()
        if SocialManager.default.isNetworkReachable(), !self.purchaseModel.isPending {
            self.startPendingUploadOfAttachment()
        }
        else {
            self.buttonSavePurchase.stopAnimation()
            let planItPurchase = DatabasePlanItPurchase().insertOfflineGiftPurchase(self.purchaseModel)
            self.navigationController?.popViewController(animated: true)
            if self.purchaseModel.purchaseId.isEmpty {
                self.delegate?.addPurchaseViewController!(self, createdNewPurchase: planItPurchase)
            }
            else {
                self.delegate?.addPurchaseViewController!(self, updatedPurchase: planItPurchase)
            }
        }
    }
}
