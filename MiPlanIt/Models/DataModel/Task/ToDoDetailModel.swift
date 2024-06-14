//
//  ToDoDetailModel.swift
//  MiPlanIt
//
//  Created by Febin Paul on 14/07/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation


class ToDoDetailModel {
    
    var tags = ["To Do"]
    var dueDate: Date?
    var todoName: String  = Strings.empty
    var recurrence: String = Strings.empty
    var notes: String = Strings.empty
    var remindValue: ReminderModel?
    var assignee: [OtherUser] = []
    var subToDos: [SubToDoDetailModel] = []
    var attachments: [UserAttachment] = []
    var dashboardDueDate: Date?
    var categoryOwnerId: String?
    
    init(planItToDo: PlanItTodo, with type: ToDoMainCategory, dashboardDate: Date? = nil) {
        self.categoryOwnerId = planItToDo.todoCategory?.createdBy?.readValueOfUserId()
        self.dashboardDueDate = dashboardDate
        self.tags = planItToDo.readAllTags().compactMap({ return $0.tag})
        self.dueDate = dashboardDate ?? planItToDo.readStartDate(using: type)
        self.todoName = planItToDo.readToDoTitle()
        self.recurrence = planItToDo.recurrence?.readRule() ?? Strings.empty
        self.notes = planItToDo.readNotes()
        if let reminder = planItToDo.readReminders() {
            self.remindValue = ReminderModel(reminder, from: .task)
        }
        self.assignee = planItToDo.readAllInvitees().compactMap({ return OtherUser(invitee: $0) })
        self.subToDos = planItToDo.readAllSubTodos().compactMap({ return SubToDoDetailModel(subToDo: $0) })
        let ownerIdValue = planItToDo.createdBy?.readValueOfUserId()
        self.attachments = planItToDo.readAllAttachments().compactMap({ return UserAttachment(with: $0, type: .task, ownerId: ownerIdValue) })
    }
    
    func readDueDate() -> String { return self.dueDate?.stringFromDate(format: DateFormatters.EEEDDHMMMHYYY) ?? Strings.empty }
        
    func addAttachement(_ attachment: UserAttachment) {
        self.attachments.append(attachment)
    }
    
    func getAttachmentCount() -> Int {
        return self.attachments.count
    }
    
    func removeAttachementAtIndex(_ index: Int) {
        self.attachments.remove(at: index)
    }
    
    func removeAttachement(_ attachment: UserAttachment) {
        self.attachments.removeAll(where: { return $0 == attachment })
    }
    
    func createTextForPrediction() -> String {
        var text: String = ""
        text += self.todoName
        text += self.notes.isEmpty ? Strings.empty : ", "+self.notes
        self.subToDos.filter({ $0.subTodoTitle != Strings.empty }).forEach { (subTodo) in
            text += ", "+subTodo.subTodoTitle
        }
        return text
    }
}


class SubToDoDetailModel {

    var completed: Bool = false
    var createdAt: Date = Date()
    var deletedStatus: Bool = false
    var modified: Date = Date()
    var subTodoId: Double = 0.0
    var subTodoTitle: String = Strings.empty
    var uniqueUUID = UUID().uuidString
    var toDo: PlanItTodo!
    
    init(subToDoTitle: String) {
        self.subTodoTitle = subToDoTitle
    }
    
    init(subToDo: PlanItSubTodo) {
        self.completed = subToDo.completed
        self.createdAt = subToDo.createdAt ?? Date()
        self.deletedStatus = subToDo.deletedStatus
        self.modified = subToDo.modifiedAt ?? Date()
        if !subToDo.readSubToDoId().isEmpty {
            self.subTodoId = subToDo.subTodoId
            self.uniqueUUID = subToDo.readSubToDoId()
        }
        self.subTodoTitle = subToDo.readSubToDoTitle()
        self.toDo = subToDo.todo
    }
    
    func readSubToDoId() -> String { return self.subTodoId == 0 ? Strings.empty : self.subTodoId.cleanValue() }

}
