//
//  ToDoItemListCell.swift
//  MiPlanIt
//
//  Created by Febin Paul on 30/06/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit
import GradientLoadingBar

protocol ToDoItemListCellDelegate: class {
    func toDoItemListCell(_ toDoCategoryListCell: ToDoItemListCell, completion flag: Bool, indexPath: IndexPath)
    func toDoItemListCell(_ toDoCategoryListCell: ToDoItemListCell, favourite flag: Bool, indexPath: IndexPath)
    func toDoItemListCell(_ toDoCategoryListCell: ToDoItemListCell, didSelect indexPath: IndexPath)
    func toDoItemListCell(_ toDoCategoryListCell: ToDoItemListCell, checkBoxSelect indexPath: IndexPath)
    func toDoItemListCell(_ toDoCategoryListCell: ToDoItemListCell, toDoIemEdited indexPath: IndexPath, editedName: String)
    func toDoItemListCell(_ toDoCategoryListCell: ToDoItemListCell, ShouldBeginEditing indexPath: IndexPath)
}

class ToDoItemListCell: UITableViewCell {
    
    var indexPath: IndexPath!
    weak var delegate: ToDoItemListCellDelegate?
    @IBOutlet weak var buttonCompletion: UIButton!
    @IBOutlet weak var buttonFavourite: UIButton!
    @IBOutlet weak var viewDateSubTask: UIView!
    @IBOutlet weak var viewDate: UIView?
    @IBOutlet weak var viewSubTask: UIView?
    @IBOutlet weak var labelSubTask: UILabel?
    @IBOutlet weak var imageViewAssigned: UIImageView?
    @IBOutlet weak var textFieldToDoTitle: UITextField?
    @IBOutlet weak var buttonSelection: UIButton?
    @IBOutlet weak var buttonItemSelection: UIButton?
    @IBOutlet weak var labelToDoDate: UILabel!
    @IBOutlet weak var labelToDoCategoryName: UILabel!
    @IBOutlet weak var mainContainerView: UIView?
    @IBOutlet weak var viewDeleteOverlay: UIView?
    @IBOutlet weak var labelCompletedTitle: UILabel?
    @IBOutlet weak var viewLoadingGradient: GradientActivityIndicatorView!
    @IBOutlet weak var buttonRemove: UIButton?
    @IBOutlet weak var labelModifiedDate: UILabel?
    @IBOutlet weak var imageViewCalendarIcon: UIImageView!
    @IBOutlet weak var imageViewRecurrent: UIImageView?
    @IBOutlet weak var viewResponseStatus: UIView!
    @IBOutlet weak var imageViewUserStatus: UIImageView!
    @IBOutlet weak var imageViewAttachmentOrNotes: UIImageView?
    @IBOutlet weak var viewLeftBorder: UIView?
    @IBOutlet weak var viewAssigneeHolder: UIView?
    @IBOutlet weak var imageViewDateIcon: UIImageView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func itemSelected(_ sender: UIButton) {
        self.delegate?.toDoItemListCell(self, didSelect: self.indexPath)
    }
    
    @IBAction func listSelectionButtonClicked(_ sender: UIButton) {
        self.delegate?.toDoItemListCell(self, checkBoxSelect: self.indexPath)
    }
    
    @IBAction func markCompletionButtonClicked(_ sender: UIButton) {
        self.delegate?.toDoItemListCell(self, completion: !self.buttonCompletion.isSelected, indexPath: self.indexPath)
    }
    
    @IBAction func markFavouriteButtonClicked(_ sender: UIButton) {
        self.delegate?.toDoItemListCell(self, favourite: !self.buttonFavourite.isSelected, indexPath: self.indexPath)
    }
    
    func setCellSelectionBorder(selected: Bool) {
        self.bordorWidth = selected ? 0.5 : 0
        self.bordorColor = selected ? UIColor(red: 86/255.0, green: 173/255.0, blue: 189/255.0, alpha: 1.0) : UIColor.clear
        self.buttonItemSelection?.isUserInteractionEnabled = !selected
    }
    
