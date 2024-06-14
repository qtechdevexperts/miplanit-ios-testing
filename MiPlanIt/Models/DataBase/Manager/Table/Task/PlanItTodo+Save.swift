//
//  PlanItTodo+Save.swift
//  MiPlanIt
//
//  Created by Arun on 06/07/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation
// import RRuleSwift

extension PlanItTodo {
    
    func isPendingCategory() -> Bool {
        if let category = self.readTodoCategory() {
            return category.isPending
        }
        return false
    }
    func readTodoId() -> String { return self.todoId == 0 ? Strings.empty : self.todoId.cleanValue() }
    func readCategoryId() -> String { if let categoryId = self.readTodoCategory()?.readCategoryId() { return categoryId } else { return Strings.empty }  }
    func readOriginalStartDate() -> Date? { return self.originalStartDate }
    func readDueDate() -> String { return self.dueDate?.stringFromDate(format: DateFormatters.EEEDDMMMYYYY) ?? Strings.empty }
    func readCompletedDate() -> String { return self.modifiedAt?.stringFromDate(format: DateFormatters.MMMSDCYYYY) ?? Strings.empty }
    func readToDoTitle() -> String { return self.todoName ?? Strings.empty }
    func readNotes() -> String { return self.note ?? Strings.empty }
    func readRecurrenceToDoId() -> String { return self.recurrenceToDoId ?? Strings.empty }
    func readAppTodoId() -> String { return self.appToDoId ?? Strings.empty }
    func readMovedFrom() -> String { return self.movedFrom ?? Strings.empty }
    func readDeleteStatus() -> Bool { return self.deletedStatus || self.readTodoCategory()?.deletedStatus == true }
    func readTodoCategory() -> PlanItTodoCategory? { return self.parent?.todoCategory ?? self.todoCategory }
    func readCreatedDate() -> Date { return self.createdAt ?? Date() }
    func readModifiedDate() -> Date { return self.modifiedAt ?? Date() }
    func readRecurrenceEndDate() -> Date? { return self.recurrenceEndDate }
    func readReminders() -> PlanItReminder? { return self.reminder}
    func isRecurrenceTodo() -> Bool { return self.isRecurrence && self.readExactDueDate() != nil }
    func readAttachmentCount() -> String { return self.attachmentsCount ?? Strings.empty }
    func readSubTodosCount() -> String { return self.subTodosCount ?? Strings.empty }
    func readOrderDate() -> Date? { return self.order }
    func readOrderUsingOrderDateOrStartDate() -> Date { return self.readOrderDate() ?? self.readOrderUsingStartDateOrCreatedDate() }
    func readOrderUsingStartDateOrCreatedDate(using type: ToDoMainCategory = .custom) -> Date { return self.readStartDate(using: type) ?? self.readCreatedDate() }
    
    func readValueOfNotificationId() -> String {
        if let bNotificationId = self.notificationId, !bNotificationId.isEmpty {
            return bNotificationId
        }
        else {
            let newNotificationId = self.readTodoId().isEmpty ? self.readAppTodoId() : self.readTodoId()
            self.notificationId = newNotificationId
            return newNotificationId
        }
    }

    func saveOrderDate(_ date: Date) {
        self.order = date
        try? self.managedObjectContext?.save()
    }
    
    func updateDeleteStatus() {
        self.deletedStatus = true
        try? self.managedObjectContext?.save()
    }
    
    func readExactDueDate() -> Date? {
        return self.parent == nil ? self.dueDate : self.originalStartDate
    }
    
    func readStartDateInQueue(using type: ToDoMainCategory = .custom, identifier: IndexPath, result: @escaping (Date?, IndexPath) -> ()) {
        let date = self.readStartDate(using: type)
        result(date, identifier)
    }
    
