//
//  TodoListCategory.swift
//  MiPlanIt
//
//  Created by Arun on 05/08/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

class TodoListCategory {
    var title: String
    var categories: [PlanItTodoCategory]
    
    init(with title: String, categories: [PlanItTodoCategory]) {
        self.title = title
        self.categories = categories
    }
}
