//
//  PlanItTodoRecurrence.swift
//  MiPlanIt
//
//  Created by Arun on 06/07/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation
import CoreData

class DatabasePlanItTodoRecurrence: DataBaseManager {
    
    func insertTodo(_ todo: PlanItTodo, recurrence: String, using context: NSManagedObjectContext? = nil) {
        let objectContext = context ?? self.mainObjectContext
        let recurrenceEntity = todo.recurrence ?? self.insertNewRecords(Table.planItTodoRecurrence, context: objectContext) as! PlanItTodoRecurrence
        todo.isRecurrence = true
        recurrenceEntity.todo = todo
        recurrenceEntity.rule = recurrence.replacingOccurrences(of: "RRULE ", with: "RRULE:")
        todo.recurrenceEndDate = recurrenceEntity.readEndDate()
    }
}
