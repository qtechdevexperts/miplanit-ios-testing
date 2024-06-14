//
//  OfflineTriggerTodoCategory.swift
//  MiPlanIt
//
//  Created by Arun on 22/09/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

extension Session {
    
    func sendTodoCategoryToServer(_ finished: @escaping () -> ()) {
        let pendingCategories = DataBasePlanItTodoCategory().readAllPendingTodoCategory()
        if pendingCategories.isEmpty {
            finished()
        }
        else {
            TodoService().sendPendingTodoCategoriesToServer(pendingCategories, callback: {
                finished()
            })
        }
    }
}

