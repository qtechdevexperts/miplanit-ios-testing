//
//  MainCategoryToDoViewController+Base.swift
//  MiPlanIt
//
//  Created by Arun on 17/07/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

extension MainCategoryToDoViewController {
    
    override func initializeUI() {
        super.initializeUI()
        self.textViewNewCategory?.isHidden = true
        self.addToDoAccessoryView?.delegate = self
        self.buttonHeaderEdit?.isHidden = true
        self.buttonHeaderInvitees.isHidden = true
        self.buttonHeaderMoreAction?.isHidden = true
        self.labelHeaderTitle.text = self.showCetegoryTitle()
        self.constraintHeaderTitleXAxis?.isActive = true
    }
    
    override func configureToDoCell(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.toDoTaskListViewCell, for: indexPath) as! ToDoItemListCell
        cell.configMainCategoryCell(index: indexPath, todoItem: self.toDoItemCellModels[indexPath.section], editMode: self.toDoMode, type: self.categoryType, delegate: self)
        return cell
    }
    
    override func deleteItemClicked(on index: IndexPath) {
        guard let todo = self.toDoItemCellModels[index.section].planItToDo, let category = todo.readTodoCategory() else { return }
        let message = todo.isRecurrenceTodo() ? Message.occurrenceDelete : Message.deleteTodoItemMessage
        self.showAlertWithAction(message: message, title: Message.deleteTodoItem, items: [Message.yes, Message.cancel], callback: { buttonindex in
            if buttonindex == 0 {
                self.saveToDoDeleteToServerUsingNetwotk([todo], from: category)
            }
        })
    }
    
    override func restoreItemClicked(on index: IndexPath) {
        self.showAlertWithAction(message: Message.restoreTodoItemMessage, title: Message.restoreTodoItem, items: [Message.yes, Message.cancel], callback: { buttonindex in
            if buttonindex == 0 {
                guard let category = self.toDoItemCellModels[index.section].planItToDo.readTodoCategory() else { return }
                self.saveToDoRestoreToServerUsingNetwotk([self.toDoItemCellModels[index.section].planItToDo], from: category)
            }
        })
    }
    
    override func editItemClicked(on index: IndexPath) {
        let cell = self.tableViewToDoItems.cellForRow(at: index) as! ToDoItemListCell
        cell.editThisCell()
    }
    
    override func toggleAllCellSelection(by flag: Bool) {
        self.toDoItemCellModels.forEach { (toDoItemCellModel) in
            toDoItemCellModel.editSelected = flag
        }
        self.tableViewToDoItems.reloadData()
    }
    
    override func fireCompleteSyncTimer() {
        self.timerSyncCompleted = nil
        self.viewCompletedPopUp.isHidden = true
        self.completedQueue.removeAll()
        self.refreshCategoriesAfterUserCompletedTodo()
    }
    
    override func refreshCategoriesAfterUserCompleteTodos(_ todos: [PlanItTodo]) {
        self.replaceTodoItemsWithChildTodos(todos)
        super.refreshCategoriesAfterUserCompleteTodos(todos)
    }
    
    func replaceTodoItemsWithChildTodos(_ todos: [PlanItTodo]) {
        if self.categoryType != .completed {
            let childTodos = self.readCompletedChildTodos(todos)
            self.addCompletedChildsToDoToMainList(childTodos)
        }
        if self.categoryType == .overdue {
            self.removeParentToDoFromOverdue()
        }
        if self.categoryType == .today {
            self.refreshCategoriesAfterUserSetToday()
        }
    }
    
    func removeParentToDoFromOverdue() {
        self.allToDoItemCellModels.removeAll { (cellModel) -> Bool in
            if let startDate = cellModel.planItToDo.readStartDate(using: .overdue) {
                return cellModel.planItToDo.parent == nil && startDate >= Date().initialHour()
            }
            return true
        }
    }
    
    override func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.textFieldSearch && self.textFieldSearch.text == Strings.empty {
            self.setBackToDefaultMode()
        }
        textField.resignFirstResponder()
        return true
    }
    
    override func setVisibilityTopStackView() {
        if self.toDoMode == .edit { return }
        super.setVisibilityTopStackView()
    }
    
    override func triggerTodoUpdateFromNotification(_ notification: Notification) {
        guard let todo = notification.object as? PlanItTodo, self.allToDoItemCellModels.contains(where: { return $0.planItToDo == todo }) else { return }
        self.isCategoryDataUpdated = true
        if todo.readDeleteStatus() {
            self.refreshCategoriesAfterUserDeleteTodos([todo])
        }
        else if self.categoryType == .unplanned {
            self.refreshUnplannedCategoriesAfterUserSetDueDate()
        }
        else if self.categoryType == .overdue {
            self.refreshCategoriesAfterUserSetDueDate()
        }
        else if self.categoryType == .upcomming {
            self.refreshCategoriesAfterUserSetUpcomming()
        }
        else if self.categoryType == .today {
            self.refreshCategoriesAfterUserSetToday()
        }
        else if self.categoryType == .completed {
            self.refreshCategoriesAfterUserUnCompleteTodo()
        }
        self.refreshCategoriesAfterUserFavouriteTodos()
    }
}
