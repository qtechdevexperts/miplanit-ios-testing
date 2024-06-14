//
//  AddNewCategoryViewController+Offline.swift
//  MiPlanIt
//
//  Created by Febin Paul on 02/12/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

extension AddNewCategoryViewController {
    
    func saveCategoryToServerUsingNetwotk() {
        if SocialManager.default.isNetworkReachable() {
            self.addNewCategory()
        }
        else {
            guard let categoryName = self.textfieldCategoryName.text?.trimmingCharacters(in: .whitespacesAndNewlines) else { return }
            let planItShopMainCategory = DatabasePlanItShopMasterCategory().insertOfflineShopCategory(name: categoryName)
            self.dismiss(animated: false) {
                self.delegate?.addNewCategoryViewController(self, add: planItShopMainCategory)
            }
        }
    }
    
    func updateCategoryToServerUsingNetwotk() {
        guard let category = self.updateShopCategory else { return }
        if SocialManager.default.isNetworkReachable() {
            self.editcategory()
        }
        else {
            guard let categoryName = self.textfieldCategoryName.text?.trimmingCharacters(in: .whitespacesAndNewlines) else { return }
            DatabasePlanItShopMasterCategory().updateOfflineShopCategory(category: category, name: categoryName)
            self.dismiss(animated: false) {
                self.delegate?.addNewCategoryViewController(self, update: category)
            }
        }
    }
    
}
