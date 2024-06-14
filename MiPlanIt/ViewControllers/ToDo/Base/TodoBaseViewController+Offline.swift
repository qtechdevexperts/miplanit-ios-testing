//
//  TodoBaseViewController+Offline.swift
//  MiPlanIt
//
//  Created by Arun on 17/09/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

extension TodoBaseViewController {
    
    func saveCategoryShareToServerUsingNetwotk(_ category: PlanItTodoCategory, users: [OtherUser], at indexPath: IndexPath) {
        if SocialManager.default.isNetworkReachable() && !category.isPending {
            self.createWebServiceForShareTodoCategory(category, users: users, at: indexPath)
        }
        else {
            category.shareTo(users: users)
            self.viewCustomToDoListContainer.refreshCategories()
        }
    }
    
    func saveCategoryDeleteToServerUsingNetwotk(_ category: PlanItTodoCategory, at indexPath: IndexPath) {
        if SocialManager.default.isNetworkReachable() && !category.isPending  {
            self.createWebServiceForDeleteTodoCategory(category, at: indexPath)
        }
        else {
            category.saveDeleteStatus(true)
            Session.shared.registerUserTodoLocationNotification()
            self.showAllTodoCategoriesValues()
        }
    }
}
