//
//  CustomCategoryToDoViewController+Callback.swift
//  MiPlanIt
//
//  Created by Febin Paul on 08/07/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation


extension CustomCategoryToDoViewController: AddToDoAccessoryViewDelegate {
    
    func addToDoAccessoryView(_ addToDoAccessoryView: AddToDoAccessoryView, textField: UITextField) {
        guard let todoName = textField.text, !todoName.isEmpty else { return }
        self.addNewTodoItemToCategory(todoName)
        textField.text = nil
    }
    
    func addToDoAccessoryView(_ addToDoAccessoryView: AddToDoAccessoryView, dismiss textField: UITextField) {
        textField.resignFirstResponder()
        self.textFieldForToDo?.resignFirstResponder()
        textField.text = nil
        self.viewOverlay.isHidden = true
        if let sortedValue = self.selectedSortValue {
            self.sortToDoBy(sortedValue.dropDownType, ascending: self.buttonSortArrow.isSelected)
        }
        let pendingTodoItems = self.readNewTodoItems()
        if let category = self.toDoPlanItCategory, !pendingTodoItems.isEmpty {
            self.saveNewToDoToServerUsingNetwotk(pendingTodoItems, category: category)
        }
    }
}

extension CustomCategoryToDoViewController: ToDoItemListCellDelegate {
    
    func toDoItemListCell(_ toDoCategoryListCell: ToDoItemListCell, toDoIemEdited indexPath: IndexPath, editedName: String) {
        guard let category = self.toDoPlanItCategory, self.toDoItemCellModels[indexPath.section].planItToDo.readToDoTitle() != editedName else { return }
        self.saveToDoNameToServerUsingNetwotk(self.toDoItemCellModels[indexPath.section].planItToDo, name: editedName, category: category)
    }
    
    func toDoItemListCell(_ toDoCategoryListCell: ToDoItemListCell, completion flag: Bool, indexPath: IndexPath) {
        guard let category = self.toDoPlanItCategory else { return }
        self.saveToDoCompleteToServerUsingNetwotk([self.toDoItemCellModels[indexPath.section].planItToDo], from: category, with: flag)
    }
    
    func toDoItemListCell(_ toDoCategoryListCell: ToDoItemListCell, favourite flag: Bool, indexPath: IndexPath) {
        guard let category = self.toDoPlanItCategory else { return }
        self.saveToDoFavoriteToServerUsingNetwotk([self.toDoItemCellModels[indexPath.section].planItToDo], from: category, with: flag)
    }
    
    func toDoItemListCell(_ toDoCategoryListCell: ToDoItemListCell, didSelect indexPath: IndexPath) {
        self.performSegue(withIdentifier: Segues.segueToDoDetail, sender: self.toDoItemCellModels[indexPath.section].planItToDo)
    }
    
    func toDoItemListCell(_ toDoCategoryListCell: ToDoItemListCell, checkBoxSelect indexPath: IndexPath) {
        self.toDoItemCellModels[indexPath.section].editSelected = !self.toDoItemCellModels[indexPath.section].editSelected
        self.checkForAllCellSelected()
        self.tableViewToDoItems.reloadData()
        self.updateSelectionLabelCount(self.toDoItemCellModels.filter({ $0.editSelected }).count)
    }
    
    func toDoItemListCell(_ toDoCategoryListCell: ToDoItemListCell, ShouldBeginEditing indexPath: IndexPath) {
        self.currentEditingCellIndex = indexPath
    }
    
}

extension CustomCategoryToDoViewController: CompletedEditActionToDoStackViewDelegate {
    
    func completedEditActionToDoStackViewMoveAll(_ completedEditActionToDoStackView: CompletedEditActionToDoStackView) {
        guard let _ = self.toDoPlanItCategory, self.viewCompletedPopUp.isHidden else { return }
        let completedList = self.allToDoItemCellModels.filter({ $0.planItToDo.completed }).compactMap({ $0.planItToDo })
        
        let parentPlanItToDos = completedList.filter({ $0.parent == nil })
        let childPlanItToDos = completedList.filter({ $0.parent != nil })
        
        var childOnlyExist = false
        childPlanItToDos.compactMap({ $0.parent }).forEach { (todo) in
            childOnlyExist = !parentPlanItToDos.contains(todo)
        }
        
        if childPlanItToDos.isEmpty || !childOnlyExist {
            self.performSegue(withIdentifier: Segues.segueToMoveList, sender: completedList)
        }
        else {
            self.performSegue(withIdentifier: Segues.toMessageScreen, sender: [Message.warning, Message.singleChildMove])
        }
    }
    
    func completedEditActionToDoStackViewUncompleAll(_ completedEditActionToDoStackView: CompletedEditActionToDoStackView) {
        guard let category = self.toDoPlanItCategory, self.viewCompletedPopUp.isHidden else { return }
        let completedList = self.allToDoItemCellModels.filter({ $0.planItToDo.completed }).compactMap({ $0.planItToDo })
        self.saveToDoCompleteToServerUsingNetwotk(completedList, from: category, with: false)
    }
    
