//
//  MyCalanderBaseViewController+Action.swift
//  MiPlanIt
//
//  Created by Nikhil RajG on 31/03/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

extension MyCalanderBaseViewController {
    
    func intialiseUIComponents() {
        self.initialiseUserListMain()
        self.calendarView.delegate = self
        self.calendarView.dataSource = self
        self.initialiseList(self.viewCalendarList)
        self.viewCalendarList.showCalendarColor = true
        self.lottieAnimationView.backgroundBehavior = .pauseAndRestore
        self.calendarView.setStyle(self.createStyle())
        self.calendarView.set(type: .day, date: self.selectedDate)
        self.showMiPlanItCalendarValues(self.readParentCalendars())
        let titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        self.segmentedControl.setTitleTextAttributes(titleTextAttributes, for: .normal)
        self.segmentedControl.setTitleTextAttributes(titleTextAttributes, for: .selected)
        self.segmentedControl.tintColor = UIColor(red: 0/255.0, green: 0/255.0, blue: 0/255.0, alpha: 0.18)
    }
    
    func initialiseList(_ list: UsersListView) {
        list.delegate = self
        list.bubbleAlignment = .left
        list.bubbleDirection = .leftToRight
        list.distanceInterBubbles = -10
        list.maxNumberOfBubbles = 50
        list.colorForBubbleTitles = UIColor.init(red: 86/255.0, green: 173/255.0, blue: 189/255.0, alpha: 1.0)
        list.colorForBubbleBorders = UIColor.init(red: 86/255.0, green: 173/255.0, blue: 189/255.0, alpha: 1.0)
        list.backgroundColor = UIColor.init(red: 1, green: 1, blue: 1, alpha: 0.8)
    }
    
    func initialiseUserListMain() {
        self.viewUsersMainList.delegate = self
        self.viewUsersMainList.bubbleAlignment = .right
        self.viewUsersMainList.bubbleDirection = .leftToRight
        self.viewUsersMainList.maxNumberOfBubbles = 1
        self.viewUsersMainList.colorForBubbleTitles = .white
//        self.viewUsersMainList.colorForBubbleBorders = .white
        self.viewUsersMainList.typeOfList = .eCalendar
    }
    
