//
//  BaseTodoDetailViewController.swift
//  MiPlanIt
//
//  Created by Aneesh Asokan on 03/07/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit
import GrowingTextView
import IQKeyboardManagerSwift

protocol BaseTodoDetailViewControllerDelegate: AnyObject {
    func baseTodoDetailViewController(_ viewController: BaseTodoDetailViewController, updated todo: PlanItTodo, completed: Bool)
}

class BaseTodoDetailViewController: UIViewController {
    
    var isNeedBorder = false
    var isCompleted = false
    var isTodoUpdated = false
    var dashboardDueDate: Date?
    var toDoDetailModel: ToDoDetailModel!
    var categoryType: ToDoMainCategory = .custom
    weak var delegate: BaseTodoDetailViewControllerDelegate?
    var mainToDoItem: PlanItTodo! {
        didSet {
            self.toDoDetailModel = ToDoDetailModel(planItToDo: self.mainToDoItem, with: self.categoryType, dashboardDate: self.dashboardDueDate)
        }
    }
    
    @IBOutlet weak var viewSubTask: ToDoDetailSubTaskView!
    @IBOutlet weak var buttonFavourite: ProcessingButton!
    @IBOutlet weak var textFieldToDoName: GrowingTextView!
    @IBOutlet weak var labelDueDate: UILabel!
    @IBOutlet weak var labelRepeat: UILabel!
    @IBOutlet weak var labelRemindMe: UILabel!
    @IBOutlet weak var textViewNotes: GrowingTextView!
    @IBOutlet weak var labelToDoCategoryName: UILabel!
    @IBOutlet weak var labelAssignToTitle: UILabel!
    @IBOutlet weak var viewAssignUser: UIView!
    @IBOutlet weak var imageViewAssignUser: UIImageView!
    @IBOutlet weak var labelAssigneName: UILabel!
    @IBOutlet weak var buttonDelete: ProcessingButton!
    @IBOutlet weak var constraintSubToDoHeight: NSLayoutConstraint!
    @IBOutlet weak var viewOverlay: UIView!
    @IBOutlet weak var viewDueDatePicker: UIView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var labelAttachmentCount: UILabel!
    @IBOutlet weak var labelTagCount: UILabel!
    @IBOutlet weak var viewAssignLabel: UIView!
    @IBOutlet weak var buttonSave: ProcessingButton!
    @IBOutlet weak var viewCompletedOverlay: UIView!
    @IBOutlet weak var viewRepeat: UIView!
    @IBOutlet weak var buttonRemoveDueDate: UIButton!
    @IBOutlet weak var viewAssignSection: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var buttonCheckMarkAsComplete: ProcessingButton?
    @IBOutlet weak var buttonBack: ProcessingButton?
    @IBOutlet weak var buttonRemoveAssignee: UIButton!
    @IBOutlet weak var imageViewUserStatus: UIImageView?
    @IBOutlet weak var viewOverlayReminder: UIView!
    @IBOutlet weak var buttonRemoveReminder: UIButton!
    @IBOutlet weak var imageViewReminderSideArrow: UIImageView?
    @IBOutlet weak var viewOverlayRepeat: UIView?
    @IBOutlet weak var dayDatePicker: DayDatePicker?
        
    var cachedImageNormal: UIImage?
    var cachedImageSel: UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.initilizeUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.addNotifications()
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if self.isBeingRemoved() && self.isTodoUpdated {
            IQKeyboardManager.shared.keyboardDistanceFromTextField = 10
            self.delegate?.baseTodoDetailViewController(self, updated: self.mainToDoItem, completed: self.isCompleted)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.removeNotifications()
        super.viewDidDisappear(animated)
    }
    
    @IBAction func removeDueDateClicked(_ sender: UIButton) {
        sender.isHidden = true
        self.labelDueDate.text = "Add Due Date"
        self.updateDueDate(date: nil)
        self.viewDueDatePicker.isHidden = true
        self.toDoDetailModel.remindValue = nil
        self.updateRemindMeTitle()
    }
    
    @IBAction func removeReminderClicked(_ sender: UIButton) {
        self.labelRemindMe.text = "Remind Me On"
        self.toDoDetailModel.remindValue = nil
        self.updateRemindMeTitle()
    }
    
    @IBAction func saveActionClicked(_ sender: UIButton) {
        self.view.endEditing(true)
        if self.textFieldToDoName.text.length == 0 {
            self.performSegue(withIdentifier: Segues.toMessageScreen, sender: [Message.warning, Message.blankTitle])
            return
        }
        self.cachedImageNormal   = self.buttonSave.image(for: .normal)
        self.buttonSave.startAnimation()
        self.startPendingUploadOfAttachment(from: true)
    }
    
    @IBAction func backButtonClicked(_ sender: UIButton) { }
    
    @IBAction func shareButtonClicked(_ sender: UIButton) {
        if self.mainToDoItem.isAssignedToMe && !self.mainToDoItem.isOwner {
            self.performSegue(withIdentifier: Segues.toMessageScreen, sender: [Message.warning, Message.assignedtomemessage])
        }
        else {
            self.performSegue(withIdentifier: Segues.toAssignScreen, sender: self)
        }
    }
    
    @IBAction func markAsCompleteClicked(_ sender: UIButton) {
        self.startPendingUploadOfAttachment(from: false)
    }
    
