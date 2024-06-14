//
//  ShoppingListViewController.swift
//  MiPlanIt
//
//  Created by Aneesh Asokan on 04/05/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit
import Lottie

class ShoppingListViewController: BaseViewController {
    
    var allShoppingList: [PlanItShopList] = [] {
        didSet {
            self.searchShoppingWithText(self.textFieldSearch.text ?? Strings.empty)
        }
    }
    
    var userShoppingList: [PlanItShopList] = [] {
        didSet {
            self.viewNoShopList.isHidden = !self.userShoppingList.isEmpty
            if self.refreshControl.isRefreshing {
                self.refreshControl.endRefreshing()
            }
        }
    }
    
    var fetchedMasterAndUserItems: Bool = false
    var categories: [ShoppingListCategory] = []
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var buttonClearSearch: UIButton!
    @IBOutlet weak var textFieldSearch: PaddingTextField!
    @IBOutlet weak var buttonSearch: UIButton!
    @IBOutlet weak var constraintSearchViewHeight: NSLayoutConstraint!
    @IBOutlet weak var viewNoShopList: UIView!
    @IBOutlet weak var viewFetchingData: UIView!
    @IBOutlet var lottieAnimationView: LottieAnimationView!
    @IBOutlet weak var constraintTabHeight: NSLayoutConstraint?
    
    var refreshControl = UIRefreshControl()
    var selectedShopList: PlanItShopList?
    var selectedIndexPath: IndexPath?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialUIComponents()
        self.createServiceToMasterData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.addNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.removeNotifications()
    }
    
    deinit {
        print("deinit called")
    }
    
    @IBAction func searchButtonClicked(_ sender: UIButton) {
        self.updateSearchHeight(sender: sender)
    }
    
    @IBAction func clearSearchButtonClicked(_ sender: Any) {
        self.textFieldSearch.text = Strings.empty
        self.searchShoppingListUsingText(Strings.empty)
    }
    
    @IBAction func addButtonClicked(_ sender: Any) {
        if Session.shared.readIsExhausted() {
            self.showExhaustedAlert()
            return
        }
        self.performSegue(withIdentifier: Segues.toAddShoppingList, sender: self)
    }
    
    @IBAction func searchTextChanges(_ sender: UITextField) {
        self.showShoppingListBasedOnSearchCriteria()
    }
    
    override func usersCalendarUpdatedWithInformation(_ notify: Notification) {
        guard self.isViewDidLoaded, let serviceDetection = notify.object as? [ServiceDetection], serviceDetection.isContainedSpecificServiceData(.shop) else { return }
        self.readAllUserShoppingList()
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.destination {
        case is NavigationDrawerViewController:
            let navigationDrawerViewController = segue.destination as! NavigationDrawerViewController
            navigationDrawerViewController.selectedOption = .shoppingList
        case is TabViewController:
            let tabViewController = segue.destination as! TabViewController
            tabViewController.selectedOption = .shoppingList
            tabViewController.delegate = self
        case is AddShoppingItemsViewController:
            let addShoppingItemsViewController = segue.destination as! AddShoppingItemsViewController
            if let planItShopList = sender as? PlanItShopList {
                addShoppingItemsViewController.planItShopList = planItShopList
            }
            addShoppingItemsViewController.delegate = self
        case is MessageViewController:
            let messageViewController = segue.destination as! MessageViewController
            messageViewController.caption = (sender as? [String])?.first
            messageViewController.errorDescription = (sender as? [String])?.last
        case is CreateNewListViewController:
            let createNewListViewController = segue.destination as! CreateNewListViewController
            createNewListViewController.delegate = self
            if let shopList = sender as? PlanItShopList {
                createNewListViewController.shop = ShopList(with: shopList)
            }
        case is SharedViewController:
            let sharedViewController = segue.destination as! SharedViewController
            if let info = sender as? PlanItShopList {
                var otherUsers = info.readAllShopListShareInvitees()
                let categoryOwnerUserId = info.createdBy?.readValueOfUserId()
                otherUsers.sort { (user1, user2) -> Bool in
                    user1.readValueOfUserId() == categoryOwnerUserId
                }
                sharedViewController.categoryOwnerId = categoryOwnerUserId
                sharedViewController.selectedInvitees = otherUsers.map({ return CalendarUser($0) })
            }
        case is ShareShoppingViewController:
            let shareShoppingViewController = segue.destination as! ShareShoppingViewController
            shareShoppingViewController.delegate = self
            if let shopList = sender as? (PlanItShopList, IndexPath) {
                self.selectedShopList = shopList.0
                self.selectedIndexPath = shopList.1
                shareShoppingViewController.selectedInvitees = shopList.0.readAllOtherUser()
            }
        default: break
        }
    }

}