    func addNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(calendarResetToInitialDate), name: NSNotification.Name(rawValue: Notifications.calendarResetToInitialDate), object: nil)
    }
    
    func removeNotifications() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Notifications.calendarResetToInitialDate), object: nil)
    }
    
    @objc func calendarResetToInitialDate() {
        let type = CalendarType.allCases[self.segmentedControl.selectedSegmentIndex]
        self.calendarView.set(type: type, date: Date())
        self.calendarView.reloadData()
    }
    
    func showEventLoadingIndicator() {
        guard let mindate = self.collectedMinMonth, let maxdate = self.collectedMaxMonth else { return }
        if (self.selectedMonth <= mindate && self.selectedMonth.monthBetweenDate(toDate: Date().startOfTheMonth()) < self.forwardCounter) || (self.selectedMonth >= maxdate && Date().startOfTheMonth().monthBetweenDate(toDate: self.selectedMonth) < self.forwardCounter) {
            self.startTabBarGradientAnimation()
        }
        else {
            self.hideEventLoadingIndicator()
        }
    }
    
    func hideEventLoadingIndicator() {
        guard let mindate = self.collectedMinMonth, let maxdate = self.collectedMaxMonth else { return }
        if self.selectedMonth > mindate && self.selectedMonth < maxdate {
            self.stopTabBarGradientAnimation()
        }
    }
    
    func readParentCalendars() -> [PlanItCalendar] {
        return DatabasePlanItCalendar().readAllPlanitCalendars().filter({ return $0.parentCalendarId == 0})
    }
    
    func readSelectedCalendar() -> PlanItCalendar? {
        return self.selectedCalanders.filter({ return $0.canEdit && ($0.calendarType == 0 || ($0.calendarType != 3 && $0.createdBy?.readValueOfUserId() == Session.shared.readUserId())) }).first
    }
    
    func checkEventPermissionToShowDetails(_ event: Event) {
        if let selectedEvent = event.eventData as? PlanItEvent {
            guard selectedEvent.accessLevel == 1 || event.calendar?.accessLevel == 2 else { return }
            self.performSegue(withIdentifier: Segues.toShowEvent, sender: event)
        }
        else if let selectedEvent = event.eventData as? OtherUserEvent {
            guard selectedEvent.accessLevel == "1" || selectedEvent.visibility == 0 else { return }
            self.checkForEventAvailability(event)
        }
    }
    
    func checkForEventAvailability(_ event: Event) {
        if let selectedEvent = event.eventData as? OtherUserEvent, selectedEvent.createdBy?.userId == Session.shared.readUserId(), let eventId = Double(selectedEvent.eventId), DatabasePlanItEvent().readPlanItEventsWith(eventId) == nil {
            self.showAlertWithAction(message: Message.notSyncMessage, title: Message.notSyncError, items: [Message.yes, Message.cancel], callback: { index in
                if index == 0 {
                    self.createServiceToFetchUsersData()
                }
                else {
                    self.performSegue(withIdentifier: Segues.toShowEvent, sender: event)
                }
            })
        }
        else {
            self.performSegue(withIdentifier: Segues.toShowEvent, sender: event)
        }
    }
    
    func readSuperEvents() -> [Event] {
        guard let minDate = self.collectedMinMonth, let maxDate = self.collectedMaxMonth, self.selectedDate >= minDate, self.selectedDate <= maxDate else { return self.selectedMonth == Date().startOfTheMonth() ? Session.shared.readFastestEvents() : self.allEvents }
        return self.allEvents
    }
    
    func readEventsFromSelectedCalendar() {
        let endOfMonth = self.selectedDate.endOfTheMonth().addDays(6)
        let startOfMonth = self.selectedDate.startOfTheMonth().addDays(-6)
        if self.selectedCalanders.isEmpty || self.selectedCalanders.contains(where: { return $0.parentCalendarId == 0 }) {
            self.events = self.readSuperEvents().filter({ return ($0.start >= startOfMonth && $0.start <= endOfMonth) || ($0.end >= startOfMonth && $0.end <= endOfMonth) || ($0.start < startOfMonth && $0.end > endOfMonth) })
        }
        else {
            self.events = self.readSuperEvents().filter({ if let calendar = $0.calendar { return (($0.start >= startOfMonth && $0.start <= endOfMonth) || ($0.end >= startOfMonth && $0.end <= endOfMonth) || ($0.start < startOfMonth && $0.end > endOfMonth)) && self.selectedCalanders.contains(calendar) } else { return false } })
        }
        self.calendarView.reloadData()
    }
    
    func readEventsOfOtherUsers() {
        let endOfMonth = self.selectedDate.endOfTheMonth().addDays(6)
        let startOfMonth = self.selectedDate.startOfTheMonth().addDays(-6)
        if self.selectedCalanders.contains(where: { return $0.parentCalendarId == 0 }) {
            self.events = self.readSuperEvents().filter({ return $0.start >= startOfMonth && $0.end <= endOfMonth })
        }
        else {
            self.events = self.readSuperEvents().filter({ if let calendar = $0.calendar, $0.isOwnersEvent { return $0.start >= startOfMonth && $0.end <= endOfMonth && self.selectedCalanders.contains(calendar) } else { return $0.start >= startOfMonth && $0.end <= endOfMonth && !$0.isOwnersEvent } })
        }
        self.calendarView.reloadData()
    }
    
    func showMiPlanItCalendarValues(_ calendars: [PlanItCalendar]) {
        self.calendarType = .myCalendar
        self.viewUsersMainList.reloadUsersListWith(self.readParentCalendars())
        self.selectedCalanders = calendars
    }
    
    func createStyle() -> Style {
        var style = Style()
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "MMM yyyy"
        style.timeline.startFromFirstEvent = false
        style.timeline.timeColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        style.timeline.currentLineHourColor = #colorLiteral(red: 1, green: 0.3450980392, blue: 0.3450980392, alpha: 1)
        style.timeline.heightLine = 1.0
        style.timeline.offsetLineRight = 100
        style.timeline.eventFont = UIFont(name: Fonts.SFUIDisplayRegular, size: 13)!
        style.timeline.timeFont = UIFont(name: Fonts.SFUIDisplayRegular, size: 12)!
        style.timeline.currentLineHourFont = UIFont(name: Fonts.SFUIDisplayRegular, size: 12)!
        style.timeline.widthTime = 40
        style.timeline.offsetTimeX = 2
        style.timeline.offsetLineLeft = 2
        style.timeline.offsetTimeY = 66
        style.timeline.offsetEvent = 3
        style.timeline.currentLineHourWidth = 40
        
        style.allDay.isPinned = true
        style.allDay.height = 20
        style.allDay.offset = 1
        style.allDay.backgroundColor = #colorLiteral(red: 0.137254902, green: 0.1450980392, blue: 0.2588235294, alpha: 1) //232542//.white
        style.allDay.titleColor = .white//.black
        style.startWeekDay = .sunday
        style.timeHourSystem = .twelveHour
        style.event.isEnableMoveEvent = false
        
        style.headerScroll.titleDays = ["S","M","T","W","T","F","S"]
        style.headerScroll.colorTitleDate = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        style.headerScroll.formatterTitle = dateFormat
        style.headerScroll.colorWeekdayBackground = .clear
        style.headerScroll.colorBackgroundSelectDate = #colorLiteral(red: 226/255.0, green: 88/255.0, blue: 90/255.0, alpha: 1)
        style.headerScroll.colorBackground = .clear
        style.headerScroll.colorBackgroundCurrentDate = #colorLiteral(red: 226/255.0, green: 88/255.0, blue: 90/255.0, alpha: 1)
        style.headerScroll.colorSelectDate = .white
        style.headerScroll.colorNameDay = #colorLiteral(red: 0.5843137255, green: 0.5764705882, blue: 0.5803921569, alpha: 1)
        style.headerScroll.colorDate = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        style.headerScroll.colorWeekendDate = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        
        style.week.colorWeekdayBackground = .clear//.white
        style.week.colorDate = #colorLiteral(red: 0.5843137255, green: 0.5764705882, blue: 0.5803921569, alpha: 1)
        style.week.colorWeekendDate = #colorLiteral(red: 0.5843137255, green: 0.5764705882, blue: 0.5803921569, alpha: 1)
        style.week.colorBackground = .clear
        
        style.month.formatter = dateFormat
        style.month.moreTitle = "..."//"🔘"
        style.month.colorMoreTitle = .white
        style.month.colorBackgroundWeekendDate = .grayMT//.white
        style.month.colorBackground = .grayMT//.clear
        style.month.colorWeekendDate = #colorLiteral(red: 0.8039215686, green: 0.8039215686, blue: 0.8039215686, alpha: 1)
        style.month.colorDate = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        style.month.colorBackgroundSelectDate = #colorLiteral(red: 226/255.0, green: 88/255.0, blue: 90/255.0, alpha: 1)
        style.month.fontNameDate = UIFont(name: Fonts.SFUIDisplayRegular, size: 18)!
        style.month.fontEventTitle = UIFont(name: Fonts.SFUIDisplayRegular, size: 13)!
        style.month.heightHeaderWeek = 25
        style.month.isHiddenTitleDate = false
        style.month.isHiddenSeporator = true
        return style
    }
    
    func updateEventCalendarIcon(on date: Date?, of events: [Event], onTimelineDrag: Bool = false) {
        guard let pointedDate = date else { return }
        var listData: [Any] = []
        let conflictedEvents = events.filter({ return $0.start <= pointedDate && $0.end >= pointedDate })
        
        let calendars = conflictedEvents.filter({ return $0.eventData is PlanItEvent && !$0.isAllDay }).compactMap({ return $0.calendar })
        let balanceCalendars = Array(Set(calendars)).sorted(by: { $0.calendarId < $1.calendarId })
        listData.append(contentsOf: balanceCalendars)
        
        let otherUserIds = conflictedEvents.compactMap({ return $0.eventData as? OtherUserEvent}).filter({ !$0.isAllDay }).map({ return $0.userId })
        let balanceUsers = Array(Set(otherUserIds))
        let conflictedUsers = self.otherUsers.filter({ return balanceUsers.contains($0.userId) }).sorted(by: { $0.userId < $1.userId })
        listData.append(contentsOf: conflictedUsers)
        
        self.viewCalendarList.reloadUsersListWith(listData, enableEventColor: true, containsMiPlanItCalendarWithOtherUser: (!self.otherUsers.isEmpty && !self.viewCalendarList.showCalendarColor) )
        self.viewCalendarList.alpha = listData.isEmpty ? 0.0 : 1.0
        self.viewCalendarList.backgroundColor = .clear
        self.viewForAlpha.alpha = listData.isEmpty ? 0.0 : 0.5
        self.viewForAlpha.backgroundColor = listData.isEmpty ? .clear : .grayLight
    }
    
    func getAvailableCalendars() -> [PlanItCalendar] {
        return DatabasePlanItCalendar().readAllPlanitCalendars().filter({ return $0.calendarType == 0 || $0.createdBy?.readValueOfUserId() == Session.shared.readUserId() })
    }
    
    func isHelpShown() -> Bool {
        return Storage().readBool(UserDefault.calendarHelp) ?? false
    }
}
