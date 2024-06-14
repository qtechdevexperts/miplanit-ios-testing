//
//  AttachFileDropDownViewController.swift
//  MiPlanIt
//
//  Created by MS Nischal on 20/03/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

protocol AttachListFileDropDownViewControllerDelegate: class {
    func attachListFileDropDownViewController(_ controller: AttachListFileDropDownViewController, selectedOption: DropDownItem)
}

class AttachListFileDropDownViewController: DropDownBaseViewController {
    
    weak var delegate: AttachListFileDropDownViewControllerDelegate?

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
    
    override func readHeightForDropDownView() -> CGFloat {
        return 280
    }
    
    override func sendSelectedOption(_ option: DropDownItem) {
        self.delegate?.attachListFileDropDownViewController(self, selectedOption: option)
    }
}
