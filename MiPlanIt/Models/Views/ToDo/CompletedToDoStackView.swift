//
//  CompletedToDoStackView.swift
//  MiPlanIt
//
//  Created by Febin Paul on 02/07/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

protocol CompletedEditActionToDoStackViewDelegate: class {
    func completedEditActionAssignedTo(_ completedEditActionToDoStackView: CompletedEditActionToDoStackView)
    func completedEditActionMoveTo(_ completedEditActionToDoStackView: CompletedEditActionToDoStackView)
    func completedEditActionDueDate(_ completedEditActionToDoStackView: CompletedEditActionToDoStackView)
    func completedEditActionDelete(_ completedEditActionToDoStackView: CompletedEditActionToDoStackView)
    
    func completedEditActionToDoStackView(_ completedEditActionToDoStackView: CompletedEditActionToDoStackView, unCompleteToDo: ToDoItemCellModel)
    func completedEditActionToDoStackView(_ completedEditActionToDoStackView: CompletedEditActionToDoStackView, onFavouriteToDo: ToDoItemCellModel, flag: Bool)
    func completedEditActionToDoStackView(_ completedEditActionToDoStackView: CompletedEditActionToDoStackView, onDeleteToDo: ToDoItemCellModel)
    func completedEditActionToDoStackView(_ completedEditActionToDoStackView: CompletedEditActionToDoStackView, onSelectToDo: ToDoItemCellModel)
    func completedEditActionToDoStackView(_ completedEditActionToDoStackView: CompletedEditActionToDoStackView, setOverlay flag: Bool)
    func completedEditActionToDoStackViewUncompleAll(_ completedEditActionToDoStackView: CompletedEditActionToDoStackView)
    func completedEditActionToDoStackViewMoveAll(_ completedEditActionToDoStackView: CompletedEditActionToDoStackView)
}

class CompletedEditActionToDoStackView: UIStackView {
    
    weak var delegate: CompletedEditActionToDoStackViewDelegate?
    var completedItems: [ToDoItemCellModel] = [] {
        didSet {
            self.viewCompleteSection.isHidden = completedItems.count == 0
            self.labelCompleted?.text = "COMPLETED (\(completedItems.count))"
            self.tableViewToDoItems.reloadData()
            if completedItems.count == 0 {
                self.hideCompleteSection()
            }
        }
    }
    
    @IBOutlet weak var tableViewToDoItems: UITableView!
    @IBOutlet weak var buttonArrow: UIButton!
    @IBOutlet weak var viewCompleteSection: UIView!
    @IBOutlet weak var viewAction: UIView!
    @IBOutlet weak var labelCompleted: UILabel?
    @IBOutlet weak var viewDismissTap: UIView!
    @IBOutlet weak var buttonUncompleteAll: UIButton!
    @IBOutlet weak var buttonMoveAll: UIButton!
    
    @IBAction func toggleShowToDoClicked(_ sender: UIButton) {
        self.toggleCompletedToDos(show: !self.buttonArrow.isSelected)
    }
    
    func toggleCompletedToDos(show flag: Bool) {
        self.viewDismissTap.isHidden = !flag
        self.buttonArrow.isSelected = flag
        self.buttonArrow.isHidden = flag
        self.buttonUncompleteAll.isHidden = !flag
        self.buttonMoveAll.isHidden = !flag
        self.delegate?.completedEditActionToDoStackView(self, setOverlay: flag)
        flag ? self.tableViewToDoItems.showAnimated(in: self) : self.tableViewToDoItems.hideAnimated(in: self)
    }
    
//    func hideCompletedSection() {
//        self.buttonArrow.isSelected = false
//        self.tableViewToDoItems.isHidden = true
//    }
    
    func setCompletedItems(items: [ToDoItemCellModel]) {
        self.completedItems = items
    }
    
    func removeDeletedItemsFromCompletedList() {
        self.completedItems.removeAll(where: { return $0.planItToDo.readDeleteStatus() })
        if self.completedItems.isEmpty {
            self.hideCompleteSection()
        }
    }
    