    func completedEditActionToDoStackView(_ completedEditActionToDoStackView: CompletedEditActionToDoStackView, setOverlay flag: Bool) {
        self.textViewNewCategory?.isUserInteractionEnabled = !flag
    }
    
    func completedEditActionToDoStackView(_ completedEditActionToDoStackView: CompletedEditActionToDoStackView, onSelectToDo: ToDoItemCellModel) {
        self.performSegue(withIdentifier: Segues.segueToDoDetail, sender: onSelectToDo.planItToDo)
    }
    
    func completedEditActionToDoStackView(_ completedEditActionToDoStackView: CompletedEditActionToDoStackView, onDeleteToDo: ToDoItemCellModel) {
        let message = onDeleteToDo.planItToDo.isRecurrenceTodo() ? Message.occurrenceDelete : Message.deleteTodoItemMessage
        self.showAlertWithAction(message: message, title: Message.deleteTodoItem, items: [Message.yes, Message.cancel], callback: { buttonindex in
        if buttonindex == 0 {
                guard let category = self.toDoPlanItCategory else { return }
                self.saveToDoDeleteToServerUsingNetwotk([onDeleteToDo.planItToDo], from: category)
            }
        })
    }
    
    func completedEditActionToDoStackView(_ completedEditActionToDoStackView: CompletedEditActionToDoStackView, onFavouriteToDo: ToDoItemCellModel, flag: Bool) {
        guard let category = self.toDoPlanItCategory else { return }
        self.saveToDoFavoriteToServerUsingNetwotk([onFavouriteToDo.planItToDo], from: category, with: flag)
    }
    
    func completedEditActionToDoStackView(_ completedEditActionToDoStackView: CompletedEditActionToDoStackView, unCompleteToDo: ToDoItemCellModel) {
        guard let category = self.toDoPlanItCategory else { return }
        self.saveToDoCompleteToServerUsingNetwotk([unCompleteToDo.planItToDo], from: category, with: false)
    }
    
    func completedEditActionAssignedTo(_ completedEditActionToDoStackView: CompletedEditActionToDoStackView) {
        let selectedToDos = self.toDoItemCellModels.filter({ $0.editSelected }).compactMap({ return $0.planItToDo })
        if selectedToDos.count > 0 {
            if !selectedToDos.filter({ return $0.isAssignedToMe && !$0.isOwner }).isEmpty {
                self.performSegue(withIdentifier: Segues.toMessageScreen, sender: [Message.error, Message.noPermissionToAssignTodo])
            }
            else {
                if selectedToDos.contains(where: { $0.parent != nil }) {
                    self.performSegue(withIdentifier: Segues.toMessageScreen, sender: [Message.warning, Message.multipleChildAssign])
                }
                else {
                    self.performSegue(withIdentifier: Segues.toAssignScreen, sender: selectedToDos)
                }
            }
        }
        else {
            self.performSegue(withIdentifier: Segues.toMessageScreen, sender: [Message.warning, Message.noToDoItemsSelectedAssign])
        }
    }
    
    func completedEditActionMoveTo(_ completedEditActionToDoStackView: CompletedEditActionToDoStackView) {
        let selectedToDos = self.toDoItemCellModels.filter({ $0.editSelected }).map({ $0.planItToDo })
        if selectedToDos.count > 0 {
            if self.buttonSelectAll.isSelected {
                let parentTodos = selectedToDos.filter({$0?.parent == nil})
                self.performSegue(withIdentifier: Segues.segueToMoveList, sender: parentTodos)
            }
            else if selectedToDos.contains(where: { $0?.parent != nil }) {
                self.performSegue(withIdentifier: Segues.toMessageScreen, sender: [Message.warning, Message.multipleChildMove])
            }
            else {
                self.performSegue(withIdentifier: Segues.segueToMoveList, sender: selectedToDos)
            }
        }
        else {
            self.performSegue(withIdentifier: Segues.toMessageScreen, sender: [Message.warning, Message.noToDoItemsSelectedMove])
        }
    }
    
    func completedEditActionDueDate(_ completedEditActionToDoStackView: CompletedEditActionToDoStackView) {
        let selectedToDos = self.toDoItemCellModels.filter({ $0.editSelected }).map({ $0.planItToDo })
        if selectedToDos.count > 0 {
            if selectedToDos.contains(where: { $0?.parent != nil }) {
                self.performSegue(withIdentifier: Segues.toMessageScreen, sender: [Message.warning, Message.multipleChildDueDate])
            }
            else {
                self.performSegue(withIdentifier: Segues.toToDoDueDate, sender: nil)
            }
        }
        else {
            self.performSegue(withIdentifier: Segues.toMessageScreen, sender: [Message.warning, Message.noToDoItemsSelectedDueDate])
        }
    }
    
