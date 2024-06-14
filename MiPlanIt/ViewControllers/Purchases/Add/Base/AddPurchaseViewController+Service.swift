//
//  AddPurchaseViewController+Service.swift
//  MiPlanIt
//
//  Created by Aneesh Asokan on 07/05/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

extension AddPurchaseViewController {
    
    func createWebServiceToUploadAttachment(_ attachement: UserAttachment) {
        UserService().uploadAttachement(attachement, callback: { response, error in
            if let _ = response {
                self.startPendingUploadOfAttachment()
            }
            else {
                let message = error ?? Message.unknownError
                self.buttonSavePurchase.stopAnimation()
                self.performSegue(withIdentifier: Segues.toMessageScreen, sender: [Message.error, message])
            }
        })
    }
    
    func createServiceToAddPurchase() {
        PurchaseService().addPurchase(self.purchaseModel, callback: { response, error in
            if let result = response {
                //MARK: - Tick Animation
                self.buttonSavePurchase.clearButtonTitleForAnimation()
                self.buttonSavePurchase.stopAnimation(animationStyle: .normal, revertAfterDelay: 0) {
                    self.buttonSavePurchase.showTickAnimation { (results) in
                        self.navigationController?.popViewController(animated: true)
                        if self.purchaseModel.purchaseId.isEmpty {
                            self.delegate?.addPurchaseViewController!(self, createdNewPurchase: result)
                        }
                        else {
                            self.delegate?.addPurchaseViewController!(self, updatedPurchase: result)
                        }
                    }
                }
            }
            else {
                self.buttonSavePurchase.stopAnimation(animationStyle: .shake, revertAfterDelay: 0) {
                    let message = error ?? Message.unknownError
                    self.performSegue(withIdentifier: Segues.toMessageScreen, sender: [Message.error, message])
                }
            }
        })
    }
}
