//
//  ToDoListBaseViewController+Offline.swift
//  MiPlanIt
//
//  Created by Arun on 18/09/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

extension ToDoListBaseViewController {

    func saveNewToDoToServerUsingNetwotk(_ todos: [PlanItTodo], category: PlanItTodoCategory) {
        if SocialManager.default.isNetworkReachable(), !category.isPending {
            self.createWebServiceToAddTodoItems(todos, to: category)
        }
        else {
            self.isCategoryDataUpdated = true
            self.tableViewToDoItems.reloadData()
            self.setVisibilityTopStackView()
        }
    }
    
    func saveToDoNameToServerUsingNetwotk(_ todo: PlanItTodo, name: String, category: PlanItTodoCategory) {
        if SocialManager.default.isNetworkReachable(), !category.isPending {
            self.createWebServiceToEditTodo(todo, name: name, to: category)
        }
        else {
            todo.saveTodoName(name)
            self.updateTitleCacelToDone()
            self.isCategoryDataUpdated = true
            self.tableViewToDoItems.reloadData()
        }
    }
    
    func saveMoveToDoToServerUsingNetwotk(_ todos: [PlanItTodo], from: PlanItTodoCategory, to: String) {
        guard let moveToCategory = DataBasePlanItTodoCategory().readSpecificToDoCategory(to) else { return }
        if SocialManager.default.isNetworkReachable(), !from.isPending, !moveToCategory.isPending, !todos.contains(where: { $0.isPending })  {
            self.createWebServiceToMoveTodos(todos, from: from, to: to)
        }
        else { //You should reset appToDoCategoryId after finishing service[Now its older category id]
            from.removeTodosFromList(todos)
            moveToCategory.addTodosToList(todos, from: from)
            self.updateTitleCacelToDone()
            self.isCategoryDataUpdated = true
            self.refreshCategoriesAfterUserMoveTodos()
        }
    }
    
    func saveToDoDeleteToServerUsingNetwotk(_ todos: [PlanItTodo], from category: PlanItTodoCategory) {
        if SocialManager.default.isNetworkReachable(), !category.isPending {
            self.createWebServiceToDeleteTodos(todos, from: category)
        }
        else {
            todos.forEach({ $0.saveDeleteStatus(true)})
            self.updateTitleCacelToDone()
            self.isCategoryDataUpdated = true
            self.refreshCategoriesAfterUserDeleteTodos(todos)
            Session.shared.registerUserTodoLocationNotification()
        }
    }
    
    func saveToDoRestoreToServerUsingNetwotk(_ todos: [PlanItTodo], from category: PlanItTodoCategory) {
        if SocialManager.default.isNetworkReachable(), !category.isPending {
            self.createWebServiceToRestoreTodos(todos, from: category)
        }
        else {
            todos.forEach({ $0.saveDeleteStatus(false)})
            self.updateTitleCacelToDone()
            self.isCategoryDataUpdated = true
            self.refreshCategoriesAfterUserRestoreTodos(todos)
            Session.shared.registerUserTodoLocationNotification()
        }
    }
    
    func saveToDoCompleteToServerUsingNetwotk(_ todos: [PlanItTodo], from category: PlanItTodoCategory, with status: Bool) {
        if SocialManager.default.isNetworkReachable(), !category.isPending {
            self.createWebServiceToCompleteTodos(todos, from: category, with: status)
        }
        else {
            todos.forEach({ $0.saveCompleteStatus(status, with: self.categoryType) })
            self.isCategoryDataUpdated = true
            status ? self.updateUndoSection(on: self.readCompletedChildTodos(todos)) : self.updateCompletedTable()
            self.refreshCategoriesAfterUserCompleteTodos(todos)
        }
    }
    
    func saveToDoFavoriteToServerUsingNetwotk(_ todos: [PlanItTodo], from category: PlanItTodoCategory, with status: Bool) {
        if SocialManager.default.isNetworkReachable(), !category.isPending {
            self.createWebServiceToFavouriteTodos(todos, from: category, with: status)
        }
        else {
            todos.forEach({ $0.saveFavoriteStatus(status) })
            self.isCategoryDataUpdated = true
            self.refreshCategoriesAfterUserFavouriteTodos()
        }
    }
    
    func saveTodoDueDateToServerUsingNetwotk(_ todos: [PlanItTodo], from category: PlanItTodoCategory, date: String) {
        if SocialManager.default.isNetworkReachable(), !category.isPending {
            self.createWebServiceToSetDueDateForTodos(todos, from: category, date: date)
        }
        else {
            todos.forEach({ $0.saveDueDate(date) })
            self.updateTitleCacelToDone()
            self.isCategoryDataUpdated = true
            self.refreshCategoriesAfterOverdueTodos()
        }
    }
    
    func saveTodoAssignUserToServerUsingNetwotk(_ user: CalendarUser, to todos: [PlanItTodo], category: PlanItTodoCategory) {
        if SocialManager.default.isNetworkReachable(), !category.isPending {
            self.createWebServiceToAssignUser(user, to: todos, category: category)
        }
        else {
            todos.forEach({ return $0.saveAssignedUser(user) })
            self.updateTitleCacelToDone()
            self.isCategoryDataUpdated = true
            self.tableViewToDoItems.reloadData()
        }
    }
}
