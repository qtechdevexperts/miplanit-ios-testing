//
//  PlanItSubToDo+Save.swift
//  MiPlanIt
//
//  Created by Febin Paul on 07/07/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

extension PlanItSubTodo {
    
    func readSubToDoId() -> String { return self.subTodoId == 0 ? Strings.empty : self.subTodoId.cleanValue() }
    func readSubToDoTitle() -> String { return self.subTodoTitle ?? Strings.empty }
}
