//
//  AddNewCategoryViewController+Action.swift
//  MiPlanIt
//
//  Created by Febin Paul on 16/11/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

extension AddNewCategoryViewController {
    
    func initilizeCategory() {
        guard let category = self.updateShopCategory else { return }
        self.textfieldCategoryName.text = category.readCategoryName()
        self.buttonAdd.setTitle(self.updateShopCategory == nil ? "Add" : "Update", for: .normal)
    }
    
    func validateCategory() -> Bool {
        guard let categoryName = self.textfieldCategoryName.text, !categoryName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return false }
        let allCategory = DatabasePlanItShopMasterCategory().readAllShopCategory()
        var categorysNames = allCategory.compactMap({ $0.readCategoryName().lowercased() })
        categorysNames.append(contentsOf: allCategory.flatMap({ $0.readAllShopSubCategory() }).compactMap({ $0.readCategoryName().lowercased() }))
        return !categorysNames.map({ $0.trimmingCharacters(in: .whitespacesAndNewlines) }).contains(categoryName.lowercased().trimmingCharacters(in: .whitespacesAndNewlines))
    }
}
