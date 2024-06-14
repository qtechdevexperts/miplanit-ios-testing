//
//  DataBasePlanItTodo.swift
//  MiPlanIt
//
//  Created by Arun on 06/07/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation
import CoreData

class DataBasePlanItTodo: DataBaseManager {
    
    @discardableResult func insertPlanItTodos(_ data: [[String: Any]], to category: PlanItTodoCategory, hardSave: Bool = false, using context: NSManagedObjectContext? = nil) -> [PlanItTodo] {
        var addedTodo: [PlanItTodo] = []
        let objectContext = context ?? self.mainObjectContext
        let localTodos = category.readAllMainTodos()
        for todo in data {
            let todoId = todo["toDoId"] as? Double ?? 0
            let appTodoId = todo["appToDoId"] as? String ?? Strings.empty
            let movedTodo = self.readMovedItem(todo["movedToDoId"] as? Double, using: objectContext)
            let todoEntity = movedTodo ?? localTodos.filter({ return ($0.todoId == todoId && todoId != 0) || ($0.appToDoId == appTodoId && !appTodoId.isEmpty) }).first ?? self.insertNewRecords(Table.planItTodo, context: objectContext) as! PlanItTodo
            if let movedItem = movedTodo, movedItem.isPending {
                todoEntity.todoId = todoId
                todoEntity.appToDoId = appTodoId
                todoEntity.todoCategory = category
                addedTodo.append(todoEntity)
                continue
            }
            todoEntity.notifiedDate = nil
            todoEntity.remindMe = LocalNotificationType.new.rawValue
            todoEntity.isPending = false
            todoEntity.isRecurrence = false
            todoEntity.isAssignedByMe = false
            todoEntity.isAssignedToMe = false
            todoEntity.isAssignedToMeAccepted = false
            todoEntity.subTodosCount = Strings.empty
            todoEntity.attachmentsCount = Strings.empty
            todoEntity.todoName = todo["title"] as? String
            todoEntity.note = todo["notes"] as? String
            todoEntity.completed = todo["isCompleted"] as? Bool ?? false
            todoEntity.favourited = todo["isFavourite"] as? Bool ?? false
            todoEntity.deletedStatus = todo["isDeleted"] as? Bool ?? false
            todoEntity.toDoStatus = todo["toDoStatus"] as? Double ?? 0
            todoEntity.reminderId = todo["reminderId"] as? Double ?? 0
            todoEntity.todoId = todoId
            todoEntity.appToDoId = appTodoId
            todoEntity.todoCategory = category
            todoEntity.user = category.user
            todoEntity.deleteSubTodos()
            if let recurrenceToDoId = todo["recurrenceToDoId"] as? Double {
                todoEntity.recurrenceToDoId = recurrenceToDoId.cleanValue()
            }
            if let date = todo["dueDate"] as? String {
                todoEntity.dueDate = date.stringToDate(formatter: DateFormatters.MMDDYYYY)
            }
            else {
                todoEntity.dueDate = nil
            }
            if let date = todo["originalStartDate"] as? String {
                todoEntity.originalStartDate = date.stringToDate(formatter: DateFormatters.MMDDYYYY)
            }
            else {
                todoEntity.originalStartDate = nil
            }
            if let date = todo["createdAt"] as? String {
                todoEntity.createdAt = date.stringToDate(formatter: DateFormatters.MMDDYYYYHMMSSA, timeZone: TimeZone(abbreviation: "UTC")!)
            }
            if let date = todo["modifiedAt"] as? String {
                todoEntity.modifiedAt = date.stringToDate(formatter: DateFormatters.MMDDYYYYHMMSSA, timeZone: TimeZone(abbreviation: "UTC")!)
            }
            if let order = todo["order"] as? Double, order != 0 {
                todoEntity.order = Date(timeIntervalSince1970: order)
            }
            if let recurrence = todo["recurrence"] as? [String], let rule = recurrence.first {
                DatabasePlanItTodoRecurrence().insertTodo(todoEntity, recurrence: rule, using: objectContext)
            }
            else {
                todoEntity.deleteRecurrence(withHardSave: false)
            }
            if let createdBy = todo["createdBy"] as? [String: Any] {
                DatabasePlanItCreator().insertTodo(todoEntity, creator: createdBy, using: objectContext)
            }
            if let modifiedBy = todo["modifiedBy"] as? [String: Any] {
                DatabasePlanItModifier().insertTodo(todoEntity, modifier: modifiedBy, using: objectContext)
            }
            if let tags = todo["tags"] as? [[String: String]] {
                let arrayTags = tags.compactMap({$0.values.first})
                DatabasePlanItTags().insertTags(arrayTags, for: todoEntity, using: objectContext)
            }
            if let attachments = todo["attachments"] as? [[String: Any]] {
                DatabasePlanItUserAttachment().insertAttachments(attachments, for: todoEntity, using: objectContext)
            }
            if let assignees = todo["assignees"] as? [[String: Any]] {
                DatabasePlanItInvitees().insertTodo(todoEntity, main: assignees, using: objectContext)
            }
            if let nonRegAssignees = todo["nonRegAssignees"] as? [[String: Any]] {
                DatabasePlanItInvitees().insertTodo(todoEntity, other: nonRegAssignees, using: objectContext)
            }
            if let subTasks = todo["subTasks"] as? [[String: Any]] {
                DatabasePlanItSubTodo().insertPlanItSubTodos(subTasks, to: todoEntity, using: objectContext)
            }
            if let child = todo["child"] as? [[String: Any]] {
                self.insertPlanItChildTodos(child, to: todoEntity, using: objectContext)
            }
            if let deletedSubTask = todo["deletedSubTasks"] as? [Double] {
                todoEntity.deleteSubTodos(deletedSubTask)
            }
            if let reminders = todo["reminders"] as? [String: Any] {
                DataBasePlanItTodoReminders().insertTodo(todoEntity, reminders: reminders, using: objectContext)
            }
            else {
                todoEntity.deleteReminder(withHardSave: false)
            }
            addedTodo.append(todoEntity)
        }
        if hardSave { try? objectContext.save() }
        return addedTodo
    }
    
