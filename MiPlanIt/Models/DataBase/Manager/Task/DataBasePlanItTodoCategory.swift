//
//  DataBasePlanItTodoCategory.swift
//  MiPlanIt
//
//  Created by Arun on 06/07/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation
import CoreData

class DataBasePlanItTodoCategory: DataBaseManager {
        
    func insertPlanItToDoCategory(_ data: [[String: Any]], using context: NSManagedObjectContext? = nil) {
        let objectContext = context ?? self.mainObjectContext
        let localToDoCategory = self.readAllUserToDoCategory(using: objectContext)
        for eachItem in data {
            let categoryId = eachItem["toDoListId"] as? Double ?? 0
            let appToDoListId = eachItem["appToDoListId"] as? String ?? Strings.empty
            let todoCategoryEntity = localToDoCategory.filter({ return $0.categoryId == categoryId || (!appToDoListId.isEmpty && appToDoListId == $0.appToDoCategoryId) }).first ?? self.insertNewRecords(Table.planItTodoCategory, context: objectContext) as! PlanItTodoCategory
            todoCategoryEntity.categoryId = categoryId
            todoCategoryEntity.appToDoCategoryId = appToDoListId
            todoCategoryEntity.categoryName = eachItem["toDoListTitle"] as? String
            todoCategoryEntity.deletedStatus = eachItem["isDeleted"] as? Bool ?? false
            todoCategoryEntity.permission = eachItem["permission"] as? Bool ?? true
            todoCategoryEntity.user = Session.shared.readUserId()
            if let date = eachItem["createdAt"] as? String {
                todoCategoryEntity.createdAt = date.stringToDate(formatter: DateFormatters.MMDDYYYYHMMSSA, timeZone: TimeZone(abbreviation: "UTC")!)
            }
            if let date = eachItem["modifiedAt"] as? String {
                todoCategoryEntity.modifiedAt = date.stringToDate(formatter: DateFormatters.MMDDYYYYHMMSSA, timeZone: TimeZone(abbreviation: "UTC")!)
            }
            if let deletedToDos = eachItem["deletedToDos"] as? [Double] {
                todoCategoryEntity.deleteChildTodos(deletedToDos)
            }
            if let createdBy = eachItem["createdBy"] as? [String: Any] {
                DatabasePlanItCreator().insertTodoCategory(todoCategoryEntity, creator: createdBy, using: objectContext)
            }
            if let sharedUsers = eachItem["invitees"] as? [[String: Any]] {
                DatabasePlanItInvitees().insertToDoCategory(todoCategoryEntity, main: sharedUsers, using: objectContext)
            }
            if let nonRegInvitees = eachItem["nonRegInvitees"] as? [[String: Any]] {
                DatabasePlanItInvitees().insertToDoCategory(todoCategoryEntity, other: nonRegInvitees, using: objectContext)
            }
            if let todos = eachItem["todos"] as? [[String: Any]] {
                DataBasePlanItTodo().insertPlanItTodos(todos, to: todoCategoryEntity, using: objectContext)
            }
        }
    }
    
    @discardableResult func insertNewPlanItToDoCategory(_ data: [[String: Any]]) -> [PlanItTodoCategory] {
        var addedCategories: [PlanItTodoCategory] = []
        let localToDoCategory = self.readAllUserToDoCategory()
        for eachItem in data {
            let categoryId = eachItem["toDoListId"] as? Double ?? 0
            let appToDoListId = eachItem["appToDoListId"] as? String ?? Strings.empty
            let todoCategoryEntity = localToDoCategory.filter({ return $0.categoryId == categoryId || (!appToDoListId.isEmpty && appToDoListId == $0.appToDoCategoryId) }).first ?? self.insertNewRecords(Table.planItTodoCategory, context: self.mainObjectContext) as! PlanItTodoCategory
            todoCategoryEntity.categoryId = categoryId
            todoCategoryEntity.appToDoCategoryId = appToDoListId
            todoCategoryEntity.categoryName = eachItem["toDoListTitle"] as? String
            todoCategoryEntity.deletedStatus = eachItem["isDeleted"] as? Bool ?? false
            todoCategoryEntity.permission = eachItem["permission"] as? Bool ?? true
            todoCategoryEntity.user = Session.shared.readUserId()
            if let date = eachItem["createdAt"] as? String {
                todoCategoryEntity.createdAt = date.stringToDate(formatter: DateFormatters.MMDDYYYYHMMSSA, timeZone: TimeZone(abbreviation: "UTC")!)
            }
            if let date = eachItem["modifiedAt"] as? String {
                todoCategoryEntity.modifiedAt = date.stringToDate(formatter: DateFormatters.MMDDYYYYHMMSSA, timeZone: TimeZone(abbreviation: "UTC")!)
            }
            if let deletedToDos = eachItem["deletedToDos"] as? [Double] {
                todoCategoryEntity.deleteChildTodos(deletedToDos)
            }
            if let createdBy = eachItem["createdBy"] as? [String: Any] {
                DatabasePlanItCreator().insertTodoCategory(todoCategoryEntity, creator: createdBy, using: self.mainObjectContext)
            }
            if let sharedUsers = eachItem["invitees"] as? [[String: Any]] {
                DatabasePlanItInvitees().insertToDoCategory(todoCategoryEntity, main: sharedUsers, using: self.mainObjectContext)
            }
            if let nonRegInvitees = eachItem["nonRegInvitees"] as? [[String: Any]] {
                DatabasePlanItInvitees().insertToDoCategory(todoCategoryEntity, other: nonRegInvitees, using: self.mainObjectContext)
            }
            if let todos = eachItem["todos"] as? [[String: Any]] {
                DataBasePlanItTodo().insertPlanItTodos(todos, to: todoCategoryEntity, using: self.mainObjectContext)
            }
            addedCategories.append(todoCategoryEntity)
        }
        self.mainObjectContext.saveContext()
        return addedCategories
    }
    