    func readStartDate(using type: ToDoMainCategory = .custom) -> Date? {
        if self.isRecurrenceTodo() {
            switch type {
            case .today:
                return self.readRecurrenceAvailableDateRange(from: Date().initialHour())?.first ?? self.readExactDueDate()
            case .upcomming:
                let todayDate = Date().initialHour()
                let suggestedUpcomingDate = self.readCollectedDates().last?.addDays(1) ?? self.readExactDueDate() ?? todayDate.addDays(1)
                let originalUpcomingDate = suggestedUpcomingDate <= todayDate ? todayDate.addDays(1) : suggestedUpcomingDate
                if let originalDueDate = self.dueDate, originalUpcomingDate < originalDueDate {
                    return self.readRecurrenceAvailableDateRange(from: originalDueDate.initialHour())?.first ?? self.readExactDueDate()
                }
                else {
                    return self.readRecurrenceAvailableDateRange(from: originalUpcomingDate)?.first ?? self.readExactDueDate()
                }
            case .overdue:
                if let lastCompletedChildDate =  self.readCollectedDates().last {
                    return self.readRecurrenceAvailableDateRange(from: lastCompletedChildDate.initialHour().adding(days: 1))?.first
                }
                else if let startDate = self.readExactDueDate() {
                    return self.readRecurrenceAvailableDateRange(from: startDate.initialHour())?.first
                }
                else {
                    return self.readRecurrenceEndDate()
                }
            default:
                if let currentOriginalStartDate = self.readRecurrenceAvailableDateRange(from: Date().initialHour())?.first {
                    return currentOriginalStartDate
                }
                else {
                    let todayDate = Date().initialHour()
                    let recurrenceUntilDate = self.readRecurrenceEndDate() ?? todayDate
                    let suggestedDate = self.readCollectedDates().last?.addDays(1) ?? self.readExactDueDate() ?? todayDate
                    let originalDate = suggestedDate < todayDate && recurrenceUntilDate >= todayDate ? Date().initialHour() : suggestedDate
                    if let originalDueDate = self.dueDate, originalDate < originalDueDate {
                        return self.readRecurrenceAvailableDateRange(from: originalDueDate.initialHour())?.first ?? self.readExactDueDate()
                    }
                    else {
                        return self.readRecurrenceAvailableDateRange(from: originalDate)?.first ?? self.readExactDueDate()
                    }
                }
            }
        }
        return self.readExactDueDate()
    }
    
    func readAllAttachments() -> [PlanItUserAttachment] {
        if let bAttachments = self.attachments, let todoAttachments = Array(bAttachments) as? [PlanItUserAttachment] {
            return todoAttachments
        }
        return []
    }
    
    func readAllTags() -> [PlanItTags] {
        if let tags = self.tags, let todoTags = Array(tags) as? [PlanItTags] {
            return todoTags
        }
        return []
    }
    
    func readAllSubTodos() -> [PlanItSubTodo] {
        if let bSubTodos = self.subTodos, let todoSubTodos = Array(bSubTodos) as? [PlanItSubTodo] {
            return todoSubTodos
        }
        return []
    }
    
    func readAllInvitees() -> [PlanItInvitees] {
        if let bInvitees = self.invitees, let localInvitees = Array(bInvitees) as? [PlanItInvitees] {
            return localInvitees
        }
        return []
    }
    
    func readAllChildTodos() -> [PlanItTodo] {
        if let childTodos = self.child, let todoSubItems = Array(childTodos) as? [PlanItTodo] {
            return todoSubItems
        }
        return []
    }
    
    func deleteAllTodoAttachments(forceRemove: Bool) {
        if forceRemove {
            let allAttachments = self.readAllAttachments()
            self.removeFromAttachments(self.attachments ?? [])
            allAttachments.forEach({ self.managedObjectContext?.delete($0) })
        }
        else {
            let allAttachments = self.readAllAttachments().filter({ return !$0.isPending })
            self.removeFromAttachments(NSSet(array: allAttachments))
            allAttachments.forEach({ self.managedObjectContext?.delete($0) })
        }
    }
    
    func deleteAllTags() {
        let allTags = self.readAllTags()
        self.removeFromTags(self.tags ?? [])
        allTags.forEach({ self.managedObjectContext?.delete($0) })
    }
    
    func deleteAllInvitees() {
        let deletedInvitees = self.readAllInvitees()
        self.removeFromInvitees(NSSet(array: deletedInvitees))
        deletedInvitees.forEach({ self.managedObjectContext?.delete($0) })
    }
    
    func deleteAllInternalInvitees() {
        let deletedInvitees = self.readAllInvitees().filter({ return !$0.isOther })
        self.removeFromInvitees(NSSet(array: deletedInvitees))
        deletedInvitees.forEach({ self.managedObjectContext?.delete($0) })
    }
    
    func deleteAllExternalInvitees() {
        let deletedInvitees = self.readAllInvitees().filter({ return $0.isOther })
        self.removeFromInvitees(NSSet(array: deletedInvitees))
        deletedInvitees.forEach({ self.managedObjectContext?.delete($0) })
    }
    
    func deleteSubTodos() {
        let allSubTodos = self.readAllSubTodos()
        self.removeFromSubTodos(self.subTodos ?? [])
        allSubTodos.forEach({ self.managedObjectContext?.delete($0) })
    }
    
    func deleteSubTodos(_ subTasks: [Double]) {
        let deletedSubTodos = self.readAllSubTodos().filter({ return subTasks.contains($0.subTodoId) })
        self.removeFromSubTodos(NSSet(array: deletedSubTodos))
        deletedSubTodos.forEach({ self.managedObjectContext?.delete($0) })
    }
    
