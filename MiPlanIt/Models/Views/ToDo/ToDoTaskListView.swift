//
//  ToDoTaskListView.swift
//  MiPlanIt
//
//  Created by Febin Paul on 29/06/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit
import Alamofire

protocol ToDoTaskListViewDelegate: class {
    func toDoTaskListView(_ toDoTaskListView: ToDoTaskListView, sliderSelected: Bool)
    func toDoTaskListView(_ toDoTaskListView: ToDoTaskListView, didSelectCategory category: PlanItTodoCategory, at indexPath: IndexPath)
    func toDoTaskListView(_ toDoTaskListView: ToDoTaskListView, assignUserForCategory category: PlanItTodoCategory, at indexPath: IndexPath)
    func toDoTaskListView(_ toDoTaskListView: ToDoTaskListView, deleteCategory category: PlanItTodoCategory, at indexPath: IndexPath)
    func toDoTaskListView(_ toDoTaskListView: ToDoTaskListView, showSharedUserForCategory category: PlanItTodoCategory, at indexPath: IndexPath)
    func toDoTaskListView(_ toDoTaskListView: ToDoTaskListView, printCategory category: PlanItTodoCategory, at indexPath: IndexPath)
}

class ToDoTaskListView: UIView {
    
    var categories: [TodoListCategory] = []
    weak var delegate: ToDoTaskListViewDelegate?
    
    @IBOutlet weak var buttonSlider: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var imgViewBlank: UIImageView!

    var toDoCategories: [PlanItTodoCategory] = [] {
        didSet {
            self.imgViewBlank.isHidden = !self.toDoCategories.isEmpty
            self.tableView.isHidden = self.toDoCategories.isEmpty
            self.groupCategoriesBasedOnOwnerShare()
        }
    }
    
    override func awakeFromNib() {
        let insets = UIEdgeInsets(top: 0, left: 0, bottom: 75, right: 0)
        self.tableView.contentInset = insets
        super.awakeFromNib()
    }
    
    func groupCategoriesBasedOnOwnerShare() {
        self.categories.removeAll()
        let ownerCategories = self.toDoCategories.filter({ return $0.createdBy?.readValueOfUserId() == Session.shared.readUserId() })
        if !ownerCategories.isEmpty {
            self.categories.append(TodoListCategory(with: Strings.mylist, categories: ownerCategories))
        }
        let sharedCategories = self.toDoCategories.filter({ return $0.createdBy?.readValueOfUserId() != Session.shared.readUserId() })
        if !sharedCategories.isEmpty {
            self.categories.append(TodoListCategory(with: Strings.sharedList, categories: sharedCategories))
        }
        self.tableView.reloadData()
    }
    
    func refreshCategories() {
        self.tableView.reloadData()
    }
    
    @IBAction func sliderButtonClicked(_ sender: UIButton) {
        self.buttonSlider.isSelected = !self.buttonSlider.isSelected
        self.delegate?.toDoTaskListView(self, sliderSelected: self.buttonSlider.isSelected)
    }

}

extension ToDoTaskListView: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.categories.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.categories[section].categories.count
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.toDoCategoryListCell, for: indexPath) as! ToDoCategoryListViewCell
        cell.configCell(self.categories[indexPath.section].categories[indexPath.row], title: self.categories[indexPath.section].title, delegate: self, indexPath: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.toDoCategoryListHeaderCell) as! ToDoCategoryListHeaderViewCell
        cell.configCell(category: self.categories[section])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footer = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 50))
        footer.backgroundColor = #colorLiteral(red: 0.137254902, green: 0.1450980392, blue: 0.2588235294, alpha: 1)
        return footer
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .normal, title:  "", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            success(true)
            self.deleteCategoryAtIndexPath(indexPath)
        })
        deleteAction.image = #imageLiteral(resourceName: "icon-cell-swipe-delete")
        deleteAction.backgroundColor = UIColor(red: 214/255, green: 101/255, blue: 101/255, alpha: 1.0)
        let swipeAction = UISwipeActionsConfiguration(actions: [deleteAction])
        swipeAction.performsFirstActionWithFullSwipe = false
        return swipeAction
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let shareAction = UIContextualAction(style: .normal, title:  "", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            success(true)
            self.assignUserForCategoryAtIndexPath(indexPath)
        })
        shareAction.image = #imageLiteral(resourceName: "icon-cell-swipe-share")
        shareAction.backgroundColor = UIColor(red: 86/255.0, green: 173/255.0, blue: 189/255.0, alpha: 1)
        
        let printAction = UIContextualAction(style: .normal, title:  "", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            success(true)
            self.printCategoryAtIndexPath(indexPath)
        })
        printAction.image = #imageLiteral(resourceName: "printswipeaction")
        printAction.backgroundColor = UIColor(red: 56/255.0, green: 190/255.0, blue: 204/255.0, alpha: 1)
        
        let swipeAction = UISwipeActionsConfiguration(actions: [shareAction, printAction])
        swipeAction.performsFirstActionWithFullSwipe = false
        return swipeAction
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.delegate?.toDoTaskListView(self, didSelectCategory: self.categories[indexPath.section].categories[indexPath.row], at: indexPath)
    }
}

extension ToDoTaskListView {
    
    func startLoadingIndicator(at indexPath: IndexPath) {
        if let cell = self.tableView.cellForRow(at: indexPath) as? ToDoCategoryListViewCell {
            cell.startGradientAnimation()
        }
    }
    
    func stopLoadingIndicator(at indexPath: IndexPath) {
        if let cell = self.tableView.cellForRow(at: indexPath) as? ToDoCategoryListViewCell {
            cell.stopGradientAnimation()
        }
    }
    
    func assignUserForCategoryAtIndexPath(_ indexPath: IndexPath) {
        self.delegate?.toDoTaskListView(self, assignUserForCategory: self.categories[indexPath.section].categories[indexPath.row], at: indexPath)
    }
    
    func printCategoryAtIndexPath(_ indexPath: IndexPath) {
        self.delegate?.toDoTaskListView(self, printCategory: self.categories[indexPath.section].categories[indexPath.row], at: indexPath)
    }
    
    func deleteCategoryAtIndexPath(_ indexPath: IndexPath) {
        self.delegate?.toDoTaskListView(self, deleteCategory: self.categories[indexPath.section].categories[indexPath.row], at: indexPath)
    }
}

extension ToDoTaskListView: ToDoCategoryListViewCellDelegate {
    
    func toDoCategoryListViewCell(_ toDoCategoryListViewCell: ToDoCategoryListViewCell, sharedUserClicked indexPath: IndexPath!) {
        self.delegate?.toDoTaskListView(self, showSharedUserForCategory: self.categories[indexPath.section].categories[indexPath.row], at: indexPath)
    }
}
