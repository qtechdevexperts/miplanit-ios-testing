//
//  FilterViewController.swift
//  MiPlanIt
//
//  Created by Febin Paul on 08/04/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

protocol FilterViewControllerDelegate: AnyObject {
    func filterViewControllerResetAllOptions(_ viewController: FilterViewController)
    func filterViewController(_ viewController: FilterViewController, selected option: DropDownItem)
}

class FilterViewController: DropDownBaseViewController {
    
    weak var delegate: FilterViewControllerDelegate?
    var selectedFilter: DropDownOptionType = .eDefault
    @IBOutlet weak var buttonResetFilter: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateResetButtonStatus()
    }
    
    override func readDropDownCaption() -> String? {
        return Strings.filter
    }
    
    override func readAllDropDownValues() -> [DropDownItem] {
        return self.readDropDownOptions()
    }

    override func readHeightForCell() -> CGFloat {
        return 90
    }
    
    override func readHeightForDropDownView() -> CGFloat {
        return 400.0
    }

    override func sendSelectedOption(_ option: DropDownItem) {
        self.delegate?.filterViewController(self, selected: option)
    }
    
    @IBAction func resetButtonClicked(_ sender: Any) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.26) {
            self.delegate?.filterViewControllerResetAllOptions(self)
        }
    }
}
