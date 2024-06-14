//
//  RepeatFullDropDownViewController.swift
//  MiPlanIt
//
//  Created by Febin Paul on 14/04/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

protocol RepeatFullDropDownViewControllerDelegate: class {
    func repeatDropDownViewController(_ controller: RepeatFullDropDownViewController, selectedDone: RepeatDropDown)
}

class RepeatFullDropDownViewController: RepeatDropDownBaseViewController {
    
    weak var delegate: RepeatFullDropDownViewControllerDelegate?
    var dropDownCategory: DropDownCategory = .eFrequency
    var repeatModel: RepeatModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func readDropDownCaption() -> String? {
        return Strings.chooseRepeatType
    }
    
    override func readAllDropDownValues() -> [DropDownItem] {
        return self.readDropDownOptions()
    }

    override func readHeightForCell() -> CGFloat {
        return 54
    }
    override func readHeightForDropDownView() -> CGFloat {
        return 400
    }
    override func sendSelectedOption(_ option: RepeatDropDown) {
        self.delegate?.repeatDropDownViewController(self, selectedDone: option)
    }
    
}
