//
//  MyCalanderBaseViewController+Calendar.swift
//  MiPlanIt
//
//  Created by Nikhil RajG on 31/03/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

extension MyCalanderBaseViewController: CalendarDelegate, CalendarDataSource, CompareEventDateProtocol {

//    func test2(){
//        let socialAccounts = DatabasePlanItSocialUser().readAllGoogleUsersSocialAccounts().first!
//        GoogleService().readCalendarEventsForUser(socialAccounts, callback: { result, error in
//            if let list = result {
//                self.sendGoogleCalendarSynchronisationToServer(list)
//            }
//            else {
//                let message = error?.localizedDescription ?? Message.unknownError
//            }
//        })
//    }
//
//    func sendGoogleCalendarSynchronisationToServer(_ calendars: [SocialCalendar]) {
////        if userCalendarTypes.count != 0{
//            let calendarIds =  self.userCalendarTypes[self.syncIndex].calendars.compactMap({ return $0.calendar.socialCalendarId })
//            let socialCalendars = calendars.filter({ return calendarIds.contains($0.calendarId) })
//
//            if !socialCalendars.isEmpty {
//                self.fetchEventsOfGoogleCalendars(socialCalendars, fromIndex: 0)
//            }
////        }
//            else {
////                self.buttonSyncCalendar?.stopAnimation()
//                self.showAlertWithAction(message: Message.socialInvalidCalendarAccount, title: Message.warning, items: [Message.no, Message.yes], callback: { option in
//                    if option == 1 {
//                        SocialManager.default.loginGoogleFromViewController(self, client: ConfigureKeys.googleClientKey, scopes: ServiceData.googleScope, result: self)
//                    }
//                })
//            }
////        }
//    }

    
    //////////////////////////////////
    func refereshCalendarData() {
        self.createServiceToFetchUsersData()
    }
    //TODO: Always Hit
    func setVisibilityEventIcon(with status: Bool) {
//        self.sayHello()
//        DispatchQueue.main.asyncAfter(deadline: .now()+10, execute: { [self] in
//            if isCalendar{
//                var test = readAllAvailableCalendars()
//            }
//        })
        self.viewCalendarListContainer.alpha = status ? 1.0 : 0.0
    }
    
    //TODO: get the user calander type
    
     func readAllAvailableCalendars() -> [UserCalendarType] {
        var userCalendarTypes: [UserCalendarType] = []
        let availableCalendars = DatabasePlanItCalendar().readAllPlanitCalendars()
        let usersAndMiPlanItCalendars = availableCalendars.filter({ return $0.isOwnersCalendar() })
        let groupedCalendar = Dictionary(grouping: usersAndMiPlanItCalendars, by: { $0.readValueOfCalendarType() + Strings.hyphen + $0.readValueOfCalendarTypeLabel() })
        userCalendarTypes = groupedCalendar.map({ key, values in
            let splittedValues = key.components(separatedBy: Strings.hyphen)
            return UserCalendarType(with: splittedValues.first, title: splittedValues.last, calendars: values, selectedCalendars: self.selectedCalendars)
        })
        let disabledCalendars = availableCalendars.filter({ return $0.calendarType != 0 && $0.createdBy?.readValueOfUserId() != Session.shared.readUserId() })
        if !disabledCalendars.isEmpty {
            self.allDisabledCalendars = disabledCalendars.map({ return UserCalendarVisibility(with: $0, isDisabled: true) })
        }
        let vc = CalanderDropDownBaseListViewController()
         vc.delegateRefresh = self
         vc.test2()
         vc.test3()
         vc.userCalendarTypes = userCalendarTypes
         self.createServiceToFetchUsersData()
//         vc.readCalendarFromAppleUsingGrantPermission(availableCalendars).
         if vc.userCalendarTypes.count > 1 {
            vc.readCalendarFromAppleUsingGrantPermission(vc.userCalendarTypes[1].calendars.map({ return $0.calendar })) //crash

         }
                


//         vc.sendAppleCalendarSynchronisationToServer(vc.userCalendarTypes[1].calendars.map({ return $0.calendar }))
//         self.createServiceToFetchUsersData()
//         self.addNotifications()
        return userCalendarTypes
    }
    func didFinishChangeTimeLine(_ date: Date?, with events: [Event]) {
        if self.calendarType == .myCalendar {
            self.viewCalendarList.reloadCalendarListWith(self.selectedCalanders)
        }
        else {
            self.viewCalendarList.reloadCalendarListWith(self.otherUsers, enableEventColor: true)
        }
    }

    func didChangeTimeLine(_ date: Date?, with events: [Event], onDragging flag: Bool) {
        self.updateEventCalendarIcon(on: date, of: events, onTimelineDrag: flag)
    }
    
