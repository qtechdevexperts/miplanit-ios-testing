//
//  PurchaseTypeDropDownViewController.swift
//  MiPlanIt
//
//  Created by Febin Paul on 08/01/21.
//  Copyright © 2021 Arun. All rights reserved.
//

import UIKit

protocol PurchaseTypeDropDownViewControllerDelegate: class {
    func purchaseTypeDropDownViewController(_ controller: PurchaseTypeDropDownViewController, selectedOption: DropDownItem)
}

class PurchaseTypeDropDownViewController: DropDownBaseViewController {

    weak var delegate: PurchaseTypeDropDownViewControllerDelegate?

    var dropDownOptions: [DropDownItem] = [] {
        didSet {
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func readDropDownCaption() -> String? {
        return "Select Category"
    }
    
    override func readAllDropDownValues() -> [DropDownItem] {
        return self.readDropDownOptions()
    }

    override func readHeightForCell() -> CGFloat {
        return 54
    }
    
    override func readHeightForDropDownView() -> CGFloat {
        return 250.0
    }
    
    override func sendSelectedOption(_ option: DropDownItem) {
        self.delegate?.purchaseTypeDropDownViewController(self, selectedOption: option)
    }

}
