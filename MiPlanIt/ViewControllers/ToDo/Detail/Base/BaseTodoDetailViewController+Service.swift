//
//  TodoDetailViewController+Service.swift
//  MiPlanIt
//
//  Created by Arun on 15/07/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

extension BaseTodoDetailViewController {
    
    func createWebServiceToCompleteTodo(with status: Bool) {
        guard let category = self.mainToDoItem.readTodoCategory() else { return }
        self.buttonCheckMarkAsComplete?.startAnimation()
        TodoService().completeTodo(self.mainToDoItem, information: self.toDoDetailModel, category: category, type: self.categoryType, with: status, callback: { response, error in
            if let result = response, result {
                self.buttonCheckMarkAsComplete?.stopAnimation(animationStyle: .normal, revertAfterDelay: 0) {
                    self.buttonCheckMarkAsComplete?.isSelected = status
                    self.isCompleted = status
                    self.isTodoUpdated = true
                    let transition = CATransition()
                    transition.duration = 0.25
                    transition.type = CATransitionType.moveIn
                    transition.subtype = CATransitionSubtype.fromBottom
                    if status == false { self.buttonSave.isHidden = false; self.viewCompletedOverlay.isHidden = true;  return }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.navigateBack()
                    }
                }
            }
            else {
                let message = error ?? Message.unknownError
                self.buttonCheckMarkAsComplete?.stopAnimation(animationStyle: .shake, revertAfterDelay: 0) {
                    self.performSegue(withIdentifier: Segues.toMessageScreen, sender: [Message.error, message])
                }
            }
        })
    }
    
    func createWebServiceToDeleteTodo(_ todo: PlanItTodo, from: PlanItTodoCategory) {
        self.cachedImageNormal   = self.buttonDelete.image(for: .normal)
        self.buttonDelete.clearButtonTitleForAnimation()
        self.buttonDelete.startAnimation()
        TodoService().deleteTodos([todo], from: from, callback: { response, error in
            if let result = response, result {
                self.buttonDelete.stopAnimation(animationStyle: .normal, revertAfterDelay: 0) {
                    self.buttonDelete.showTickAnimation(borderOnly: self.isNeedBorder, completion: { (result) in
                        self.isTodoUpdated = true
                        self.navigateBack()
                    })
                }
            }
            else {
                let message = error ?? Message.unknownError
                self.buttonDelete.stopAnimation(animationStyle: .shake, revertAfterDelay: 0) {
                    self.resetButton(self.buttonDelete)
                    self.performSegue(withIdentifier: Segues.toMessageScreen, sender: [Message.error, message])
                }
            }
        })
    }
    
    func createWebServiceToFavouriteTodo(_ todo: PlanItTodo, from: PlanItTodoCategory, with status: Bool) {
        self.cachedImageNormal   = self.buttonFavourite.image(for: .normal)
        self.cachedImageSel   = self.buttonFavourite.image(for: .selected)
        self.buttonFavourite.clearButtonTitleForAnimation()
        self.buttonFavourite.startAnimation()
        TodoService().favouriteTodos([todo], from: from, with: status, callback: { response, error in
            if let result = response, result {
                self.buttonFavourite.clearButtonTitleForAnimation()
                self.buttonFavourite.stopAnimation(animationStyle: .normal, revertAfterDelay: 0) {
                    self.isTodoUpdated = true
                    self.resetButton(self.buttonFavourite)
                    self.buttonFavourite.isSelected = status
                }
            }
            else {
                let message = error ?? Message.unknownError
                self.buttonFavourite.stopAnimation(animationStyle: .shake, revertAfterDelay: 0) {
                    self.resetButton(self.buttonFavourite)
                    self.performSegue(withIdentifier: Segues.toMessageScreen, sender: [Message.error, message])
                }
            }
        })
    }
    
    func createWebServiceToUploadAttachment(_ attachement: UserAttachment, from save: Bool) {
        if !save { self.buttonCheckMarkAsComplete?.startAnimation() }
        UserService().uploadAttachement(attachement, callback: { response, error in
            if let _ = response {
                self.startPendingUploadOfAttachment(from: save)
            }
            else {
                let message = error ?? Message.unknownError
                self.buttonSave.stopAnimation(animationStyle: .shake, revertAfterDelay: 0) {
                    self.resetButton(self.buttonSave)
                    self.performSegue(withIdentifier: Segues.toMessageScreen, sender: [Message.error, message])
                }
            }
        })
    }
    
    func createWebServiceToEditTodoDetails(_ details: ToDoDetailModel) {
        guard let category = self.mainToDoItem.readTodoCategory() else { return }
        TodoService().editTodo(self.mainToDoItem, information: details, category: category, callback: { response, error in
            if let _ = response {
                self.buttonSave.clearButtonTitleForAnimation()
                self.buttonSave.stopAnimation(animationStyle: .normal, revertAfterDelay: 0) {
                    self.buttonSave.showTickAnimation(borderOnly: self.isNeedBorder, completion: { (result) in
                        self.isTodoUpdated = true
                        self.navigateBack()
                    })
                }
            }
            else {
                let message = error ?? Message.unknownError
                self.buttonSave.stopAnimation(animationStyle: .shake, revertAfterDelay: 0) {
                    self.buttonSave.setTitle("Save", color: .white)
                    self.performSegue(withIdentifier: Segues.toMessageScreen, sender: [Message.error, message])
                }
            }
        })
    }
}
