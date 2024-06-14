//
//  MoreActionDropDownController.swift
//  MiPlanIt
//
//  Created by Febin Paul on 09/07/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit
import CoreGraphics

protocol MoreActionToDoDropDownControllerDelegate: class {
    func moreActionToDoDropDownController(_ controller: MoreActionToDoDropDownController, selectedOption: DropDownItem)
}

class MoreActionToDoDropDownController: DropDownBaseViewController {

    @IBOutlet weak var viewTransition: UIView!
    weak var delegate: MoreActionToDoDropDownControllerDelegate?
    var containsToDoItems: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func readDropDownCaption() -> String? {
        return Strings.listOption
    }
    
    func setSortByCaption() {
        self.labelDopDownTitle.text =  Strings.sortBy
    }
    
    override func readAllDropDownValues() -> [DropDownItem] {
        return self.readListDropDownOptions()
    }
    
    override func readHeightForCell() -> CGFloat {
        return 54
    }
    
    override func readHeightForDropDownView() -> CGFloat {
        return 300
    }
    
    @IBAction func dismissButtonTouched(_ sender: UIButton) {
        self.showOrHideDropDownOptions(false)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.26) {
            self.dismiss(animated: false, completion: nil)
        }
    }
    
    override func dismissDropDownButtonTouched(_ sender: UIButton) {
        let transition = CATransition()
        transition.duration = 0.25
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromLeft
        self.tableViewDropDownOptions.superview?.layer.add(transition, forKey: nil)
        self.buttonCancel?.isHidden = true
        self.labelDopDownTitle.text = self.readDropDownCaption()
        self.dropDownItems = self.readListDropDownOptions()
    }
    
    override func sendSelectedOption(_ option: DropDownItem) {
        switch option.dropDownType {
        case .eSortOption:
            let transition = CATransition()
            transition.duration = 0.25
            transition.type = CATransitionType.push
            transition.subtype = CATransitionSubtype.fromRight
            self.viewTransition.layer.add(transition, forKey: nil)
            self.buttonCancel?.isHidden = false
            self.setSortByCaption()
            self.dropDownItems = self.readSortDropDownOptions()
        default:
            self.showOrHideDropDownOptions(false)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.26) {
                self.dismiss(animated: false) {
                    self.delegate?.moreActionToDoDropDownController(self, selectedOption: option)
                }
            }
            
        }
    }

}
