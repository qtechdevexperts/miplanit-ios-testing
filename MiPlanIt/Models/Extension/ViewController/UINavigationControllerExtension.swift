//
//  UINavigationControllerExtension.swift
//  EZCapture
//
//  Created by Arun on 28/12/19.
//  Copyright © 2019 Arun. All rights reserved.
//

import UIKit

extension UINavigationController {
    
    func storyboard(_ name: String, setRootViewController identifier: String, animated: Bool = true, fromMenu: Bool = false, force: Bool = false) {
        guard self.viewControllers.first?.restorationIdentifier != identifier || force else {
            if identifier == StoryBoardIdentifier.calendar && !fromMenu {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: Notifications.calendarResetToInitialDate), object: nil)
            }
            return
        }
        isMenuOpened = fromMenu
        let storyBoard = UIStoryboard(name: name, bundle: Bundle.main)
        let viewController = storyBoard.instantiateViewController(withIdentifier: identifier)
        self.setViewControllers([viewController], animated: animated)
    }
    
    func storyboardShoppingItemList(planItShopList: PlanItShopList, onComplete completeFlag: Bool = false) {
        let storyBoard = UIStoryboard(name: StoryBoards.shoppingList, bundle: Bundle.main)
        let viewController = storyBoard.instantiateViewController(withIdentifier: StoryBoardIdentifier.shoppingList) as! ShoppingListViewController
        let shopItemsListVC = storyBoard.instantiateViewController(withIdentifier: StoryBoardIdentifier.AddShoppingItemsViewController) as! AddShoppingItemsViewController
        shopItemsListVC.planItShopList = planItShopList
        shopItemsListVC.defaultOpenCompleteSection = completeFlag
        self.setViewControllers([viewController, shopItemsListVC], animated: true)
    }
    
    func storyboardToDoList(planItToDoCategory: PlanItTodoCategory, onComplete completeFlag: Bool = false) {
        let storyBoard = UIStoryboard(name: StoryBoards.myTask, bundle: Bundle.main)
        let todoBaseViewController = storyBoard.instantiateViewController(withIdentifier: StoryBoardIdentifier.todoBase) as! TodoBaseViewController
        let todoListViewController = storyBoard.instantiateViewController(withIdentifier: StoryBoardIdentifier.customCategoryToDoViewController) as! CustomCategoryToDoViewController
        todoListViewController.toDoPlanItCategory = planItToDoCategory
        self.setViewControllers([todoBaseViewController, todoListViewController], animated: true)
    }
}
