//
//  PurchaseViewController+Callback.swift
//  MiPlanIt
//
//  Created by Arun on 08/05/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

extension PurchaseViewController: AddPurchaseViewControllerDelegate, PurchaseDetailViewControllerDelegate {
    
    func addPurchaseViewController(_ viewController: AddPurchaseViewController, createdNewPurchase purchase: PlanItPurchase) {
        self.readAllUserPurchasesUsingFilterCriteria()
    }
    
    func purchaseDetailViewController(_ viewController: PurchaseDetailViewController, deletedPurchase purchase: PlanItPurchase) {
        self.allPurchases.removeAll(where: { return $0 == purchase })
    }
    
    func purchaseDetailViewController(_ viewController: PurchaseDetailViewController, updatedPurchase purchase: PlanItPurchase) {
        if filterCriteria.isEmpty {
            self.showPurchaseBasedOnSearchCriteria()
        }
        else {
            self.showPurchaseBasedOnFilterCriteria()
        }
    }
}

extension PurchaseViewController: PurchaseFilterViewControllerDelegate {
    
    func purchaseFilterViewController(_ viewController: PurchaseFilterViewController, filters: [Filter]) {
        self.filterCriteria = filters
        self.buttonFilter.isSelected = !filters.isEmpty
    }
}

