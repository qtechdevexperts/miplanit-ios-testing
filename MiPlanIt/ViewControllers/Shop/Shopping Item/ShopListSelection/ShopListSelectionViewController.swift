//
//  ShopListSelectionViewController.swift
//  MiPlanIt
//
//  Created by Febin Paul on 13/11/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

protocol  ShopListSelectionViewControllerDelegate: class {
    func shopListSelectionViewController(_ shopListSelectionViewController: ShopListSelectionViewController, selectedShopList: PlanItShopList)
}

class ShopListSelectionViewController: UIViewController {

    var allShopListSelectionOptions: [ShopListSelectionOption] = [] {
        didSet{
            self.tableView.reloadData()
        }
    }
    var currentShopList: PlanItShopList!
    weak var delegate: ShopListSelectionViewControllerDelegate?
    var planItShopListItem: [PlanItShopListItems] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.createShopListData()
    }
    
    @IBAction func doneButtonClicked(_ sender: UIButton) {
        self.dismiss(animated: false) {
            self.delegate?.shopListSelectionViewController(self, selectedShopList: self.currentShopList)
        }
    }
    
    @IBAction func cancelButtonClicked(_ sender: UIButton) {
        self.dismiss(animated: false, completion: nil)
    }
    
}
