//
//  ToDoDetailDashboardCell.swift
//  MiPlanIt
//
//  Created by Febin Paul on 05/10/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

class ToDoDetailDashboardCell: UITableViewCell {
    
    var index: IndexPath!
    
    @IBOutlet weak var labelToDoTitle: UILabel!
    @IBOutlet weak var labelDueDate: UILabel!
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var imageViewUserStatus: UIImageView?
    @IBOutlet weak var viewAssignee: UIView!
    @IBOutlet weak var imageViewAssignee: UIImageView!
    @IBOutlet weak var viewList: UIView!
    @IBOutlet weak var labelToDoList: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func setAssigneOrSharedUser(planItToDo: PlanItTodo) {
        if let assignee = planItToDo.readAllInvitees().first {
            self.viewAssignee.isHidden = false
            self.imageViewAssignee.image = assignee.fullName?.shortStringImage()
            if let profileImage = assignee.profileImage {
                self.imageViewAssignee.pinImageFromURL(URL(string: profileImage), placeholderImage: assignee.fullName?.shortStringImage())
            }
        }
        else if !planItToDo.isOwner, let creator = planItToDo.createdBy, creator.readValueOfUserId() != Session.shared.readUserId() {
            self.viewAssignee.isHidden = false
            self.imageViewAssignee.image = creator.readValueOfFullName().shortStringImage()
            if let profileImage = creator.profileImage {
                self.imageViewAssignee.pinImageFromURL(URL(string: profileImage), placeholderImage: creator.readValueOfFullName().shortStringImage())
            }
        }
    }
    
    func configCell(todo: DashboardToDoItem, index: IndexPath, dateSection: DashBoardSection) {
        guard let planItToDo = todo.todoData as? PlanItTodo else { return }
        self.index = index
        self.labelToDoTitle.text = planItToDo.readToDoTitle()
        if let categoryName = planItToDo.readTodoCategory()?.readCategoryName() {
            self.labelToDoList.text = categoryName
            self.viewList.isHidden = categoryName.isEmpty
        }
        self.readShowingDateOfTodoInThread(planItToDo, item: todo, type: dateSection, identifier: index)
        self.viewAssignee.isHidden = true
        self.setAssigneOrSharedUser(planItToDo: planItToDo)
    }
    
    func configCellOnSearch(todo: DashboardToDoItem, index: IndexPath) {
        guard let planItToDo = todo.todoData as? PlanItTodo else { return }
        self.index = index
        self.labelToDoTitle.text = planItToDo.readToDoTitle()
        if let categoryName = planItToDo.readTodoCategory()?.readCategoryName() {
            self.labelToDoList.text = categoryName
            self.viewList.isHidden = categoryName.isEmpty
        }
        self.readShowingDateOfTodoInThread(planItToDo, item: todo, type: .all, identifier: index)
        self.viewAssignee.isHidden = true
        self.setAssigneOrSharedUser(planItToDo: planItToDo)
    }
    
    func readShowingDateOfTodoInThread(_ todo: PlanItTodo, item: DashboardToDoItem, type: DashBoardSection, identifier: IndexPath) {
        if let dueDate = todo.dueDate, todo.isRecurrenceTodo(), item.initialDate > dueDate {
            let dateToShow = item.initialDate.stringFromDate(format: DateFormatters.EEEDDMMMYYYY)
            let fullString = ("Due On: \(dateToShow)")
            self.labelDueDate.text = fullString
            self.labelDueDate.isHidden = dateToShow.isEmpty
        }
        else {
            self.labelDueDate.isHidden = true
            let type: ToDoMainCategory = type == .today ? .today : type == .tomorrow ? .upcomming : .all
            todo.readStartDateInQueue(using: type, identifier: identifier, result: { date, indexPath in
                guard self.index.section == indexPath.section, self.index.row == indexPath.row  else { return }
                if let dateToShow = date?.stringFromDate(format: DateFormatters.EEEDDMMMYYYY) {
                    let fullString = ("Due On: \(dateToShow)")
                    self.labelDueDate.text = fullString
                    self.labelDueDate.isHidden = dateToShow.isEmpty
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
