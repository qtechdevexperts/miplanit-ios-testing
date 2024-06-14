//
//  PurchaseViewController.swift
//  MiPlanIt
//
//  Created by Aneesh Asokan on 29/04/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit
import Lottie

class PurchaseViewController: BaseViewController {
    
    var filterCriteria: [Filter] = [] {
        didSet {
            self.showPurchaseBasedOnFilterCriteria()
        }
    }
    var allPurchases: [PlanItPurchase] = [] {
        didSet {
            if filterCriteria.isEmpty {
                self.showPurchaseBasedOnSearchCriteria()
            }
            else {
                self.showPurchaseBasedOnFilterCriteria()
            }
        }
    }
    
    var userPurchases: [PlanItPurchase] = [] {
        didSet {
            self.viewNoItem.isHidden = !self.userPurchases.isEmpty
            self.tableViewPurchasesList.reloadData()
            if self.refreshControl.isRefreshing {
                self.refreshControl.endRefreshing()
            }
        }
    }
    var refreshControl = UIRefreshControl()

    @IBOutlet weak var viewNoItem: UIView!
    @IBOutlet weak var buttonFilter: UIButton!
    @IBOutlet weak var buttonClearSearch: UIButton!
    @IBOutlet weak var buttonSearch: UIButton!
    @IBOutlet weak var textFieldSearch: PaddingTextField!
    @IBOutlet weak var tableViewPurchasesList: UITableView!
    @IBOutlet weak var constraintSearchViewHeight: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialUIComponents()
        self.readAllUserPurchasesUsingFilterCriteria()
        self.createServiceToFetchUsersData()
        // Do any additional setup after loading the view.
    }
    
    override func usersCalendarUpdatedWithInformation(_ notify: Notification) {
        guard let serviceDetection = notify.object as? [ServiceDetection], serviceDetection.isContainedSpecificServiceData(.purchase) else { return }
        self.readAllUserPurchasesUsingFilterCriteria()
    }

    @IBAction func searchButtonClicked(_ sender: UIButton) {
        self.updateSearchHeight(sender: sender)
    }
    
    @IBAction func clearSearchButtonClicked(_ sender: Any) {
        self.textFieldSearch.text = Strings.empty
        self.buttonSearch.isSelected = false
        self.buttonClearSearch.isHidden = true
        if filterCriteria.isEmpty {
            self.showPurchaseBasedOnSearchCriteria()
        }
        else {
            self.showPurchaseBasedOnFilterCriteria()
        }
    }
    
    @IBAction func addPurchaseButtonClicked(_ sender: UIButton) {
        if Session.shared.readIsExhausted() {
            self.showExhaustedAlert()
            return
        }
        self.performSegue(withIdentifier: Segues.toAddPurchase, sender: nil)
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.destination {
        case is NavigationDrawerViewController:
            let navigationDrawerViewController = segue.destination as! NavigationDrawerViewController
            navigationDrawerViewController.selectedOption = .purchase
        case is TabViewController:
            let tabViewController = segue.destination as! TabViewController
            tabViewController.selectedOption = .purchase
        case is MessageViewController:
            let messageViewController = segue.destination as! MessageViewController
            messageViewController.caption = (sender as? [String])?.first
            messageViewController.errorDescription = (sender as? [String])?.last
        case is AddPurchaseViewController:
            let addPurchaseViewController = segue.destination as! AddPurchaseViewController
            addPurchaseViewController.delegate = self
        case is PurchaseDetailViewController:
            let purchaseDetailViewController = segue .destination as! PurchaseDetailViewController
            purchaseDetailViewController.planitPurchase = sender as? PlanItPurchase
            purchaseDetailViewController.delegate = self
        case is PurchaseFilterViewController:
            let purchaseFilterViewController = segue.destination as! PurchaseFilterViewController
            purchaseFilterViewController.purchases = self.allPurchases
            purchaseFilterViewController.selectedFilters = self.filterCriteria
            purchaseFilterViewController.delegate = self
        default: break
        }
    }

}
