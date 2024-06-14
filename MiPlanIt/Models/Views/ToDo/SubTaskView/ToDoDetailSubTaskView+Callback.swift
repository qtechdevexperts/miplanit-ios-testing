//
//  ToDoDetailSubTaskView+Callback.swift
//  MiPlanIt
//
//  Created by Febin Paul on 13/07/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

extension ToDoDetailSubTaskView: ToDoSubTaskViewDelegate {
    
    func toDoSubTaskView(_ toDoSubTaskView: ToDoSubTaskView, onDelete subToDoModel: SubToDoDetailModel, uniqueId: String) {
        if let viewIndex = self.stackViewSubTask.arrangedSubviews.firstIndex(where: { (view) -> Bool in
            if let subToDoView = view as? ToDoSubTaskView {
                return subToDoView.uniqueId == uniqueId
            }
            return false
        }) {
            self.stackViewSubTask.arrangedSubviews[viewIndex].removeFromSuperview()
            if subToDoModel.readSubToDoId().isEmpty {
                self.toDoDetailModel.subToDos.removeAll(where: { return $0.uniqueUUID == uniqueId })
            }
            else {
                subToDoModel.deletedStatus = true
            }
        }
    }
}
