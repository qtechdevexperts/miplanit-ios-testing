//
//  DashboardCardViewToDoCell.swift
//  MiPlanIt
//
//  Created by Febin Paul on 03/10/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

class DashboardCardViewToDoCell: UITableViewCell {
    
    var index: IndexPath!

    @IBOutlet weak var labelToDoName: UILabel!
    @IBOutlet weak var labelToDoTime: UILabel!
    @IBOutlet weak var buttonCompletion: UIButton!
    @IBOutlet weak var buttonFavorite: UIButton!
    @IBOutlet weak var imageViewUserStatus: UIImageView?
    @IBOutlet weak var viewAssignee: UIView!
    @IBOutlet weak var imageViewAssignee: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func configCell(todo: DashboardToDoItem, index: IndexPath, dateSection: DashBoardSection) {
        self.index = index
        guard let planItTodo = todo.todoData as? PlanItTodo else { return }
        self.labelToDoName.text = planItTodo.readToDoTitle()
        self.readShowingDateOfTodoInThread(planItTodo, item: todo, type: dateSection, identifier: index)
        self.buttonCompletion.isSelected = planItTodo.completed
        self.buttonFavorite.isSelected = planItTodo.favourited
        self.viewAssignee.isHidden = true
        if let assignee = planItTodo.readAllInvitees().first {
            self.viewAssignee.isHidden = false
            self.imageViewAssignee.image = assignee.fullName?.shortStringImage()
            if let profileImage = assignee.profileImage {
                self.imageViewAssignee.pinImageFromURL(URL(string: profileImage), placeholderImage: assignee.fullName?.shortStringImage())
            }
        }
        else if !planItTodo.isOwner, let creator = planItTodo.createdBy, creator.readValueOfUserId() != Session.shared.readUserId() {
            self.viewAssignee.isHidden = false
            self.imageViewAssignee.image = creator.readValueOfFullName().shortStringImage()
            if let profileImage = creator.profileImage {
                self.imageViewAssignee.pinImageFromURL(URL(string: profileImage), placeholderImage: creator.readValueOfFullName().shortStringImage())
            }
        }
    }
    
    func readShowingDateOfTodoInThread(_ todo: PlanItTodo, item: DashboardToDoItem, type: DashBoardSection, identifier: IndexPath) {
        if let dueDate = todo.dueDate, todo.isRecurrenceTodo(), item.initialDate > dueDate {
            let categoryName = todo.readTodoCategory()?.readCategoryName() ?? Strings.empty
            let dateToShow = item.initialDate.stringFromDate(format: DateFormatters.EEEDDMMMYYYY)
            let fullString = ("Due On: \(dateToShow)" + (categoryName.isEmpty ? Strings.empty : ", \(categoryName)"))
            self.labelToDoTime.text = fullString
            self.labelToDoTime.isHidden = dateToShow.isEmpty && categoryName.isEmpty
        }
        else {
            self.labelToDoTime.isHidden = true
            let type: ToDoMainCategory = type == .today ? .today : type == .tomorrow ? .upcomming : .all
            todo.readStartDateInQueue(using: type, identifier: identifier, result: { [weak self] date, indexPath in
                guard let self = self, self.index.section == indexPath.section, self.index.row == indexPath.row  else { return }
                let categoryName = todo.readTodoCategory()?.readCategoryName() ?? Strings.empty
                if let dateToShow = date?.stringFromDate(format: DateFormatters.EEEDDMMMYYYY) {
                    let fullString = ("Due On: \(dateToShow)" + (categoryName.isEmpty ? Strings.empty : ", \(categoryName)"))
                    self.labelToDoTime.text = fullString
                    self.labelToDoTime.isHidden = dateToShow.isEmpty && categoryName.isEmpty
                }
                else {
                    self.labelToDoTime.text = categoryName
                    self.labelToDoTime.isHidden = categoryName.isEmpty
                }
            })
        }
    }
    
    private func configureAssigneRespondStatus(_ status: RespondStatus) {
        switch status {
        case .eAccepted:
            self.imageViewUserStatus?.isHidden = false
            self.imageViewUserStatus?.image = #imageLiteral(resourceName: "acceptedInvitee")
        case .eRejected:
            self.imageViewUserStatus?.isHidden = false
            self.imageViewUserStatus?.image = #imageLiteral(resourceName: "rejectedInvitee")
        case .eNotResponded:
            self.imageViewUserStatus?.isHidden = false
            self.imageViewUserStatus?.image = #imageLiteral(resourceName: "notRespondedInvitee")
        default:
            self.imageViewUserStatus?.isHidden = true
            self.imageViewUserStatus?.image = nil
        }
    }
    
}
