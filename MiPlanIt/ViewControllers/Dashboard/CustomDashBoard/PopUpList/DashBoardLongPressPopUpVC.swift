//
//  DashBoardLongPressPopUpVC.swift
//  MiPlanIt
//
//  Created by Febin Paul on 04/03/21.
//  Copyright © 2021 Arun. All rights reserved.
//

import UIKit

class DashBoardLongPressPopUpVC: UIViewController {

    var bottomConstraintValue = -(UIScreen.main.bounds.size.height)
    var dashboardEvents: [DashboardEventItem] = []
    var dashboardTodos: [DashboardToDoItem] = []
    var dashboardPurchase: [DashboardPurchaseItem] = []
    var dashboardGifts: [DashboardGiftItem] = []
    var dashboardShopListItems: [DashboardShopListItem] = []
    var selectedDashboardProfile: CustomDashboardProfile?
    var activeSection: DashBoardSection! = .today
    var profileImage: Any?
    
    @IBOutlet weak var constraintBottomView: NSLayoutConstraint!
    @IBOutlet weak var labelEvent: UILabel!
    @IBOutlet weak var labelToDo: UILabel!
    @IBOutlet weak var labelShopping: UILabel!
    @IBOutlet weak var labelCouponGift: UILabel!
    @IBOutlet weak var labelReceiptBill: UILabel!
    @IBOutlet weak var viewEventContainer: UIView!
    @IBOutlet weak var viewToDoContainer: UIView!
    @IBOutlet weak var viewShoppingContainer: UIView!
    @IBOutlet weak var viewCouponGiftContainer: UIView!
    @IBOutlet weak var viewReceiptBills: UIView!
    @IBOutlet weak var labelDashboardName: UILabel!
    @IBOutlet weak var labelSubText: UILabel!
    @IBOutlet weak var imageProfile: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.initializeUIComponents()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.toggleCompletedView(showFlag: true)
    }
    
    @IBAction func closePopUpButtonClicked(_ sender: UIButton) {
        self.toggleCompletedView(showFlag: false)
    }
    
}