    func completedEditActionDelete(_ completedEditActionToDoStackView: CompletedEditActionToDoStackView) {
        let selectedTodos = self.toDoItemCellModels.filter({ return $0.editSelected}).compactMap({ return $0.planItToDo })
        if let category = self.toDoPlanItCategory, !selectedTodos.isEmpty {
            let message = selectedTodos.contains(where: { return $0.isRecurrenceTodo() }) ? Message.occurrenceDelete : Message.deleteTodoItemMessage
            self.showAlertWithAction(message: message, title: Message.deleteTodoItem, items: [Message.yes, Message.cancel], callback: { buttonindex in
            if buttonindex == 0 {
                    self.saveToDoDeleteToServerUsingNetwotk(selectedTodos, from: category)
                }
            })
        }
        else {
            self.performSegue(withIdentifier: Segues.toMessageScreen, sender: [Message.warning, Message.noToDoItemsSelectedDelete])
        }
    }
}

extension CustomCategoryToDoViewController: MoveListToDoViewControllerDelegate {
    
    func moveListToDoViewController(_ controller: MoveListToDoViewController, selectedOption: DropDownItem, moveToDos: [PlanItTodo]) {
        if let category = self.toDoPlanItCategory, category.readIdentifier() != selectedOption.value {
            self.saveMoveToDoToServerUsingNetwotk(moveToDos, from: category, to: selectedOption.value)
        }
    }
}

extension CustomCategoryToDoViewController: ShareToDoListViewControllerDelegate {
    
    func shareToDoListViewController(_ viewController: ShareToDoListViewController, selected users: [OtherUser]) {
        self.saveCategoryShareToServerUsingNetwotk(self.toDoPlanItCategory, users: users)
    }
}

extension CustomCategoryToDoViewController: BaseTodoDetailViewControllerDelegate {
    
    func baseTodoDetailViewController(_ viewController: BaseTodoDetailViewController, updated todo: PlanItTodo, completed: Bool) {
        self.isCategoryDataUpdated = true
        if todo.readDeleteStatus() {
            self.refreshCategoriesAfterUserDeleteTodos([todo])
        }
        else {
            if completed {
                self.replaceTodoItemsWithChildTodos([todo])
            }
            self.updateCompletedTable()
            self.refreshCategoriesAfterUserFavouriteTodos()
        }
    }
}

extension CustomCategoryToDoViewController: MoreActionToDoDropDownControllerDelegate {
    
    func moreActionToDoDropDownController(_ controller: MoreActionToDoDropDownController, selectedOption: DropDownItem) {
        switch selectedOption.dropDownType {
        case .ePrint:
            self.printToDos()
        case .eShare:
            self.performSegue(withIdentifier: Segues.toInviteesList, sender: nil)
        case .eAlphabetically, .eFavourite, .eDueDate, .eCreatedDate:
            self.selectedSortValue = selectedOption
            self.sortToDoBy(selectedOption.dropDownType, ascending: self.buttonSortArrow.isSelected)
        case .eDelete:
            self.showAlertWithAction(message: Message.deleteCategoryMessage, title: Message.deleteTodoCategory, items: [Message.yes, Message.cancel], callback: { index in
                if index == 0 {
                    guard let category = self.toDoPlanItCategory else {
                        return
                    }
                    self.saveCategoryDeleteToServerUsingNetwotk(category)
                }
            })
        default:
            break
        }
    }
}

extension CustomCategoryToDoViewController: CategoryListFilterControllerDelegate {
    
    func categoryListFilterController(_ controller: CategoryListFilterController, selectedOption: DropDownItem) {
        self.activeFilter = selectedOption
    }
    
    func categoryListFilterControllerClearOption(_ controller: CategoryListFilterController) {
        self.activeFilter = nil
    }
    
    func categoryListFilterControllerClearOption(_ controller: CategoryListFilterController, selectedOption: DropDownItem, selectedDate: Date) {
        self.activeFilter = selectedOption
        self.activeFilter?.value = selectedDate.stringFromDate(format: DateFormatters.DDHMMHYYYY)
    }
}


extension CustomCategoryToDoViewController: AssignToDoViewControllerDelegate {
    
    func assignToDoViewController(_ assignToDoViewController: AssignToDoViewController, selectedAssige: CalendarUser?, toDoItems: [PlanItTodo]) {
        guard let assignee = selectedAssige, let category = self.toDoPlanItCategory, !toDoItems.isEmpty else { return }
        self.saveTodoAssignUserToServerUsingNetwotk(assignee, to: toDoItems, category: category)
    }
}


extension CustomCategoryToDoViewController: DueDateViewControllerDelegate {
    
    func dueDateViewController(_ dueDateViewController: DueDateViewController, dueDate: Date) {
        let selectedTodos = self.toDoItemCellModels.filter({ $0.editSelected }).compactMap({ $0.planItToDo })
        if let category = self.toDoPlanItCategory, !selectedTodos.isEmpty {
            let date = dueDate.stringFromDate(format: DateFormatters.YYYYHMMMHDD)
            self.saveTodoDueDateToServerUsingNetwotk(selectedTodos, from: category, date: date)
        }
    }
}