    func insertPlanItChildTodos(_ data: [[String: Any]], to parent: PlanItTodo, hardSave: Bool = false, using context: NSManagedObjectContext? = nil) {
        let localTodos = parent.readAllChildTodos()
        let objectContext = context ?? self.mainObjectContext
        for todo in data {
            let todoId = todo["toDoId"] as? Double ?? 0
            let appTodoId = todo["appToDoId"] as? String ?? Strings.empty
            let movedTodo = self.readMovedItem(todo["movedToDoId"] as? Double, using: objectContext)
            let todoEntity = movedTodo ?? localTodos.filter({ return ($0.todoId == todoId && todoId != 0) || ($0.appToDoId == appTodoId && !appTodoId.isEmpty) }).first ?? self.insertNewRecords(Table.planItTodo, context: objectContext) as! PlanItTodo
            if let movedItem = movedTodo, movedItem.isPending {
                todoEntity.todoId = todoId
                todoEntity.appToDoId = appTodoId
                todoEntity.parent = parent
                continue
            }
            todoEntity.notifiedDate = nil
            todoEntity.remindMe = LocalNotificationType.new.rawValue
            todoEntity.isPending = false
            todoEntity.isRecurrence = false
            todoEntity.isAssignedByMe = false
            todoEntity.isAssignedToMe = false
            todoEntity.isAssignedToMeAccepted = false
            todoEntity.subTodosCount = Strings.empty
            todoEntity.attachmentsCount = Strings.empty
            todoEntity.todoName = todo["title"] as? String
            todoEntity.note = todo["notes"] as? String
            todoEntity.completed = todo["isCompleted"] as? Bool ?? false
            todoEntity.favourited = todo["isFavourite"] as? Bool ?? false
            todoEntity.deletedStatus = todo["isDeleted"] as? Bool ?? false
            todoEntity.toDoStatus = todo["toDoStatus"] as? Double ?? 0
            todoEntity.reminderId = todo["reminderId"] as? Double ?? 0
            if todoEntity.completed {
                todoEntity.overdueViewStatus = true
            }
            todoEntity.todoId = todoId
            todoEntity.appToDoId = appTodoId
            todoEntity.parent = parent
            todoEntity.user = parent.user
            todoEntity.deleteSubTodos()
            if let recurrenceToDoId = todo["recurrenceToDoId"] as? Double {
                todoEntity.recurrenceToDoId = recurrenceToDoId.cleanValue()
            }
            if let date = todo["dueDate"] as? String {
                todoEntity.dueDate = date.stringToDate(formatter: DateFormatters.MMDDYYYY)
            }
            else {
                todoEntity.dueDate = nil
            }
            if let date = todo["originalStartDate"] as? String {
                todoEntity.originalStartDate = date.stringToDate(formatter: DateFormatters.MMDDYYYY)
            }
            if let date = todo["createdAt"] as? String {
                todoEntity.createdAt = date.stringToDate(formatter: DateFormatters.MMDDYYYYHMMSSA, timeZone: TimeZone(abbreviation: "UTC")!)
            }
            if let date = todo["modifiedAt"] as? String {
                todoEntity.modifiedAt = date.stringToDate(formatter: DateFormatters.MMDDYYYYHMMSSA, timeZone: TimeZone(abbreviation: "UTC")!)
            }
            if let createdBy = todo["createdBy"] as? [String: Any] {
                DatabasePlanItCreator().insertTodo(todoEntity, creator: createdBy, using: objectContext)
            }
            if let modifiedBy = todo["modifiedBy"] as? [String: Any] {
                DatabasePlanItModifier().insertTodo(todoEntity, modifier: modifiedBy, using: objectContext)
            }
            if let order = todo["order"] as? Double, order != 0 {
                todoEntity.order = Date(timeIntervalSince1970: order)
            }
            if let tags = todo["tags"] as? [[String: String]] {
                let arrayTags = tags.compactMap({$0.values.first})
                DatabasePlanItTags().insertTags(arrayTags, for: todoEntity, using: objectContext)
            }
            if let attachments = todo["attachments"] as? [[String: Any]] {
                DatabasePlanItUserAttachment().insertAttachments(attachments, for: todoEntity, using: objectContext)
            }
            if let assignees = todo["assignees"] as? [[String: Any]] {
                DatabasePlanItInvitees().insertTodo(todoEntity, main: assignees, using: objectContext)
            }
            if let nonRegAssignees = todo["nonRegAssignees"] as? [[String: Any]] {
                DatabasePlanItInvitees().insertTodo(todoEntity, other: nonRegAssignees, using: objectContext)
            }
            if let subTasks = todo["subTasks"] as? [[String: Any]] {
                DatabasePlanItSubTodo().insertPlanItSubTodos(subTasks, to: todoEntity, using: objectContext)
            }
            if let deletedSubTask = todo["deletedSubTasks"] as? [Double] {
                todoEntity.deleteSubTodos(deletedSubTask)
            }
            if let reminders = todo["reminders"] as? [String: Any] {
                DataBasePlanItTodoReminders().insertTodo(todoEntity, reminders: reminders, using: objectContext)
            }
            else {
                todoEntity.deleteReminder(withHardSave: false)
            }
        }
        if hardSave { try? objectContext.save() }
    }
    
