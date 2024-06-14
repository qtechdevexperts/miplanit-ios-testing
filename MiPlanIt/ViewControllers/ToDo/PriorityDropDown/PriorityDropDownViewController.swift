//
//  PriorityDropDownViewController.swift
//  MiPlanIt
//
//  Created by Febin Paul on 19/05/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

protocol PriorityDropDownViewControllerDelegate: class {
    func priorityDropDownViewController(_ controller: PriorityDropDownViewController, selectedOption: DropDownItem)
}

class PriorityDropDownViewController: DropDownBaseViewController {
    
    weak var delegate: PriorityDropDownViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func readDropDownCaption() -> String? {
        return Strings.choosePriorityType
    }
    
    override func readAllDropDownValues() -> [DropDownItem] {
        return self.readDropDownOptions()
    }
    
    override func readHeightForCell() -> CGFloat {
        return 54
    }
    
    override func readHeightForDropDownView() -> CGFloat {
        return 370
    }
    
    override func sendSelectedOption(_ option: DropDownItem) {
        self.delegate?.priorityDropDownViewController(self, selectedOption: option)
    }
    
}
