//
//  GiftTypeDropDownViewController.swift
//  MiPlanIt
//
//  Created by Aneesh Asokan on 22/12/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit
protocol GiftTypeDropDownViewControllerDelegate: class {
    func giftTypeDropDownViewController(_ controller: GiftTypeDropDownViewController, selectedOption: DropDownItem)
}

class GiftTypeDropDownViewController: DropDownBaseViewController {

    weak var delegate: GiftTypeDropDownViewControllerDelegate?

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
        self.delegate?.giftTypeDropDownViewController(self, selectedOption: option)
    }

}
