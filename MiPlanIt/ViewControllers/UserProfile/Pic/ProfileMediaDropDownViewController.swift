//
//  ProfileMediaDropDownViewController.swift
//  MiPlanIt
//
//  Created by MS Nischal on 20/03/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

protocol ProfileMediaDropDownViewControllerDelegate: class {
    func profileMediaDropDownViewController(_ controller: ProfileMediaDropDownViewController, selectedOption: DropDownItem)
}

class ProfileMediaDropDownViewController: DropDownBaseViewController {
    
    weak var delegate: ProfileMediaDropDownViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func readDropDownCaption() -> String? {
        return Strings.chooseImage
    }
    
    override func readAllDropDownValues() -> [DropDownItem] {
        return self.readDropDownOptions()
    }

    override func readHeightForCell() -> CGFloat {
        return 54
    }
    
    override func sendSelectedOption(_ option: DropDownItem) {
        self.delegate?.profileMediaDropDownViewController(self, selectedOption: option)
    }
}
