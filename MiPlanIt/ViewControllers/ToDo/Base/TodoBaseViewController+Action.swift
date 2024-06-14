//
//  TodoBaseViewController+Action.swift
//  MiPlanIt
//
//  Created by Febin Paul on 06/05/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

extension TodoBaseViewController {
    
    func initilizeUIComponent() {
        self.createPanGestureRecognizer()
        self.viewMenus.forEach({ $0.delegate = self })
        self.viewCustomToDoListContainer.delegate = self
        self.showAllTodoCategoriesValues()
        self.setRefreshController()
    }
    
    func setRefreshController() {
        self.refreshControl = self.scrollView.addRefreshControl(target: self,
                                                          action: #selector(doRefresh(_:)))
        refreshControl.tintColor = UIColor.white
        self.refreshControl.attributedTitle = NSAttributedString(string: "")
    }
    
    @objc func doRefresh(_ sender: UIRefreshControl) {
        self.createServiceToFetchUsersData()
    }
    
    func addNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidEnterForground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(triggerTodoUpdateFromNotification(_:)), name: NSNotification.Name(rawValue: Notifications.dashboardToDoUpdate), object: nil)
    }
    
    func removeNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Notifications.dashboardToDoUpdate), object: nil)
    }
    
    @objc func applicationDidEnterForground() {
        if self.viewCustomToDoListContainer.buttonSlider.isSelected {
            self.showCard(expanded: false, isAnimated: false)
        }
    }
    
    @objc func triggerTodoUpdateFromNotification(_ notification: Notification) {
        self.showAllTodoCategoriesValues()
    }
    
    func showAllTodoCategoriesValues() {
        self.viewMenus.forEach({ $0.showLoader() })
        self.viewCustomToDoListContainer.toDoCategories = DataBasePlanItTodoCategory().readAllAvailableUserToDoCategory()
        let databasePlanItTodo = DataBasePlanItTodo()
        databasePlanItTodo.readAllAvailableTodosUsingQueue(result: { allTodos in
            self.manageTodoMainCategories(using: allTodos, converter: databasePlanItTodo, completion: { categorizedTodo in
                guard let category = categorizedTodo.first, let viewIndex = self.viewMenus.firstIndex(where: { $0.mainCategory == category.key }) else { return }
                self.viewMenus[viewIndex].todos = category.value
            })
        })
    }
    
    func checkAnyNotificationListId() {
        guard let listId = self.notificationTodoListId else { return }
        self.notificationTodoListId = nil
        guard let todoCategory = DataBasePlanItTodoCategory().readSpecificToDoCategories([listId]).first, !todoCategory.deletedStatus else { return }
        self.performSegue(withIdentifier: Segues.toCustomCategoryToDoListView, sender: (todoCategory, IndexPath(row: 0, section: 0)))
    }
    
    func manageTodoMainCategories(using allTodos: [PlanItTodo], converter: DataBasePlanItTodo, completion: @escaping ([ToDoMainCategory: [PlanItTodo]]) -> ()) {
        
        let allTabTodos = allTodos.filter({ return !$0.completed || $0.readDeleteStatus() })
        DispatchQueue.main.async {
            let convertedTodos = allTabTodos.compactMap({ return try? converter.mainObjectContext.existingObject(with: $0.objectID) as? PlanItTodo })
            completion([ToDoMainCategory.all: convertedTodos]) }
        
        //Today Todos
        let startDate = Date().initialHour()
        let endDate = Date().initialHour().adding(days: 1).adding(seconds: -1)
        let todayTodos = allTabTodos.filter({ return !$0.completed && !$0.readDeleteStatus() && $0.readTodoAvailableAtTimeRange(from: startDate, to: endDate) })
        DispatchQueue.main.async {
            let convertedTodos = todayTodos.compactMap({ return try? converter.mainObjectContext.existingObject(with: $0.objectID) as? PlanItTodo })
            completion([ToDoMainCategory.today: convertedTodos]) }
        
        //Upcoming Todos
        let upcomingTodos = allTabTodos.filter({ if !$0.isRecurrenceTodo() { if let dueDate = $0.readExactDueDate(), dueDate > endDate { return !$0.completed && !$0.readDeleteStatus() } else { return false } } else { if let dueDate = $0.readRecurrenceEndDate(), dueDate <= endDate { return false } else { return !$0.completed && !$0.readDeleteStatus() } } })
        DispatchQueue.main.async {
            let convertedTodos = upcomingTodos.compactMap({ return try? converter.mainObjectContext.existingObject(with: $0.objectID) as? PlanItTodo })
            completion([ToDoMainCategory.upcomming: convertedTodos]) }
        
        //Favorited Todos
        let favoritedTodos = allTabTodos.filter({ return !$0.completed && !$0.readDeleteStatus() && $0.favourited })
        DispatchQueue.main.async {
            let convertedTodos = favoritedTodos.compactMap({ return try? converter.mainObjectContext.existingObject(with: $0.objectID) as? PlanItTodo })
            completion([ToDoMainCategory.favourite: convertedTodos]) }
        
        //Unplanned Todos
        let unplannedTodos = allTabTodos.filter({ return !$0.completed && !$0.readDeleteStatus() && $0.readExactDueDate() == nil })
        DispatchQueue.main.async {
            let convertedTodos = unplannedTodos.compactMap({ return try? converter.mainObjectContext.existingObject(with: $0.objectID) as? PlanItTodo })
            completion([ToDoMainCategory.unplanned: convertedTodos]) }
        
        //Overdue Todos
        let overdueTodos = allTabTodos.filter({ if !$0.isRecurrenceTodo() { if let dueDate = $0.readExactDueDate(), dueDate < startDate { return !$0.completed && !$0.readDeleteStatus() } else { return false } } else { if let dueDate = $0.readStartDate(using: .overdue), dueDate < startDate { return !$0.completed && !$0.readDeleteStatus() } else { return false } } })
        DispatchQueue.main.async {
            let convertedTodos = overdueTodos.compactMap({ return try? converter.mainObjectContext.existingObject(with: $0.objectID) as? PlanItTodo })
            completion([ToDoMainCategory.overdue: convertedTodos]) }
        
        //AssignedToMe Todos
        let assignedToMeTodos = allTabTodos.filter({ return !$0.completed && !$0.readDeleteStatus() && $0.isAssignedToMeAccepted })
        DispatchQueue.main.async {
            let convertedTodos = assignedToMeTodos.compactMap({ return try? converter.mainObjectContext.existingObject(with: $0.objectID) as? PlanItTodo })
            completion([ToDoMainCategory.assignedToMe: convertedTodos]) }
        
        //Completed Todos
        let completedTodos = allTodos.filter({ return !$0.readDeleteStatus() && $0.completed })
        DispatchQueue.main.async {
            let convertedTodos = completedTodos.compactMap({ return try? converter.mainObjectContext.existingObject(with: $0.objectID) as? PlanItTodo })
            completion([ToDoMainCategory.completed: convertedTodos]) }
        
        //AssignedByMe Todos
        let assignedByMeTodos = allTabTodos.filter({ return !$0.completed && !$0.readDeleteStatus() && $0.isAssignedByMe })
        DispatchQueue.main.async {
            let convertedTodos = assignedByMeTodos.compactMap({ return try? converter.mainObjectContext.existingObject(with: $0.objectID) as? PlanItTodo })
            completion([ToDoMainCategory.assignedbyMe: convertedTodos]) }
    }
    
    //PAN Gesture
    func getNormalOffsetHeight() -> CGFloat {
        return (UIApplication.shared.keyWindow?.frame.size.width)! + 10
    }
    
    func createPanGestureRecognizer() {
        let panGesture = UIPanGestureRecognizer(target: self, action:(#selector(self.handleSwipeGesture)))
        panGesture.delaysTouchesBegan = false
        panGesture.delaysTouchesEnded = false
        panGesture.delegate = self
        self.viewCustomToDoListContainer.addGestureRecognizer(panGesture)
        self.constraintToDoListViewTop.constant = self.getNormalOffsetHeight()
    }
    
    @objc func handleSwipeGesture(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: self.view)
        switch sender.state {
        case .began:
          self.toDoStartingTopConstant = self.constraintToDoListViewTop.constant
        case .changed :
          if self.toDoStartingTopConstant + translation.y > 30.0 && self.constraintToDoListViewTop.constant <= self.getNormalOffsetHeight() {
            self.constraintToDoListViewTop.constant = self.toDoStartingTopConstant + translation.y
          }
        case .ended :
          if let safeAreaHeight = UIApplication.shared.keyWindow?.safeAreaLayoutGuide.layoutFrame.size.height,
            let bottomPadding = UIApplication.shared.keyWindow?.safeAreaInsets.bottom {
            if self.constraintToDoListViewTop.constant < (safeAreaHeight + bottomPadding) * 0.25 || translation.y < -80.0 {
                self.showCard(expanded: true)
            } else if self.constraintToDoListViewTop.constant < (safeAreaHeight) - 70 || translation.y > 100.0 {
                self.showCard(expanded: false)
            }
          }
        default:
          break
        }
    }
    
    func showCard(expanded: Bool, isAnimated: Bool = true) {
        self.view.layoutIfNeeded()
        if expanded {
            self.constraintToDoListViewTop.constant = 10.0
            self.viewCustomToDoListContainer.buttonSlider.isSelected = true
        } else {
            self.constraintToDoListViewTop.constant = self.getNormalOffsetHeight()
            self.viewCustomToDoListContainer.buttonSlider.isSelected = false
        }
        self.toDoStartingTopConstant = self.constraintToDoListViewTop.constant
        if isAnimated {
            let showCard = UIViewPropertyAnimator(duration: 0.25, curve: .easeIn, animations: {
                self.view.layoutIfNeeded()
            })
            showCard.startAnimation()
        }
        else {
            self.view.layoutIfNeeded()
        }
    }
    
    func printToDos(_ category: PlanItTodoCategory) {
        if category.readAllAvailableMainTodos().count > 0 {
            var html = "<!DOCTYPE html><html><meta charset=\"UTF-8\"><head><title>To Do List</title><style>body {background-color: white;text-align: center;color: black;font-family: Arial, Helvetica, sans-serif;}li.style1 {text-align: left;font-size: 15px;font-weight: bold;line-height: 25px}li.style2 {text-align: left;font-size: 13px;line-height: 25px}hr.newstyle {border-top: 1px dashed black;} span.style1 {text-align: left;font-size: 12px;line-height: 15px;color:gray;}span.style2 {text-align: left;font-size: 14px;line-height: 15px;color:black;}h2.style1 {text-align: left;}</style></head><body>"
            if let filepath = Bundle.main.path(forResource: "base64image", ofType: "txt") {
                do {
                    let contents = try String(contentsOfFile: filepath)
                    html.append("<p><img src=\"data:image/jpg;base64, \(contents)\" alt=\"Logo Image\" width=\"40\" height=\"40\" /></p>")
                    
                } catch {
                    // contents could not be loaded
                }
            }
            html.append("<h1><u>\(category.categoryName ?? Strings.unavailable) </u></h1>")
            if let sharedBy = category.readSharedByUser(), sharedBy.readValueOfUserId() != Session.shared.readUserId() {
                html.append("<h2 class = 'style1'> Shared By: \(sharedBy.fullName ?? Strings.empty)</h2>")
            }
            html.append("<ul>")
            let sortedToDo = category.readAllAvailableMainTodos().sorted(by: { return $0.readOrderUsingOrderDateOrStartDate() < $1.readOrderUsingOrderDateOrStartDate() })
            for todo in sortedToDo {
                html.append("<li class = 'style1'>\(todo.readToDoTitle())")
                if !todo.readDueDate().isEmpty {
                    html.append("  [\(todo.readStartDate(using: .custom)?.stringFromDate(format: DateFormatters.EEEDDMMMYYYY) ?? Strings.empty)]")
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
    
}
