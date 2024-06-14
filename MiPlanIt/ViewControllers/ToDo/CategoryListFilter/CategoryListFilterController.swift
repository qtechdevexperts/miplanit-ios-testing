//
//  CategoryListFilterController.swift
//  MiPlanIt
//
//  Created by Febin Paul on 01/07/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

protocol CategoryListFilterControllerDelegate: class {
    func categoryListFilterController(_ controller: CategoryListFilterController, selectedOption: DropDownItem)
    func categoryListFilterControllerClearOption(_ controller: CategoryListFilterController)
    func categoryListFilterControllerClearOption(_ controller: CategoryListFilterController, selectedOption: DropDownItem, selectedDate: Date)
}

class CategoryListFilterController: DropDownBaseViewController {
    
    weak var delegate: CategoryListFilterControllerDelegate?
    var categoryType: ToDoMainCategory = .custom
    var activeFilter: DropDownItem?
    
    @IBOutlet weak var viewDueDate: UIView!
    @IBAction func dueDateCloseButtonClicked(_ sender: UIButton) {
        self.viewDueDate.isHidden = true
    }
    
    @IBAction func dueDateDoneButtonClicked(_ sender: UIButton) {
        let dropDownDate =  DropDownItem(name: Strings.date, type: .eCreatedDate, isNeedImage: true, isSelected: self.isFilterActive(on: .eCreatedDate), imageName: FileNames.calendarIcon, value: Date().stringFromDate(format: DateFormatters.DDHMMHYYYY))
        self.delegate?.categoryListFilterController(self, selectedOption: dropDownDate)
        self.dismissDropDownButtonTouched(sender)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func readDropDownCaption() -> String? {
        return Strings.filter
    }
    
    override func readAllDropDownValues() -> [DropDownItem] {
        return self.readDropDownOptions()
    }
    
    override func readHeightForCell() -> CGFloat {
        return 54
    }
    
    override func readHeightForDropDownView() -> CGFloat {
        return 320
    }
    
    override func sendSelectedOption(_ option: DropDownItem) {
        self.delegate?.categoryListFilterController(self, selectedOption: option)
    }
    
    override func cancelOptionClicked(_ sender: UIButton) {
        self.delegate?.categoryListFilterControllerClearOption(self)
        self.dismissDropDownButtonTouched(sender)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.dropDownItems[indexPath.row].dropDownType == .eCreatedDate {
            self.viewDueDate.isHidden = false
            return
        }
        self.showOrHideDropDownOptions(false)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.26) {
            self.dismiss(animated: false) {
                self.sendSelectedOption(self.dropDownItems[indexPath.row])
            }
        }
    }
    
}
