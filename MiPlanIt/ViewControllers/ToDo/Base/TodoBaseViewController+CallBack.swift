//
//  TodoBaseViewController+CallBack.swift
//  MiPlanIt
//
//  Created by Febin Paul on 08/07/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

extension TodoBaseViewController: ToDoDashBoardMenuViewDelegate {
    
    func toDoDashBoardMenuView(_ toDoDashBoardMenuView: ToDoDashBoardMenuView, onSelected todos: [PlanItTodo], category: ToDoMainCategory) {
        self.performSegue(withIdentifier: Segues.toMainCategoryToDoListView, sender: (todos, category))
    }
}

extension TodoBaseViewController: ToDoTaskListViewDelegate {
    
    func toDoTaskListView(_ toDoTaskListView: ToDoTaskListView, sliderSelected: Bool) {
        
    }
    
    func toDoTaskListView(_ toDoTaskListView: ToDoTaskListView, didSelectCategory category: PlanItTodoCategory, at indexPath: IndexPath) {
        self.performSegue(withIdentifier: Segues.toCustomCategoryToDoListView, sender: (category, indexPath))
    }
    
    func toDoTaskListView(_ toDoTaskListView: ToDoTaskListView, assignUserForCategory category: PlanItTodoCategory, at indexPath: IndexPath) {
        self.performSegue(withIdentifier: Segues.toInviteesList, sender: (category, indexPath))
    }
    
    func toDoTaskListView(_ toDoTaskListView: ToDoTaskListView, printCategory category: PlanItTodoCategory, at indexPath: IndexPath) {
        self.printToDos(category)
    }
    
    
    func toDoTaskListView(_ toDoTaskListView: ToDoTaskListView, deleteCategory category: PlanItTodoCategory, at indexPath: IndexPath) {
        self.showAlertWithAction(message: Message.deleteCategoryMessage, title: Message.deleteTodoCategory, items: [Message.yes, Message.cancel], callback: { index in
            if index == 0 {
                self.saveCategoryDeleteToServerUsingNetwotk(category, at: indexPath)
            }
        })
    }
    
    func toDoTaskListView(_ toDoTaskListView: ToDoTaskListView, showSharedUserForCategory category: PlanItTodoCategory, at indexPath: IndexPath) {
        self.performSegue(withIdentifier: Segues.toSharedUsers, sender: (category, indexPath))
    }
}

extension TodoBaseViewController: ShareToDoListViewControllerDelegate {
    
    func shareToDoListViewController(_ viewController: ShareToDoListViewController, selected users: [OtherUser]) {
        guard let indexPath = viewController.selectedIndexPath else { return }
        self.saveCategoryShareToServerUsingNetwotk(self.viewCustomToDoListContainer.categories[indexPath.section].categories[indexPath.row], users: users, at: indexPath)
    }
}

extension TodoBaseViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}


extension TodoBaseViewController: ToDoListBaseViewControllerDelegate {
    
    func todoListBaseViewControllerDidChangeTodoItems(_ viewController: ToDoListBaseViewController) {
        self.showAllTodoCategoriesValues()
    }
    
    func todoListBaseViewController(_ viewController: ToDoListBaseViewController, sendTodoReadStatus todos: [PlanItTodo]) {
        switch viewController.categoryType {
        case .assignedToMe:
            todos.forEach({
                if let invitees = $0.readAllInvitees().filter({ $0.readValueOfUserId() == Session.shared.readUserId() }).first {
                    invitees.isRead = true
                }
            })
            CoreData.default.mainManagedObjectContext.saveContext()
            if let viewIndex = self.viewMenus.firstIndex(where: { $0.mainCategory == .assignedToMe }) {
                self.viewMenus[viewIndex].updateUnReadCountOfAssignedToMe()
            }
        case .overdue:
            todos.forEach({ $0.overdueViewStatus = true })
//            try? CoreData.default.persistentContainer.viewContext.save()
            CoreData.default.mainManagedObjectContext.saveContext()
            if let viewIndex = self.viewMenus.firstIndex(where: { $0.mainCategory == .overdue }) {
                self.viewMenus[viewIndex].updateUnReadCountOfOverdue()
            }
        case .completed:
            todos.forEach({ $0.completedViewStatus = true })
//            try? CoreData.default.persistentContainer.viewContext.save()
            CoreData.default.mainManagedObjectContext.saveContext()
            if let viewIndex = self.viewMenus.firstIndex(where: { $0.mainCategory == .completed }) {
                self.viewMenus[viewIndex].updateUnReadCountOfCompleted()
            }
        default:
            break
        }
    }
}


extension TodoBaseViewController: TabViewControllerDelegate {
    
    func tabViewController(_ tabViewController: TabViewController, updateHeightWithAd: Bool) {
        self.constraintTabHeight?.constant = updateHeightWithAd ? 147 : 77
    }
}
