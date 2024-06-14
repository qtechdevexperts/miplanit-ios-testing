//
//  ToDoListBaseViewController+Action.swift
//  MiPlanIt
//
//  Created by Febin Paul on 08/07/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation
import IQKeyboardManagerSwift


extension ToDoListBaseViewController {
    
    func addNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil )
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil )
        NotificationCenter.default.addObserver(self, selector: #selector(triggerTodoUpdateFromNotification(_:)), name: NSNotification.Name(rawValue: Notifications.dashboardToDoUpdate), object: nil)
    }
    
    func removeNotifications() {
        NotificationCenter.default.removeObserver(self, name:  UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name:  UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Notifications.dashboardToDoUpdate), object: nil)
    }
    
    func hideCompleteSection() {
        if !self.stackViewCompletedEditAction.tableViewToDoItems.isHidden {
            self.stackViewCompletedEditAction.toggleCompletedToDos(show: false)
        }
    }

    func enableAccesoryView() {
        IQKeyboardManager.shared.enable = false
        self.textFieldForToDo?.delegate = self
        self.textFieldForToDo?.becomeFirstResponder()
        self.addToDoAccessoryView?.textField.becomeFirstResponder()
//        self.textFieldForToDo?.resignFirstResponder()
        self.viewOverlay.isHidden = false
    }
    
    func setOnSearchActive(_ flag: Bool) {
        self.viewSearch.isHidden = !flag
        self.buttonBack.isHidden = flag
        self.headerToolVisibility(false, onSearch: true)
        self.labelHeaderTitle.isHidden = flag
        _ = flag ? self.textFieldSearch.becomeFirstResponder() : self.view.endEditing(true)
    }
    
    func setOnEditModeActive(_ flag: Bool) {
        self.toDoMode = flag ? .edit : .default
        self.buttonEditCancel?.setTitle("Cancel", for: .normal)
        DispatchQueue.main.asyncAfter(deadline: .now()+0.3) {
            self.viewEditView?.isHidden = !flag
            self.stackViewTop?.isHidden = flag
            self.labelHeaderTitle.isHidden = flag
            self.buttonSelectAll.isHidden = !(self.toDoItemCellModels.count > 1 && flag)
            self.stackViewCompletedEditAction.setActionView(mode: self.toDoMode)
            self.buttonBack.isHidden = flag
            self.view.backgroundColor = .white
            if flag {
                self.stackViewCompletedEditAction.hideCompleteSection()
            }
        }
    }
    
    func headerToolVisibility(_ flag: Bool, onSearch: Bool = false) {
        self.buttonSearch?.isHidden = !flag
        self.buttonHeaderEdit?.isHidden = !flag
        self.viewShareLabelCount?.isHidden = !flag
        self.viewFilterSection?.isHidden = self.categoryType == .custom ? true : onSearch
        self.buttonHeaderInvitees?.isHidden = false
        self.buttonMoreOption?.isHidden = false
        if onSearch {
            self.buttonHeaderInvitees?.isHidden = true
            self.buttonMoreOption?.isHidden = true
        }
    }
    
    func updateTitleCacelToDone() {
        self.buttonEditCancel?.setTitle("Done", for: .normal)
    }
    
    func setBackToDefaultMode() {
        self.toDoMode = .default
        self.viewEditView?.isHidden = true
        self.labelHeaderTitle.isHidden = false
        self.buttonSelectAll.isHidden = true
        self.buttonSelectAll.isSelected = false
        self.stackViewCompletedEditAction.setActionView(mode: .default)
        self.viewSearch.isHidden = true
        self.buttonBack.isHidden = false
        self.labelHeaderTitle.isHidden = false
        self.view.endEditing(true)
        self.view.backgroundColor = UIColor.init(red: 247 / 255.0, green: 246 / 255.0, blue: 251 / 255.0, alpha: 1.0)
        self.viewItemSelection?.isHidden = true
        self.textFieldSearch.text = Strings.empty
        self.stackViewCompletedEditAction.resetCompleteSection()
        self.setVisibilityTopStackView()
        self.setVisibilityBGImage()
        self.setVisibilityNoToDoImage()
        if self.categoryType == .custom {
            self.setOnEditModeActive(false)
        }
    }
    
    func sortToDoBy(_ type: DropDownOptionType, ascending: Bool) {
        switch type {
        case .eAlphabetically:
            self.toDoItemCellModels.sort { (toDo1, toDo2) -> Bool in
                toDo1.planItToDo.readToDoTitle().localizedCaseInsensitiveCompare(toDo2.planItToDo.readToDoTitle()) == (ascending ? ComparisonResult.orderedAscending : ComparisonResult.orderedDescending)
            }
        case .eCreatedDate:
            self.toDoItemCellModels.sort { (toDo1, toDo2) -> Bool in
                toDo1.planItToDo.createdAt?.compare(toDo2.planItToDo.createdAt ?? Date()) == (ascending ? .orderedAscending : .orderedDescending)
            }
        case .eDueDate:
            self.toDoItemCellModels.sort { (toDo1, toDo2) -> Bool in
                return (toDo1.planItToDo.readStartDate(using: self.categoryType) ?? Date().adding(years: -50)).compare(toDo2.planItToDo.readStartDate(using: self.categoryType) ?? Date().adding(years: -50)) == (ascending ? .orderedAscending : .orderedDescending)
            }
        case .eFavourite:
            self.toDoItemCellModels.sort { (toDo1, toDo2) -> Bool in
                ascending ? toDo1.planItToDo.favourited && !toDo2.planItToDo.favourited : !toDo1.planItToDo.favourited && toDo2.planItToDo.favourited
            }
        default:
            break
        }
        self.tableViewToDoItems.reloadData()
    }
    
    func readCompletedChildTodos(_ todos: [PlanItTodo]) -> [PlanItTodo] {
        var childTodos: [PlanItTodo] = []
        for todo in todos {
            if todo.isRecurrenceTodo() && !todo.completed {
                switch self.categoryType {
                case .today:
                    if let todayItem = todo.readAllChildTodos().filter({ return $0.readOriginalStartDate()?.initialHour() == Date().initialHour()}).first {
                        childTodos.append(todayItem)
                    }
                case .upcomming:
                    if let todayItem = todo.readAllChildTodos().sorted(by: { ($0.readOriginalStartDate() ?? Date()) > ($1.readOriginalStartDate() ?? Date()) }).first {
                        childTodos.append(todayItem)
                    }
                default:
                    if let todayItem = todo.readAllChildTodos().sorted(by: { $0.readModifiedDate() > $1.readModifiedDate() }).first {
                        childTodos.append(todayItem)
                    }
                }
            }
            else {
                childTodos.append(todo)
            }
        }
        return childTodos
    }
    
    func startCompletedUndoTimer() {
        self.timerSyncCompleted = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(fireCompleteSyncTimer), userInfo: nil, repeats: false)
    }
    
    func updateUndoSection(on todos: [PlanItTodo]) {
        self.completedQueue.append(contentsOf: todos)
        if self.viewCompletedPopUp.isHidden && self.timerSyncCompleted == nil {
            self.startCompletedUndoTimer()
        }
        self.labelUndoCompletedCount.text = "Completed (\(self.completedQueue.count))"
        self.viewCompletedPopUp.isHidden = self.completedQueue.count == 0
    }
    
    func updateCompletedTable() {
        if self.categoryType == .custom {
            debugPrint("####### self.allToDoItemCellModels.count: \(self.allToDoItemCellModels.count)")
            self.toDoItemCellModels = self.allToDoItemCellModels.filter({ !$0.planItToDo.completed })
            self.stackViewCompletedEditAction.setCompletedItems(items: self.allToDoItemCellModels.filter({ $0.planItToDo.completed }))
        }
        else if self.categoryType == .completed {
            self.allToDoItemCellModels = self.allToDoItemCellModels.filter({ $0.planItToDo.completed })
        }
        if let sortedValue = self.selectedSortValue {
            self.sortToDoBy(sortedValue.dropDownType, ascending: self.buttonSortArrow.isSelected)
        }
        self.tableViewToDoItems.reloadData()
        self.setVisibilityTopStackView()
    }
    
    @objc func fireCompleteSyncTimer() {
        
    }
    
    func undoCompleteToDo() {
        self.timerSyncCompleted?.invalidate()
        self.timerSyncCompleted = nil
        self.viewCompletedPopUp.isHidden = true
        guard let category = self.completedQueue.first?.readTodoCategory() else { return }
        self.saveToDoCompleteToServerUsingNetwotk(self.completedQueue, from: category, with: false)
        self.completedQueue.removeAll()
    }
    
    func updateListByFilter() {
        self.toDoItemCellModels = self.getFilteredItems()
        if self.viewSearch.isHidden {
            self.setVisibilityTopStackView()
        }
        self.setVisibilityBGImage()
        self.setVisibilityNoToDoImage()
        self.tableViewToDoItems.reloadData()
    }
    
    func checkSearchAfterAPICallChange() {
        guard let view = self.viewSearch, !view.isHidden, let text = self.textFieldSearch.text else {
            self.tableViewToDoItems.reloadData()
            return
        }
        self.setOnSearchActive(true)
        self.filterListBySearchText(text)
    }
    
    func getFilteredItems() -> [ToDoItemCellModel] {
        guard let filer = self.activeFilter else {
            return self.categoryType == .custom ? self.allToDoItemCellModels.filter{( !$0.planItToDo.readDeleteStatus() && !$0.planItToDo.completed )} : self.allToDoItemCellModels.filter{( !$0.planItToDo.readDeleteStatus() )}
        }
        switch filer.dropDownType {
        case .eFavourite:
            return self.allToDoItemCellModels.filter{( $0.planItToDo.favourited && !$0.planItToDo.completed && !$0.planItToDo.readDeleteStatus() )}
        case .eUnplanned:
            return self.allToDoItemCellModels.filter{( $0.planItToDo.readExactDueDate() == nil && !$0.planItToDo.readDeleteStatus() )}
        case .eOverDue:
            let startDate = Date().initialHour()
            return self.allToDoItemCellModels.filter{ if !$0.planItToDo.isRecurrenceTodo() { if let dueDate = $0.planItToDo.readExactDueDate(), dueDate < startDate { return !$0.planItToDo.completed && !$0.planItToDo.readDeleteStatus() } else { return false } } else { if let dueDate = $0.planItToDo.readRecurrenceEndDate(), dueDate < startDate { return !$0.planItToDo.completed && !$0.planItToDo.readDeleteStatus() } else { return false } } }
        case .eAssignedToMe:
            return self.allToDoItemCellModels.filter({ return !$0.planItToDo.readDeleteStatus() && $0.planItToDo.isAssignedToMeAccepted && !$0.planItToDo.completed })
        case .eCompleted:
            return self.allToDoItemCellModels.filter({ $0.planItToDo.completed && !$0.planItToDo.readDeleteStatus() })
        case .eAssignedByMe:
            return self.allToDoItemCellModels.filter({ return $0.planItToDo.isAssignedByMe && !$0.planItToDo.readDeleteStatus() && !$0.planItToDo.completed })
        case .eCreatedDate:
            guard let filterDate = filer.value.toDate(withFormat: DateFormatters.DDHMMHYYYY) else { return [] }
            return self.allToDoItemCellModels.filter({ $0.planItToDo.createdAt == filterDate && !$0.planItToDo.readDeleteStatus() })
        case .eDelete:
            return self.allToDoItemCellModels.filter{( $0.planItToDo.readDeleteStatus() )}
        default:
            break
        }
        return []
    }
    
    func filterListBySearchText(_ text: String) {
        if text == Strings.empty {
            self.updateListByFilter()
        }
        else {
            self.toDoItemCellModels = self.getFilteredItems().filter({ (item) -> Bool in
                let containsToDoTitle = item.planItToDo.readToDoTitle().lowercased().contains(text.lowercased())
                if self.categoryType != .custom {
                    return containsToDoTitle || item.planItToDo.readTodoCategory()?.readCategoryName().lowercased().contains(text.lowercased()) ?? false
                }
                else {
                    return containsToDoTitle
                }
            })
        }
        if let sortedValue = self.selectedSortValue {
            self.sortToDoBy(sortedValue.dropDownType, ascending: self.buttonSortArrow.isSelected)
        }
        self.setVisibilityNoToDoImage()
        self.tableViewToDoItems.reloadData()
    }
}

extension ToDoListBaseViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        textField.returnKeyType = ((textField.text?.isEmpty ?? Strings.empty.isEmpty || (range.length == 1 && range.location == 0)) && string.isEmpty) ? .default : .done
        textField.reloadInputViews()
        return true
    }
}

extension ToDoListBaseViewController: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
        }
        textView.returnKeyType = ((textView.text?.isEmpty ?? Strings.empty.isEmpty || (range.length == 1 && range.location == 0)) && text.isEmpty) ? .default : .done
        textView.reloadInputViews()
        return true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        self.view.endEditing(true)
    }
}


extension ToDoListBaseViewController: NormalSpeechTextFieldDelegate {
    func normalSpeechTextField(_ normalSpeechTextField: NormalSpeechTextField, test: String) {
        self.filterListBySearchText(test)
    }
}