    @IBAction func deleteButtonClicked(_ sender: Any) {
        guard let category = self.mainToDoItem.readTodoCategory() else { return }
        let message = self.mainToDoItem.isRecurrenceTodo() ? Message.occurrenceDelete : Message.deleteTodoItemMessage
        self.showAlertWithAction(message: message, title: Message.deleteTodoItem, items: [Message.yes, Message.cancel], callback: { buttonindex in
            if buttonindex == 0 {
                self.saveToDoDeleteToServerUsingNetwotk(self.mainToDoItem, from: category)
            }
        })
    }
    
    @IBAction func favoriteButtonClicked(_ sender: UIButton) {
        guard let category = self.mainToDoItem.readTodoCategory() else { return }
        self.createWebServiceToFavouriteTodo(self.mainToDoItem, from: category, with: !sender.isSelected)
    }
    
    @IBAction func dueDateClicked(_ sender: UIButton) {
        if self.mainToDoItem.parent != nil { return }
        self.viewDueDatePicker.isHidden = !self.viewDueDatePicker.isHidden
        self.updateDueDate(date: self.toDoDetailModel.dueDate == nil ? Date() : self.toDoDetailModel.dueDate)
        self.labelDueDate.text = "Due " + (self.toDoDetailModel.dueDate ?? Date()).stringFromDate(format: DateFormatters.EEEDDHMMMHYYY)
//        self.datePicker.date = (self.toDoDetailModel.dueDate ?? Date())
        self.dayDatePicker?.selectRow(self.dayDatePicker?.selectedDate(date: self.toDoDetailModel.dueDate ?? Date()) ?? 0, inComponent: 0, animated: true)
        self.buttonRemoveDueDate.isHidden = false
        self.viewOverlayReminder.isHidden = true
        self.viewOverlayRepeat?.isHidden = true
    }
    
    @IBAction func attachButtonClicked(_ sender: UIButton) { }
    
    @IBAction func dueDateChanged(_ sender: UIDatePicker) {
        self.updateDueDateChange(sender.date)
    }
    
    @IBAction func removeAssignClicked(_ sender: UIButton) {
        self.toDoDetailModel.assignee = []
        self.viewAssignUser.isHidden = true
        self.viewAssignLabel.isHidden = false
        self.buttonRemoveAssignee.isHidden = true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        self.view.endEditing(true)
        switch segue.destination {
        case is ToDoRemindViewController:
            let toDoRemindViewController = segue.destination as? ToDoRemindViewController
            toDoRemindViewController?.delegate = self
        case is RepeatViewController:
            let repeatViewController = segue.destination as? RepeatViewController
            repeatViewController?.delegate = self
            repeatViewController?.eventStartDate = self.toDoDetailModel.dueDate
            repeatViewController?.orginalRecurrenceRule = self.toDoDetailModel.recurrence
        case is AddTaskTagViewController:
            let addTaskTagViewController = segue.destination as! AddTaskTagViewController
            addTaskTagViewController.tags = self.toDoDetailModel.tags
            addTaskTagViewController.textToPredict = self.toDoDetailModel.createTextForPrediction()
            addTaskTagViewController.canAddTag = !self.mainToDoItem.completed
            addTaskTagViewController.delegate = self
        case is NotificationToDoTagViewController:
            let notificationToDoTagViewController = segue.destination as! NotificationToDoTagViewController
            notificationToDoTagViewController.tags = self.toDoDetailModel.tags
            notificationToDoTagViewController.textToPredict = self.toDoDetailModel.createTextForPrediction()
            notificationToDoTagViewController.canAddTag = !self.mainToDoItem.completed
            notificationToDoTagViewController.delegate = self
        case is NotificationToDoRepeatViewController:
            let notificationToDoRepeatViewController = segue.destination as! NotificationToDoRepeatViewController
            notificationToDoRepeatViewController.delegate = self
        case is AttachmentListViewController:
            let attachmentListViewController = segue.destination as! AttachmentListViewController
            attachmentListViewController.delegate = self
            attachmentListViewController.activityType = self.mainToDoItem.completed ? .none : .task
            attachmentListViewController.attachments = self.toDoDetailModel.attachments
            attachmentListViewController.itemOwnerId = self.toDoDetailModel.categoryOwnerId
        case is AttachFileDropDownViewController:
            let attachDropDownViewController = segue.destination as? AttachFileDropDownViewController
            attachDropDownViewController?.delegate = self
            attachDropDownViewController?.countofAttachments = self.toDoDetailModel.getAttachmentCount()
        case is AssignToDoViewController:
            let assignViewController = segue.destination as! AssignToDoViewController
            assignViewController.delegate = self
            if let assignedUser = self.toDoDetailModel.assignee.first {
                assignViewController.selectedUser = AssignUser(calendarUser: CalendarUser(assignedUser))
            }
        case is MessageViewController:
            let messageViewController = segue.destination as! MessageViewController
            messageViewController.caption = (sender as? [String])?.first
            messageViewController.errorDescription = (sender as? [String])?.last
        case is TaskReminderViewController:
            let taskReminderViewController = segue.destination as! TaskReminderViewController
            taskReminderViewController.startDate = self.toDoDetailModel.dueDate
            taskReminderViewController.toDoReminder = ReminderModel(self.toDoDetailModel.remindValue, from: .task)
            taskReminderViewController.delegate = self
        default: break
        }
    }
    
    @objc func navigateBack() { }
}