    func insertPlanItTodos(_ data: [[String: Any]], hardSave: Bool = false, using context: NSManagedObjectContext? = nil) {
        let objectContext = context ?? self.mainObjectContext
        let localTodos = self.readTodoWithIds(todos: data, using: objectContext)
        for todo in data {
            let todoId = todo["toDoId"] as? Double ?? 0
            let appTodoId = todo["appToDoId"] as? String ?? Strings.empty
            let movedTodo = self.readMovedItem(todo["movedToDoId"] as? Double, using: objectContext)
            let todoEntity = movedTodo ?? localTodos.filter({ return ($0.todoId == todoId && todoId != 0) || ($0.appToDoId == appTodoId && !appTodoId.isEmpty) }).first ?? self.insertNewRecords(Table.planItTodo, context: objectContext) as! PlanItTodo
            if let movedItem = movedTodo, movedItem.isPending {
                todoEntity.todoId = todoId
                todoEntity.appToDoId = appTodoId
                continue
            }
            todoEntity.notifiedDate = nil
            todoEntity.remindMe = LocalNotificationType.new.rawValue
            todoEntity.isPending = false
            todoEntity.isRecurrence = false
            todoEntity.isAssignedByMe = false
            todoEntity.isAssignedToMe = false
            todoEntity.isAssignedToMeAccepted = false
            todoEntity.subTodosCount = Strings.empty
            todoEntity.attachmentsCount = Strings.empty
            todoEntity.todoName = todo["title"] as? String
            todoEntity.note = todo["notes"] as? String
            todoEntity.completed = todo["isCompleted"] as? Bool ?? false
            todoEntity.favourited = todo["isFavourite"] as? Bool ?? false
            todoEntity.deletedStatus = todo["isDeleted"] as? Bool ?? false
            todoEntity.toDoStatus = todo["toDoStatus"] as? Double ?? 0
            todoEntity.reminderId = todo["reminderId"] as? Double ?? 0
            todoEntity.todoId = todoId
            todoEntity.appToDoId = appTodoId
            todoEntity.deleteSubTodos()
            if let recurrenceToDoId = todo["recurrenceToDoId"] as? Double {
                todoEntity.recurrenceToDoId = recurrenceToDoId.cleanValue()
            }
            if let date = todo["dueDate"] as? String {
                todoEntity.dueDate = date.stringToDate(formatter: DateFormatters.MMDDYYYY)
            }
            else {
                todoEntity.dueDate = nil
            }
            if let date = todo["originalStartDate"] as? String {
                todoEntity.originalStartDate = date.stringToDate(formatter: DateFormatters.MMDDYYYY)
            }
            else {
                todoEntity.originalStartDate = nil
            }
            if let date = todo["createdAt"] as? String {
                todoEntity.createdAt = date.stringToDate(formatter: DateFormatters.MMDDYYYYHMMSSA, timeZone: TimeZone(abbreviation: "UTC")!)
            }
            if let date = todo["modifiedAt"] as? String {
                todoEntity.modifiedAt = date.stringToDate(formatter: DateFormatters.MMDDYYYYHMMSSA, timeZone: TimeZone(abbreviation: "UTC")!)
            }
            if let order = todo["order"] as? Double, order != 0 {
                todoEntity.order = Date(timeIntervalSince1970: order)
            }
            if let recurrence = todo["recurrence"] as? [String], let rule = recurrence.first {
                DatabasePlanItTodoRecurrence().insertTodo(todoEntity, recurrence: rule, using: objectContext)
            }
            else {
                todoEntity.deleteRecurrence(withHardSave: false)
            }
            if let createdBy = todo["createdBy"] as? [String: Any] {
                DatabasePlanItCreator().insertTodo(todoEntity, creator: createdBy, using: objectContext)
            }
            if let modifiedBy = todo["modifiedBy"] as? [String: Any] {
                DatabasePlanItModifier().insertTodo(todoEntity, modifier: modifiedBy, using: objectContext)
            }
            if let tags = todo["tags"] as? [[String: String]] {
                let arrayTags = tags.compactMap({$0.values.first})
                DatabasePlanItTags().insertTags(arrayTags, for: todoEntity, using: objectContext)
            }
            if let attachments = todo["attachments"] as? [[String: Any]] {
                DatabasePlanItUserAttachment().insertAttachments(attachments, for: todoEntity, using: objectContext)
            }
            if let assignees = todo["assignees"] as? [[String: Any]] {
                DatabasePlanItInvitees().insertTodo(todoEntity, main: assignees, using: objectContext)
            }
            if let nonRegAssignees = todo["nonRegAssignees"] as? [[String: Any]] {
                DatabasePlanItInvitees().insertTodo(todoEntity, other: nonRegAssignees, using: objectContext)
            }
            if let subTasks = todo["subTasks"] as? [[String: Any]] {
                DatabasePlanItSubTodo().insertPlanItSubTodos(subTasks, to: todoEntity, using: objectContext)
            }
            if let child = todo["child"] as? [[String: Any]] {
                self.insertPlanItChildTodos(child, to: todoEntity, using: objectContext)
            }
            if let deletedSubTask = todo["deletedSubTasks"] as? [Double] {
                todoEntity.deleteSubTodos(deletedSubTask)
            }
            if let reminders = todo["reminders"] as? [String: Any] {
                DataBasePlanItTodoReminders().insertTodo(todoEntity, reminders: reminders, using: objectContext)
            }
            else {
                todoEntity.deleteReminder(withHardSave: false)
            }
        }
        if hardSave { try? objectContext.save() }
    }
    
