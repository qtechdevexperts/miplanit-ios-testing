//
//  CountrySelectionViewController.swift
//  MiPlanIt
//
//  Created by Nikhil RajG on 17/03/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

protocol CountrySelectionViewControllerDelegate: class {
    func countrySelectionViewController(_ viewController: CountrySelectionViewController, selectedCode: String)
}

class CountrySelectionViewController: UIViewController {
    
    weak var delegate: CountrySelectionViewControllerDelegate?
    
    @IBOutlet weak var textFieldSearch: UITextField!
    @IBOutlet weak var tableViewCountryCode: UITableView!
    
    var showingCountries: [Country] = []  {
        didSet {
            self.tableViewCountryCode.reloadData()
        }
    }
    
    lazy var countries: [Country] = {
        return self.readCountries()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.showingCountries = self.countries
        // Do any additional setup after loading the view.
    }
    
    @IBAction func backButtonClicked(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}
