//
//  MainCategoryToDoViewController.swift
//  MiPlanIt
//
//  Created by Febin Paul on 08/07/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

class MainCategoryToDoViewController: ToDoListBaseViewController {
    
    var categorisedTodos: [PlanItTodo] = []
    var refreshControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialRefreshControl()
        self.sortTodosWithCategoryType()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.sendReadStatusOfTodoItemsToServer()
        super.viewWillDisappear(animated)
    }
    
    override func toggleSortOrder(_ sender: UIButton) {
        super.toggleSortOrder(sender)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.destination {
        case is TodoDetailViewController:
            let todoDetailViewController = segue.destination as! TodoDetailViewController
            todoDetailViewController.delegate = self
            todoDetailViewController.categoryType = self.categoryType //always first
            todoDetailViewController.mainToDoItem = sender as? PlanItTodo
        case is MoveListToDoViewController:
            let moveListViewController = segue.destination as! MoveListToDoViewController
            moveListViewController.moveToDos = self.toDoItemCellModels.filter({ $0.editSelected }).map({ $0.planItToDo })
            moveListViewController.delegate = self
        case is CategoryListFilterController:
            let categoryListFilterController = segue.destination as! CategoryListFilterController
            categoryListFilterController.delegate = self
            categoryListFilterController.categoryType = self.categoryType
            categoryListFilterController.activeFilter = self.activeFilter
        case is MessageViewController:
            let messageViewController = segue.destination as! MessageViewController
            messageViewController.caption = (sender as? [String])?.first
            messageViewController.errorDescription = (sender as? [String])?.last
        default: break
        }
    }

}
