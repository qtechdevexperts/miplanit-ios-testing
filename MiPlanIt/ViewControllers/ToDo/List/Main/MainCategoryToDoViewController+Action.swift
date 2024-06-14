//
//  MainCategoryToDoViewController+Action.swift
//  MiPlanIt
//
//  Created by Febin Paul on 08/07/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

extension MainCategoryToDoViewController {
    
    func sortTodosWithCategoryType() {
        self.activityIndicator?.startAnimating()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            self.categorisedTodos.sort(by: { return $0.readOrderUsingStartDateOrCreatedDate(using: self.categoryType) < $1.readOrderUsingStartDateOrCreatedDate(using: self.categoryType) })
            self.allToDoItemCellModels = self.categorisedTodos.map({ ToDoItemCellModel(planItToDo: $0) })
//            self.categorisedTodos.removeAll()
            self.updateCompletedTable()
            self.activityIndicator?.stopAnimating()
        }
    }
    
    func initialRefreshControl() {
        self.refreshControl.tintColor = UIColor.white
        self.refreshControl.attributedTitle = NSAttributedString(string: "")
        self.refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        self.tableViewToDoItems?.addSubview(refreshControl)
    }
    
    @objc func refresh(_ sender: AnyObject) {
        self.refreshControl.beginRefreshing()
        self.createServiceToFetchUsersDataInsidePullToRefresh { [weak self] (serviceDetection) in
            guard let self = self else {return}
            if self.refreshControl.isRefreshing {
                self.refreshControl.endRefreshing()
                if serviceDetection.isContainedSpecificServiceData(.todo) {
                    self.labelHeaderTitle.text = self.showCetegoryTitle()
                    self.setVisibilityTopStackView()
                    self.sortTodosWithCategoryType()
                    self.isCategoryDataUpdated = true
                }
            }
        }
    }
    
    func showCetegoryTitle() -> String {
        switch self.categoryType {
        case .all:
            labelNoItemTitle.text = "No Tasks available"
            return "All"
        case .today:
            labelNoItemTitle.text = "No Tasks for Today"
            return "Today"
        case .upcomming:
            labelNoItemTitle.text = "No Upcoming Tasks available"
            return "Upcoming"
        case .favourite:
            labelNoItemTitle.text = "No Favorite Tasks available"
            return "Favorite"
        case .unplanned:
            labelNoItemTitle.text = "No Unplanned Tasks available"
            return "Unplanned"
        case .overdue:
            labelNoItemTitle.text = "No Overdue Tasks available"
            return "Overdue"
        case .assignedToMe:
            labelNoItemTitle.text = "No Tasks Assigned"
            return "Assigned to Me"
        case .completed:
            labelNoItemTitle.text = "No Tasks Completed"
            return "Completed"
        case .assignedbyMe:
            labelNoItemTitle.text = "No Tasks Assigned"
            return "Assigned by Me"
        case .custom:
            return Strings.empty
        }
    }
    
    func sendReadStatusOfTodoItemsToServer() {
        if self.categoryType == .assignedToMe {
            let unreadTodos = self.toDoItemCellModels.flatMap({ return $0.planItToDo.readAllInvitees() }).filter({ return $0.readValueOfUserId() == Session.shared.readUserId() && !$0.isRead }).compactMap({ return $0.todo })
            if !unreadTodos.isEmpty {
                self.delegate?.todoListBaseViewController(self, sendTodoReadStatus: unreadTodos)
            }
        }
    }
}
