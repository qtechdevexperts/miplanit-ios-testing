//
//  CustomCategoryToDoViewController+Action.swift
//  MiPlanIt
//
//  Created by Febin Paul on 08/07/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation


extension CustomCategoryToDoViewController {
    
    func sortTodosWithCategoryType() {
        guard let category = self.toDoPlanItCategory else {
            self.buttonMoreOption?.isHidden = true
            self.buttonHeaderInvitees?.isHidden = true
            return
        }
        self.activityIndicator?.startAnimating()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            self.allToDoItemCellModels = category.readAllAvailableMainTodos().filter({ return !$0.readDeleteStatus() }).sorted(by: { return $0.readOrderUsingOrderDateOrStartDate() < $1.readOrderUsingOrderDateOrStartDate() }).map({ ToDoItemCellModel(planItToDo: $0) })
            if self.toDoItemCellModels.count > 0 { self.stackViewCompletedEditAction.hideCompleteSection() }
            self.updateCompletedTable()
            self.activityIndicator?.stopAnimating()
        }
    }
    
    func initialRefreshControl() {
        self.refreshControl.attributedTitle = NSAttributedString(string: "")
        self.refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        self.tableViewToDoItems?.addSubview(refreshControl)
    }
    
    @objc func refresh(_ sender: AnyObject) {
        self.refreshControl.beginRefreshing()
        self.createServiceToFetchUsersDataInsidePullToRefresh { [weak self] (serviceDetection) in
            guard let self = self else {return}
            if self.refreshControl.isRefreshing {
                self.refreshControl.endRefreshing()
                if serviceDetection.isContainedSpecificServiceData(.todo) || self.pullToRefreshDate != (Session.shared.readUser()?.readUserSettings().readLastTodoFetchDataTime() ?? Strings.empty ) {
                    self.showSharedCategoryDetails()
                    self.updatedActionViews()
                    self.setVisibilityTopStackView()
                    self.sortTodosWithCategoryType()
                    self.isCategoryDataUpdated = true
                    self.pullToRefreshDate = Session.shared.readUser()?.readUserSettings().readLastTodoFetchDataTime() ?? Strings.empty
                }
            }
        }
    }
    
    func showSharedCategoryDetails() {
        if let sharedBy = self.toDoPlanItCategory?.readSharedByUser(), sharedBy.readValueOfUserId() != Session.shared.readUserId() {
            self.imgSharedBy.isHidden = false
            self.imgSharedBy.pinImageFromURL(URL(string: sharedBy.readValueOfProfileImage()), placeholderImage: sharedBy.fullName?.shortStringImage())
        }
        else {
            self.imgSharedBy.isHidden = true
        }
    }
    
    func readNormalMessageFont(_ string: String) -> NSAttributedString {
        let myAttribute = [ NSAttributedString.Key.foregroundColor: UIColor.black,  NSAttributedString.Key.font: UIFont(name: Fonts.SFUIDisplayRegular, size: 18)! ]
        let result = NSAttributedString(string: string, attributes: myAttribute)
        return result
    }
    
    func readActionMessageFont(_ string: String) -> NSAttributedString {
        let myAttribute = [ NSAttributedString.Key.foregroundColor:  UIColor.black,  NSAttributedString.Key.font: UIFont(name: Fonts.SFUIDisplayMedium, size: 22)! ]
        let p1 = NSMutableParagraphStyle()
        p1.alignment = .left
        p1.paragraphSpacing = 30
        let result = NSAttributedString(string: string, attributes: myAttribute)
        return result
    }
    
    func updateTextLabel(string: String, bold: Bool) -> NSAttributedString{
        return bold ? self.readNormalMessageFont(string) : self.readActionMessageFont(string)
    }
    
    func sortToDo(_ planItTodos: [PlanItTodo], ascending: Bool) -> [PlanItTodo] {
        guard let type = self.selectedSortValue?.dropDownType else { return planItTodos.sorted(by: { return $0.readOrderUsingOrderDateOrStartDate() < $1.readOrderUsingOrderDateOrStartDate() }) }
        switch type {
        case .eAlphabetically:
            return planItTodos.sorted { (toDo1, toDo2) -> Bool in
                toDo1.readToDoTitle().localizedCaseInsensitiveCompare(toDo2.readToDoTitle()) == (ascending ? ComparisonResult.orderedAscending : ComparisonResult.orderedDescending)
            }
        case .eCreatedDate:
            return planItTodos.sorted { (toDo1, toDo2) -> Bool in
                toDo1.createdAt?.compare(toDo2.createdAt ?? Date()) == (ascending ? .orderedAscending : .orderedDescending)
            }
        case .eDueDate:
            let sortedDueDate = planItTodos.sorted { (toDo1, toDo2) -> Bool in
                return (toDo1.readStartDate(using: self.categoryType) ?? Date().adding(years: -50)).compare(toDo2.readStartDate(using: self.categoryType) ?? Date().adding(years: -50)) == (ascending ? .orderedAscending : .orderedDescending)
            }
            return sortedDueDate
        case .eFavourite:
            return planItTodos.sorted { (toDo1, toDo2) -> Bool in
                ascending ? toDo1.favourited && !toDo2.favourited : !toDo1.favourited && toDo2.favourited
            }
        default:
            return planItTodos.sorted(by: { return $0.readOrderUsingOrderDateOrStartDate() < $1.readOrderUsingOrderDateOrStartDate() })
        }
    }

    func printToDos() {
        if let category = self.toDoPlanItCategory, category.readAllAvailableMainTodos().count > 0 {
            var html = "<!DOCTYPE html><html><meta charset=\"UTF-8\"><head><title>To Do List</title><style>body {background-color: white;text-align: center;color: black;font-family: Arial, Helvetica, sans-serif;}li.style1 {text-align: left;font-size: 15px;font-weight: bold;line-height: 25px}li.style2 {text-align: left;font-size: 13px;line-height: 25px}hr.newstyle {border-top: 1px dashed black;} span.style1 {text-align: left;font-size: 12px;line-height: 15px;color:gray;}span.style2 {text-align: left;font-size: 14px;line-height: 15px;color:black;}h2.style1 {text-align: left;}</style></head><body>"
            if let filepath = Bundle.main.path(forResource: "base64image", ofType: "txt") {
                do {
                    let contents = try String(contentsOfFile: filepath)
                    html.append("<p><img src=\"data:image/jpg;base64, \(contents)\" alt=\"Logo Image\" width=\"40\" height=\"40\" /></p>")
                    
                } catch {
                    // contents could not be loaded
                }
            }
            html.append("<h1><u>\(self.toDoPlanItCategory?.categoryName ?? Strings.unavailable) </u></h1>")
            if let sharedBy = self.toDoPlanItCategory?.readSharedByUser(), sharedBy.readValueOfUserId() != Session.shared.readUserId() {
                html.append("<h2 class = 'style1'> Shared By: \(sharedBy.fullName ?? Strings.empty)</h2>")
            }
            html.append("<ul>")
            let sortedToDo = self.sortToDo(self.toDoPlanItCategory!.readAllAvailableMainTodos(), ascending: self.buttonSortArrow.isSelected)
            for todo in sortedToDo {
                html.append("<li class = 'style1'>\(todo.readToDoTitle())")
                if !todo.readDueDate().isEmpty {
                    html.append("  [\(todo.readStartDate(using: self.categoryType)?.stringFromDate(format: DateFormatters.EEEDDMMMYYYY) ?? Strings.empty)]")
                }
                if todo.completed == true {
                    html.append("  &#10003;")
                }
                let assigees = todo.readAllInvitees().first
                if let user = assigees {
                    html.append("<br> <span class = 'style1'>Assignee: \(user.readValueOfFullName())</span>")
                }
                if let note = todo.note, !note.isEmpty {
                    html.append("<br> <span class = 'style1'>Notes: \(note)</span>")
                }
                if todo.readAllSubTodos().count > 0 {
                    html.append("<br> <span class = 'style2'>Subtasks: <br></span>")
                    html.append("<ul>")
                    for subTodo in todo.readAllSubTodos() {
                        html.append("<li class = 'style2'>\(subTodo.readSubToDoTitle())")
                        if subTodo.completed == true {
                            html.append("  &#10003;")
                        }
                        html.append("</li>")
                    }
                    html.append("</ul>")
                }
                
                html.append("</li>")
            }
            html.append("</ul></body></html>")
            let data = Data(html.utf8)
            if let attributedString = try? NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil) {
                let print = UISimpleTextPrintFormatter(attributedText: attributedString)
                let vc = UIActivityViewController(activityItems: [print], applicationActivities: nil)
                present(vc, animated: true)
            }
        }
        else {
            self.performSegue(withIdentifier: Segues.toMessageScreen, sender: [Message.error, Message.noitemstoprinttodo])
        }
    }
    
    
    func updatedActionViews() {
        self.labelHeaderTitle.text = "Lists"
        self.viewFilterSection?.isHidden = true
        self.textViewNewCategory?.isUserInteractionEnabled = true
        self.textViewNewCategory?.text = self.toDoPlanItCategory?.readCategoryName()
        self.tableViewToDoItems.isHidden = self.toDoPlanItCategory == nil
        self.updateHeaderVisibilityButton()
        self.buttonAddTodo?.isHidden = self.toDoPlanItCategory == nil
        if self.toDoPlanItCategory == nil {
            self.textViewNewCategory?.becomeFirstResponder()
        }
        self.buttonHeaderInvitees.isHidden = self.toDoPlanItCategory?.readAllToDoSharedInvitees().count == 0
    }
    
    func updateViewAfterAddCategory() {
        self.isCategoryDataUpdated = true
        self.toDoMode = .default
        self.updatedActionViews()
        self.stackViewCompletedEditAction.setActionView(mode: self.toDoMode)
        self.setBackToDefaultMode()
    }
    
    func updateHeaderVisibilityButton() {
        if self.toDoPlanItCategory == nil || self.toDoItemCellModels.isEmpty {
            self.headerToolVisibility(false)
        }
        else {
            self.headerToolVisibility(true)
        }
    }
    
    func showTryAgainAlertForCategory() {
        self.showAlertWithAction(message: Message.toDoNotSaved, title: Message.unknownError, items: [Message.cancel, Message.tryAgain], callback: { index in
            if index == 0 {
                if self.toDoMode == .edit {
                    self.textViewNewCategory?.text = self.toDoPlanItCategory?.readCategoryName()
                }
                else {
                    self.dismiss(animated: true, completion: nil)
                }
            }
            else if let category = self.textViewNewCategory?.text {
                self.saveCategoryToServerUsingNetwotk(category)
            }
        })
    }
    
    func readNewTodoItems() -> [PlanItTodo] {
        return self.toDoItemCellModels.filter({ return $0.planItToDo.isPending }).map({ return $0.planItToDo })
    }
    
    func addNewTodoItemToCategory(_ todo: String) {
        let todoItem = DataBasePlanItTodo().insertNewTodo(todo, to: self.toDoPlanItCategory)
        self.viewBGImageContainer?.isHidden = true
        self.tableViewToDoItems.beginUpdates()
        self.allToDoItemCellModels.append(ToDoItemCellModel(planItToDo: todoItem))
        self.tableViewToDoItems.insertSections(IndexSet(integer: self.toDoItemCellModels.count-1), with: UITableView.RowAnimation.fade)
        self.tableViewToDoItems.endUpdates()
        self.tableViewToDoItems.scrollToRow(at: IndexPath(row: 0, section: self.toDoItemCellModels.count-1), at: .top, animated: true)
    }
    
    func checkForAllCellSelected() {
        if !self.buttonSelectAll.isHidden{
            self.buttonSelectAll.isSelected = self.toDoItemCellModels.filter({ !$0.editSelected }).count == 0
        }
    }
    
    func updateSelectionLabelCount(_ count: Int) {
        self.viewItemSelection?.isHidden = count == 0
        self.labelItemSelectionCount.text = "\(count) item selected"
    }
    
    func reOrderTodo(_ todo: ToDoItemCellModel, from index: IndexPath) {
        if index.section - 1 >= 0 {
            let orderedTodos = self.reorderFromTopToBottom(at: index.section - 1)
            guard let category = self.toDoPlanItCategory, !orderedTodos.isEmpty else { return }
            self.createWebServiceToReOrderTodos(orderedTodos, from: category)
        }
        else {
            if index.section + 1 < self.toDoItemCellModels.count {
                let orderedTodos = self.reorderFromBottomToTop(at: index.section + 1)
                guard let category = self.toDoPlanItCategory, !orderedTodos.isEmpty else { return }
                self.createWebServiceToReOrderTodos(orderedTodos, from: category)
            }
        }
    }
    
    func reorderFromTopToBottom(at index: Int) -> [PlanItTodo] {
        var ontimeExcecution = false
        var orderedTodos: [PlanItTodo] = []
        var baseOrder = self.toDoItemCellModels[index].planItToDo.readOrderUsingOrderDateOrStartDate()
        for section in (index+1..<self.toDoItemCellModels.count) {
            guard let todo = self.toDoItemCellModels[section].planItToDo else { continue }
            if todo.readOrderDate() == baseOrder || !ontimeExcecution {
                baseOrder = baseOrder.adding(seconds: 1)
                ontimeExcecution = true
                todo.saveOrderDate(baseOrder)
                orderedTodos.append(todo)
            }
            else { break }
        }
        return orderedTodos
    }
    
    func reorderFromBottomToTop(at index: Int) -> [PlanItTodo] {
        var ontimeExcecution = false
        var orderedTodos: [PlanItTodo] = []
        var baseOrder = self.toDoItemCellModels[index].planItToDo.readOrderUsingOrderDateOrStartDate()
        for section in (0..<index).reversed() {
            guard let todo = self.toDoItemCellModels[section].planItToDo else { continue }
            if todo.readOrderDate() == baseOrder || !ontimeExcecution {
                baseOrder = baseOrder.adding(seconds: -1)
                ontimeExcecution = true
                todo.saveOrderDate(baseOrder)
                orderedTodos.append(todo)
            }
            else { break }
        }
        return orderedTodos
    }
}