    func insertNewTodo(_ todo: String, to category: PlanItTodoCategory?) -> PlanItTodo {
        let todoEntity = self.insertNewRecords(Table.planItTodo, context: self.mainObjectContext) as! PlanItTodo
        todoEntity.isOwner = true
        DatabasePlanItTags().insertTags(["To Do"], for: todoEntity, using: self.mainObjectContext)
        todoEntity.isPending = true
        todoEntity.appToDoId = UUID().uuidString
        todoEntity.todoName = todo
        todoEntity.todoCategory = category
        todoEntity.user = category?.user
        self.mainObjectContext.saveContext()
        return todoEntity
    }
    
    func insertNewChildTodo(parent: PlanItTodo, hardSave: Bool = false) -> PlanItTodo {
        let todoEntity = self.insertNewRecords(Table.planItTodo, context: self.mainObjectContext) as! PlanItTodo
        todoEntity.isOwner = true
        todoEntity.isPending = true
        todoEntity.appToDoId = UUID().uuidString
        todoEntity.parent = parent
        todoEntity.recurrenceToDoId = parent.todoId.cleanValue()
        if hardSave { self.mainObjectContext.saveContext() }
        return todoEntity
    }
    
    func readMovedItem(_ itemId: Double?, using context: NSManagedObjectContext? = nil) -> PlanItTodo? {
        if let todoId = itemId, todoId != 0 {
            return self.readTodoWithId(todoId: todoId, using: context).first
        }
        return nil
    }
    
