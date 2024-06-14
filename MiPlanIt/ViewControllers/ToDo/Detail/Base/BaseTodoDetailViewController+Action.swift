//
//  TodoDetailViewController+Action.swift
//  MiPlanIt
//
//  Created by Febin Paul on 07/07/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation
import IQKeyboardManagerSwift
// import RRuleSwift
import Lottie
import EventKit

extension BaseTodoDetailViewController {
    
    func initilizeUI() {
        self.viewSubTask.toDoDetailModel = self.toDoDetailModel
        self.viewSubTask.setSubToDoView()
        self.textFieldToDoName.text = self.toDoDetailModel.todoName
        self.buttonRemoveDueDate.isHidden = self.toDoDetailModel.dueDate == nil || self.mainToDoItem.parent != nil
        self.viewOverlayReminder?.isHidden = self.toDoDetailModel.dueDate != nil
        self.viewOverlayRepeat?.isHidden = self.toDoDetailModel.dueDate != nil
        self.viewAssignSection.isUserInteractionEnabled = true
        if self.toDoDetailModel.dueDate != nil {
            self.labelDueDate.text = "Due \(self.toDoDetailModel.readDueDate())"
        }
        self.labelRepeat.text = self.mainToDoItem.readRecurrenceStatement() == Strings.empty ? "Repeat" : self.mainToDoItem.readRecurrenceStatement()
        self.buttonRemoveAssignee.isHidden = self.toDoDetailModel.assignee.isEmpty || (self.mainToDoItem.isAssignedToMe && !self.mainToDoItem.isOwner)
        if let assignee = self.toDoDetailModel.assignee.first {
            self.viewAssignUser.isHidden = false
            self.viewAssignLabel.isHidden = true
            self.imageViewAssignUser.pinImageFromURL(URL(string: assignee.profileImage), placeholderImage: assignee.fullName.shortStringImage())
            self.labelAssigneName.text = assignee.fullName
            self.configureAssigneRespondStatus(assignee.readResponseStatus())
        }
        self.updateRemindMeTitle()
        self.labelToDoCategoryName.text = self.mainToDoItem.readTodoCategory()?.readCategoryName()
        self.buttonFavourite.isSelected = self.mainToDoItem.favourited
        self.buttonCheckMarkAsComplete?.isSelected = self.mainToDoItem.completed
        self.showTagsCount()
        self.showAttachmentsCount()
        self.viewCompletedOverlay.isHidden = !self.mainToDoItem.completed
        self.buttonSave.isHidden = self.mainToDoItem.completed
        
        if self.mainToDoItem.isRecurrenceTodo() {
            let collectedDate = self.mainToDoItem.readCollectedDates().last?.addDays(1) ?? Date()
            self.datePicker.minimumDate = collectedDate
        }
        else {
            self.datePicker.minimumDate = Date()
        }
        
        self.viewRepeat.isHidden = !self.mainToDoItem.readRecurrenceToDoId().isEmpty
        self.viewAssignSection.isHidden = !self.mainToDoItem.readRecurrenceToDoId().isEmpty
        if let dueDate = self.mainToDoItem.dueDate {
            self.datePicker.date = dueDate
        }
        self.noteLineHeight(onStart: false)
        IQKeyboardManager.shared.keyboardDistanceFromTextField = 60
        self.dayDatePicker?.dataSource = self.dayDatePicker
        self.dayDatePicker?.delegate = self.dayDatePicker
        self.dayDatePicker?.dayDatePickerDelegate = self
        self.dayDatePicker?.setUpData()
        self.datePicker.setValue(UIColor.white, forKeyPath: "textColor")
        self.dayDatePicker?.setValue(UIColor.white, forKeyPath: "textColor")
    }
    
    func updateDueDateChange(_ date: Date) {
        self.updateDueDate(date: date)
        self.labelDueDate.text = "Due " + date.stringFromDate(format: DateFormatters.EEEDDHMMMHYYY)
        self.buttonRemoveDueDate.isHidden = false
        self.viewOverlayReminder.isHidden = true
        self.viewOverlayRepeat?.isHidden = true
    }
    
    func updateDueDate(date: Date?) {
        self.toDoDetailModel.dueDate = date?.initialHour()
        if date == nil {
            self.toDoDetailModel.recurrence = Strings.empty
            self.setRepeatTitle(rule: self.toDoDetailModel.recurrence)
        }
        else if !self.toDoDetailModel.recurrence.isEmpty, var recurrenceRule = RecurrenceRule(rruleString: self.toDoDetailModel.recurrence), let untilDate = recurrenceRule.recurrenceEnd?.endDate, let dueDate = date?.endOfDay, untilDate < dueDate {
            recurrenceRule.recurrenceEnd = EKRecurrenceEnd(end: dueDate)
            self.toDoDetailModel.recurrence = recurrenceRule.toRRuleString()
            self.setRepeatTitle(rule: self.toDoDetailModel.recurrence)
        }
    }
    
