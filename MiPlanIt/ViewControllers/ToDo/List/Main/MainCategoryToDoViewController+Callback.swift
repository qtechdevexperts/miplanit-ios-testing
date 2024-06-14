//
//  MainCategoryToDoViewController+Callback.swift
//  MiPlanIt
//
//  Created by Febin Paul on 08/07/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation
//TEST: testing
extension MainCategoryToDoViewController: AddToDoAccessoryViewDelegate {
    
    func addToDoAccessoryView(_ addToDoAccessoryView: AddToDoAccessoryView, textField: UITextField) {
        textField.resignFirstResponder()
        self.textFieldForToDo?.resignFirstResponder()
        //        self.delegate?.tabViewController(self, taskName: textField.text)
        textField.text = nil
        self.viewOverlay.isHidden = true
    }
    
    func addToDoAccessoryView(_ addToDoAccessoryView: AddToDoAccessoryView, dismiss textField: UITextField) {
        textField.resignFirstResponder()
        self.textFieldForToDo?.resignFirstResponder()
        textField.text = nil
        self.viewOverlay.isHidden = true
    }
}

extension MainCategoryToDoViewController: ToDoItemListCellDelegate {
    
    func toDoItemListCell(_ toDoCategoryListCell: ToDoItemListCell, toDoIemEdited indexPath: IndexPath, editedName: String) {
        print(editedName)
    }
    
    func toDoItemListCell(_ toDoCategoryListCell: ToDoItemListCell, completion flag: Bool, indexPath: IndexPath) {
        guard self.toDoItemCellModels.count > indexPath.section, let category = self.toDoItemCellModels[indexPath.section].planItToDo.readTodoCategory() else { return }
        self.saveToDoCompleteToServerUsingNetwotk([self.toDoItemCellModels[indexPath.section].planItToDo], from: category, with: flag)
    }
    
    func toDoItemListCell(_ toDoCategoryListCell: ToDoItemListCell, favourite flag: Bool, indexPath: IndexPath) {
        guard self.toDoItemCellModels.count > indexPath.section, let category = self.toDoItemCellModels[indexPath.section].planItToDo.readTodoCategory() else { return }
        self.saveToDoFavoriteToServerUsingNetwotk([self.toDoItemCellModels[indexPath.section].planItToDo], from: category, with: flag)
    }
    
    func toDoItemListCell(_ toDoCategoryListCell: ToDoItemListCell, didSelect indexPath: IndexPath) {
        guard self.toDoItemCellModels.count > indexPath.section else { return }
        self.performSegue(withIdentifier: Segues.segueToDoDetail, sender: self.toDoItemCellModels[indexPath.section].planItToDo)
        if self.categoryType == .overdue || self.categoryType == .completed || self.categoryType == .assignedToMe {
            self.delegate?.todoListBaseViewController(self, sendTodoReadStatus: [self.toDoItemCellModels[indexPath.section].planItToDo])
            self.tableViewToDoItems.reloadRows(at: [indexPath], with: .none)
        }
    }
    
    func toDoItemListCell(_ toDoCategoryListCell: ToDoItemListCell, checkBoxSelect indexPath: IndexPath) {
        guard self.toDoItemCellModels.count > indexPath.section else { return }
        self.toDoItemCellModels[indexPath.section].editSelected = !self.toDoItemCellModels[indexPath.section].editSelected
        self.tableViewToDoItems.reloadRows(at: [indexPath], with: .none)
    }
    
    func toDoItemListCell(_ toDoCategoryListCell: ToDoItemListCell, ShouldBeginEditing indexPath: IndexPath) {
    }
    
}

extension MainCategoryToDoViewController: MoveListToDoViewControllerDelegate {
    
    func moveListToDoViewController(_ controller: MoveListToDoViewController, selectedOption: DropDownItem, moveToDos: [PlanItTodo]) { }
}

extension MainCategoryToDoViewController: BaseTodoDetailViewControllerDelegate {
    
    func baseTodoDetailViewController(_ viewController: BaseTodoDetailViewController, updated todo: PlanItTodo, completed: Bool) {
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

extension MainCategoryToDoViewController: CategoryListFilterControllerDelegate {
    
    func categoryListFilterControllerClearOption(_ controller: CategoryListFilterController, selectedOption: DropDownItem, selectedDate: Date) {
        self.activeFilter = selectedOption
        self.activeFilter?.value = selectedDate.stringFromDate(format: DateFormatters.DDHMMHYYYY)
    }
    
    
    func categoryListFilterControllerClearOption(_ controller: CategoryListFilterController) {
        self.activeFilter = nil
    }
    
    
    func categoryListFilterController(_ controller: CategoryListFilterController, selectedOption: DropDownItem) {
        self.activeFilter = selectedOption
    }
}
