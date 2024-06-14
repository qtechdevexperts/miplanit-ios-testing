//
//  ToDoListBaseViewController+Override.swift
//  MiPlanIt
//
//  Created by Arun on 14/07/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

extension ToDoListBaseViewController {
    
    @objc func initializeUI() {
        self.addToDoAccessoryView = AddToDoAccessoryView(frame: CGRect(x: 0, y: 0, width: 10, height: 64))
        self.addToDoAccessoryView?.backgroundColor = UIColor.clear
        self.textFieldForToDo?.inputAccessoryView = self.addToDoAccessoryView
        self.labelDayPart.text = "Good " + Date().getDayPart()
        self.textFieldSearch.attributedPlaceholder = NSAttributedString(string: "Search To Do",
                                                                        attributes: [NSAttributedString.Key.foregroundColor: UIColor(white: 1.0, alpha: 0.4)])
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleOverlayTap(_:)))
        tap.numberOfTapsRequired = 1
        self.viewOverlay.isUserInteractionEnabled = true
        self.viewOverlay.addGestureRecognizer(tap)
        self.viewFilterSection?.isHidden = self.categoryType != .all
        self.textFieldSearch.delegate = self
        self.textFieldSearch.normalSpeechDelegate = self
        self.showShareLabelCount()
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture))
        swipeDown.direction = .down
        self.stackViewCompletedEditAction.addGestureRecognizer(swipeDown)
        self.loadInterstilialAds()
    }
    
    func loadInterstilialAds() {
        self.showInterstitalViewController()
    }
    
    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        self.stackViewCompletedEditAction.toggleCompletedToDos(show: false)
    }
    
    @objc func showShareLabelCount() {  }
    
    @objc func handleOverlayTap(_ sender: UITapGestureRecognizer) { }
    
    @objc func configureToDoCell(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.toDoTaskListViewCell, for: indexPath)
        return cell
    }
    
    @objc func setVisibilityBGImage() {
        if categoryType == .all {
            if let filter = activeFilter, filter.dropDownType == .eDelete {
                self.viewBGImageContainer?.isHidden = !self.allToDoItemCellModels.isEmpty;
            }
            else {
                self.viewBGImageContainer?.isHidden = !self.toDoItemCellModels.isEmpty;
            }
        }
        else {
            self.viewBGImageContainer?.isHidden = !self.allToDoItemCellModels.isEmpty;
        }
    }
    
    @objc func setVisibilityNoToDoImage() {
        if !(self.viewBGImageContainer?.isHidden ?? true) {
            self.imageViewNoToDoItem?.isHidden = true
            return
        }
        if self.categoryType == .all {
            if let filter = activeFilter, filter.dropDownType == .eDelete {
                self.imageViewNoToDoItem?.isHidden = self.viewSearch.isHidden && self.activeFilter == nil ? !self.allToDoItemCellModels.isEmpty : !self.toDoItemCellModels.isEmpty
            }
            else {
                self.imageViewNoToDoItem?.isHidden =  !self.toDoItemCellModels.isEmpty
            }
        }
        else {
            self.imageViewNoToDoItem?.isHidden = self.viewSearch.isHidden ? !self.allToDoItemCellModels.isEmpty : !self.toDoItemCellModels.isEmpty
        }
    }
    
    @objc func setVisibilityTopStackView() {
        if self.categoryType == .all {
            self.stackViewTop?.isHidden = self.allToDoItemCellModels.isEmpty
            self.buttonSearch?.isHidden = self.toDoItemCellModels.isEmpty
            self.buttonHeaderEdit?.isHidden = true
            self.buttonHeaderMoreAction?.isHidden = true
            self.viewFilterSection?.isHidden = (self.stackViewTop?.isHidden ?? true)
        }
        else if self.categoryType != .custom {
            self.stackViewTop?.isHidden = self.allToDoItemCellModels.isEmpty
            self.buttonSearch?.isHidden = self.toDoItemCellModels.isEmpty
            self.buttonHeaderEdit?.isHidden = true
            self.buttonHeaderMoreAction?.isHidden = true
            self.viewFilterSection?.isHidden = true
        }
    }
    
    @objc func triggerTodoUpdateFromNotification(_ notification: Notification) { }
    
    @objc func deleteItemClicked(on index: IndexPath) { }
    
    @objc func restoreItemClicked(on index: IndexPath) { }
    
    @objc func moveItemClicked(on index: IndexPath) { }
    
    @objc func editItemClicked(on index: IndexPath) { }
    
    @objc func assignItemClicked(on index: IndexPath) { }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            self.tableViewToDoItems.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: self.stackViewCompletedEditAction.tableViewToDoItems.isHidden ? keyboardRectangle.height : 0, right: 0)
            self.tableViewToDoItems.scrollIndicatorInsets = self.tableViewToDoItems.contentInset
            if let indexPath = self.currentEditingCellIndex {
                DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
                    self.tableViewToDoItems.scrollToRow(at: indexPath, at: UITableView.ScrollPosition.top, animated: false)
                }
            }
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        self.constraintTableViewBottom.constant = 18.0
        self.currentEditingCellIndex = nil
        self.tableViewToDoItems.contentInset = .zero
    }
    
    @objc func toggleAllCellSelection(by flag: Bool) { }
    
    @objc func refreshCategoriesAfterUserDeleteTodos(_ todos: [PlanItTodo]) {
        self.viewItemSelection?.isHidden = true
        if self.categoryType == .all {
            self.toDoItemCellModels = self.getFilteredItems()
        }
        else {
            self.allToDoItemCellModels.removeAll(where: { return $0.planItToDo.readDeleteStatus() })
        }
        self.setVisibilityBGImage()
        self.setVisibilityNoToDoImage()
        self.setVisibilityTopStackView()
        self.checkSearchAfterAPICallChange()
//        self.tableViewToDoItems.reloadData()
    }
    
    @objc func refreshCategoriesAfterUserRestoreTodos(_ todos: [PlanItTodo]) {
        if self.categoryType == .all { self.toDoItemCellModels = self.getFilteredItems() }
        self.setVisibilityTopStackView()
        self.filterListBySearchText(self.textFieldSearch.text ?? Strings.empty)
//        self.tableViewToDoItems.reloadData()
        self.checkSearchAfterAPICallChange()
    }
    
    @objc func refreshCategoriesAfterUserMoveTodos() {
        self.viewItemSelection?.isHidden = true
        self.checkSearchAfterAPICallChange()
    }
    
    func addCompletedChildsToDoToMainList(_ todos: [PlanItTodo]) {
        todos.forEach({ todo in if !self.allToDoItemCellModels.contains(where: { $0.planItToDo == todo || todo.readDeleteStatus() }) { self.allToDoItemCellModels.insert(ToDoItemCellModel(planItToDo: todo), at: 0) } })
    }
    
    @objc func refreshCategoriesAfterUserCompleteTodos(_ todos: [PlanItTodo]) {
//        self.tableViewToDoItems.reloadData()
        self.checkSearchAfterAPICallChange()
    }
    
    func updateListAfterRefreshCategories() {
        self.activeFilter != nil ? self.updateListByFilter() : self.tableViewToDoItems.reloadData()
        self.setVisibilityTopStackView()
    }
    
    func refreshUnplannedCategoriesAfterUserSetDueDate() {
        self.allToDoItemCellModels.removeAll(where: {
            if !$0.planItToDo.completed && !$0.planItToDo.readDeleteStatus() && $0.planItToDo.readExactDueDate() == nil {
                return false
            }
            return true
        })
        self.updateListAfterRefreshCategories()
    }

    func refreshCategoriesAfterUserSetDueDate() {
        self.allToDoItemCellModels.removeAll(where: {
            if let dueDate = $0.planItToDo.readStartDate(using: .overdue) {
                return dueDate >= Date().initialHour() || $0.planItToDo.completed || $0.planItToDo.readDeleteStatus()
            }
            else {
                return $0.planItToDo.completed || $0.planItToDo.readDeleteStatus()
            }
        })
        self.updateListAfterRefreshCategories()
    }
    
    func refreshCategoriesAfterUserCompletedTodo() {
        if self.categoryType != .custom && self.categoryType != .completed {
            if self.categoryType == .overdue {
                self.allToDoItemCellModels.removeAll(where: {
                    if let dueDate = $0.planItToDo.readStartDate(using: .overdue) {
                        return dueDate >= Date().initialHour() || $0.planItToDo.completed || $0.planItToDo.readDeleteStatus()
                    }
                    else {
                        return $0.planItToDo.completed || $0.planItToDo.readDeleteStatus()
                    }
                })
            }
            else {
                self.allToDoItemCellModels.removeAll(where: {
                    return $0.planItToDo.completed
                })
            }
            self.updateListAfterRefreshCategories()
        }
    }
    
    func refreshCategoriesAfterUserUnCompleteTodo() {
        self.allToDoItemCellModels.removeAll(where: {
            return !$0.planItToDo.completed
        })
    }
    
    func refreshCategoriesAfterUserSetToday() {
        let startDate = Date().initialHour()
        let endDate = Date().initialHour().adding(days: 1).adding(seconds: -1)
        self.allToDoItemCellModels.removeAll(where: {
            return !$0.planItToDo.readDeleteStatus() && !$0.planItToDo.readTodoAvailableAtTimeRange(from: startDate, to: endDate)
        })
    }
    
    func refreshCategoriesAfterUserSetUpcomming() {
        let endDate = Date().initialHour().adding(days: 1)
        self.allToDoItemCellModels.removeAll(where: {
            if !$0.planItToDo.isRecurrenceTodo() {
                if let dueDate = $0.planItToDo.readExactDueDate() {
                    return dueDate < endDate && !$0.planItToDo.readDeleteStatus()
                }
                else {
                    return true
                }}
            else { if let dueDate = $0.planItToDo.readRecurrenceEndDate(), dueDate < endDate { return !$0.planItToDo.readDeleteStatus() } else { return false } }
        })
    }
    
    @objc func refreshCategoriesAfterUserFavouriteTodos() {
        if self.categoryType == .favourite {
            self.allToDoItemCellModels.removeAll(where: {
                !$0.planItToDo.favourited
            })
        }
        self.updateListAfterRefreshCategories()
        self.checkSearchAfterAPICallChange()
    }
    
    @objc func refreshCategoriesAfterOverdueTodos() {
        if self.categoryType == .overdue {
            let startDate = Date().initialHour()
            self.allToDoItemCellModels.removeAll(where: {
                if !$0.planItToDo.isRecurrenceTodo() {
                    if let dueDate = $0.planItToDo.readExactDueDate() {
                        return dueDate >= startDate || $0.planItToDo.readDeleteStatus() || $0.planItToDo.completed
                    }
                    else {
                        return true
                    }
                }
                else {
                    if let dueDate = $0.planItToDo.readRecurrenceEndDate() {
                        return dueDate >= startDate || $0.planItToDo.readDeleteStatus() || $0.planItToDo.completed
                    }
                    else {
                        return true
                    }
                }
            })
        }
        self.updateListAfterRefreshCategories()
    }
    
    @objc func startLoadingIndicatorForTodos(_ todos: [PlanItTodo]) {
        for todo in todos {
            if let index = self.toDoItemCellModels.firstIndex(where: { $0.planItToDo == todo }) {
              let indexPath = IndexPath(row: 0, section: index)
                if let cell = self.tableViewToDoItems.cellForRow(at: indexPath) as? ToDoItemListCell {
                    cell.startGradientAnimation()
                }
            }
            
            if let index = self.stackViewCompletedEditAction.completedItems.firstIndex(where: { $0.planItToDo == todo }) {
                let indexPath = IndexPath(row: 0, section: index)
                if let cell = self.stackViewCompletedEditAction.tableViewToDoItems.cellForRow(at: indexPath) as? ToDoItemListCell {
                    cell.startGradientAnimation()
                }
            }
        }
    }
    
    @objc func stopLoadingIndicatorForTodos(_ todos: [PlanItTodo]) {
        for todo in todos {
            if let index = self.toDoItemCellModels.firstIndex(where: { $0.planItToDo == todo }) {
                let indexPath = IndexPath(row: 0, section: index)
                if let cell = self.tableViewToDoItems.cellForRow(at: indexPath) as? ToDoItemListCell {
                    cell.stopGradientAnimation()
                }
            }
            
            if let index = self.stackViewCompletedEditAction.completedItems.firstIndex(where: { $0.planItToDo == todo }) {
                let indexPath = IndexPath(row: 0, section: index)
                if let cell = self.stackViewCompletedEditAction.tableViewToDoItems.cellForRow(at: indexPath) as? ToDoItemListCell {
                    cell.stopGradientAnimation()
                }
            }
        }
    }
}
