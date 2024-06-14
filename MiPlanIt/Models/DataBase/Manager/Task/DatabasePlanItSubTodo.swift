//
//  DatabasePlanItSubTodo.swift
//  MiPlanIt
//
//  Created by Arun on 06/07/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation
import CoreData

class DatabasePlanItSubTodo: DataBaseManager {

    func insertPlanItSubTodos(_ data: [[String: Any]], to todo: PlanItTodo, using context: NSManagedObjectContext? = nil) {
        let objectContext = context ?? self.mainObjectContext
        todo.subTodosCount = data.isEmpty ? Strings.empty : "\(data.count)"
        for subTodo in data {
            let subTodoEntity = self.insertNewRecords(Table.planItSubTodo, context: objectContext) as! PlanItSubTodo
            subTodoEntity.subTodoId = subTodo["subTaskId"] as? Double ?? 0
            subTodoEntity.subTodoTitle = subTodo["taskTitle"] as? String
            subTodoEntity.completed = subTodo["isCompleted"] as? Bool ?? false
            subTodoEntity.deletedStatus = subTodo["isDeleted"] as? Bool ?? false
            if let date = subTodo["createdAt"] as? String {
                subTodoEntity.createdAt = date.stringToDate(formatter: DateFormatters.MMDDYYYYHMMSSA, timeZone: TimeZone(abbreviation: "UTC")!)
            }
            if let date = subTodo["modifiedAt"] as? String {
                subTodoEntity.modifiedAt = date.stringToDate(formatter: DateFormatters.MMDDYYYYHMMSSA, timeZone: TimeZone(abbreviation: "UTC")!)
            }
            if let createdBy = subTodo["createdBy"] as? [String: Any] {
                DatabasePlanItCreator().insertSubTodo(subTodoEntity, creator: createdBy, using: objectContext)
            }
            if let modifiedBy = subTodo["modifiedBy"] as? [String: Any] {
                DatabasePlanItModifier().insertSubTodo(subTodoEntity, modifier: modifiedBy, using: objectContext)
            }
            subTodoEntity.todo = todo
        }
    }
    
    func insertPlanItSubTodos(_ data: [SubToDoDetailModel], to todo: PlanItTodo, using context: NSManagedObjectContext? = nil) {
        todo.deleteSubTodos()
        let objectContext = context ?? self.mainObjectContext
        todo.subTodosCount = data.isEmpty ? Strings.empty : "\(data.count)"
        for subTodo in data {
            let subTodoEntity = self.insertNewRecords(Table.planItSubTodo, context: objectContext) as! PlanItSubTodo
            subTodoEntity.completed = subTodo.completed
            subTodoEntity.deletedStatus = subTodo.deletedStatus
            subTodoEntity.subTodoTitle = subTodo.subTodoTitle
            subTodoEntity.subTodoId = subTodo.subTodoId
            subTodoEntity.createdAt = subTodo.createdAt
            subTodoEntity.modifiedAt = subTodo.modified
            subTodoEntity.todo = todo
        }
    }
}