    func deleteRecurrence(withHardSave status: Bool = true) {
        guard let deletedRecurrence = self.recurrence else { return }
        self.recurrence = nil
        deletedRecurrence.deleteItSelf(withHardSave: status)
    }
    
    func deleteReminder(withHardSave status: Bool = true) {
        guard let deletedReminder = self.reminder else { return }
        self.reminder = nil
        deletedReminder.deleteItSelf(withHardSave: status)
    }
        
    func readCollectedDates() -> [Date] {
        return self.readAllChildTodos().compactMap({ return $0.readOriginalStartDate()?.initialHour() }).sorted(by: <)
    }
    
    func readAllAvailableDates(from: Date, to: Date) -> [Date] {
        if !self.isRecurrenceTodo() {
            guard let startDate = self.readExactDueDate(), startDate >= from, startDate <= to else { return [] }
            return [startDate]
        }
        else {
            if let recurrenceEnd = self.readRecurrenceEndDate() {
                guard recurrenceEnd >= from, let availableDate = self.readRecurrenceAvailableDateRange(from: from, to: to) else { return [] }
                return availableDate
            }
            else {
                guard let availableDate = self.readRecurrenceAvailableDateRange(from: from, to: to) else { return [] }
                return availableDate
            }
        }
    }
    
    func readTodoAvailableAtTimeRange(from: Date, to: Date) -> Bool {
        if !self.isRecurrenceTodo() {
            if let startDate = self.readExactDueDate(), startDate >= from , startDate <= to { return true }
            else { return false }
        }
        else {
            if let recurrenceEnd = self.readRecurrenceEndDate() {
                guard recurrenceEnd >= from, let availableDate = self.readRecurrenceAvailableDateRange(from: from, to: to) else { return false }
                return !availableDate.isEmpty
            }
            else {
                guard let availableDate = self.readRecurrenceAvailableDateRange(from: from, to: to) else { return false }
                return !availableDate.isEmpty
            }
        }
    }
    
    func isNextOccurrenceAvailableFromDate(_ date: Date) -> Bool {
        guard let availableDate = self.recurrence?.readAllAvailableDates(from: date) else { return false }
        return !availableDate.isEmpty
    }
    
    func readRecurrenceAvailableDateRange(from: Date, to: Date? = nil) -> [Date]? {
        guard let availableDate = self.recurrence?.readAllAvailableDates(from: from, to: to) else { return nil }
        let excludedDates: [Date] = self.readAllChildTodos().compactMap({ return $0.readOriginalStartDate()?.initialHour() })
        let balanceDates: [Date] = availableDate.compactMap({ let initialDate = $0.initialHour(); if excludedDates.contains(initialDate) { return nil } else { return initialDate } })
        return balanceDates
    }
    
    private func getFrequency(recurrence: String) -> String? {
        if let repeatValue = recurrence.slice(from: "FREQ=", to: ";") {
            return repeatValue
        }
        else if let repeatValue = recurrence.slice(from: "FREQ=") {
            return repeatValue
        }
        return nil
    }
    
    func getRepeatValueType(recurrence: String) -> DropDownOptionType {
        if let repeatValue = self.getFrequency(recurrence: recurrence) {
            switch repeatValue.uppercased() {
            case "DAILY":
                return .eEveryDay
            case "WEEKLY":
                return .eEveryWeek
            case "MONTHLY", "RELATIVEMONTHLY", "ABSOLUTEMONTHLY":
                return .eEveryMonth
            case "YEARLY":
                return .eEveryYear
            default:
                break
            }
        }
        return .eNever
    }
    
    func readRecurrenceStatement() -> String {
        var repeatString = ""
        if self.isRecurrenceTodo() {
            if let planItToDoRecurrence = self.recurrence, let rrRuleObject = RecurrenceRule(rruleString: planItToDoRecurrence.readRule()) {
                repeatString = "Repeats "
                switch rrRuleObject.frequency {
                case .daily:
                    let interval = planItToDoRecurrence.findIntervalInRule()
                    let everyYear = "\(interval.isEmpty ? "Yearly " : "every \(interval) \(Strings.years) " )"
                    let everyDay = "\(interval.isEmpty ? "Daily " : "every \(interval) \(Strings.days) " )"
                    repeatString += planItToDoRecurrence.readRule().contains("BYMONTH=") ? everyYear : everyDay
                case .weekly:
                    repeatString += planItToDoRecurrence.getRepeatWeeklyString()
                case .monthly:
                    repeatString += planItToDoRecurrence.getRepeatMonthyString()
                case .yearly:
                    let interval = planItToDoRecurrence.findIntervalInRule()
                    repeatString += "\(interval.isEmpty ? "Yearly " : "every \(interval) Year " )"
                default:
                    repeatString += Strings.empty
                }
                if let repeatUntilDate = rrRuleObject.recurrenceEnd?.endDate {
                    repeatString += "until \(repeatUntilDate.stringFromDate(format: DateFormatters.DDHMMMMHYYYY))"
                }
            }
        }
        return repeatString
    }
    
    

