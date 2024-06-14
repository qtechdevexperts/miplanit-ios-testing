//
//  PurchaseDetailViewController+CallBack.swift
//  MiPlanIt
//
//  Created by Aneesh Asokan on 09/05/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation
extension PurchaseDetailViewController: AddPurchaseViewControllerDelegate {
    
    func addPurchaseViewController(_ viewController: AddPurchaseViewController, updatedPurchase purchase: PlanItPurchase) {
        self.isModified = true
        self.planitPurchase = purchase
        self.initialiseUIComponents()
    }
}
