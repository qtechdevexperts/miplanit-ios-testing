//
//  BaseTodoDetailViewController+Offline.swift
//  MiPlanIt
//
//  Created by Arun on 21/09/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

extension BaseTodoDetailViewController {
    
    func saveTodoCompleteToServerUsingNetwotk(with status: Bool) {
        if SocialManager.default.isNetworkReachable(), !self.mainToDoItem.isPendingCategory() {
            self.createWebServiceToCompleteTodo(with: status)
        }
        else {
            self.mainToDoItem.saveCompleteStatus(status, with: self.categoryType)
            self.buttonCheckMarkAsComplete?.isSelected = status
            self.isTodoUpdated = true
            let transition = CATransition()
            transition.duration = 0.25
            transition.type = CATransitionType.moveIn
            transition.subtype = CATransitionSubtype.fromBottom
            if status == false { self.buttonSave.isHidden = false; self.viewCompletedOverlay.isHidden = true;  return }
            Session.shared.registerUserTodoLocationNotification()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.navigateBack()
            }
        }
    }
    
    func saveToDoDeleteToServerUsingNetwotk(_ todo: PlanItTodo, from: PlanItTodoCategory) {
        if SocialManager.default.isNetworkReachable(), !todo.isPendingCategory() {
            self.createWebServiceToDeleteTodo(todo, from: from)
        }
        else {
            todo.saveDeleteStatus(true)
            self.isTodoUpdated = true
            Session.shared.registerUserTodoLocationNotification()
            self.navigateBack()
        }
    }
    
    func saveToDoFavoriteToServerUsingNetwotk(_ todo: PlanItTodo, from: PlanItTodoCategory, with status: Bool) {
        if SocialManager.default.isNetworkReachable(), !todo.isPendingCategory() {
            self.createWebServiceToFavouriteTodo(todo, from: from, with: status)
        }
        else {
            todo.saveFavoriteStatus(status)
            self.isTodoUpdated = true
            self.buttonFavourite.isSelected = status
        }
    }
    
    func saveToDoAttachmentsToServerUsingNetwotk(_ attachement: UserAttachment, from save: Bool) {
        if SocialManager.default.isNetworkReachable(), !self.mainToDoItem.isPendingCategory() {
            self.createWebServiceToUploadAttachment(attachement, from: save)
        }
        else {
            self.mainToDoItem.saveTodoDetails(self.toDoDetailModel)
            self.isTodoUpdated = true
            self.buttonSave.stopAnimation()
            Session.shared.registerUserTodoLocationNotification()
            self.navigateBack()
        }
    }
    
    func saveTodoDetailsToServerUsingNetwotk(_ details: ToDoDetailModel) {
        if SocialManager.default.isNetworkReachable(), !self.mainToDoItem.isPendingCategory() {
            self.createWebServiceToEditTodoDetails(details)
        }
        else {
            self.mainToDoItem.saveTodoDetails(self.toDoDetailModel)
            self.isTodoUpdated = true
            self.buttonSave.stopAnimation()
            Session.shared.registerUserTodoLocationNotification()
            self.navigateBack()
        }
    }
}