    @discardableResult func insertNewNotificationPlanItToDo(_ data: [String: Any]) -> PlanItTodo? {
        let localToDoCategory = self.readAllUserToDoCategory()
        let categoryId = data["toDoListId"] as? Double ?? 0
        let todoCategoryEntity = localToDoCategory.filter({ return $0.categoryId == categoryId }).first ?? self.insertNewRecords(Table.planItTodoCategory, context: self.mainObjectContext) as! PlanItTodoCategory
        todoCategoryEntity.categoryId = categoryId
        todoCategoryEntity.categoryName = data["toDoListTitle"] as? String
        todoCategoryEntity.user = Session.shared.readUserId()
        todoCategoryEntity.createdAt = Date().toGlobalTime()
        todoCategoryEntity.modifiedAt = Date().toGlobalTime()
        let todos = DataBasePlanItTodo().insertPlanItTodos([data], to: todoCategoryEntity, using: self.mainObjectContext)
        self.mainObjectContext.saveContext()
        return todos.first
    }
    
    @discardableResult func insertNewOfflinePlanItToDoCategory(_ category: PlanItTodoCategory? = nil, name: String) -> PlanItTodoCategory {
        let todoCategoryEntity = category ?? self.insertNewRecords(Table.planItTodoCategory, context: self.mainObjectContext) as! PlanItTodoCategory
        todoCategoryEntity.isPending = true
        todoCategoryEntity.permission = true
        todoCategoryEntity.deletedStatus = false
        todoCategoryEntity.appToDoCategoryId = UUID().uuidString
        todoCategoryEntity.categoryName = name
        todoCategoryEntity.createdAt = Date().toGlobalTime()
        todoCategoryEntity.modifiedAt = Date().toGlobalTime()
        todoCategoryEntity.user = Session.shared.readUserId()
        DatabasePlanItCreator().insertTodoCategory(todoCategoryEntity, creator: Session.shared.readUser(), using: self.mainObjectContext)
        if let user = Session.shared.readUser() {
            DatabasePlanItInvitees().insertToDoCategory(todoCategoryEntity, other: [OtherUser(planItUser: user)], using: self.mainObjectContext)
        }
        self.mainObjectContext.saveContext()
        return todoCategoryEntity
    }
    
    func readAllUserToDoCategory(using context: NSManagedObjectContext? = nil) -> [PlanItTodoCategory] {
        let objectContext = context ?? self.mainObjectContext
        let predicate = NSPredicate(format: "user == %@", Session.shared.readUserId())
        return self.readRecords(fromCoreData: Table.planItTodoCategory, predicate: predicate, sortDescriptor: ["createdAt"], ascending: false, context: objectContext) as! [PlanItTodoCategory]
    }
    
    func readAllAvailableUserToDoCategory(using context: NSManagedObjectContext? = nil) -> [PlanItTodoCategory] {
        let objectContext = context ?? self.mainObjectContext
        let predicate = NSPredicate(format: "user == %@ AND permission == YES AND deletedStatus == NO", Session.shared.readUserId())
        return self.readRecords(fromCoreData: Table.planItTodoCategory, predicate: predicate, sortDescriptor: ["createdAt"], ascending: false, context: objectContext) as! [PlanItTodoCategory]
    }
    
    func removedPlantItCategories(_ categoryIds: [Double], using context: NSManagedObjectContext? = nil) {
        let objectContext = context ?? self.mainObjectContext
        let predicate = NSPredicate(format: "user == %@ AND categoryId IN %@", Session.shared.readUserId(), categoryIds)
        let myPlanItCategories = self.readRecords(fromCoreData: Table.planItTodoCategory, predicate: predicate, context: objectContext) as! [PlanItTodoCategory]
        myPlanItCategories.forEach({ objectContext.delete($0) })
    }
    
    func readSpecificToDoCategories(_ categories: [Double], using context: NSManagedObjectContext? = nil) -> [PlanItTodoCategory] {
        let objectContext = context ?? self.mainObjectContext
        let predicate = NSPredicate(format: "user == %@ AND categoryId IN %@", Session.shared.readUserId(), categories)
        return self.readRecords(fromCoreData: Table.planItTodoCategory, predicate: predicate, context: objectContext) as! [PlanItTodoCategory]
    }
    
    func readSpecificToDoCategory(_ identifier: String, using context: NSManagedObjectContext? = nil) -> PlanItTodoCategory? {
        let value = Double(identifier) ?? -1
        let objectContext = context ?? self.mainObjectContext
        let predicate = NSPredicate(format: "user == %@ AND (categoryId == %f OR appToDoCategoryId == %@)", Session.shared.readUserId(), value, identifier)
        let records = self.readRecords(fromCoreData: Table.planItTodoCategory, predicate: predicate, context: objectContext) as! [PlanItTodoCategory]
        return records.first
    }
    
    func readAllPendingTodoCategory(using context: NSManagedObjectContext? = nil) -> [PlanItTodoCategory] {
        let objectContext = context ?? self.mainObjectContext
        let predicate = NSPredicate(format: "user == %@ AND isPending == YES", Session.shared.readUserId())
        return self.readRecords(fromCoreData: Table.planItTodoCategory, predicate: predicate, context: objectContext) as! [PlanItTodoCategory]
    }
}
