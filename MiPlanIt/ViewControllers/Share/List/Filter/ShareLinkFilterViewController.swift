//
//  ShareLinkFilterViewController.swift
//  MiPlanIt
//
//  Created by Febin Paul on 31/03/21.
//  Copyright © 2021 Arun. All rights reserved.
//

import UIKit

protocol ShareLinkFilterViewControllerDelegate: class {
    func shareLinkFilterViewControllerResetAllOptions(_ viewController: ShareLinkFilterViewController)
    func shareLinkFilterViewController(_ viewController: ShareLinkFilterViewController, selected option: DropDownItem)
}

class ShareLinkFilterViewController: DropDownBaseViewController {
    
    var selectedFilter: DropDownOptionType?
    weak var delegate: ShareLinkFilterViewControllerDelegate?
    
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
        self.delegate?.shareLinkFilterViewController(self, selected: option)
    }
    
    @IBAction func resetButtonClicked(_ sender: Any) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.26) {
            self.delegate?.shareLinkFilterViewControllerResetAllOptions(self)
        }
    }
}
