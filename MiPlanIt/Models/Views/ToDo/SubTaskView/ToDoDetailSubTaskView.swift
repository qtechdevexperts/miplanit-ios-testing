//
//  ToDoDetailSubTaskView.swift
//  MiPlanIt
//
//  Created by Febin Paul on 07/07/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

class ToDoDetailSubTaskView: UIView {
    
    var toDoDetailModel: ToDoDetailModel!
    
    @IBOutlet weak var viewAddNewSubTask: UIView!
    @IBOutlet weak var stackViewSubTask: UIStackView!
    
    @IBAction func addSubTaskClicked(_ sender: UIButton) {
        let subTask = ToDoSubTaskView()
        subTask.textFieldToDo.becomeFirstResponder()
        subTask.delegate = self
        self.stackViewSubTask.addArrangedSubview(subTask)
        let newSubTask = SubToDoDetailModel(subToDoTitle: Strings.empty)
        self.toDoDetailModel.subToDos.append(newSubTask)
        subTask.setViewIndexForSubTask(newSubTask)
        self.moveAddSubViewToBottom()
    }
    
    func setSubToDoView() {
        self.removeAllArrangedSubviews()
        let subTasks = self.toDoDetailModel.subToDos.filter({ return !$0.deletedStatus })
        subTasks.forEach { (model) in
            let subTask = ToDoSubTaskView()
            subTask.delegate = self
            subTask.setViewIndexForSubTask(model)
            self.stackViewSubTask.addArrangedSubview(subTask)
        }
        self.moveAddSubViewToBottom()
    }
    
    func moveAddSubViewToBottom() {
        if let addView = self.stackViewSubTask.arrangedSubviews.filter({ $0.tag == 99 }).first {
            self.stackViewSubTask.removeArrangedSubview(addView)
            self.stackViewSubTask.addArrangedSubview(self.viewAddNewSubTask)
        }
    }
    
    @discardableResult func removeAllArrangedSubviews() -> [UIView] {
        return self.stackViewSubTask.arrangedSubviews.filter({$0.tag != 99}).reduce([UIView]()) { $0 + [removeArrangedSubViewProperly($1)] }
    }

    func removeArrangedSubViewProperly(_ view: UIView) -> UIView {
        self.stackViewSubTask.removeArrangedSubview(view)
        NSLayoutConstraint.deactivate(view.constraints)
        view.removeFromSuperview()
        return view
    }
}


