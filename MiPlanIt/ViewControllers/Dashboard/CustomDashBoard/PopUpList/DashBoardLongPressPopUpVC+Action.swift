//
//  DashBoardLongPressPopUpVC+Action.swift
//  MiPlanIt
//
//  Created by Febin Paul on 04/03/21.
//  Copyright © 2021 Arun. All rights reserved.
//

import Foundation


extension DashBoardLongPressPopUpVC {
    
    func initializeUIComponents() {
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture))
        swipeDown.direction = .down
        self.view.addGestureRecognizer(swipeDown)
        self.constraintBottomView.constant = self.bottomConstraintValue
        let name = Session.shared.readUser()?.readValueOfName() ?? Strings.myDashboard
        self.labelDashboardName.text = self.selectedDashboardProfile?.planItDashboardName ?? name
        
        if let imageData = self.profileImage as? Data {
            self.imageProfile.image = UIImage(data: imageData)
        }
        else if let profileImageString = self.profileImage as? String {
            self.imageProfile.pinImageFromURL(URL(string: profileImageString), placeholderImage: UIImage(named: Strings.dashboardDefaultIcon))
        }
        else if let user = Session.shared.readUser(){
            self.imageProfile.pinImageFromURL(URL(string: user.readValueOfProfile()), placeholderImage: UIImage(named: Strings.dashboardDefaultIcon))
        }
        let eventCount = self.selectedDashboardProfile?.totalEventsCount ?? self.dashboardEvents.count
        let toDoCount = self.selectedDashboardProfile?.totalTodosCount ?? self.dashboardTodos.count
        let purchaseCount = self.selectedDashboardProfile?.totalPurchasesCount ?? self.dashboardPurchase.count
        let giftsCount = self.selectedDashboardProfile?.totalGiftsCount ?? self.dashboardGifts.count
        let shopListCount = self.selectedDashboardProfile?.totalShopingCount ?? self.dashboardShopListItems.count
        
        self.viewEventContainer.isHidden = eventCount == 0
        self.labelEvent.text = "Events (\(eventCount))"
        
        self.viewToDoContainer.isHidden = toDoCount == 0
        self.labelToDo.text = "To Do (\(toDoCount))"
        
        self.viewShoppingContainer.isHidden = shopListCount == 0
        self.labelShopping.text = "Shopping (\(shopListCount))"
        
        self.viewReceiptBills.isHidden = purchaseCount == 0
        self.labelReceiptBill.text = "Receipts & Bills (\(purchaseCount))"
        
        self.viewCouponGiftContainer.isHidden = giftsCount == 0
        self.labelCouponGift.text = "Coupons & Gifts (\(giftsCount))"
        
        self.labelSubText.text = Message.dashboardPopUpSubText(eventCount+toDoCount+purchaseCount+giftsCount+shopListCount, self.activeSection)
    }
    
    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        self.toggleCompletedView(showFlag: false)
    }
    
    func toggleCompletedView(showFlag: Bool) {
        self.constraintBottomView.constant = showFlag ? -40 : -UIScreen.main.bounds.size.height
        UIView.animate(withDuration: 0.2, delay: 0.0, options: UIView.AnimationOptions.curveEaseIn, animations: {
            self.view.layoutIfNeeded()
         }) { (finished) in
            if !showFlag {
                self.dismiss(animated: false, completion: nil)
            }
        }
    }
}
