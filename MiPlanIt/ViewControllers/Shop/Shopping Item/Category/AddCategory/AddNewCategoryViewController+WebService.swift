//
//  AddNewCategoryViewController+WebService.swift
//  MiPlanIt
//
//  Created by Febin Paul on 08/11/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation


extension AddNewCategoryViewController {
    
    func addNewCategory() {
        guard let categoryName = self.textfieldCategoryName.text?.trimmingCharacters(in: .whitespacesAndNewlines) else { return }
        ShopService().addShopCategory(categoryName, appCategoryId: UUID().uuidString) { (response, error) in
            if let result = response {
                self.dismiss(animated: false) {
                    self.delegate?.addNewCategoryViewController(self, add: result)
                }
            }
        }
    }
    
    func editcategory() {
        guard let categoryName = self.textfieldCategoryName.text?.trimmingCharacters(in: .whitespacesAndNewlines), let shopCategory = self.updateShopCategory else { return }
        ShopService().updateShopCategory(shopCategory, categoryName: categoryName, appCategoryId: UUID().uuidString) { (response, error) in
            if let result = response {
                self.dismiss(animated: false) {
                    self.delegate?.addNewCategoryViewController(self, update: result)
                }
            }
        }
    }
}
