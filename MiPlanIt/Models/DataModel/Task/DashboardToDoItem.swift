//
//  ToDoItem.swift
//  MiPlanIt
//
//  Created by Febin Paul on 26/10/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation


class DashboardToDoItem {
    
    var id: String = ""
    var text: String = ""
    var description: String = ""
    var initialDate: Date = Date()
    var actualDate: Date?
    var todoData: Any?
    var todoId: String = ""
    var tags: [String] = []
    
    init(with todo: PlanItTodo, startDate: Date? = nil, converter: DataBasePlanItTodo) {
        self.initialDate = startDate ?? Date().initialHour()
        self.actualDate = startDate
        self.todoId = todo.readTodoId()
        self.id = Session.shared.readUserId() + todo.readTodoId()
        self.text = todo.readToDoTitle()
        self.description = todo.readNotes()
        self.tags = todo.readAllTags().compactMap({ $0.readTag() })
        self.todoData = try? converter.mainObjectContext.existingObject(with: todo.objectID)
    }
    
    func readAllTags() -> [String] {
        return self.tags.compactMap({ $0.lowercased() })
    }
    
    func containsName(_ string: String) -> Bool {
        return self.text.lowercased().contains(string)
    }
    
    func containsTags(_ string: String) -> Bool {
        return !self.tags.filter({ $0.lowercased().contains(string) }).isEmpty
    }
    
    func containsDescription(_ string: String) -> Bool {
        return self.description.lowercased().contains(string)
    }
}
