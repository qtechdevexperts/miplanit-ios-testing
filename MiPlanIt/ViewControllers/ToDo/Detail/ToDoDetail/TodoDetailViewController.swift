//
//  TodoDetailViewController.swift
//  MiPlanIt
//
//  Created by Febin Paul on 28/07/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

class TodoDetailViewController: BaseTodoDetailViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func ReminderButtonClicked(_ sender: UIButton) {
        guard self.toDoDetailModel.dueDate != nil else {
            return
        }
        self.performSegue(withIdentifier: "seguePushReminder", sender: self)
    }
    
    @IBAction func repeatButtonClicked(_ sender: UIButton) {
        guard self.toDoDetailModel.dueDate != nil else {
            return
        }
        self.performSegue(withIdentifier: Segues.showToDoRepeat, sender: self)
    }
    
    @IBAction override func saveActionClicked(_ sender: UIButton) {
        self.view.endEditing(true)
        if self.textFieldToDoName.text.length == 0 {
            self.performSegue(withIdentifier: Segues.toMessageScreen, sender: [Message.warning, Message.blankTitle])
            return
        }
        self.cachedImageNormal   = self.buttonSave.image(for: .normal)
        self.buttonSave.startAnimation()
        self.startPendingUploadOfAttachment(from: true)
    }
    
    @IBAction override func backButtonClicked(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction override func attachButtonClicked(_ sender: UIButton) {
        self.view.endEditing(true)
        self.performSegue(withIdentifier: self.mainToDoItem.completed ? Segues.toAttachments : Segues.toProfileDropDown, sender: self)
    }
    
    override func navigateBack() {
        self.navigationController?.popViewController(animated: true)
    }
}