    func refreshCategoriesAfterUserFavouriteTodos() {
        self.tableViewToDoItems.reloadData()
    }
    
    func setActionView(mode: ToDoMode) {
        self.viewAction.isHidden = mode == .default
    }
    
    func hideCompleteSection() {
        self.viewCompleteSection.isHidden = true
        self.tableViewToDoItems.isHidden = true
        self.buttonArrow.isSelected = false
        self.toggleCompletedToDos(show: self.buttonArrow.isSelected)
        self.viewDismissTap.isHidden = true
    }
    
    func showCompleteSection() {
        self.viewCompleteSection.isHidden = false
        self.tableViewToDoItems.isHidden = false
        self.buttonArrow.isSelected = true
        self.toggleCompletedToDos(show: self.buttonArrow.isSelected)
        self.viewDismissTap.isHidden = false
    }
    
    func resetCompleteSection() {
        self.viewCompleteSection.isHidden = completedItems.count == 0
    }

    @IBAction func assignToClicked(_ sender: UIButton) {
        self.delegate?.completedEditActionAssignedTo(self)
    }
    
    @IBAction func moveToClicked(_ sender: UIButton) {
        self.delegate?.completedEditActionMoveTo(self)
    }
    
    @IBAction func dueDateClicked(_ sender: UIButton) {
        self.delegate?.completedEditActionDueDate(self)
    }
    
    @IBAction func deleteClicked(_ sender: UIButton) {
        self.delegate?.completedEditActionDelete(self)
    }
    
    @IBAction func unCompleteAllClicked(_ sender: Any) {
        self.delegate?.completedEditActionToDoStackViewUncompleAll(self)
    }
    
    @IBAction func moveAllClicked(_ sender: Any) {
        self.delegate?.completedEditActionToDoStackViewMoveAll(self)
    }

}


extension CompletedEditActionToDoStackView: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.completedItems.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ToDoItemListCell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.toDoCompletedTaskListViewCell, for: indexPath) as! ToDoItemListCell
        cell.configCompletedCell(index: indexPath, todoItem: self.completedItems[indexPath.section], delegate: self)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return section == (self.completedItems.count-1) ? 75 : 10
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footer = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: section == (self.completedItems.count-1) ? 75 : 10))
        footer.backgroundColor = UIColor.clear
        return footer
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .normal, title:  "", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            success(true)
            self.delegate?.completedEditActionToDoStackView(self, onDeleteToDo: self.completedItems[indexPath.section])
        })
        deleteAction.image = #imageLiteral(resourceName: "icon-cell-swipe-delete")
        deleteAction.backgroundColor = UIColor(red: 214/255, green: 101/255, blue: 101/255, alpha: 1.0)
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}



extension CompletedEditActionToDoStackView: ToDoItemListCellDelegate {
    
    func toDoItemListCell(_ toDoCategoryListCell: ToDoItemListCell, ShouldBeginEditing indexPath: IndexPath) {
        
    }
    
    func toDoItemListCell(_ toDoCategoryListCell: ToDoItemListCell, toDoIemEdited indexPath: IndexPath, editedName: String) {
        
    }
    
    func toDoItemListCell(_ toDoCategoryListCell: ToDoItemListCell, checkBoxSelect indexPath: IndexPath) {
        
    }
    
    func toDoItemListCell(_ toDoCategoryListCell: ToDoItemListCell, didSelect indexPath: IndexPath) {
        self.delegate?.completedEditActionToDoStackView(self, onSelectToDo: self.completedItems[indexPath.section])
    }
    
    
    func toDoItemListCell(_ toDoCategoryListCell: ToDoItemListCell, completion flag: Bool, indexPath: IndexPath) {
        self.delegate?.completedEditActionToDoStackView(self, unCompleteToDo: self.completedItems[indexPath.section])
    }
    
    func toDoItemListCell(_ toDoCategoryListCell: ToDoItemListCell, favourite flag: Bool, indexPath: IndexPath) {
        self.delegate?.completedEditActionToDoStackView(self, onFavouriteToDo: self.completedItems[indexPath.section], flag: flag)
    }
    
}
