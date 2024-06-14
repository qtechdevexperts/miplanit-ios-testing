//
//  CustomDashBoardListViewController.swift
//  MiPlanIt
//
//  Created by fsadmin on 06/11/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

protocol CustomDashBoardListViewControllerDelegate: class {
    func customDashBoardListViewController(_ customDashBoardListViewController: CustomDashBoardListViewController, deleted dashBoard: CustomDashboardProfile)
    func customDashBoardListViewController(_ customDashBoardListViewController: CustomDashBoardListViewController, onSelect dashBoard: CustomDashboardProfile?)
    func customDashBoardListViewController(_ customDashBoardListViewController: CustomDashBoardListViewController, onCreate dashBoard: CustomDashboardProfile)
    func customDashBoardListViewController(_ customDashBoardListViewController: CustomDashBoardListViewController, update profile: CustomDashboardProfile)
}

class CustomDashBoardListViewController: UIViewController {
    
    var customDashboardProfile: [CustomDashboardProfile] = [] {
        didSet {
            self.tableView?.reloadData()
        }
    }
    var itemsCount: Int = 0
    var dashboardEvents: [DashboardEventItem] = []
    var dashboardTodos: [DashboardToDoItem] = []
    var dashboardPurchase: [DashboardPurchaseItem] = []
    var dashboardGifts: [DashboardGiftItem] = []
    var dashboardShopListItems: [DashboardShopListItem] = []
    weak var delegate: CustomDashBoardListViewControllerDelegate?
    var editable: Bool = true
    var activeDashboardSection: DashBoardSection = .today
    @IBOutlet weak var buttonAddDashboard: UIButton!
    @IBOutlet weak var tableView: UITableView?
    @IBOutlet weak var viewUsersList: UIView!
    @IBOutlet weak var labelDashboardSection: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialiseUIComponents()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !self.isHelpShown() {
            self.performSegue(withIdentifier: "toCustomDashboardListHelp", sender: nil)
            Storage().saveBool(flag: true, forkey: UserDefault.customDashboardListHelp)
        }
    }
    
    @IBAction func buttonBackClicked(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func helpButtonClicked(_ sender: UIButton) {
        self.performSegue(withIdentifier: "toCustomDashboardListHelp", sender: nil)
        Storage().saveBool(flag: true, forkey: UserDefault.customDashboardListHelp)
    }
    
    @IBAction func buttonAddUsersClicked(_ sender: UIButton) {
        if Session.shared.readIsExhausted() {
            self.showExhaustedAlert()
            return
        }
        self.performSegue(withIdentifier: Segues.toCreateDashboard, sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.destination {
        case is CreateDashboardViewController:
            let createDashboardViewController =  segue.destination as! CreateDashboardViewController
            createDashboardViewController.delegate = self
            createDashboardViewController.customDashboardProfiles = self.customDashboardProfile
            if let customDashboardProfile = sender as? CustomDashboardProfile {
                createDashboardViewController.dashboardModel = Dashboard(with: customDashboardProfile.planItDashboard)
            }
        case is DashBoardLongPressPopUpVC:
            let dashBoardLongPressPopUpVC =  segue.destination as! DashBoardLongPressPopUpVC
            dashBoardLongPressPopUpVC.dashboardEvents = self.dashboardEvents
            dashBoardLongPressPopUpVC.dashboardTodos = self.dashboardTodos
            dashBoardLongPressPopUpVC.dashboardShopListItems = self.dashboardShopListItems
            dashBoardLongPressPopUpVC.dashboardPurchase = self.dashboardPurchase
            dashBoardLongPressPopUpVC.dashboardGifts = self.dashboardGifts
            dashBoardLongPressPopUpVC.activeSection = self.activeDashboardSection
            if let profile = sender as? CustomDashboardProfile {
                dashBoardLongPressPopUpVC.selectedDashboardProfile = profile
                dashBoardLongPressPopUpVC.profileImage = profile.planItDashboard.readImage()
            }
        default: break
        }
    }
    
}
