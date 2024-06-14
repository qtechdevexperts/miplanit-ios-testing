//
//  ToDoItemCellModel.swift
//  MiPlanIt
//
//  Created by Febin Paul on 09/07/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

class ToDoItemCellModel {
    
    var planItToDo: PlanItTodo!
    var editSelected: Bool = false
    
    init(planItToDo: PlanItTodo) {
        self.planItToDo = planItToDo
    }
}
