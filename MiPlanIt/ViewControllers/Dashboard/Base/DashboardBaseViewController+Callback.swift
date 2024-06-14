//
//  DashboardBaseViewController+Callback.swift
//  MiPlanIt
//
//  Created by Arun Aniyappan on 16/12/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

extension DashboardBaseViewController: BaseTodoDetailViewControllerDelegate {
    
    func baseTodoDetailViewController(_ viewController: BaseTodoDetailViewController, updated todo: PlanItTodo, completed: Bool) { self.detectTodoUpdate() }
}

extension DashboardBaseViewController: ViewEventViewControllerDelegate {
    
    func viewEventViewController(_ viewController: ViewEventViewController, update events: [PlanItEvent], deletedChilds: [String]?) { self.detectEventUpdate() }
    
    func viewEventViewController(_ viewController: ViewEventViewController, update events: [OtherUserEvent], deletedChilds: [String]?) { self.detectEventUpdate() }
    
    func viewEventViewController(_ viewController: ViewEventViewController, deleted events: [PlanItEvent], deletedChilds: [String]?, withType type: RecursiveEditOption) { self.detectEventUpdate() }
    
    func viewEventViewController(_ viewController: ViewEventViewController, deleted events: [OtherUserEvent], deletedChilds: [String]?, withType type: RecursiveEditOption) { self.detectEventUpdate() }
}

extension DashboardBaseViewController: PurchaseDetailViewControllerDelegate {
    
    func purchaseDetailViewController(_ viewController: PurchaseDetailViewController, deletedPurchase purchase: PlanItPurchase) { self.detectPurchaseUpdate() }
    
    func purchaseDetailViewController(_ viewController: PurchaseDetailViewController, updatedPurchase purchase: PlanItPurchase) { self.detectPurchaseUpdate() }
}

extension DashboardBaseViewController: GiftCouponDetailViewControllerDelegate {
    
    func giftCouponDetailViewController(_ viewController: GiftCouponDetailViewController, deletedGiftCoupon giftCoupon: PlanItGiftCoupon) { self.detectGiftCardUpdate() }
    
    func giftCouponDetailViewController(_ viewController: GiftCouponDetailViewController, updatedGiftCoupon giftCoupon: PlanItGiftCoupon) { self.detectGiftCardUpdate() }
}

extension DashboardBaseViewController: ToDoListBaseViewControllerDelegate {
    
    func todoListBaseViewControllerFetchData(_ viewController: ToDoListBaseViewController, completion: @escaping ([ServiceDetection])->()) {
        self.createServiceToDoPullToRefresh { (serviceDectection) in
            completion(serviceDectection)
        }
    }
    
    func todoListBaseViewControllerDidChangeTodoItems(_ viewController: ToDoListBaseViewController) {
        self.detectTodoUpdate()
    }
    
    func todoListBaseViewController(_ viewController: ToDoListBaseViewController, sendTodoReadStatus todos: [PlanItTodo]) {
        switch viewController.categoryType {
        case .overdue:
            todos.forEach({ $0.overdueViewStatus = true })
            CoreData.default.mainManagedObjectContext.saveContext()
        default:
            break
        }
    }
    
}

extension DashboardBaseViewController: ShoppingItemDetailViewControllerDelegate {
    
    func shoppingItemDetailViewController(_ shoppingItemDetailViewController: ShoppingItemDetailViewController, onAddUserCategory: CategoryData) {
        
    }
    
    func shoppingItemDetailViewController(_ shoppingItemDetailViewController: ShoppingItemDetailViewController, addUpdateItemDetail: ShopListItemDetailModel) {
        self.detectShopingUpdate()
    }
    
    func shoppingItemDetailViewController(_ shoppingItemDetailViewController: ShoppingItemDetailViewController, onDeleteShopListItem: ShopListItemDetailModel) {
        self.detectShopingUpdate()
    }
}


extension DashboardBaseViewController: PricingViewControllerDelegate {
    
    func pricingViewController(_ pricingViewController: PricingViewController, purchaseStatus: Bool) {
        if purchaseStatus {
            self.createWebServiceToCheckInApp()
        }
        else {
            /// if purchase failed
        }
    }
}
