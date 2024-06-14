//
//  TodoBaseViewController+Service.swift
//  MiPlanIt
//
//  Created by Arun on 11/07/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

extension TodoBaseViewController {
    
    func createServiceToFetchUsersData() {
        guard let user = self.requestUserTodoDataIfNeeded() else { return }
        TodoService().fetchUsersToDoServerData(user, callback: { result, serviceDetection, error in
            if self.refreshControl.isRefreshing {
                self.refreshControl.endRefreshing()
            }
            if result, serviceDetection.isContainedSpecificServiceData(.todo) {
                self.showAllTodoCategoriesValues()
            }
            self.checkAnyNotificationListId()
        })
    }
    
    func createWebServiceForShareTodoCategory(_ category: PlanItTodoCategory, users: [OtherUser], at indexPath: IndexPath) {
        self.viewCustomToDoListContainer.startLoadingIndicator(at: indexPath)
        TodoService().shareTodoCategory(category, invitees: users, callback: { response, error  in
            self.viewCustomToDoListContainer.stopLoadingIndicator(at: indexPath)
            if let _ = response {
                self.viewCustomToDoListContainer.refreshCategories()
            }
            else {
                let message = error ?? Message.unknownError
                self.performSegue(withIdentifier: Segues.toMessageScreen, sender: [Message.error, message])
            }
        })
    }
    
    func createWebServiceForDeleteTodoCategory(_ category: PlanItTodoCategory, at indexPath: IndexPath) {
        self.viewCustomToDoListContainer.startLoadingIndicator(at: indexPath)
        TodoService().deleteTodoCategory(category, callback: { response, removeStatus, error in
            self.viewCustomToDoListContainer.stopLoadingIndicator(at: indexPath)
            if let _ = response {
                self.showAllTodoCategoriesValues()
            }
            else if let removedStatus = removeStatus, removedStatus {
                self.showAllTodoCategoriesValues()
            }
            else {
                let message = error ?? Message.unknownError
                self.performSegue(withIdentifier: Segues.toMessageScreen, sender: [Message.error, message])
            }
        })
    }
    
    func createWebServiceForTodoMarkASRead(_ todos: [PlanItTodo]) {
        TodoService().todoMarkAsRead(todos, callback: { [weak self] response, error in
            if let result = response, let base = self, result {
                if let viewIndex = base.viewMenus.firstIndex(where: { $0.mainCategory == .assignedToMe }) {
                    base.viewMenus[viewIndex].updateUnReadCountOfAssignedToMe()
                }
            }
        })
    }
}

