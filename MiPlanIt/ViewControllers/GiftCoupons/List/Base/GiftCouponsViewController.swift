//
//  PurchaseViewController.swift
//  MiPlanIt
//
//  Created by Aneesh Asokan on 29/04/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

class GiftCouponsViewController: BaseViewController {
    
    var selectedCategory = GiftCouponType.active
    var refreshControl = UIRefreshControl()
    var filterCriteria: [Filter] = [] {
        didSet {
            self.showGiftCouponsBasedOnFilterCriteria()
        }
    }
    var allGiftCoupons: [PlanItGiftCoupon] = [] {
        didSet {
            if filterCriteria.isEmpty {
                self.showGiftCouponsBasedOnSearchCriteria()
            }
            else {
                self.showGiftCouponsBasedOnFilterCriteria()
            }
        }
    }
    
    var userGiftCoupons: [PlanItGiftCoupon] = [] {
        didSet {
            if self.refreshControl.isRefreshing {
                self.refreshControl.endRefreshing()
            }
            self.viewNoItem.isHidden = !self.userGiftCoupons.isEmpty
            self.tableViewGiftCouponsList.reloadData()
            
        }
    }
    
    @IBOutlet weak var tableViewGiftCouponsList: UITableView!
    @IBOutlet weak var viewNoItem: UIView!
    @IBOutlet weak var buttonClearSearch: UIButton!
    @IBOutlet weak var textFieldSearch: PaddingTextField!
    @IBOutlet weak var buttonSearch: UIButton!
    @IBOutlet weak var buttonFilter: UIButton!
    @IBOutlet weak var constraintSearchViewHeight: NSLayoutConstraint!
    @IBOutlet weak var viewCouponStatusSelection: CouponStatusSelectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.selectedCategory = .active
        self.initialUIComponents()
        self.readAllUserGiftCouponsUsingFilterCriteria()
        self.createServiceToFetchUsersData()
        // Do any additional setup after loading the view.
    }
    
    override func usersCalendarUpdatedWithInformation(_ notify: Notification) {
        guard let serviceDetection = notify.object as? [ServiceDetection], serviceDetection.isContainedSpecificServiceData(.gift) else { return }
        self.readAllUserGiftCouponsUsingFilterCriteria()
    }

    @IBAction func searchButtonClicked(_ sender: UIButton) {
        self.updateSearchHeight(sender: sender)
    }
    
    @IBAction func clearSearchButtonClicked(_ sender: Any) {
        self.textFieldSearch.text = Strings.empty
        self.buttonSearch.isSelected = false
        self.buttonClearSearch.isHidden = true
        if filterCriteria.isEmpty {
            self.showGiftCouponsBasedOnSearchCriteria()
        }
        else {
            self.showGiftCouponsBasedOnFilterCriteria()
        }
        
    }
    
    @IBAction func addCouponButtonClicked(_ sender: UIButton) {
        if Session.shared.readIsExhausted() {
            self.showExhaustedAlert()
            return
        }
        self.performSegue(withIdentifier: Segues.toAddGiftCoupon, sender: nil)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.destination {
        case is NavigationDrawerViewController:
            let navigationDrawerViewController = segue.destination as! NavigationDrawerViewController
            navigationDrawerViewController.selectedOption = .giftCoupon
        case is TabViewController:
            let tabViewController = segue.destination as! TabViewController
            tabViewController.selectedOption = .giftCoupon
        case is MessageViewController:
            let messageViewController = segue.destination as! MessageViewController
            messageViewController.caption = (sender as? [String])?.first
            messageViewController.errorDescription = (sender as? [String])?.last
        case is AddGiftCouponsViewController:
            let addGiftCouponsViewController = segue.destination as! AddGiftCouponsViewController
            addGiftCouponsViewController.delegate = self
        case is GiftCouponDetailViewController:
            let giftCouponDetailViewController = segue.destination as! GiftCouponDetailViewController
            giftCouponDetailViewController.planItGiftCoupon = sender as? PlanItGiftCoupon
            giftCouponDetailViewController.delegate = self
        case is GiftFilterViewController:
            let giftFilterViewController = segue.destination as! GiftFilterViewController
            giftFilterViewController.giftCoupons = self.allGiftCoupons
            giftFilterViewController.selectedFilters = self.filterCriteria
            giftFilterViewController.delegate = self
        default: break
        }
    }
}
