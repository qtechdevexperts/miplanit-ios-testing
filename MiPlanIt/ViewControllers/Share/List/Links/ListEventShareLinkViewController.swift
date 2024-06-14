//
//  ListEventShareLinkViewController.swift
//  MiPlanIt
//
//  Created by Febin Paul on 29/03/21.
//  Copyright © 2021 Arun. All rights reserved.
//

import UIKit

class ListEventShareLinkViewController: UIViewController {
    
    var allShareLinks: [PlanItShareLink] = [] {
        didSet {
            self.showListBasedOnFilterCriteria()
        }
    }
    
    var showShareListLists: [PlanItShareLink] = [] {
        didSet {
            self.viewNoItem.isHidden = !self.showShareListLists.isEmpty
            self.tableView.reloadData()
        }
    }
    var refreshControl = UIRefreshControl()
    var filterCriteria: DropDownOptionType? = nil {
        didSet {
            self.showListBasedOnFilterCriteria()
        }
    }
    var apiCallInProgress: Bool = false
    
    @IBOutlet weak var buttonProcessingLoader: ProcessingButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var constraintSearchViewHeight: NSLayoutConstraint!
    @IBOutlet weak var buttonSearch: UIButton!
    @IBOutlet weak var buttonClearSearch: UIButton!
    @IBOutlet weak var textFieldSearch: PaddingTextField!
    @IBOutlet weak var buttonFilterOption: UIButton!
    @IBOutlet weak var viewNoItem: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.initializeData()
    }

    @IBAction func backButtonClicked(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func searchButtonClicked(_ sender: UIButton) {
        self.updateSearchHeight(sender: sender)
    }
    
    @IBAction func clearSearchButtonClicked(_ sender: Any) {
        self.clearSearch()
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.destination {
        case is CreateShareLinkViewController:
            let createShareLinkViewController = segue.destination as! CreateShareLinkViewController
            if let planItShareLink = sender as? PlanItShareLink {
                createShareLinkViewController.shareLinkModel = MiPlanitShareLink(planItShareLink)
                createShareLinkViewController.delegate = self
            }
        case is ShareLinkFilterViewController:
            let shareLinkFilterViewController = segue.destination as! ShareLinkFilterViewController
            shareLinkFilterViewController.delegate = self
            shareLinkFilterViewController.selectedFilter = self.filterCriteria
        default: break
        }
    }
    
}
