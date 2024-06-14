//
//  TodoService.swift
//  MiPlanIt
//
//  Created by Arun on 11/07/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

class TodoService {
    
    func fetchUsersToDoServerData(_ user: PlanItUser, callback: @escaping (Bool, [ServiceDetection], String?) -> ()) {
        let todoCommand = TodoCommand()
        Session.shared.saveUsersTodoDataFetching(true)
        todoCommand.usersToDoData(["userId": user.readValueOfUserId(), "lastSyncDate": user.readUserSettings().readLastTodoFetchDataTime()], callback: { result, error in
            if let data = result {
                DatabasePlanItData().insertPlanItUserDataForTodo(data, callback: { lastSyncTime, serviceDetection in
                    user.readUserSettings().saveLastTodoFetchDataTime(lastSyncTime)
                    Session.shared.saveUsersTodoDataFetching(false)
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: Notifications.todoUsersDataUpdated), object: serviceDetection)
                    callback(true, serviceDetection, error)
                })
            }
            else {
                Session.shared.saveUsersTodoDataFetching(false)
                callback(false, [], error ?? Message.unknownError)
            }
        })
    }
    
    private func makeBasicParameterForCategory(_ category: PlanItTodoCategory?) -> [String: Any] {
        var params: [String: Any] = [:]
        if let todoCategory = category {
            if !todoCategory.readCategoryId().isEmpty {
                params["toDoListId"] = todoCategory.readCategoryId()
            }
            params["toDoListTitle"] = todoCategory.readCategoryName()
            params["isDeleted"] = todoCategory.deletedStatus
            params["userId"] = Session.shared.readUserId()
            params["appToDoListId"] = todoCategory.readAppsToServerId()
            let invitees = todoCategory.readAllCategoryInvitees()
            if invitees.isEmpty {
                params["invitees"] = [["userId": Session.shared.readUserId()]]
            }
            else {
                params["invitees"] = invitees.map({ return !$0.readValueOfUserId().isEmpty ? ["userId": $0.userId] : !$0.readValueOfEmail().isEmpty ? ["email": $0.readValueOfEmail(), "fullName": $0.readValueOfFullName()] : ["phone": $0.readValueOfPhone(), "fullName": $0.readValueOfFullName(), "countryCode": $0.readValueOfCountryCode()] })
            }
        }
        else {
            params["userId"] = Session.shared.readUserId()
            params["isDeleted"] = false
            params["invitees"] = [["userId": Session.shared.readUserId()]]
        }
        return params
    }
    
    func sendPendingTodoCategoriesToServer(_ categories: [PlanItTodoCategory], callback: @escaping () -> ()) {
        var params: [String: Any] = [:]
        var updatedCategories: [[String: Any]] = []
        var insertedCategories: [[String: Any]] = []
        categories.forEach({  if $0.readCategoryId().isEmpty { insertedCategories.append(self.makeBasicParameterForCategory($0)) } else { updatedCategories.append(self.makeBasicParameterForCategory($0)) } })
        if !updatedCategories.isEmpty { params["updateTodoList"] = updatedCategories }
        if !insertedCategories.isEmpty { params["insertTodoList"] = insertedCategories }
        let todoCommand = TodoCommand()
        todoCommand.addEditCategory(params, callback: { response, error in
            if let result = response, let serverCategories = result["toDoList"] as? [[String: Any]] {
                categories.forEach({ $0.isPending = false })
                DataBasePlanItTodoCategory().insertNewPlanItToDoCategory(serverCategories)
                callback()
            }
            else {
                callback()
            }
        })
    }
    
    func addEditTodoCategory(_ category: PlanItTodoCategory?, name: String, callback: @escaping (PlanItTodoCategory?, String?) -> ()) {
        var categoryParams = self.makeBasicParameterForCategory(category)
        categoryParams["toDoListTitle"] = name
        var params: [String: Any] = [:]
        if let _ = category { params["updateTodoList"] = [categoryParams] }
        else { params["insertTodoList"] = [categoryParams] }
        let todoCommand = TodoCommand()
        todoCommand.addEditCategory(params, callback: { response, error in
            if let result = response, let categories = result["toDoList"] as? [[String: Any]] {
               let insertedCategories = DataBasePlanItTodoCategory().insertNewPlanItToDoCategory(categories)
                callback(insertedCategories.first, nil)
            }
            else {
                callback(nil, error ?? Message.unknownError)
            }
        })
    }
    
    func shareTodoCategory(_ category: PlanItTodoCategory?, invitees: [OtherUser], callback: @escaping (PlanItTodoCategory?, String?) -> ()) {
        var categoryParams = self.makeBasicParameterForCategory(category)
        var sharedUsers: [[String: Any]] = invitees.map({ return !$0.userId.isEmpty ? ["userId": $0.userId] : !$0.email.isEmpty ? ["email": $0.email, "fullName": $0.fullName] : ["phone": $0.phone, "fullName": $0.fullName, "countryCode": $0.countryCode] })
        sharedUsers.append(["userId": Session.shared.readUserId()])
        categoryParams["invitees"] = sharedUsers
        var params: [String: Any] = [:]
        if let _ = category { params["updateTodoList"] = [categoryParams] }
        else { params["insertTodoList"] = [categoryParams] }
        let todoCommand = TodoCommand()
        todoCommand.addEditCategory(params, callback: { response, error in
            if let result = response, let categories = result["toDoList"] as? [[String: Any]] {
                let insertedCategories = DataBasePlanItTodoCategory().insertNewPlanItToDoCategory(categories)
                callback(insertedCategories.first, nil)
            }
            else {
                callback(nil, error ?? Message.unknownError)
            }
        })
    }
    
    func deleteTodoCategory(_ category: PlanItTodoCategory?, callback: @escaping (PlanItTodoCategory?, Bool?, String?) -> ()) {
        var categoryParams = self.makeBasicParameterForCategory(category)
        if let creator = category?.createdBy, creator.readValueOfUserId() != Session.shared.readUserId() {
            categoryParams["isRemoved"] = true
        }
        else {
            categoryParams["isDeleted"] = true
        }
        var params: [String: Any] = [:]
        if let _ = category { params["updateTodoList"] = [categoryParams] }
        else { params["insertTodoList"] = [categoryParams] }
        let todoCommand = TodoCommand()
        todoCommand.addEditCategory(params, callback: { response, error in
            if let result = response {
                if let creator = category?.createdBy, creator.readValueOfUserId() != Session.shared.readUserId(), let deletedToDoLists = result["deletedToDoLists"] as? [Double], !deletedToDoLists.isEmpty {
                    DataBasePlanItTodoCategory().removedPlantItCategories(deletedToDoLists)
                    callback(nil, true, nil)
                }
                else if let categories = result["toDoList"] as? [[String: Any]] {
                    category?.readAllTodos().forEach({$0.deletedStatus = true})
                    let insertedCategories = DataBasePlanItTodoCategory().insertNewPlanItToDoCategory(categories)
                    Session.shared.registerUserTodoLocationNotification()
                    callback(insertedCategories.first, nil, nil)
                }
            }
            else {
                callback(nil, nil, error ?? Message.unknownError)
            }
        })
    }
    
    private func makeBasicParameterForTodo(_ todo: PlanItTodo, category: PlanItTodoCategory) -> [String: Any] {
        var todoParams: [String: Any] = ["toDoListId": category.readCategoryId(), "userId": Session.shared.readUserId(), "title": todo.readToDoTitle(), "isCompleted": todo.completed, "isFavourite": todo.favourited, "notes": todo.readNotes(), "isDeleted": todo.deletedStatus, "recurrenceToDoId": todo.readRecurrenceToDoId(), "tags": todo.readAllTags().compactMap({ return $0.tag}), "assignees": todo.readAllInvitees().map({ return !$0.readValueOfUserId().isEmpty ? ["userId": $0.userId] : !$0.readValueOfEmail().isEmpty ? ["email": $0.readValueOfEmail(), "fullName": $0.readValueOfFullName()] : ["phone": $0.readValueOfPhone(), "fullName": $0.readValueOfFullName(), "countryCode": $0.readValueOfCountryCode()] }), "attachments": todo.readAllAttachments().compactMap({ return $0.isPending ? nil : $0.readAttachmentId()})]
        if !todo.readTodoId().isEmpty {
            todoParams["toDoId"] = todo.readTodoId()
        }
        else {
            todoParams["appToDoId"] = todo.readAppTodoId()
        }
        if let startDate = todo.readExactDueDate()?.stringFromDate(format: DateFormatters.YYYYHMMMHDD) {
            todoParams["dueDate"] = startDate
        }
        if let rule = todo.recurrence?.readRule(), !rule.isEmpty {
            todoParams["recurrence"] = [rule]
        }
        if let originalStartDate = todo.readOriginalStartDate()?.stringFromDate(format: DateFormatters.YYYYHMMMHDD) {
            todoParams["originalStartDate"] = originalStartDate
        }
        let subTask: [[String: Any]] = todo.readAllSubTodos().map({
            var subTodoParams: [String: Any] = ["taskTitle": $0.readSubToDoTitle(), "isDeleted": $0.deletedStatus, "isCompleted": $0.completed]
            if !todo.readTodoId().isEmpty { subTodoParams["toDoId"] = todo.readTodoId() }
            if !$0.readSubToDoId().isEmpty { subTodoParams["subTaskId"] = $0.readSubToDoId() }
            return subTodoParams
        })
        todoParams["subTask"] = subTask
        if let reminderParam = todo.reminder?.readReminderNumericValueParameter() {
            todoParams["reminders"] = reminderParam
        }
        return todoParams
    }
    
    func sendPendingTodosToServer(_ todos: [PlanItTodo], callback: @escaping () -> ()) {
        var updatedTodos: [[String: Any]] = []
        var insertedTodos: [[String: Any]] = []
        todos.forEach({
            if let category = $0.readTodoCategory() {
               if $0.readTodoId().isEmpty { insertedTodos.append(self.makeBasicParameterForTodo($0, category: category)) } else { updatedTodos.append(self.makeBasicParameterForTodo($0, category: category)) }
            }
        })
        var params: [String: Any] = [:]
        if !updatedTodos.isEmpty { params["updateTodo"] = updatedTodos }
        if !insertedTodos.isEmpty { params["insertTodo"] = insertedTodos }
        let todoCommand = TodoCommand()
        todoCommand.addEditTodos(params, callback: { response, error in
            if let result = response, let planItTodos = result["toDo"] as? [[String: Any]] {
                DataBasePlanItTodo().insertPlanItTodos(planItTodos, hardSave: true)
                Session.shared.registerUserTodoLocationNotification()
                callback()
            }
            else {
                callback()
            }
        })
    }
    
    func addEditTodos(_ todos: [PlanItTodo], category: PlanItTodoCategory, callback: @escaping (Bool?, String?) -> ()) {
        var updatedTodos: [[String: Any]] = []
        var insertedTodos: [[String: Any]] = []
        todos.forEach({  if $0.readTodoId().isEmpty { insertedTodos.append(self.makeBasicParameterForTodo($0, category: category)) } else { updatedTodos.append(self.makeBasicParameterForTodo($0, category: category)) } })
        var params: [String: Any] = [:]
        if !updatedTodos.isEmpty { params["updateTodo"] = updatedTodos }
        if !insertedTodos.isEmpty { params["insertTodo"] = insertedTodos }
        let todoCommand = TodoCommand()
        todoCommand.addEditTodos(params, callback: { response, error in
            if let result = response, let planItTodos = result["toDo"] as? [[String: Any]] {
                DataBasePlanItTodo().insertPlanItTodos(planItTodos, to: category, hardSave: true)
                Session.shared.registerUserTodoLocationNotification()
                callback(true, nil)
            }
            else {
                callback(nil, error ?? Message.unknownError)
            }
        })
    }
    
    func editTodo(_ todo: PlanItTodo, name: String, category: PlanItTodoCategory, callback: @escaping (Bool?, String?) -> ()) {
        var updatedTodos: [[String: Any]] = []
        var insertedTodos: [[String: Any]] = []
        var todoParam = self.makeBasicParameterForTodo(todo, category: category)
        todoParam["title"] = name
        if todo.readTodoId().isEmpty { insertedTodos.append(todoParam) } else { updatedTodos.append(todoParam) }
        var params: [String: Any] = [:]
        if !updatedTodos.isEmpty { params["updateTodo"] = updatedTodos }
        if !insertedTodos.isEmpty { params["insertTodo"] = insertedTodos }
        let todoCommand = TodoCommand()
        todoCommand.addEditTodos(params, callback: { response, error in
            if let result = response, let planItTodos = result["toDo"] as? [[String: Any]] {
                DataBasePlanItTodo().insertPlanItTodos(planItTodos, to: category, hardSave: true)
                Session.shared.registerUserTodoLocationNotification()
                callback(true, nil)
            }
            else {
                callback(nil, error ?? Message.unknownError)
            }
        })
    }
    
    func completeTodo(_ todo: PlanItTodo, information: ToDoDetailModel, category: PlanItTodoCategory, type: ToDoMainCategory, with status: Bool, callback: @escaping (Bool?, String?) -> ()) {
        var updatedTodos: [[String: Any]] = []
        var insertedTodos: [[String: Any]] = []
        var todoParams = self.makeBasicParameterForTodo(todo, category: category)
        todoParams["title"] = information.todoName
        todoParams["tags"] = information.tags
        todoParams["notes"] = information.notes
        todoParams["type"] = "complete"
        todoParams["attachments"] = information.attachments.compactMap({ return $0.identifier.isEmpty ? nil : Int($0.identifier) })
        if let date = information.dueDate?.stringFromDate(format: DateFormatters.YYYYHMMMHDD) {
            todoParams["dueDate"] = date
        }
        else {
            todoParams["dueDate"] = Strings.empty
        }
        todoParams["assignees"] = information.assignee.map({ return !$0.userId.isEmpty ? ["userId": $0.userId] : !$0.email.isEmpty ? ["email": $0.email, "fullName": $0.fullName] : ["phone": $0.phone, "fullName": $0.fullName, "countryCode": $0.countryCode] })
        let subTask: [[String: Any]] = information.subToDos.filter({ return !$0.subTodoTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }).map({
            var subTodoParams: [String: Any] = ["taskTitle": $0.subTodoTitle, "isDeleted": $0.deletedStatus, "isCompleted": $0.completed, "toDoId": todo.readTodoId()]
            if !$0.readSubToDoId().isEmpty { subTodoParams["subTaskId"] = $0.readSubToDoId() }
            return subTodoParams
        })
        
        todoParams["subTask"] = subTask
        if let reminderParam = information.remindValue?.readReminderNumericValueParameter() {
            todoParams["reminders"] =  reminderParam
        }
        else {
            todoParams["reminders"] =  nil
        }
        todoParams["recurrence"] = information.recurrence.isEmpty ? [] : [information.recurrence]
        todoParams["isCompleted"] = status
        var readyToCreateChild = false
        if status, todo.isRecurrenceTodo(), let originalStartDate = information.dashboardDueDate ?? todo.readStartDate(using: type)?.initialHour(), todo.isNextOccurrenceAvailableFromDate(originalStartDate.adding(days: 1)) {
            readyToCreateChild = true
            todoParams["toDoId"] = Strings.empty
            todoParams["recurrence"] = []
            todoParams["attachments"] = []
            todoParams["recurrenceToDoId"] = todo.readTodoId()
            todoParams["originalStartDate"] = originalStartDate.stringFromDate(format: DateFormatters.YYYYHMMMHDD)
        }
        if todo.readTodoId().isEmpty || (todo.isRecurrenceTodo() && readyToCreateChild) { insertedTodos.append(todoParams) } else { updatedTodos.append(todoParams) }
        var params: [String: Any] = [:]
        if !updatedTodos.isEmpty { params["updateTodo"] = updatedTodos }
        if !insertedTodos.isEmpty { params["insertTodo"] = insertedTodos }
        let todoCommand = TodoCommand()
        todoCommand.addEditTodos(params, callback: { response, error in
            if let result = response, let planItTodos = result["toDo"] as? [[String: Any]] {
                DataBasePlanItTodo().insertPlanItTodos(planItTodos, to: category, hardSave: true)
                todo.updateToDoCompleteViewStatus(with: status)
                Session.shared.registerUserTodoLocationNotification()
                callback(true, nil)
            }
            else {
                callback(nil, error ?? Message.unknownError)
            }
        })
    }
    
    func editTodo(_ todo: PlanItTodo, information: ToDoDetailModel, category: PlanItTodoCategory, callback: @escaping (Bool?, String?) -> ()) {
        var updatedTodos: [[String: Any]] = []
        var insertedTodos: [[String: Any]] = []
        var todoParams = self.makeBasicParameterForTodo(todo, category: category)
        todoParams["title"] = information.todoName.trimmingCharacters(in: .whitespacesAndNewlines)
        todoParams["tags"] = information.tags
        todoParams["notes"] = information.notes.trimmingCharacters(in: .whitespacesAndNewlines)
        todoParams["attachments"] = information.attachments.compactMap({ return $0.identifier.isEmpty ? nil : Int($0.identifier) })
        if let date = information.dueDate?.stringFromDate(format: DateFormatters.YYYYHMMMHDD) {
            todoParams["dueDate"] = date
        }
        else {
            todoParams["dueDate"] = Strings.empty
        }
        todoParams["assignees"] = information.assignee.map({ return !$0.userId.isEmpty ? ["userId": $0.userId] : !$0.email.isEmpty ? ["email": $0.email, "fullName": $0.fullName] : ["phone": $0.phone, "fullName": $0.fullName, "countryCode": $0.countryCode] })
        let subTask: [[String: Any]] = information.subToDos.filter({ return !$0.subTodoTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }).map({
            var subTodoParams: [String: Any] = ["taskTitle": $0.subTodoTitle, "isDeleted": $0.deletedStatus, "isCompleted": $0.completed, "toDoId": todo.readTodoId()]
            if !$0.readSubToDoId().isEmpty { subTodoParams["subTaskId"] = $0.readSubToDoId() }
            return subTodoParams
        })
        todoParams["subTask"] = subTask
        if let reminderParam = information.remindValue?.readReminderNumericValueParameter() {
            todoParams["reminders"] =  reminderParam
        }
        else {
            todoParams["reminders"] =  nil
        }
        todoParams["recurrence"] = information.recurrence.isEmpty ? [] : [information.recurrence]
        if todo.readTodoId().isEmpty { insertedTodos.append(todoParams) } else { updatedTodos.append(todoParams) }
        var params: [String: Any] = [:]
        if !updatedTodos.isEmpty { params["updateTodo"] = updatedTodos }
        if !insertedTodos.isEmpty { params["insertTodo"] = insertedTodos }
        let todoCommand = TodoCommand()
        todoCommand.addEditTodos(params, callback: { response, error in
            if let result = response, let planItTodos = result["toDo"] as? [[String: Any]] {
                DataBasePlanItTodo().insertPlanItTodos(planItTodos, to: category, hardSave: true)
                Session.shared.registerUserTodoLocationNotification()
                callback(true, nil)
            }
            else {
                callback(nil, error ?? Message.unknownError)
            }
        })
    }
    
    func todoMarkAsRead(_ todos: [PlanItTodo], callback: @escaping (Bool?, String?) -> ()) {
        let markAsRead: [String: Any] = ["userId": Session.shared.readUserId(), "toDoIds": todos.map({ return $0.readTodoId() })]
        let todoCommand = TodoCommand()
        todoCommand.markASRead(["markAsRead": [markAsRead]], callback: { response, error in
            if let result = response, let planItTodos = result["todos"] as? [[String: Any]] {
                DataBasePlanItTodo().markLocalTodosASRead(todos, datas: planItTodos)
                callback(true, nil)
            }
            else {
                callback(nil, error ?? Message.unknownError)
            }
        })
    }
    
    func sendPendingMovedTodos(_ todos: [PlanItTodo], callback: @escaping () -> ()) {
        var moveToDoList: [[String: Any]] = []
        let groupedMovedFrom = Dictionary(grouping: todos, by: { $0.readMovedFrom() })
        for (from, fromValues) in groupedMovedFrom {
            let groupedMovedTo = Dictionary(grouping: fromValues, by: { $0.readCategoryId() })
            for (to, toValues) in groupedMovedTo {
                moveToDoList.append(["userId": Session.shared.readUserId(), "toDoListIdFrom": from, "toDoListIdTo": to, "toDoIds": toValues.map({ return $0.readTodoId() })])
            }
        }
        let todoCommand = TodoCommand()
        todoCommand.moveTodos(["moveToDoList": moveToDoList], callback: { response, error in
            if let result = response, let categories = result["toDoList"] as? [[String: Any]] {
                todos.forEach({ $0.movedFrom = Strings.empty })
                DataBasePlanItTodoCategory().insertNewPlanItToDoCategory(categories)
                callback()
            }
            else {
                callback()
            }
        })
    }
    
    func moveTodos(_ todos: [PlanItTodo], from: PlanItTodoCategory, to: String, callback: @escaping (Bool?, String?) -> ()) {
        let moveToDoList: [String: Any] = ["userId": Session.shared.readUserId(), "toDoListIdFrom": from.readCategoryId(), "toDoListIdTo": to, "toDoIds": todos.map({ return $0.readTodoId() })]
        let todoCommand = TodoCommand()
        todoCommand.moveTodos(["moveToDoList": [moveToDoList]], callback: { response, error in
            if let result = response, let categories = result["toDoList"] as? [[String: Any]] {
                todos.forEach({ $0.movedFrom = Strings.empty })
                DataBasePlanItTodoCategory().insertNewPlanItToDoCategory(categories)
                callback(true, nil)
            }
            else {
                callback(nil, error ?? Message.unknownError)
            }
        })
    }
    
    func restoreTodos(_ todos: [PlanItTodo], from category: PlanItTodoCategory, callback: @escaping (Bool?, String?) -> ()) {
        var updatedTodos: [[String: Any]] = []
        var insertedTodos: [[String: Any]] = []
        todos.forEach({
            var todoParam = self.makeBasicParameterForTodo($0, category: category)
            todoParam["isDeleted"] = false
            if $0.readTodoId().isEmpty { insertedTodos.append(todoParam) } else { updatedTodos.append(todoParam) }
        })
        var params: [String: Any] = [:]
        if !updatedTodos.isEmpty { params["updateTodo"] = updatedTodos }
        if !insertedTodos.isEmpty { params["insertTodo"] = insertedTodos }
        let todoCommand = TodoCommand()
        todoCommand.addEditTodos(params, callback: { response, error in
            if let result = response, let planItTodos = result["toDo"] as? [[String: Any]] {
                category.deletedStatus = false
                DataBasePlanItTodo().insertPlanItTodos(planItTodos, to: category, hardSave: true)
                Session.shared.registerUserTodoLocationNotification()
                callback(true, nil)
            }
            else {
                callback(nil, error ?? Message.unknownError)
            }
        })
    }
    
    func deleteTodos(_ todos: [PlanItTodo], from category: PlanItTodoCategory, callback: @escaping (Bool?, String?) -> ()) {
        var updatedTodos: [[String: Any]] = []
        var insertedTodos: [[String: Any]] = []
        todos.forEach({
            var todoParam = self.makeBasicParameterForTodo($0, category: category)
            todoParam["isDeleted"] = true
            if $0.readTodoId().isEmpty { insertedTodos.append(todoParam) } else { updatedTodos.append(todoParam) }
        })
        var params: [String: Any] = [:]
        if !updatedTodos.isEmpty { params["updateTodo"] = updatedTodos }
        if !insertedTodos.isEmpty { params["insertTodo"] = insertedTodos }
        let todoCommand = TodoCommand()
        todoCommand.addEditTodos(params, callback: { response, error in
            if let result = response, let planItTodos = result["toDo"] as? [[String: Any]] {
                DataBasePlanItTodo().insertPlanItTodos(planItTodos, to: category, hardSave: true)
                Session.shared.registerUserTodoLocationNotification()
                callback(true, nil)
            }
            else {
                callback(nil, error ?? Message.unknownError)
            }
        })
    }
    
    func completeTodos(_ todos: [PlanItTodo], from category: PlanItTodoCategory, type: ToDoMainCategory, with status: Bool, callback: @escaping (Bool?, String?) -> ()) {
        var updatedTodos: [[String: Any]] = []
        var insertedTodos: [[String: Any]] = []
        todos.forEach({
            var todoParam = self.makeBasicParameterForTodo($0, category: category)
            todoParam["isCompleted"] = status
            todoParam["type"] = "complete"
            var readyToCreateChild = false
            if status, $0.isRecurrenceTodo(), let originalStartDate = $0.readStartDate(using: type)?.initialHour(), $0.isNextOccurrenceAvailableFromDate(originalStartDate.adding(days: 1)) {
                readyToCreateChild = true
                todoParam["toDoId"] = Strings.empty
                todoParam["recurrence"] = []
                todoParam["attachments"] = []
                todoParam["recurrenceToDoId"] = $0.readTodoId()
                todoParam["originalStartDate"] = originalStartDate.stringFromDate(format: DateFormatters.YYYYHMMMHDD)
            }
            if $0.readTodoId().isEmpty || ($0.isRecurrenceTodo() && readyToCreateChild) { insertedTodos.append(todoParam) } else { updatedTodos.append(todoParam) }
        })
        var params: [String: Any] = [:]
        if !updatedTodos.isEmpty { params["updateTodo"] = updatedTodos }
        if !insertedTodos.isEmpty { params["insertTodo"] = insertedTodos }
        let todoCommand = TodoCommand()
        todoCommand.addEditTodos(params, callback: { response, error in
            if let result = response, let planItTodos = result["toDo"] as? [[String: Any]] {
                DataBasePlanItTodo().insertPlanItTodos(planItTodos, to: category, hardSave: true)
                todos.forEach({ $0.updateToDoCompleteViewStatus(with: status) })
                Session.shared.registerUserTodoLocationNotification()
                callback(true, nil)
            }
            else {
                callback(nil, error ?? Message.unknownError)
            }
        })
    }
    
    func favouriteTodos(_ todos: [PlanItTodo], from category: PlanItTodoCategory, with status: Bool, callback: @escaping (Bool?, String?) -> ()) {
        var updatedTodos: [[String: Any]] = []
        var insertedTodos: [[String: Any]] = []
        todos.forEach({
            var todoParam = self.makeBasicParameterForTodo($0, category: category)
            todoParam["isFavourite"] = status
            todoParam["type"] = "favourite"
            if $0.readTodoId().isEmpty { insertedTodos.append(todoParam) } else { updatedTodos.append(todoParam) }
        })
        var params: [String: Any] = [:]
        if !updatedTodos.isEmpty { params["updateTodo"] = updatedTodos }
        if !insertedTodos.isEmpty { params["insertTodo"] = insertedTodos }
        let todoCommand = TodoCommand()
        todoCommand.addEditTodos(params, callback: { response, error in
            if let result = response, let planItTodos = result["toDo"] as? [[String: Any]] {
                DataBasePlanItTodo().insertPlanItTodos(planItTodos, to: category, hardSave: true)
                callback(true, nil)
            }
            else {
                callback(nil, error ?? Message.unknownError)
            }
        })
    }
    
    func dueDateTodos(_ todos: [PlanItTodo], from category: PlanItTodoCategory, date: String, callback: @escaping (Bool?, String?) -> ()) {
        var updatedTodos: [[String: Any]] = []
        var insertedTodos: [[String: Any]] = []
        todos.forEach({
            var todoParam = self.makeBasicParameterForTodo($0, category: category)
            todoParam["dueDate"] = date
            if $0.readTodoId().isEmpty { insertedTodos.append(todoParam) } else { updatedTodos.append(todoParam) }
        })
        var params: [String: Any] = [:]
        if !updatedTodos.isEmpty { params["updateTodo"] = updatedTodos }
        if !insertedTodos.isEmpty { params["insertTodo"] = insertedTodos }
        let todoCommand = TodoCommand()
        todoCommand.addEditTodos(params, callback: { response, error in
            if let result = response, let planItTodos = result["toDo"] as? [[String: Any]] {
                DataBasePlanItTodo().insertPlanItTodos(planItTodos, to: category, hardSave: true)
                Session.shared.registerUserTodoLocationNotification()
                callback(true, nil)
            }
            else {
                callback(nil, error ?? Message.unknownError)
            }
        })
    }
    
    func assignUser(_ user: CalendarUser, to todos: [PlanItTodo], category: PlanItTodoCategory, callback: @escaping (Bool?, String?) -> ()) {
        var updatedTodos: [[String: Any]] = []
        var insertedTodos: [[String: Any]] = []
        let localUser: [String: Any] = !user.userId.isEmpty ? ["userId": user.userId] : !user.email.isEmpty ? ["email": user.email, "fullName": user.name] : ["phone": user.phone, "fullName": user.name, "countryCode": user.countryCode]
        todos.forEach({
            var todoParam = self.makeBasicParameterForTodo($0, category: category)
            todoParam["assignees"] = [localUser]
            if $0.readTodoId().isEmpty { insertedTodos.append(todoParam) } else { updatedTodos.append(todoParam) }
        })
        var params: [String: Any] = [:]
        if !updatedTodos.isEmpty { params["updateTodo"] = updatedTodos }
        if !insertedTodos.isEmpty { params["insertTodo"] = insertedTodos }
        let todoCommand = TodoCommand()
        todoCommand.addEditTodos(params, callback: { response, error in
            if let result = response, let planItTodos = result["toDo"] as? [[String: Any]] {
                DataBasePlanItTodo().insertPlanItTodos(planItTodos, to: category, hardSave: true)
                callback(true, nil)
            }
            else {
                callback(nil, error ?? Message.unknownError)
            }
        }) 
    }
    
    func reorderTodos(_ todos: [PlanItTodo], category: PlanItTodoCategory, callback: @escaping (Bool?, String?) -> ()) {
        let orderToDo: [[String: Any]] = todos.map({ return ["toDoId": $0.readTodoId(), "toDoListId": category.readCategoryId(), "userId": Session.shared.readUserId(), "order": $0.readOrderUsingOrderDateOrStartDate().timeIntervalSince1970] })
        let todoCommand = TodoCommand()
        todoCommand.reorderTodos(["orderToDo": orderToDo], callback: { response, error in
            if let status = response {
                callback(status, error)
            }
            else {
                callback(false, error ?? Message.unknownError)
            }
        })
    }
}

