//
//  ToDoListBaseViewController+Service.swift
//  MiPlanIt
//
//  Created by Arun on 14/07/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

extension ToDoListBaseViewController {
    
    func createWebServiceToAddTodoItems(_ todos: [PlanItTodo], to category: PlanItTodoCategory) {
        self.startLoadingIndicatorForTodos(todos)
        TodoService().addEditTodos(todos, category: category, callback: { response, error in
            self.stopLoadingIndicatorForTodos(todos)
            if let result = response, result {
                self.isCategoryDataUpdated = true
                self.tableViewToDoItems.reloadData()
                self.setVisibilityTopStackView()
            }
        })
    }
    
    func createWebServiceToEditTodo(_ todo: PlanItTodo, name: String, to category: PlanItTodoCategory) {
        self.startLoadingIndicatorForTodos([todo])
        TodoService().editTodo(todo, name: name, category: category, callback: { response, error in
            self.stopLoadingIndicatorForTodos([todo])
            if let result = response, result {
                self.updateTitleCacelToDone()
                self.isCategoryDataUpdated = true
                self.tableViewToDoItems.reloadData()
            }
            else {
                let message = error ?? Message.unknownError
                self.performSegue(withIdentifier: Segues.toMessageScreen, sender: [Message.error, message])
            }
        })
    }
    
    func createWebServiceToMoveTodos(_ todos: [PlanItTodo], from: PlanItTodoCategory, to: String) {
        self.startLoadingIndicatorForTodos(todos)
        TodoService().moveTodos(todos, from: from, to: to, callback: { response, error in
            self.stopLoadingIndicatorForTodos(todos)
            if let result = response, result {
                self.updateTitleCacelToDone()
                self.isCategoryDataUpdated = true
                self.refreshCategoriesAfterUserMoveTodos()
            }
            else {
                let message = error ?? Message.unknownError
                self.performSegue(withIdentifier: Segues.toMessageScreen, sender: [Message.error, message])
            }
        })
    }
    
    func createWebServiceToDeleteTodos(_ todos: [PlanItTodo], from: PlanItTodoCategory) {
        self.startLoadingIndicatorForTodos(todos)
        TodoService().deleteTodos(todos, from: from, callback: { response, error in
            self.stopLoadingIndicatorForTodos(todos)
            if let result = response, result {
                self.updateTitleCacelToDone()
                self.isCategoryDataUpdated = true
                self.refreshCategoriesAfterUserDeleteTodos(todos)
            }
            else {
                let message = error ?? Message.unknownError
                self.performSegue(withIdentifier: Segues.toMessageScreen, sender: [Message.error, message])
            }
        })
    }
    
    func createWebServiceToRestoreTodos(_ todos: [PlanItTodo], from: PlanItTodoCategory) {
        self.startLoadingIndicatorForTodos(todos)
        TodoService().restoreTodos(todos, from: from, callback: { response, error in
            self.stopLoadingIndicatorForTodos(todos)
            if let result = response, result {
                self.updateTitleCacelToDone()
                self.isCategoryDataUpdated = true
                self.refreshCategoriesAfterUserRestoreTodos(todos)
            }
            else {
                let message = error ?? Message.unknownError
                self.performSegue(withIdentifier: Segues.toMessageScreen, sender: [Message.error, message])
            }
        })
    }
    
    func createWebServiceToCompleteTodos(_ todos: [PlanItTodo], from: PlanItTodoCategory, with status: Bool) {
        self.startLoadingIndicatorForTodos(todos)
        TodoService().completeTodos(todos, from: from, type: self.categoryType, with: status, callback: { response, error in
            self.stopLoadingIndicatorForTodos(todos)
            if let result = response, result {
                self.isCategoryDataUpdated = true
                status ? self.updateUndoSection(on: self.readCompletedChildTodos(todos)) : self.updateCompletedTable()
                self.refreshCategoriesAfterUserCompleteTodos(todos)
            }
            else {
                let message = error ?? Message.unknownError
                self.performSegue(withIdentifier: Segues.toMessageScreen, sender: [Message.error, message])
            }
        })
    }
    
    func createWebServiceToFavouriteTodos(_ todos: [PlanItTodo], from: PlanItTodoCategory, with status: Bool) {
        self.startLoadingIndicatorForTodos(todos)
        TodoService().favouriteTodos(todos, from: from, with: status, callback: { response, error in
            self.stopLoadingIndicatorForTodos(todos)
            if let result = response, result {
                self.isCategoryDataUpdated = true
                self.refreshCategoriesAfterUserFavouriteTodos()
            }
            else {
                let message = error ?? Message.unknownError
                self.performSegue(withIdentifier: Segues.toMessageScreen, sender: [Message.error, message])
            }
        })
    }
    
    func createWebServiceToSetDueDateForTodos(_ todos: [PlanItTodo], from: PlanItTodoCategory, date: String) {
        self.startLoadingIndicatorForTodos(todos)
        TodoService().dueDateTodos(todos, from: from, date: date, callback: { response, error in
            self.stopLoadingIndicatorForTodos(todos)
            if let result = response, result {
                self.updateTitleCacelToDone()
                self.isCategoryDataUpdated = true
                self.refreshCategoriesAfterOverdueTodos()
            }
            else {
                let message = error ?? Message.unknownError
                self.performSegue(withIdentifier: Segues.toMessageScreen, sender: [Message.error, message])
            }
        })
    }
    
    func createWebServiceToAssignUser(_ user: CalendarUser, to todos: [PlanItTodo], category: PlanItTodoCategory) {
        self.startLoadingIndicatorForTodos(todos)
        TodoService().assignUser(user, to: todos, category: category, callback: { response, error in
            self.stopLoadingIndicatorForTodos(todos)
            if let result = response, result {
                self.updateTitleCacelToDone()
                self.isCategoryDataUpdated = true
                self.tableViewToDoItems.reloadData()
            }
            else {
                let message = error ?? Message.unknownError
                self.performSegue(withIdentifier: Segues.toMessageScreen, sender: [Message.error, message])
            }
        })
    }
    func createServiceToFetchUsersDataInsidePullToRefresh(completion: @escaping ([ServiceDetection]) -> ()) {
        guard let user = Session.shared.readUser() else {
            completion([])
            return
        }
        TodoService().fetchUsersToDoServerData(user, callback: { result, serviceDetection, error in
            completion(serviceDetection)
        })
    }
}
