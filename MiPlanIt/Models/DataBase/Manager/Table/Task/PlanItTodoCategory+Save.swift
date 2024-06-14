//
//  PlanItTodoCategory.swift
//  MiPlanIt
//
//  Created by Arun on 06/07/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

extension PlanItTodoCategory {
    
    func readCategoryId() -> String {
        return self.categoryId == 0 ? Strings.empty : self.categoryId.cleanValue()
    }
    
    func readAppsToServerId() -> String {
        return self.appToDoCategoryId ?? Strings.empty
    }
    
    func readIdentifier() -> String {
        return self.readCategoryId().isEmpty ? self.readAppsToServerId() : self.readCategoryId()
    }
    
    func readCategoryName() -> String {
        return self.categoryName ?? Strings.empty
    }
    
    func readModifiedDate() -> Date {
        return self.modifiedAt ?? Date()
    }
    
    func readAllMainTodos() -> [PlanItTodo] {
        if let bTodos = self.todos, let localTodos = Array(bTodos) as? [PlanItTodo] {
            return localTodos
        }
        return []
    }
    
    func readAllTodos() -> [PlanItTodo] {
        let localEvents = self.readAllMainTodos()
        let recurrenceEvent = localEvents.flatMap({ return $0.readAllChildTodos() })
        return (localEvents + recurrenceEvent)
    }
    
    func readAllAvailableMainTodos() -> [PlanItTodo] {
        return self.readAllTodos().filter({ return !$0.deletedStatus })
    }
    
    func readAllCategoryInvitees() -> [PlanItInvitees] {
        if let bInvitees = self.invitees, let localInvitees = Array(bInvitees) as? [PlanItInvitees] {
            return localInvitees
        }
        return []
    }
    
    func readSharedByUser() -> PlanItSharedUser? {
        return self.readAllCategoryInvitees().filter({ return $0.readValueOfUserId() == Session.shared.readUserId() }).first?.sharedBy
    }
    
    func readAllInvitees() -> [PlanItInvitees] {
        return self.readAllCategoryInvitees().filter({ return $0.readValueOfUserId() != Session.shared.readUserId() })
    }
    
    func readAllOtherUser() -> [OtherUser] {
        return self.readAllInvitees().compactMap({ OtherUser(invitee: $0, deletable: $0.readValueOfUserId() != self.createdBy?.readValueOfUserId() ) })
    }
    
    func deleteChildTodos(_ childTodos: [Double]) {
        let deletedTodos = self.readAllMainTodos().filter({ return childTodos.contains($0.todoId) })
        self.removeFromTodos(NSSet(array: deletedTodos))
        deletedTodos.forEach({ self.managedObjectContext?.delete($0) })
    }
    
    func deleteAllInvitees() {
        let deletedInvitees = self.readAllCategoryInvitees()
        self.removeFromInvitees(NSSet(array: deletedInvitees))
        deletedInvitees.forEach({ self.managedObjectContext?.delete($0) })
    }
    
    func deleteAllInternalInvitees() {
        let deletedInvitees = self.readAllCategoryInvitees().filter({ return !$0.isOther })
        self.removeFromInvitees(NSSet(array: deletedInvitees))
        deletedInvitees.forEach({ self.managedObjectContext?.delete($0) })
    }
    
    func deleteAllExternalInvitees() {
        let deletedInvitees = self.readAllCategoryInvitees().filter({ return $0.isOther })
        self.removeFromInvitees(NSSet(array: deletedInvitees))
        deletedInvitees.forEach({ self.managedObjectContext?.delete($0) })
    }
    
    func updateDeleteStatus() {
        self.deletedStatus = true
        try? self.managedObjectContext?.save()
    }
    
    func readAllToDoSharedInvitees() -> [PlanItInvitees] {
        if let invitees = self.invitees, let planItInvitees = Array(invitees) as? [PlanItInvitees] {
            return planItInvitees.filter({ $0.readValueOfUserId() != Session.shared.readUserId() })
        }
        return []
    }
    
    func readSpecificToDo(_ todo: Double) -> PlanItTodo? {
        return self.readAllTodos().filter({ return $0.todoId == todo }).first
    }
    
    //MARK: - Save Offline
    func saveDeleteStatus(_ status: Bool) {
        if self.readCategoryId().isEmpty {
            self.managedObjectContext?.delete(self)
        }
        else {
            self.isPending = true
            self.deletedStatus = status
            self.readAllTodos().forEach({$0.deletedStatus = status})
        }
        try? self.managedObjectContext?.save()
    }
    
    func shareTo(users: [OtherUser]) {
        self.isPending = true
        DatabasePlanItInvitees().insertToDoCategory(self, other: users)
        try? self.managedObjectContext?.save()
    }
    
    func removeTodosFromList(_ todos: [PlanItTodo]) {
        self.removeFromTodos(NSSet(array: todos))
    }
    
    func addTodosToList(_ todos: [PlanItTodo], from category: PlanItTodoCategory) {
        todos.forEach({
            if $0.readMovedFrom().isEmpty && !category.readCategoryId().isEmpty, !$0.readTodoId().isEmpty {
                $0.movedFrom = category.readCategoryId()
            } else { $0.isPending = true }
        })
        self.addToTodos(NSSet(array: todos))
        try? self.managedObjectContext?.save()
    }
}
