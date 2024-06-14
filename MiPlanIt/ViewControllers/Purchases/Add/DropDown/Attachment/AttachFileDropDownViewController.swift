//
//  AttachFileDropDownViewController.swift
//  MiPlanIt
//
//  Created by MS Nischal on 20/03/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

protocol AttachFileDropDownViewControllerDelegate: class {
    func attachFileDropDownViewController(_ controller: AttachFileDropDownViewController, selectedOption: DropDownItem)
}

class AttachFileDropDownViewController: DropDownBaseViewController {
    
    weak var delegate: AttachFileDropDownViewControllerDelegate?
    var countofAttachments = 0
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
        return self.countofAttachments > 0 ? 370 : 300
    }
    
    override func sendSelectedOption(_ option: DropDownItem) {
        self.delegate?.attachFileDropDownViewController(self, selectedOption: option)
    }
}