    private func configureAssigneeRespondStatus(_ status: RespondStatus?) {
        guard let respondStatus = status, self.imageViewAssigned?.isHidden == false else {
            self.imageViewUserStatus?.isHidden = true
            self.imageViewUserStatus?.image = nil
            return
        }
        switch respondStatus {
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
    
    fileprivate func cellCommonConguration(index: IndexPath, editMode: ToDoMode = .default, todoItem: ToDoItemCellModel, delegate: ToDoItemListCellDelegate) {
        self.indexPath = index
        self.delegate = delegate
        self.textFieldToDoTitle?.text = todoItem.planItToDo.readToDoTitle()
        if todoItem.planItToDo.readDeleteStatus() {
            self.textFieldToDoTitle?.attributedText = todoItem.planItToDo.readToDoTitle().strikeThrough()
        }
        self.buttonCompletion.isHidden = editMode == .edit
        self.buttonSelection?.isHidden = editMode == .default
        self.textFieldToDoTitle?.isUserInteractionEnabled = editMode == .edit
        self.buttonFavourite.isUserInteractionEnabled = editMode == .default
        self.buttonItemSelection?.isHidden = editMode == .edit
        self.buttonCompletion.isSelected = todoItem.planItToDo.completed
        self.buttonFavourite.isSelected = todoItem.planItToDo.favourited
        self.imageViewRecurrent?.isHidden = !todoItem.planItToDo.isRecurrenceTodo()
        let assigees = todoItem.planItToDo.readAllInvitees().first
        self.viewAssigneeHolder?.isHidden = assigees == nil
        if let user = assigees {
            self.imageViewAssigned?.pinImageFromURL(URL(string: user.profileImage ?? Strings.empty), placeholderImage: user.readValueOfFullName().shortStringImage(1))
        }
        self.configureAssigneeRespondStatus(assigees?.readResponseStatus())
        self.buttonSelection?.isSelected = todoItem.editSelected
        self.setCellSelectionBorder(selected: todoItem.editSelected)
        self.mainContainerView?.isUserInteractionEnabled = !todoItem.planItToDo.readDeleteStatus()
        self.mainContainerView?.alpha = todoItem.planItToDo.completed || todoItem.planItToDo.readDeleteStatus() ? 0.5 : 1.0
        self.buttonRemove?.isHidden = !todoItem.planItToDo.readDeleteStatus()
        if todoItem.planItToDo.readDeleteStatus() {
            self.buttonSelection?.isHidden = true
            self.buttonCompletion?.isHidden = true
        }
    }
    
    func configMainCategoryCell(index: IndexPath, todoItem: ToDoItemCellModel, editMode: ToDoMode, type: ToDoMainCategory, delegate: ToDoItemListCellDelegate) {
        self.viewLeftBorder?.isHidden = true
        self.viewDateSubTask.isHidden = false
        self.backgroundColor = editMode == .edit ? .gray : .clear
        self.cellCommonConguration(index: index, editMode: editMode, todoItem: todoItem, delegate: delegate)
        self.readShowingDateOfTodoForMainCategoryInThread(todoItem, type: type, identifier: index)
        self.labelToDoCategoryName.text = todoItem.planItToDo.readTodoCategory()?.readCategoryName()
        self.imageViewCalendarIcon.image = todoItem.planItToDo.completed ? #imageLiteral(resourceName: "icon-todo-calendar-blue") : #imageLiteral(resourceName: "list-calendar-icon")
        if type == .assignedToMe, let me = todoItem.planItToDo.readAllInvitees().filter({ return $0.readValueOfUserId() == Session.shared.readUserId() }).first, !me.isRead {
            self.viewLeftBorder?.isHidden = false
            self.viewLeftBorder?.backgroundColor = UIColor(red: 107/255.0, green: 193/255.0, blue: 64/255.0, alpha: 1.0)
        }
        if type == .overdue, let todo = todoItem.planItToDo, !todo.overdueViewStatus {
            self.viewLeftBorder?.isHidden = false
            self.viewLeftBorder?.backgroundColor = UIColor(red: 255/255.0, green: 57/255.0, blue: 57/255.0, alpha: 1.0)
        }
        if type == .completed, let todo = todoItem.planItToDo, todo.isAssignedByMe, !todo.isAssignedToMe, !todo.completedViewStatus {
            self.viewLeftBorder?.isHidden = false
            self.viewLeftBorder?.backgroundColor = UIColor(red: 175/255.0, green: 82/255.0, blue: 222/255.0, alpha: 1.0)
        }
    }
    
    func configCustomCategoryCell(index: IndexPath, todoItem: ToDoItemCellModel, editMode: ToDoMode, delegate: ToDoItemListCellDelegate) {
        self.viewDateSubTask.isHidden = false
        self.backgroundColor = editMode == .edit ? .gray : .clear
        self.cellCommonConguration(index: index, editMode: editMode, todoItem: todoItem, delegate: delegate)
        self.readShowingDateOfTodoForCustomCategoryInThread(todoItem, identifier: index)
        self.viewSubTask?.isHidden = todoItem.planItToDo.readSubTodosCount().isEmpty
        self.labelSubTask?.text = todoItem.planItToDo.readSubTodosCount()
        self.imageViewAttachmentOrNotes?.isHidden = todoItem.planItToDo.readAttachmentCount().isEmpty && todoItem.planItToDo.readNotes().isEmpty
        self.viewDateSubTask.isHidden = todoItem.planItToDo.readSubTodosCount().isEmpty && todoItem.planItToDo.readAttachmentCount().isEmpty && todoItem.planItToDo.readNotes().isEmpty && !todoItem.planItToDo.isRecurrenceTodo() && todoItem.planItToDo.readExactDueDate() == nil
    }
    
    func configCompletedCell(index: IndexPath, todoItem: ToDoItemCellModel, delegate: ToDoItemListCellDelegate) {
        self.cellCommonConguration(index: index, todoItem: todoItem, delegate: delegate)
        self.labelCompletedTitle?.text = todoItem.planItToDo.readToDoTitle()
        self.readShowingDateOfTodoForCompletedCategoryInThread(todoItem, identifier: index)
        if todoItem.planItToDo.completed {
            self.imageViewDateIcon?.isHidden = false
            self.labelModifiedDate?.isHidden = false
            self.labelModifiedDate?.text = todoItem.planItToDo.readCompletedDate()
            if let modifiedUser = todoItem.planItToDo.modifiedBy {
                self.imageViewAssigned?.isHidden = false
                self.imageViewAssigned?.pinImageFromURL(URL(string: modifiedUser.readValueOfProfileImage()), placeholderImage: modifiedUser.readValueOfFullName().shortStringImage(1))
            }
        }
    }
    
    func readShowingDateOfTodoForMainCategoryInThread(_ todo: ToDoItemCellModel, type: ToDoMainCategory, identifier: IndexPath) {
        self.viewDate?.isHidden = true; self.labelToDoDate.text = Strings.empty
        todo.planItToDo.readStartDateInQueue(using: type, identifier: identifier, result: { date, index in
            guard self.indexPath.section == index.section, self.indexPath.row == index.row  else { return }
            let dateToShow =  date?.stringFromDate(format: DateFormatters.MMMSDCYYYY)
            self.viewDate?.isHidden = dateToShow == nil
            self.labelToDoDate.text = dateToShow
        })
    }
    
    func readShowingDateOfTodoForCustomCategoryInThread(_ todo: ToDoItemCellModel, identifier: IndexPath) {
        self.viewDate?.isHidden = true; self.labelToDoDate.text = Strings.empty
        todo.planItToDo.readStartDateInQueue(using: .custom, identifier: identifier, result: { date, index in
            guard self.indexPath.section == index.section, self.indexPath.row == index.row  else { return }
            let dateToShow =  date?.stringFromDate(format: DateFormatters.MMMSDCYYYY)
            self.viewDate?.isHidden = dateToShow == nil
            self.labelToDoDate.text = dateToShow
        })
    }
    
    func readShowingDateOfTodoForCompletedCategoryInThread(_ todo: ToDoItemCellModel, identifier: IndexPath) {
        self.labelModifiedDate?.isHidden = true
        self.imageViewDateIcon?.isHidden = true
        todo.planItToDo.readStartDateInQueue(using: .custom, identifier: identifier, result: { date, index in
            guard self.indexPath.section == index.section, self.indexPath.row == index.row  else { return }
            let dateToShow =  date?.stringFromDate(format: DateFormatters.MMMSDCYYYY)
            self.labelModifiedDate?.isHidden = dateToShow == nil
            self.labelModifiedDate?.text = dateToShow
            self.imageViewDateIcon?.isHidden = dateToShow == nil
        })
    }
    
    func editThisCell() {
        DispatchQueue.main.asyncAfter(deadline: .now()+1.0) {
            self.textFieldToDoTitle?.isUserInteractionEnabled = true
            self.textFieldToDoTitle?.becomeFirstResponder()
        }
    }
    
    func startGradientAnimation() {
        self.viewLoadingGradient.isHidden = false
        self.viewLoadingGradient.fadeIn()
        UIApplication.shared.beginIgnoringInteractionEvents()
    }
    
    func stopGradientAnimation() {
        self.viewLoadingGradient.fadeOut()
        self.viewLoadingGradient.isHidden = true
        UIApplication.shared.endIgnoringInteractionEvents()
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        if editing {
            for view in subviews where view.description.contains("Reorder") {
                for case let subview as UIImageView in view.subviews {
                   subview.image = UIImage(named: "icon_CalendarSwap.png")
                    view.backgroundColor = .gray
                    subview.contentMode = .center
                }
            }
        }
    }
    
}


extension ToDoItemListCell: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        self.delegate?.toDoItemListCell(self, ShouldBeginEditing: self.indexPath)
        textField.returnKeyType = .default
        textField.reloadInputViews()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.setCellSelectionBorder(selected: true)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text?.length == 0 {
            return
        }
        self.setCellSelectionBorder(selected: (self.buttonSelection?.isSelected ?? false) )
        self.delegate?.toDoItemListCell(self, toDoIemEdited: self.indexPath, editedName: self.textFieldToDoTitle?.text ?? Strings.empty)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        textField.returnKeyType = ((textField.text?.isEmpty ?? Strings.empty.isEmpty || (range.length == 1 && range.location == 0)) && string.isEmpty) ? .default : .done
        textField.reloadInputViews()
        return true
    }
}