    func readReminderIntervalsFromStartDate(_ date: Date) -> Date? {
        if let reminder = self.readReminders() {
            return reminder.readReminderMinutesFromDate(date)
        }
        return nil
    }
    
    func createTextForPrediction() -> String {
        var text: String = ""
        text += self.readToDoTitle()
        text += self.readNotes().isEmpty ? Strings.empty : ", "+self.readNotes()
        return text
    }
    
    //MARK: - Save Offline
    func saveTodoName(_ name: String) {
        self.isPending = true
        self.todoName = name
        try? self.managedObjectContext?.save()
    }
    
    func saveDeleteStatus(_ status: Bool) {
        self.isPending = true
        self.deletedStatus = status
        try? self.managedObjectContext?.save()
    }
    
    func saveCompleteStatus(_ status: Bool, with type: ToDoMainCategory) {
        if self.isRecurrenceTodo(), let originalStartDate = self.readStartDate(using: type), self.isNextOccurrenceAvailableFromDate(originalStartDate.adding(days: 1)) {
            let childTodo = DataBasePlanItTodo().insertNewChildTodo(parent: self)
            childTodo.completed = status
            childTodo.dueDate = originalStartDate
            childTodo.originalStartDate = originalStartDate
            childTodo.favourited = self.favourited
            childTodo.createdAt = Date()
            childTodo.isRecurrence = false
            childTodo.modifiedAt = Date()
            childTodo.note = self.note
            childTodo.todoName = self.todoName
            childTodo.toDoStatus = self.toDoStatus
            childTodo.user = self.user
            childTodo.order = self.order ?? originalStartDate
            childTodo.addToAttachments(self.attachments ?? [])
            childTodo.addToTags(self.tags ?? [])
            childTodo.addToInvitees(self.invitees ?? [])
            childTodo.addToSubTodos(self.subTodos ?? [])
            childTodo.reminder = self.reminder
        }
        else {
            self.isPending = true
            self.completed = status
        }
        try? self.managedObjectContext?.save()
    }
    
    func saveFavoriteStatus(_ status: Bool) {
        self.isPending = true
        self.favourited = status
        try? self.managedObjectContext?.save()
    }
    
    func saveDueDate(_ date: String) {
        self.isPending = true
        self.dueDate = date.stringToDate(formatter: DateFormatters.YYYYHMMMHDD)
        try? self.managedObjectContext?.save()
    }
    
    func saveAssignedUser(_ user: CalendarUser) {
        self.isPending = true
        DatabasePlanItInvitees().insertTodo(self, other: user)
        try? self.managedObjectContext?.save()
    }
    
    func saveTodoAttachments(_ data: [UserAttachment]) {
        DatabasePlanItUserAttachment().insertAttachments(data, for: self)
    }
    
    func saveTodoTags(_ tags: [String]) {
        DatabasePlanItTags().insertTags(tags, for: self)
    }
    
    func saveTodoInvitees(_ invitees: [OtherUser]) {
        DatabasePlanItInvitees().insertTodo(self, other: invitees)
    }
    
    func saveTodoSubTask(_ subTodos: [SubToDoDetailModel]) {
        DatabasePlanItSubTodo().insertPlanItSubTodos(subTodos, to: self)
    }
    
    func saveTodoReminder(_ reminder: ReminderModel?) {
        if let reminders = reminder {
            DataBasePlanItTodoReminders().insertTodo(self, reminders: reminders)
        }
        else {
            self.deleteReminder(withHardSave: false)
        }
    }
    
    func saveTodoRecurrence(_ recurrence: String) {
        if recurrence.isEmpty {
            self.deleteRecurrence(withHardSave: false)
        }
        else {
            DatabasePlanItTodoRecurrence().insertTodo(self, recurrence: recurrence)
        }
    }
    
    func saveTodoDetails(_ details:ToDoDetailModel) {
        self.isPending = true
        self.remindMe = LocalNotificationType.new.rawValue
        self.saveTodoAttachments(details.attachments)
        self.dueDate = details.dueDate
        self.todoName = details.todoName
        self.note = details.notes
        self.saveTodoTags(details.tags)
        self.saveTodoInvitees(details.assignee)
        self.saveTodoSubTask(details.subToDos)
        self.saveTodoReminder(details.remindValue)
        self.saveTodoRecurrence(details.recurrence)
        try? self.managedObjectContext?.save()
    }
    
    func updateToDoCompleteViewStatus(with flag: Bool) {
        self.completedViewStatus = flag
        try? self.managedObjectContext?.save()
    }
}
