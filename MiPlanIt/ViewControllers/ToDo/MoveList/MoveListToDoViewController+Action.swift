//
//  MovelListViewController+Action.swift
//  MiPlanIt
//
//  Created by Febin Paul on 07/07/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

extension MoveListToDoViewController {
    func initialiseComponents() {
        self.viewNewList.isHidden = true
    }
    
    func readDropDownOptions() -> [DropDownItem]  {
        return DataBasePlanItTodoCategory().readAllAvailableUserToDoCategory().map{ book in
            var isSelected: Bool = false
            if let category = self.currentCategory {
                isSelected = book.readIdentifier() == category.readIdentifier()
            }
            return DropDownItem(name: book.readCategoryName(), identifier: book.readCategoryName(), isNeedImage: true, isSelected: isSelected, imageName: FileNames.todolistIcon, value: book.readIdentifier())
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.dropDownItems.forEach{( $0.isSelected = false )}
        self.dropDownItems[indexPath.row].isSelected = true
        self.tableViewDropDownOptions.reloadData()
    }
    
    func showTryAgainAlertForCategory() {
        self.showAlertWithAction(message: Message.toDoNotSaved, title: Message.unknownError, items: [Message.cancel, Message.tryAgain], callback: { index in
            if index == 0 {
                self.dismiss(animated: true, completion: nil)
            }
            else if let category = self.textFieldNewList.text {
                self.saveCategoryToServerUsingNetwotk(category)
            }
        })
    }
}

extension MoveListToDoViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        textField.returnKeyType = ((textField.text?.isEmpty ?? Strings.empty.isEmpty || (range.length == 1 && range.location == 0)) && string.isEmpty) ? .default : .done
        textField.reloadInputViews()
        return true
    }
   
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
