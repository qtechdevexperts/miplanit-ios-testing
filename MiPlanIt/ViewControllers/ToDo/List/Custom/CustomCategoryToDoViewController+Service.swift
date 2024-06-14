//
//  CustomCategoryToDoViewController+Service.swift
//  MiPlanIt
//
//  Created by Arun on 11/07/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

extension CustomCategoryToDoViewController {
    
    func createWebServiceForTodoCategory(_ category: String) {
        self.buttonLoader.isHidden = false
        self.buttonLoader.startAnimation()
        TodoService().addEditTodoCategory(self.toDoPlanItCategory, name: category, callback: { response, error  in
            if let result = response {
                self.buttonLoader.stopAnimation(animationStyle: .normal, revertAfterDelay: 0) {
                    self.isCategoryDataUpdated = true
                    self.buttonLoader.isHidden = true
                    self.toDoPlanItCategory = result
                    self.updateViewAfterAddCategory()
                }
            }
            else {
                self.buttonLoader.stopAnimation(animationStyle: .shake, revertAfterDelay: 0) {
                    self.buttonLoader.isHidden = true
                    self.showTryAgainAlertForCategory()
                }
            }
        })
    }
    
    func createWebServiceForShareTodoCategory(_ category: PlanItTodoCategory?, users: [OtherUser]) {
        self.buttonLoader.isHidden = false
        self.buttonLoader.startAnimation()
        TodoService().shareTodoCategory(category, invitees: users, callback: { response, error  in
            if let category = response {
                self.showShareLabelCount()
                self.buttonLoader.stopAnimation(animationStyle: .normal, revertAfterDelay: 0) {
                    self.isCategoryDataUpdated = true
                    self.buttonLoader.isHidden = true
                    self.buttonHeaderInvitees.isHidden = category.readAllToDoSharedInvitees().count == 0
                }
            }
            else {
                self.buttonLoader.stopAnimation(animationStyle: .shake, revertAfterDelay: 0) {
                    self.buttonLoader.isHidden = true
                    let message = error ?? Message.unknownError
                    self.performSegue(withIdentifier: Segues.toMessageScreen, sender: [Message.error, message])
                }
            }
        })
    }
    
    func createWebServiceForDeleteTodoCategory(_ category: PlanItTodoCategory) {
        self.buttonLoader.isHidden = false
        self.buttonLoader.startAnimation()
        TodoService().deleteTodoCategory(category, callback: { response, removeStatus, error in
            if let _ = response {
                self.buttonLoader.stopAnimation(animationStyle: .normal, revertAfterDelay: 0) {
                    self.isCategoryDataUpdated = true
                    self.buttonLoader.isHidden = true
                    self.navigationController?.popViewController(animated: true)
                }
            }
            else if let removedStatus = removeStatus, removedStatus {
                self.buttonLoader.stopAnimation(animationStyle: .normal, revertAfterDelay: 0) {
                    self.isCategoryDataUpdated = true
                    self.buttonLoader.isHidden = true
                    self.navigationController?.popViewController(animated: true)
                }
            }
            else {
                self.buttonLoader.stopAnimation(animationStyle: .shake, revertAfterDelay: 0) {
                    self.buttonLoader.isHidden = true
                    let message = error ?? Message.unknownError
                    self.performSegue(withIdentifier: Segues.toMessageScreen, sender: [Message.error, message])
                }
            }
        })
    }
    
    func createWebServiceToReOrderTodos(_ todos: [PlanItTodo], from category: PlanItTodoCategory) {
        TodoService().reorderTodos(todos, category: category, callback: { _, _ in })
    }
}
