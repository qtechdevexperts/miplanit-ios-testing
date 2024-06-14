//
//  OfflineTriggerTodo.swift
//  MiPlanIt
//
//  Created by Arun on 22/09/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

extension Session {
    
    func sendPendingAttachmentsToServer(type: AttachmentType, finished: @escaping () -> ()) {
        let pendingAttachments = DatabasePlanItUserAttachment().readAllPendingAttachements().filter({ $0.todo != nil })
        if pendingAttachments.isEmpty {
            finished()
        }
        else {
            self.uploadPendingAttachmentsToServer(pendingAttachments, type: type, finished: finished)
        }
    }
    
    func uploadPendingAttachmentsToServer(_ attachments: [PlanItUserAttachment], type: AttachmentType, at index: Int = 0, finished: @escaping () -> ()) {
        guard index < attachments.count else { finished(); return }
        let ownerIdValue = attachments[index].todo?.createdBy?.readValueOfUserId() ?? Strings.empty
        let convertedAttachment = UserAttachment(with: attachments[index], type: .task, ownerId: ownerIdValue)
        UserService().uploadAttachement(convertedAttachment, callback: { attachment, _ in
            if let result = attachment {
                attachments[index].saveTodoAttachmentIdentifier(result.identifier)
            }
            self.uploadPendingAttachmentsToServer(attachments, type: type, at: index + 1, finished: finished)
        })
    }
    
    func sendTodoToServer(_ finished: @escaping () -> ()) {
        let pendingTodos = DataBasePlanItTodo().readAllPendingTodos().filter({ return !$0.isPendingCategory() })
        if pendingTodos.isEmpty {
            finished()
        }
        else {
            TodoService().sendPendingTodosToServer(pendingTodos, callback: {
                finished()
            })
        }
    }
    
    func sendTodoMovesToServer(_ finished: @escaping () -> ()) {
        let pendingMovedTodos = DataBasePlanItTodo().readAllPendingMovedTodos().filter({ return !$0.isPendingCategory() })
        if pendingMovedTodos.isEmpty {
            finished()
        }
        else {
            TodoService().sendPendingMovedTodos(pendingMovedTodos, callback: {
                finished()
            })
        }
    }
}
