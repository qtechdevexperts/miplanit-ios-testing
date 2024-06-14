//
//  SingleDayCalendarViewController+Calendar.swift
//  MiPlanIt
//
//  Created by Arun on 03/08/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

extension SingleDayCalendarViewController: CalendarDelegate, CalendarDataSource {
    
    func refereshCalendarData() {
        
    }
    
    
    func setVisibilityEventIcon(with status: Bool) {
        self.viewCalendarListContainer.alpha = status ? 1.0 : 0.0
    }
    
    func didFinishChangeTimeLine(_ date: Date?, with events: [Event]) {
    }
    
    func didChangeTimeLine(_ date: Date?, with events: [Event], onDragging flag: Bool) {
        guard let pointedDate = date else { return }
        var listData: [Any] = []
        let conflictedEvents = events.filter({ return $0.start <= pointedDate && $0.end >= pointedDate })
        
        let calendars = conflictedEvents.filter({ return $0.eventData is PlanItEvent && !$0.isAllDay}).compactMap({ return $0.calendar})
        let balanceCalendars = Array(Set(calendars)).sorted(by: { $0.calendarId < $1.calendarId })
        listData.append(contentsOf: balanceCalendars)
        
        let otherUserIds = conflictedEvents.compactMap({ return $0.eventData as? OtherUserEvent}).filter({ !$0.isAllDay }).map({ return $0.userId })
        let balanceUsers = Array(Set(otherUserIds))
        let conflictedUsers = self.eventUsers.filter({ return balanceUsers.contains($0.userId) }).sorted(by: { $0.userId < $1.userId })
        listData.append(contentsOf: conflictedUsers)
        
        self.viewCalendarList.reloadUsersListWith(listData, enableEventColor: true, containsMiPlanItCalendarWithOtherUser: self.containsMiPlanItCalendarWithOtherUser)
        self.viewCalendarList.alpha = listData.isEmpty ? 0.0 : 1.0
    }
    
    func didSelectDate(_ date: Date?, type: CalendarType, frame: CGRect?) {
    }
    
    func didSelectEvent(_ event: Event, type: CalendarType, frame: CGRect?) {
        self.dismiss(animated: true) {
            self.delegate?.singleDayCalendarViewController(self, didSelect: event)
        }
    }
    
    func eventsForCalendar() -> [Event] {
        return self.events
    }
    
    func willDisplayDate(_ date: Date?, events: [Event]) -> DateStyle? {
        return nil//DateStyle(backgroundColor: .white, textColor: .black, dotBackgroundColor: .white)
    }
    
    func didAddEvent(_ date: Date?, type: CalendarType) {
        if type == .day {
            dismiss(animated: true) {
                self.delegate?.singleDayCalendarViewController(self, createEventOn: date)
            }
        }
    }
}
