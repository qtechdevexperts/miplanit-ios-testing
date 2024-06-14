//
//  TodoBaseViewController.swift
//  MiPlanIt
//
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

class TodoBaseViewController: BaseViewController {
    
    var toDoStartingTopConstant : CGFloat = 20.0
    var refreshControl = UIRefreshControl()
    var notificationTodoListId: Double?
    
    @IBOutlet weak var viewOverlay: UIView!
    @IBOutlet weak var viewToDoMenu: UIView!
    @IBOutlet weak var buttonProcessing: ProcessingButton!
    @IBOutlet weak var viewCustomToDoListContainer: ToDoTaskListView!
    @IBOutlet weak var constraintToDoListViewTop: NSLayoutConstraint!
    @IBOutlet var viewMenus: [ToDoDashBoardMenuView]!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var constraintTabHeight: NSLayoutConstraint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initilizeUIComponent()
        self.createServiceToFetchUsersData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.addNotifications()
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.removeNotifications()
        super.viewWillDisappear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if self.viewCustomToDoListContainer.buttonSlider.isSelected {
            self.showCard(expanded: false, isAnimated: false)
        }
        super.viewDidAppear(animated)
    }
    
    override func usersCalendarUpdatedWithInformation(_ notify: Notification) {
        guard self.isViewDidLoaded, let serviceDetection = notify.object as? [ServiceDetection], serviceDetection.isContainedSpecificServiceData(.todo) else { return }
        self.showAllTodoCategoriesValues()
    }
    
    @IBAction func addCategoryButtonClicked(_ sender: UIButton) {
        if Session.shared.readIsExhausted() {
            self.showExhaustedAlert()
            return
        }
        self.performSegue(withIdentifier: Segues.toCustomCategoryToDoListView, sender: nil)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.destination {
        case is NavigationDrawerViewController:
            let navigationDrawerViewController =  segue.destination as! NavigationDrawerViewController
            navigationDrawerViewController.selectedOption = .myTask
        case is TabViewController:
            let tabViewController = segue.destination as! TabViewController
            tabViewController.selectedOption = .myTask
            tabViewController.delegate = self
        case is ShareToDoListViewController:
            let shareToDoListViewController = segue.destination as! ShareToDoListViewController
            shareToDoListViewController.delegate = self
            if let info = sender as? (PlanItTodoCategory, IndexPath) {
                shareToDoListViewController.selectedIndexPath = info.1
                shareToDoListViewController.selectedInvitees = info.0.readAllOtherUser()
            }
        case is SharedViewController:
            let sharedViewController = segue.destination as! SharedViewController
            if let info = sender as? (PlanItTodoCategory, IndexPath) {
                var otherUsers = info.0.readAllCategoryInvitees()
                let categoryOwnerUserId = info.0.createdBy?.readValueOfUserId()
                otherUsers.sort { (user1, user2) -> Bool in
                    user1.readValueOfUserId() == categoryOwnerUserId
                }
                sharedViewController.categoryOwnerId = categoryOwnerUserId
                sharedViewController.selectedInvitees = otherUsers.map({ return CalendarUser($0) })
            }
        case is MainCategoryToDoViewController:
            let mainCategoryToDoViewController = segue.destination as! MainCategoryToDoViewController
            mainCategoryToDoViewController.delegate = self
            if let info = sender as? ([PlanItTodo], ToDoMainCategory) {
                mainCategoryToDoViewController.categoryType = info.1
                mainCategoryToDoViewController.categorisedTodos = info.0
            }
        case is CustomCategoryToDoViewController:
            let customCategoryToDoViewController = segue.destination as! CustomCategoryToDoViewController
            customCategoryToDoViewController.delegate = self
            if let info = sender as? (PlanItTodoCategory, IndexPath) {
                customCategoryToDoViewController.toDoPlanItCategory = info.0
            }
        case is MessageViewController:
            let messageViewController = segue.destination as! MessageViewController
            messageViewController.caption = (sender as? [String])?.first
            messageViewController.errorDescription = (sender as? [String])?.last
        default: break
        }
    }
}