    func updateRemindMeTitle() {
        self.viewOverlayReminder?.isHidden = self.toDoDetailModel.dueDate != nil
        self.viewOverlayRepeat?.isHidden = self.toDoDetailModel.dueDate != nil
        if let remider = self.toDoDetailModel?.remindValue, self.toDoDetailModel.dueDate != nil {
            var remindTime = "\(remider.reminderBeforeValue) \(remider.reminderBeforeUnit) before "
            remindTime += remider.readReminderTimeString()
            self.labelRemindMe.text = remindTime
            self.buttonRemoveReminder.isHidden = false
            self.imageViewReminderSideArrow?.isHidden = true
            return
        }
        self.labelRemindMe.text = Strings.chooseRemindType
        self.buttonRemoveReminder.isHidden = true
        self.imageViewReminderSideArrow?.isHidden = false
    }
    
    func addNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(triggerTodoUpdateFromNotification(_:)), name: NSNotification.Name(rawValue: Notifications.dashboardToDoUpdate), object: nil)
    }
    
    func removeNotifications() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Notifications.dashboardToDoUpdate), object: nil)
    }
    
    @objc func triggerTodoUpdateFromNotification(_ notification: Notification) {
        guard let todo = notification.object as? PlanItTodo, self.mainToDoItem == todo else { return }
        if todo.readDeleteStatus() {
            self.isTodoUpdated = true
            self.navigateBack()
        }
        else {
            self.mainToDoItem = todo
            self.initilizeUI()
        }
    }
    
    func noteLineHeight(onStart: Bool) {
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 7
        let attributes = [NSAttributedString.Key.paragraphStyle : style, NSAttributedString.Key.font : UIFont(name: "SFUIDisplay-Regular", size: 16)!]
        self.textViewNotes.attributedText = NSAttributedString(string: (self.toDoDetailModel.notes == Strings.empty && onStart) ? " " : self.toDoDetailModel.notes, attributes: attributes)
        self.textViewNotes.textColor = .white
    }
    
    func setRepeatTitle(rule: String) {
        var repeatText = "Never"
        if let rrRuleObject = RecurrenceRule(rruleString: rule) {
            repeatText = "Repeats "
            switch rrRuleObject.frequency {
            case .daily:
                let day = rrRuleObject.interval > 1 ? "\(rrRuleObject.interval) days" : "day"
                let everyDay = "every \(day) "
                repeatText += everyDay
            case .weekly:
                let weekDays = self.getWeekDays(weekDays: rrRuleObject.byweekday.map({$0.rawValue}))
                repeatText += weekDays.isEmpty ? "weekly " : ( weekDays.joined(separator: ",")+" ")
            case .monthly:
                let month = rrRuleObject.interval > 1 ? "\(rrRuleObject.interval) months" : "month"
                repeatText += "every \(month) "
            case .yearly:
                let year = rrRuleObject.interval > 1 ? "\(rrRuleObject.interval) years" : "year"
                repeatText += "every \(year) "
            default:
                repeatText += Strings.empty
            }
            if let repeatUntilDate = rrRuleObject.recurrenceEnd?.endDate {
                repeatText += "until \(repeatUntilDate.stringFromDate(format: DateFormatters.MMMDDYYYY))"
            }
        }
        self.labelRepeat.text = repeatText
    }
    
    func getWeekDays(weekDays: [Int]) -> [String] {
        var weekDayItem: [String] = []
        weekDays.forEach { (int) in
            weekDayItem.append(int.getWeekDay())
        }
        return weekDayItem
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
    
    func showAttachmentsCount() {
        self.labelAttachmentCount.text = "\(self.toDoDetailModel.attachments.count)"
        self.labelAttachmentCount.isHidden = self.toDoDetailModel.attachments.isEmpty
    }
    
    func showTagsCount() {
        self.labelTagCount.text = "\(self.toDoDetailModel.tags.count)"
        self.labelTagCount.isHidden = self.toDoDetailModel.tags.isEmpty
    }
    
    func startPendingUploadOfAttachment(from save: Bool) {
        if let pendingAttachMent = self.toDoDetailModel.attachments.filter({ return $0.identifier.isEmpty }).first {
            self.saveToDoAttachmentsToServerUsingNetwotk(pendingAttachMent, from: save)
        }
        else {
            if save { self.saveTodoDetailsToServerUsingNetwotk(self.toDoDetailModel) }
            else { self.saveTodoCompleteToServerUsingNetwotk(with: !(self.buttonCheckMarkAsComplete?.isSelected ?? true)) }
        }
    }
    
    func resetButton(_ button: ProcessingButton) {
        if let img = self.cachedImageNormal {
            button.setImage(img, for: .normal)
        }
        self.cachedImageNormal = nil
        if let imgSel = self.cachedImageSel {
            button.setImage(imgSel, for: .selected)
        }
        self.cachedImageSel = nil
    }
}
