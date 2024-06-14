//
//  RequestNotificationViewController.swift
//  MiPlanIt
//
//  Created by Febin Paul on 08/04/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit
import Lottie

class RequestNotificationViewController: SwipeDrawerViewController {
    
    enum ActivityType: Int {
       case calendar = 1, event = 2, todoList = 3, shoppingList = 4, todoAssignee = 5
    }
    
    var currentPage: Int = 0
    var itemsPerPage: Int = 50
    var pendingReadRequest: [Double] = []
    var refreshControl = UIRefreshControl()
    @IBOutlet weak var viewFetchingData: UIView!
    @IBOutlet var lottieAnimationView: LottieAnimationView!
    @IBOutlet weak var tableViewNotification: UITableView!
    @IBOutlet weak var imageViewEmptyNotification: UIImageView!
    @IBOutlet weak var buttonFilterOption: UIButton!
    @IBOutlet weak var buttonClearAll: ProcessingButton!
    @IBOutlet weak var constraintTabHeight: NSLayoutConstraint?
    
    var showAnimation: Bool = true
    var selectedFilter = DropDownOptionType.eDefault {
        didSet {
            self.buttonFilterOption.isSelected = self.selectedFilter != .eDefault
        }
    }
    
    var userNotifications: [UserNotification] = [] {
        didSet {
            guard self.selectedFilter == .eDefault else { return }
            self.showingUserNotifications = self.userNotifications
        }
    }
    
    var showingUserNotifications: [UserNotification] = [] {
        didSet {
            self.tableViewNotification.reloadData()
            self.imageViewEmptyNotification.isHidden = !self.showingUserNotifications.isEmpty
            self.buttonClearAll.isHidden = self.showingUserNotifications.isEmpty
            if self.refreshControl.isRefreshing {
                self.refreshControl.endRefreshing()
            }
        }
    }
    
    var serviceStarted = false {
        didSet {
            if self.serviceStarted { if self.showAnimation {self.startLottieAnimations()} }
            else { self.stopLottieAnimations(); self.buttonClearAll.isHidden = false }
        }
    }
    
    @IBAction func clearAllButtonClicked(_ sender: UIButton) {
        self.deleteNotification()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialiseUIComponents()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.getUserNotificationFromNetwork()
        super.viewWillAppear(animated)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.destination {
        case is NavigationDrawerViewController:
            let navigationDrawerViewController =  segue.destination as! NavigationDrawerViewController
            navigationDrawerViewController.selectedOption = .requests
        case is FilterViewController:
            let filterViewController = segue.destination as! FilterViewController
            filterViewController.delegate = self
            filterViewController.selectedFilter = self.selectedFilter
        case is TabViewController:
            let tabViewController = segue.destination as! TabViewController
            tabViewController.selectedOption = .notification
            tabViewController.delegate = self
        case is MessageViewController:
            let messageViewController = segue.destination as! MessageViewController
            messageViewController.caption = (sender as? [String])?.first
            messageViewController.errorDescription = (sender as? [String])?.last
        case is NotificationToDoDetailViewController:
            let todoDetailViewController = segue.destination as! NotificationToDoDetailViewController
            if let planItTodo = sender as? PlanItTodo {
                todoDetailViewController.mainToDoItem = planItTodo
            }
        default: break
        }
    }
}