    func markLocalTodosASRead(_ localTodos: [PlanItTodo], datas: [[String: Any]]) {
        let todoIds = datas.compactMap({ return $0["toDoId"] as? Double })
        localTodos.filter({ return todoIds.contains($0.todoId)}).flatMap({ return $0.readAllInvitees() }).filter({ return $0.readValueOfUserId() == Session.shared.readUserId() }).forEach({ $0.isRead = true })
        self.mainObjectContext.saveContext()
    }
    
    func readUser(_ user: String, allPendingRemindMeTodosUsingType type: [LocalNotificationType], completionHandler: @escaping ([PlanItTodo]) -> ()) {
        self.privateObjectContext.perform {
            let types = type.map({ return $0.rawValue })
            let predicate = NSPredicate(format: "user == %@ AND remindMe IN %@", user, types)
            let todos = self.readRecords(fromCoreData: Table.planItTodo, predicate: predicate, context: self.privateObjectContext) as! [PlanItTodo]
            completionHandler(todos)
        }
    }
    
    func readAllChildEventOfToDo(_ todo: PlanItTodo, using context: NSManagedObjectContext? = nil) -> [PlanItTodo] {
        let objectContext = context ?? self.mainObjectContext
        let predicate = NSPredicate(format: "user == %@ AND parent.todoId == %@", Session.shared.readUserId(), todo.readTodoId())
        return self.readRecords(fromCoreData: Table.planItTodo, predicate: predicate, context: objectContext) as! [PlanItTodo]
    }
    