    func didSelectDate(_ date: Date?, type: CalendarType, frame: CGRect?) {
        self.selectedDate = (date ?? Date()).initialHour()
        self.calendarView.reloadData()
        if self.segmentedControl.selectedSegmentIndex == 2 && type == .week {
            let events = self.events.filter({ return compareStartEndDate(event: $0, date: self.selectedDate) })
            self.performSegue(withIdentifier: Segues.toSingleDayView, sender: (events, self.selectedDate))
        }
    }
    
    func didSelectMore(_ date: Date, frame: CGRect?) {
        let events = self.events.filter({ return compareStartEndDate(event: $0, date: date) })
        self.performSegue(withIdentifier: Segues.toSingleDayView, sender: (events, date.initialHour()))
    }
    
    func didSelectEvent(_ event: Event, type: CalendarType, frame: CGRect?) {
        self.checkEventPermissionToShowDetails(event)
    }

    func eventsForCalendar() -> [Event] {
        return self.events
    }
    
    func willDisplayDate(_ date: Date?, events: [Event]) -> DateStyle? {
        return nil//DateStyle(backgroundColor: .white, textColor: .black, dotBackgroundColor: .white)
    }
    
    func didAddEvent(_ date: Date?, type: CalendarType) {
        if type == .day {
            self.performSegue(withIdentifier: Segues.toAddNewEventScreen, sender: date)
        }
    }
}

extension MyCalanderBaseViewController: SingleDayCalendarViewControllerDelegate {
    
    func singleDayCalendarViewController(_ viewcontroller: SingleDayCalendarViewController, createEventOn date: Date?) {
        self.performSegue(withIdentifier: Segues.toAddNewEventScreen, sender: date)
    }
    
    
    func singleDayCalendarViewController(_ viewcontroller: SingleDayCalendarViewController, didSelect event: Event) {
        self.checkEventPermissionToShowDetails(event)
    }
}

extension MyCalanderBaseViewController: AddCalendarViewControllerDelegate {
    
    func addCalendarViewController(_ viewController: AddCalendarViewController, createdNewCalendar calendar: PlanItCalendar) {
        var selectedCalendars = self.selectedCalanders
        if self.selectedCalanders.filter({ $0.parentCalendarId == 0 }).isEmpty {
            selectedCalendars = selectedCalendars + [calendar]
        }
        self.showMiPlanItCalendarValues(selectedCalendars)
    }
}

extension MyCalanderBaseViewController: CreateEventsViewControllerDelegate {
    
    func createEventsViewController(_ viewController: CreateEventsViewController, addedEvents: [Any], deletedChilds: [String]?, toCalendars calendars: [UserCalendarVisibility]) {
        guard let events = addedEvents as? [PlanItEvent] else { return }
        self.addUsersNewEvents(events, to: calendars)
    }
}

extension MyCalanderBaseViewController:ViewEventViewControllerDelegate {
    
    func viewEventViewController(_ viewController: ViewEventViewController, deleted events: [OtherUserEvent], deletedChilds: [String]?, withType type: RecursiveEditOption) {
        guard let event = viewController.eventPlanOtherObject as? OtherUserEvent else { return }
        self.delete(event: event, childs: events, deletedChilds: deletedChilds ?? [], for: viewController.dateEvent, with: type)
    }
    
    func viewEventViewController(_ viewController: ViewEventViewController, update events: [OtherUserEvent], deletedChilds: [String]?) {
        guard let event = viewController.eventPlanOtherObject as? OtherUserEvent else { return }
        let childEvents = events.flatMap({ return $0.readAllChildEvents() })
        self.updateOtherExistingEvents(events + childEvents, parent: event, deletedChilds: deletedChilds ?? [])
    }
    
    func viewEventViewController(_ viewController: ViewEventViewController, deleted events: [PlanItEvent], deletedChilds: [String]?, withType type: RecursiveEditOption) {
        guard let event = viewController.eventPlanOtherObject as? PlanItEvent else { return }
        self.delete(event: event, childs: events, deletedChilds: deletedChilds ?? [], for: viewController.dateEvent, with: type)
    }
    
    func viewEventViewController(_ viewController: ViewEventViewController, update events: [PlanItEvent], deletedChilds: [String]?) {
        let childEvents = events.flatMap({ return $0.readAllChildEvents() })
        self.updateUsersExistingEvents(events + childEvents, deletedChilds: deletedChilds ?? [])
    }
}


extension MyCalanderBaseViewController: TabViewControllerDelegate {
    
    func tabViewController(_ tabViewController: TabViewController, updateHeightWithAd: Bool) {
        self.constraintTabHeight?.constant = updateHeightWithAd ? 147 : 77
    }
}
