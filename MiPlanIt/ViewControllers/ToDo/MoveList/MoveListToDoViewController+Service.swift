//
//  MoveListToDoViewController+Service.swift
//  MiPlanIt
//
//  Created by Aneesh Asokan on 29/07/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

extension MoveListToDoViewController {
    
    func createWebServiceForTodoCategory(_ category: String) {
        self.buttonMove.startAnimation()
        TodoService().addEditTodoCategory(nil, name: category, callback: { response, error  in
            if let result = response {
                let newCategory = DropDownItem(name: result.categoryName!, identifier: result.categoryName!, value: result.categoryId.cleanValue())
                self.buttonMove.stopAnimation(animationStyle: .normal, revertAfterDelay: 0) {
                    self.delegate?.moveListToDoViewController(self, selectedOption: newCategory, moveToDos: self.moveToDos)
                }
                self.dismissDropDownButtonTouched(self.buttonMove)
            }
            else {
                self.buttonMove.stopAnimation(animationStyle: .shake, revertAfterDelay: 0) {
                    self.showTryAgainAlertForCategory()
                }
            }
        })
    }
}
