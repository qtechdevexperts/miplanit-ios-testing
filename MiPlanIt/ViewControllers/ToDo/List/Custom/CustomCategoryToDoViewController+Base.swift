//
//  CustomCategoryToDoViewController+Base.swift
//  MiPlanIt
//
//  Created by Arun on 14/07/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

extension CustomCategoryToDoViewController {
    
    override func initializeUI() {
        super.initializeUI()
        self.addToDoAccessoryView?.delegate = self
        self.stackViewCompletedEditAction.delegate = self
        self.constraintHeaderTitleXAxis?.isActive = false
        self.showSharedCategoryDetails()
        self.updatedActionViews()
        self.setVisibilityTopStackView()
    }
    
    override func configureToDoCell(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.toDoTaskListViewCell, for: indexPath) as! ToDoItemListCell
        cell.configCustomCategoryCell(index: indexPath, todoItem: self.toDoItemCellModels[indexPath.section], editMode: self.toDoMode, delegate: self)
        return cell
    }
    
    override func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.textFieldSearch {
            if self.textFieldSearch.text == Strings.empty {
                self.setBackToDefaultMode()
            }
            textField.resignFirstResponder()
            return false
        }
        if var categoryName = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) {
            if let category = self.toDoPlanItCategory, category.categoryName == categoryName {
                textField.resignFirstResponder()
                return true
            }
            categoryName = categoryName == Strings.empty ? "Untitled List" : categoryName
            self.saveCategoryToServerUsingNetwotk(categoryName)
            return super.textFieldShouldReturn(textField)
        }
        else {
            debugPrint("Show valid error message")
        }
        return false
    }
    
    override func textViewDidEndEditing(_ textView: UITextView) {
        //TODO: Create ToDo Issue -- need to fix
        if var categoryName = textView.text, categoryName != ""{ //, !self.isBeingRemoved() {
            categoryName = categoryName.trimmingCharacters(in: .whitespacesAndNewlines)
            if let category = self.toDoPlanItCategory, category.categoryName == categoryName {
                textView.resignFirstResponder()
                return
            }
            categoryName = categoryName == Strings.empty ? "Untitled List" : categoryName
            self.saveCategoryToServerUsingNetwotk(categoryName)
            return super.textViewDidEndEditing(textView)
        }
        else {
            debugPrint("Show valid error message")
        }
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
    
    override func moveItemClicked(on index: IndexPath) {
        if self.toDoItemCellModels[index.section].planItToDo.parent == nil {
            self.performSegue(withIdentifier: Segues.segueToMoveList, sender: [self.toDoItemCellModels[index.section].planItToDo])
        }
        else {
            self.performSegue(withIdentifier: Segues.toMessageScreen, sender: [Message.warning, Message.singleChildMove])
        }
    }
    
    override func editItemClicked(on index: IndexPath) {
        let cell = self.tableViewToDoItems.cellForRow(at: index) as! ToDoItemListCell
        cell.editThisCell()
    }
    
    override func assignItemClicked(on index: IndexPath) {
        if self.toDoItemCellModels[index.section].planItToDo.isAssignedToMe && !self.toDoItemCellModels[index.section].planItToDo.isOwner {
            self.performSegue(withIdentifier: Segues.toMessageScreen, sender: [Message.error, Message.noPermissionToAssignTodo])
        }
        else {
            if self.toDoItemCellModels[index.section].planItToDo.parent == nil {
                self.performSegue(withIdentifier: Segues.toAssignScreen, sender: [self.toDoItemCellModels[index.section].planItToDo])                
            }
            else {
                self.performSegue(withIdentifier: Segues.toMessageScreen, sender: [Message.error, Message.singleChildAssign])
            }
        }
    }
    
    override func toggleAllCellSelection(by flag: Bool) {
        self.toDoItemCellModels.forEach { (toDoItemCellModel) in
            toDoItemCellModel.editSelected = flag
        }
        self.tableViewToDoItems.reloadData()
        self.updateSelectionLabelCount(self.toDoItemCellModels.filter({ $0.editSelected }).count)
    }
    
    override func refreshCategoriesAfterUserDeleteTodos(_ todos: [PlanItTodo]) {
        self.stackViewCompletedEditAction.removeDeletedItemsFromCompletedList()
        super.refreshCategoriesAfterUserDeleteTodos(todos)
    }
    
    @objc override func refreshCategoriesAfterUserMoveTodos() {
        let todoIds = self.toDoPlanItCategory?.readAllAvailableMainTodos().map({ return $0.readTodoId() }) ?? []
        self.allToDoItemCellModels.removeAll(where: { return !todoIds.contains($0.planItToDo.readTodoId()) })
        self.stackViewCompletedEditAction.setCompletedItems(items: self.allToDoItemCellModels.filter({ $0.planItToDo.completed }))
        self.tableViewToDoItems.reloadData()
        self.buttonSelectAll.isHidden = self.toDoItemCellModels.isEmpty || self.toDoMode != .edit
        self.setVisibilityTopStackView()
        self.setVisibilityBGImage()
        self.setVisibilityNoToDoImage()
        super.refreshCategoriesAfterUserMoveTodos()
    }
    
    @objc override func refreshCategoriesAfterUserFavouriteTodos() {
        super.refreshCategoriesAfterUserFavouriteTodos()
        self.stackViewCompletedEditAction.refreshCategoriesAfterUserFavouriteTodos()
    }
    
    override func fireCompleteSyncTimer() {
        self.timerSyncCompleted = nil
        self.viewCompletedPopUp.isHidden = true
        self.completedQueue.removeAll()
        self.updateCompletedTable()
    }
    
    override func handleOverlayTap(_ sender: UITapGestureRecognizer) {
        self.viewOverlay.isHidden = true
        self.addToDoAccessoryView?.textField.resignFirstResponder()
        self.textFieldForToDo?.resignFirstResponder()
        self.view.endEditing(true)
        let pendingTodoItems = self.readNewTodoItems()
        if let category = self.toDoPlanItCategory, !pendingTodoItems.isEmpty {
            self.saveNewToDoToServerUsingNetwotk(pendingTodoItems, category: category)
        }
    }
    
    override func setVisibilityTopStackView() {
        if self.toDoMode == .edit { return }
        super.setVisibilityTopStackView()
        self.updateHeaderVisibilityButton()
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return (self.toDoMode == .edit)
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let itemToMove = self.toDoItemCellModels[sourceIndexPath.section]
        self.toDoItemCellModels.remove(at: sourceIndexPath.section)
        self.toDoItemCellModels.insert(itemToMove, at: destinationIndexPath.section)
        self.reOrderTodo(itemToMove, from: destinationIndexPath)
        self.tableViewToDoItems.reloadData()
        self.updateTitleCacelToDone()
    }
    
    override func showShareLabelCount() {
        guard let category = self.toDoPlanItCategory else { return }
        self.labelShareCount?.isHidden = category.readAllInvitees().count == 0
        self.labelShareCount?.text = "\(category.readAllInvitees().count)"
    }
    
    override func triggerTodoUpdateFromNotification(_ notification: Notification) {
        guard let todo = notification.object as? PlanItTodo, self.allToDoItemCellModels.contains(where: { return $0.planItToDo == todo }) else { return }
        self.isCategoryDataUpdated = true
        if todo.readDeleteStatus() {
            self.refreshCategoriesAfterUserDeleteTodos([todo])
        }
        else {
            self.updateCompletedTable()
            self.refreshCategoriesAfterUserFavouriteTodos()
        }
    }
    
    override func refreshCategoriesAfterUserCompleteTodos(_ todos: [PlanItTodo]) {
        self.replaceTodoItemsWithChildTodos(todos)
        super.refreshCategoriesAfterUserCompleteTodos(todos)
    }
    
    func replaceTodoItemsWithChildTodos(_ todos: [PlanItTodo]) {
        let childTodos = self.readCompletedChildTodos(todos)
        self.addCompletedChildsToDoToMainList(childTodos)
    }
}
