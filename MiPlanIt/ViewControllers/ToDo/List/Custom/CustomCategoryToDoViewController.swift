//
//  CustomCategoryToDoViewController.swift
//  MiPlanIt
//
//  Created by Febin Paul on 08/07/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

class CustomCategoryToDoViewController: ToDoListBaseViewController {
    
    var toDoPlanItCategory: PlanItTodoCategory?
    var refreshControl = UIRefreshControl()
    var pullToRefreshDate: String = Session.shared.readUser()?.readUserSettings().readLastTodoFetchDataTime() ?? Strings.empty
    
    @IBOutlet weak var buttonLoader: ProcessingButton!
    @IBOutlet weak var labelItemSelectionCount: UILabel!
    @IBOutlet weak var imgSharedBy: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialRefreshControl()
        self.sortTodosWithCategoryType()
    }
    
    @IBAction func shareInviteesClicked(_ sender: UIButton) {
        self.hideCompleteSection()
        self.performSegue(withIdentifier: Segues.toSharedUsers, sender: nil)
    }
    
    @IBAction func moreActionClicked(_ sender: UIButton) {
        self.hideCompleteSection()
        self.performSegue(withIdentifier: Segues.segueToMoreList, sender: nil)
    }
    
    override func toggleSortOrder(_ sender: UIButton) {
        super.toggleSortOrder(sender)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.destination {
        case is MoveListToDoViewController:
            let moveListViewController = segue.destination as! MoveListToDoViewController
            moveListViewController.currentCategory = self.toDoPlanItCategory
            if let planItToDo = sender as? [PlanItTodo] {
                moveListViewController.moveToDos = planItToDo
            }
            moveListViewController.delegate = self
        case is ShareToDoListViewController:
            let shareToDoListViewController = segue.destination as! ShareToDoListViewController
            shareToDoListViewController.delegate = self
            shareToDoListViewController.selectedInvitees = self.toDoPlanItCategory?.readAllOtherUser() ?? []
        case is MoreActionToDoDropDownController:
            let moreActionDropDownController = segue.destination as! MoreActionToDoDropDownController
            moreActionDropDownController.delegate = self
            moreActionDropDownController.containsToDoItems = self.toDoPlanItCategory != nil && !self.toDoItemCellModels.isEmpty
        case is CategoryListFilterController:
            let categoryListFilterController = segue.destination as! CategoryListFilterController
            categoryListFilterController.delegate = self
            categoryListFilterController.activeFilter = self.activeFilter
            categoryListFilterController.categoryType = self.categoryType
        case is AssignToDoViewController:
            let assignViewController = segue.destination as! AssignToDoViewController
            assignViewController.delegate = self
            if let todo = sender as? [PlanItTodo], let assignee = todo.first?.readAllInvitees().first, todo.count == 1 {
                assignViewController.selectedUser = AssignUser(calendarUser: CalendarUser(assignee))
            }
            assignViewController.toDoItems =  sender as? [PlanItTodo] ?? []
        case is TodoDetailViewController:
            let todoDetailViewController = segue.destination as! TodoDetailViewController
            todoDetailViewController.delegate = self
            todoDetailViewController.categoryType = self.categoryType //always first
            todoDetailViewController.mainToDoItem = sender as? PlanItTodo
        case is DueDateViewController:
            let toDoDueDateViewController = segue.destination as! DueDateViewController
            toDoDueDateViewController.delegate = self
        case is MessageViewController:
            let messageViewController = segue.destination as! MessageViewController
            messageViewController.caption = (sender as? [String])?.first
            messageViewController.errorDescription = (sender as? [String])?.last
        case is SharedViewController:
            let sharedViewController = segue.destination as! SharedViewController
            var otherUsers = self.toDoPlanItCategory?.readAllCategoryInvitees() ?? []
            let categoryOwnerUserId = self.toDoPlanItCategory?.createdBy?.readValueOfUserId()
            otherUsers.sort { (user1, user2) -> Bool in
                user1.readValueOfUserId() == categoryOwnerUserId
            }
            sharedViewController.categoryOwnerId = categoryOwnerUserId
            sharedViewController.selectedInvitees = otherUsers.map({ return CalendarUser($0) })
        default: break
        }
    }

}
