//
//  PurchaseDetailViewController+Service.swift
//  MiPlanIt
//
//  Created by Aneesh Asokan on 08/05/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation
extension PurchaseDetailViewController {

    func callWebServiceForDeletePurchase() {
        let cachedImage   = self.buttonDelete.image(for: .normal)
        self.buttonDelete.clearButtonTitleForAnimation()
        self.buttonDelete.startAnimation()
        PurchaseService().deletePurchase(self.planitPurchase, callback: { (response, error) in
            if response == true {
                self.buttonDelete.stopAnimation(animationStyle: .normal, revertAfterDelay: 0) {
                //MARK: - Tick Animation
                self.buttonDelete.showTickAnimation { (result) in
                    self.isModified = false
                    self.navigationController?.popViewController(animated: true)
                    self.delegate?.purchaseDetailViewController(self, deletedPurchase: self.planitPurchase)
                    }
                }
            }
            else {
                self.buttonDelete.stopAnimation(animationStyle: .shake, revertAfterDelay: 0) {
                    let message = error ?? Message.unknownError
                    self.buttonDelete.setImage(cachedImage, for: .normal)
                    self.performSegue(withIdentifier: Segues.toMessageScreen, sender: [Message.error, message])
                    
                }
            }
        })
    }
}