class TodoCommand: WSManager {

    func usersToDoData(_ params: [String: Any]?, callback: @escaping (Dictionary<String, Any>?, String?) -> ()) {
        self.get(endPoint: ServiceData.todoFetch, params: params, callback: { response, error in
            if let result = response {
                if let data = result.data as? [[String: Any]], let details = data.first {
                    callback(details, nil)
                }
                else {
                    callback(nil, result.error)
                }
            }
            else {
                callback(nil, error?.message ?? Message.unknownError)
            }
        })
    }
    
    func addEditCategory(_ params: [String: Any]?, callback: @escaping (Dictionary<String, Any>?, String?) -> ()) {
        self.post(endPoint: ServiceData.todoCategory, params: params, callback: { response, error in
            if let result = response {
                if let data = result.data as? [[String: Any]], let details = data.first {
                    callback(details, nil)
                }
                else {
                    callback(nil, result.error)
                }
            }
            else {
                callback(nil, error?.message ?? Message.unknownError)
            }
        })
    }
    
    func addEditTodos(_ params: [String: Any]?, callback: @escaping (Dictionary<String, Any>?, String?) -> ()) {
        self.post(endPoint: ServiceData.todos, params: params, callback: { response, error in
            if let result = response {
                if let data = result.data as? [[String: Any]], let details = data.first {
                    callback(details, nil)
                }
                else {
                    callback(nil, result.error)
                }
            }
            else {
                callback(nil, error?.message ?? Message.unknownError)
            }
        })
    }
    
