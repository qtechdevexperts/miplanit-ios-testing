//
//  ToDoRemindViewController.swift
//  MiPlanIt
//
//  Created by Febin Paul on 13/07/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

protocol ToDoRemindViewControllerDelegate: class {
    func toDoRemindViewController(_ controller: ToDoRemindViewController, selectedOption: DropDownItem)
}

class ToDoRemindViewController: DropDownBaseViewController {
    
    weak var delegate: ToDoRemindViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func readDropDownCaption() -> String? {
        return Strings.chooseRemindType
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
    
    override func sendSelectedOption(_ option: DropDownItem) {
        self.delegate?.toDoRemindViewController(self, selectedOption: option)
    }
    
}
 
