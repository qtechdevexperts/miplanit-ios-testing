//
//  ToDoSubTaskView.swift
//  MiPlanIt
//
//  Created by Febin Paul on 13/07/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit
import GrowingTextView
import IQKeyboardManagerSwift

protocol ToDoSubTaskViewDelegate: AnyObject {
    func toDoSubTaskView(_ toDoSubTaskView: ToDoSubTaskView, onDelete subToDoModel: SubToDoDetailModel, uniqueId: String)
}


class ToDoSubTaskView: UIView {
    
    let kCONTENT_XIB_NAME = "ToDoSubTaskView"
    
    var uniqueId: String!
    var subToDoModel: SubToDoDetailModel!
    weak var delegate: ToDoSubTaskViewDelegate?

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var buttonCompletion: UIButton!
    @IBOutlet weak var textFieldToDo: GrowingTextView!
    @IBOutlet weak var buttonDelete: UIButton!
    
    @IBAction func buttonDeleted(_ sender: UIButton) {
        self.delegate?.toDoSubTaskView(self, onDelete: self.subToDoModel, uniqueId: self.uniqueId)
    }
    
    @IBAction func completionButtonClicked(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        self.subToDoModel.completed = sender.isSelected
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed(kCONTENT_XIB_NAME, owner: self, options: nil)
        contentView.fixInView(self)
        self.addDoneButtonOnKeyboard()
    }
    
    func addDoneButtonOnKeyboard(){
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        doneToolbar.barStyle = .default

        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.doneButtonAction))

        let items = [flexSpace, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()

        self.textFieldToDo.inputAccessoryView = doneToolbar
    }

    @objc func doneButtonAction(){
        self.textFieldToDo.resignFirstResponder()
    }
    
    func setViewIndexForSubTask(_ subToDoModel: SubToDoDetailModel) {
        self.uniqueId = subToDoModel.uniqueUUID
        self.subToDoModel = subToDoModel
        self.textFieldToDo.text = subToDoModel.subTodoTitle
        self.buttonCompletion.isSelected = subToDoModel.completed
    }
    
}


extension ToDoSubTaskView: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        self.subToDoModel.subTodoTitle = textView.text
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        textView.returnKeyType = ((textView.text?.isEmpty ?? Strings.empty.isEmpty || (range.length == 1 && range.location == 0)) && text.isEmpty) ? .default : .done
        textView.reloadInputViews()
        if (text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
}


extension ToDoSubTaskView: GrowingTextViewDelegate {
    func textViewDidChangeHeight(_ textView: GrowingTextView, height: CGFloat) {
        IQKeyboardManager.shared.reloadLayoutIfNeeded()
    }
}
