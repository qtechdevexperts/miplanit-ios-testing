//
//  MoveListViewController.swift
//  MiPlanIt
//
//  Created by Febin Paul on 07/07/20.
//  Copyright © 2020 Arun. All rights reserved.
//


import Foundation
import UIKit
import IQKeyboardManagerSwift

protocol MoveListToDoViewControllerDelegate: class {
    func moveListToDoViewController(_ controller: MoveListToDoViewController, selectedOption: DropDownItem, moveToDos: [PlanItTodo])
}

class MoveListToDoViewController: DropDownBaseViewController {
    
    weak var delegate: MoveListToDoViewControllerDelegate?
    var currentCategory: PlanItTodoCategory?
    var moveToDos: [PlanItTodo] = []
    @IBOutlet weak var buttonBack: UIButton!
    @IBOutlet weak var buttonMove: ProcessingButton!
    @IBOutlet weak var textFieldNewList: FloatingTextField!
    @IBOutlet weak var viewNewList: UIView!
    @IBOutlet weak var viewMoveLists: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialiseComponents()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        IQKeyboardManager.shared.enable = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        IQKeyboardManager.shared.enable = false
    }
    
    override func readDropDownCaption() -> String? {
        return Strings.moveTo
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
        self.delegate?.moveListToDoViewController(self, selectedOption: option, moveToDos: self.moveToDos)
    }
    
    override func doneButtonTouched(_ sender: UIButton) {
        if let selectedItem = self.dropDownItems.filter({ $0.isSelected == true }).first {
            self.delegate?.moveListToDoViewController(self, selectedOption: selectedItem, moveToDos: self.moveToDos)
        }
        self.dismissDropDownButtonTouched(sender)
    }
    
    override func cancelOptionClicked(_ sender: UIButton) {
        let transition = CATransition()
        transition.duration = 0.25
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromLeft
        self.viewNewList.layer.add(transition, forKey: nil)
        self.viewNewList.isHidden = true
        self.textFieldNewList.resignFirstResponder()
    }

    @IBAction func newListButtonTouched(_ sender: UIButton) {
        self.viewNewList.isHidden = false
        let transition = CATransition()
        transition.duration = 0.25
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromRight
        self.viewNewList.layer.add(transition, forKey: nil)
    }
    
    @IBAction func moveOptionClicked(_ sender: UIButton) {
        var categoryName: String = "Untitled List"
        if let name = self.textFieldNewList.text?.trimmingCharacters(in: .whitespacesAndNewlines) {
            categoryName = name.isEmpty ?  categoryName : name
        }
        self.textFieldNewList.text = categoryName
        self.saveCategoryToServerUsingNetwotk(categoryName)
    }
}
