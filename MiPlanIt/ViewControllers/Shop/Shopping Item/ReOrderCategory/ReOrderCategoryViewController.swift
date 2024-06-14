//
//  ReOrderCategoryViewController.swift
//  MiPlanIt
//
//  Created by Febin Paul on 28/04/21.
//  Copyright © 2021 Arun. All rights reserved.
//

import UIKit

protocol ReOrderCategoryViewControllerDelegate: class {
    func reorderCategoryViewController(_ ReOrderCategoryViewController: ReOrderCategoryViewController, shopListCategorys: [ShopItemListSection])
}

class ReOrderCategoryViewController: UIViewController {
    
    var shopListCategory: [ShopItemListSection] = []
    weak var delegate: ReOrderCategoryViewControllerDelegate?

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bottomDropDownConstraints: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.initializeUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.showOrHideDropDownOptions(true)
        super.viewDidAppear(animated)
    }
    
    @IBAction func closeButtonClicked(_ sender: UIButton) {
        self.showOrHideDropDownOptions(false)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.26) {
            self.dismiss(animated: false, completion: nil)
        }
    }
    
    
    @IBAction func doneButtonClicked(_ sender: UIButton) {
        self.shopListCategory.enumerated().forEach({ $1.setOrderValue($0) })
        self.delegate?.reorderCategoryViewController(self, shopListCategorys: self.shopListCategory)
        self.showOrHideDropDownOptions(false)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.26) {
            self.dismiss(animated: false, completion: nil)
        }
    }
}
