//
//  FilterDropDownViewController.swift
//  MiPlanIt
//
//  Created by MS Nischal on 20/03/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

protocol PurchaseFilterDropDownViewControllerDelegate: class {
    func purchaseFilterDropDownViewController(_ controller: PurchaseFilterDropDownViewController, selectedOption: DropDownItem)
}

class PurchaseFilterDropDownViewController: DropDownBaseViewController {
    
    weak var delegate: PurchaseFilterDropDownViewControllerDelegate?
    var dropDownOptions: [DropDownItem] = [] {
        didSet {
            
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func readDropDownCaption() -> String? {
        return "Select Item"
    }
    
    override func readAllDropDownValues() -> [DropDownItem] {
        return self.readDropDownOptions()
    }

    override func readHeightForCell() -> CGFloat {
        return 54
    }
    
    override func readHeightForDropDownView() -> CGFloat {
        return 350.0
    }
    
    override func sendSelectedOption(_ option: DropDownItem) {
        self.delegate?.purchaseFilterDropDownViewController(self, selectedOption: option)
    }
}