    func markASRead(_ params: [String: Any]?, callback: @escaping (Dictionary<String, Any>?, String?) -> ()) {
        self.post(endPoint: ServiceData.todoMarkASRead, params: params, callback: { response, error in
            if let result = response {
                if let data = result.data as? [[String: Any]], let details = data.first {
                    callback(details, nil)
                }
                else {
                    callback(nil, result.error)
                }
            }
            else {
                callback(nil, error?.message ?? Message.unknownError)
            }
        })
    }
    
    func moveTodos(_ params: [String: Any]?, callback: @escaping (Dictionary<String, Any>?, String?) -> ()) {
        self.post(endPoint: ServiceData.todoMove, params: params, callback: { response, error in
            if let result = response {
                if let data = result.data as? [[String: Any]], let details = data.first {
                    callback(details, nil)
                }
                else {
                    callback(nil, result.error)
                }
            }
            else {
                callback(nil, error?.message ?? Message.unknownError)
            }
        })
    }
    
    func reorderTodos(_ params: [String: Any]?, callback: @escaping (Bool?, String?) -> ()) {
        self.post(endPoint: ServiceData.todoReOrder, params: params, callback: { response, error in
            if let result = response {
                callback(result.isSuccessful(), result.error)
            }
            else {
                callback(false, error?.message ?? Message.unknownError)
            }
        })
    }
}
