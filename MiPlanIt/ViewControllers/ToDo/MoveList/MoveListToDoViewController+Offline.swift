//
//  MoveListToDoViewController+Offline.swift
//  MiPlanIt
//
//  Created by Arun on 17/09/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

extension MoveListToDoViewController {
    
    func saveCategoryToServerUsingNetwotk(_ category: String) {
        if SocialManager.default.isNetworkReachable() {
            self.createWebServiceForTodoCategory(category)
        }
        else {
            let newCategory = DataBasePlanItTodoCategory().insertNewOfflinePlanItToDoCategory(name: category)
            let categoryModel = DropDownItem(name: newCategory.readCategoryName(), identifier: newCategory.readCategoryName(), value: newCategory.readIdentifier())
            self.delegate?.moveListToDoViewController(self, selectedOption: categoryModel, moveToDos: self.moveToDos)
            self.dismissDropDownButtonTouched(self.buttonMove)
        }
    }
}
