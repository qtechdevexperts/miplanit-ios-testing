//
//  CustomCategoryToDoViewController+Offline.swift
//  MiPlanIt
//
//  Created by Arun on 16/09/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

extension CustomCategoryToDoViewController {
    
    func saveCategoryToServerUsingNetwotk(_ category: String) {
        if SocialManager.default.isNetworkReachable() {
            self.createWebServiceForTodoCategory(category)
        }
        else {
            self.toDoPlanItCategory = DataBasePlanItTodoCategory().insertNewOfflinePlanItToDoCategory(self.toDoPlanItCategory, name: category)
            self.updateViewAfterAddCategory()
        }
    }
    
    func saveCategoryShareToServerUsingNetwotk(_ category: PlanItTodoCategory?, users: [OtherUser]) {
        if SocialManager.default.isNetworkReachable() && !(category?.isPending ?? true) {
            self.createWebServiceForShareTodoCategory(category, users: users)
        }
        else {//Don't forget to clear all invitees from offline service
            guard let user = Session.shared.readUser() else { return }
            var allUser: [OtherUser] = [OtherUser(planItUser: user)]
            allUser.append(contentsOf: users)
            category?.shareTo(users: allUser)
            self.isCategoryDataUpdated = true
            self.showShareLabelCount()
            self.buttonHeaderInvitees.isHidden = category?.readAllToDoSharedInvitees().count == 0
        }
    }
    
    func saveCategoryDeleteToServerUsingNetwotk(_ category: PlanItTodoCategory) {
        if SocialManager.default.isNetworkReachable() && !category.isPending {
            self.createWebServiceForDeleteTodoCategory(category)
        }
        else {
            category.saveDeleteStatus(true)
            Session.shared.registerUserTodoLocationNotification()
            self.isCategoryDataUpdated = true
            self.navigationController?.popViewController(animated: true)
        }
    }
}