    func readTodoWithIds(todos: [[String: Any]], using context: NSManagedObjectContext? = nil) -> [PlanItTodo] {
        let objectContext = context ?? self.mainObjectContext
        let todoIds = todos.compactMap({ return $0["toDoId"] as? Double })
        let appTodoIds: [String] = todos.compactMap({ if let appToDoId = $0["appToDoId"] as? String, !appToDoId.isEmpty { return appToDoId } else { return nil } })
        let predicate = NSPredicate(format: "user == %@ AND (todoId IN %@ OR appToDoId IN %@)", Session.shared.readUserId(), todoIds, appTodoIds)
         return self.readRecords(fromCoreData: Table.planItTodo, predicate: predicate, context: objectContext) as! [PlanItTodo]
    }
    
    func readTodoWithId(todoId: Double, using context: NSManagedObjectContext? = nil) -> [PlanItTodo] {
        let objectContext = context ?? self.mainObjectContext
        let predicate = NSPredicate(format: "user == %@ AND todoId == %f", Session.shared.readUserId(), todoId)
        return self.readRecords(fromCoreData: Table.planItTodo, predicate: predicate, context: objectContext) as! [PlanItTodo]
    }
    
    func readAllPendingTodos(using context: NSManagedObjectContext? = nil) -> [PlanItTodo] {
        let objectContext = context ?? self.mainObjectContext
        let predicate = NSPredicate(format: "user == %@ AND isPending == YES AND (movedFrom == '' OR movedFrom == nil)", Session.shared.readUserId())
        return self.readRecords(fromCoreData: Table.planItTodo, predicate: predicate, context: objectContext) as! [PlanItTodo]
    }
    
    func readAllPendingMovedTodos(using context: NSManagedObjectContext? = nil) -> [PlanItTodo] {
        let objectContext = context ?? self.mainObjectContext
        let predicate = NSPredicate(format: "user == %@ AND movedFrom.length > 0", Session.shared.readUserId())
        return self.readRecords(fromCoreData: Table.planItTodo, predicate: predicate, context: objectContext) as! [PlanItTodo]
    }
    
    func readAllAvailableTodos(using context: NSManagedObjectContext? = nil) -> [PlanItTodo]  {
        let objectContext = context ?? self.mainObjectContext
        let predicate = NSPredicate(format: "user == %@", Session.shared.readUserId())
        return self.readRecords(fromCoreData: Table.planItTodo, predicate: predicate, context: objectContext) as! [PlanItTodo]
    }
    
    func readAllAvailableTodosUsingQueue(result: @escaping ([PlanItTodo]) -> ()) {
        self.privateObjectContext.perform {
            let predicate = NSPredicate(format: "user == %@", Session.shared.readUserId())
            let todos = self.readRecords(fromCoreData: Table.planItTodo, predicate: predicate, context: self.privateObjectContext) as! [PlanItTodo]
            result(todos)
        }
    }
    
    func readAllFutureTodosUsingQueue(startOfMonth: Date, endOfMonth: Date, anyItemsExist: Bool, result: @escaping ([PlanItTodo]) -> ()) {
        self.privateObjectContext.perform {
            let start = startOfMonth as NSDate
            let end = endOfMonth as NSDate
            let predicate = NSPredicate(format: "user == %@ AND ((dueDate >= %@ AND dueDate <= %@) OR (originalStartDate >= %@ AND originalStartDate <= %@) OR (isRecurrence == YES AND ((recurrenceEndDate >= %@ AND recurrenceEndDate <= %@ AND dueDate != nil) OR (dueDate <= %@ AND (recurrenceEndDate == nil OR recurrenceEndDate >= %@)) )) \(anyItemsExist ? "" : "OR dueDate == nil")) AND (parent == nil OR parent.completed == NO)", Session.shared.readUserId(), start, end, start, end, start, end, start, end)
            let todos = self.readRecords(fromCoreData: Table.planItTodo, predicate: predicate, context: self.privateObjectContext) as! [PlanItTodo]
            result(todos)
        }
    }
}
