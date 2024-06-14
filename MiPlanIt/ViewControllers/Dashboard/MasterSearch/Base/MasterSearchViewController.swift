//
//  MasterSearchViewController.swift
//  MiPlanIt
//
//  Created by Febin Paul on 22/12/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

class MasterSearchViewController: DashboardBaseViewController {
    
    var masterSearchItems: [Int:[Any]] = [0: [], 1: [], 2: [], 3: [], 4: []] // 0: event, 1: todo, 2: shopping, 3: gift, 4: purchase
    var selectedFilterDate: Date!
    var selectedFilterDateEnd: Date!
    var activeSection: DashBoardTitle = .event {
        didSet {
            self.checkResultAndReload()
        }
    }
    var activeCustomDashboard: PlanItDashboard?
    
    @IBOutlet weak var imageViewNoResult: UIImageView!
    @IBOutlet weak var tableView: UITableView?
    @IBOutlet weak var buttonFilter: UIButton!
    @IBOutlet weak var textfieldSearch: UITextField!
    @IBOutlet weak var viewButtons: UIView!
    @IBOutlet weak var labelDateRange: UILabel!
    @IBOutlet weak var buttonCloseSearch: ProcessingButton!
    @IBOutlet weak var viewSearchSections: DashboardSearchSectionView!

    override func viewDidLoad() {
        self.initialDateRangeSetUp()
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.initializeUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.textfieldSearch.becomeFirstResponder()
    }
    @IBAction func backButtonClicked(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func closeSearchClicked(_ sender: UIButton) {
        self.textfieldSearch.text = Strings.empty
        self.view.endEditing(true)
        self.updateSearchList(forceReload: true)
    }
    
    @IBAction func searchValueChanged(_ sender: UITextField) {
        self.updateSearchList(forceReload: true)
    }
    
    @IBAction func filterButtonClicked(_ sender: UIButton) {
        self.view.endEditing(true)
        self.performSegue(withIdentifier: Segues.showSearchFilter, sender: nil)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        switch segue.destination {
        case is SearchFilterDateViewController:
            let searchFilterDateViewController = segue.destination as! SearchFilterDateViewController
            searchFilterDateViewController.delegate = self
            searchFilterDateViewController.startDateSelected = self.selectedFilterDate
            searchFilterDateViewController.endDateSelected = self.selectedFilterDateEnd
        default: break
        }
    }
    
    override func dashboardHaveExistingData(_ type: DashBoardTitle) {
        self.refreshSearchDataWith(type)
        super.dashboardHaveExistingData(type)
    }
    
    override func dashboardDidFinishDataManipulation(_ type: DashBoardTitle) {
        self.refreshSearchDataWith(type)
        super.dashboardDidFinishDataManipulation(type)
    }
    
    override func dasboardFindDataForCustomDashboard(_ type: DashBoardTitle) {
        self.updateSearchList(type)
    }
    
}
