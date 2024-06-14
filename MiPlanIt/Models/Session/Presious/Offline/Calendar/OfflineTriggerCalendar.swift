//
//  OfflineTriggerCalendar.swift
//  MiPlanIt
//
//  Created by Arun Aniyappan on 27/11/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

extension Session {
    
    func sendCalendarsToServer(_ finished: @escaping () -> ()) {
        let pendingCalendars = DatabasePlanItCalendar().readAllPendingCalendars()
        if pendingCalendars.isEmpty {
            self.sendDeleteCalendarsToServer(finished)
        }
        else {
            self.startCalendarsSending(pendingCalendars) {
                self.sendDeleteCalendarsToServer(finished)
            }
        }
    }
    
    private func startCalendarsSending(_ calendars: [PlanItCalendar], atIdex: Int = 0, finished: @escaping () -> ()) {
        if atIdex < calendars.count {
            self.sendCalendarToServer(calendar: calendars[atIdex], at: atIdex, result: { index in
                self.startCalendarsSending(calendars, atIdex: index + 1, finished: finished)
            })
        }
        else {
            finished()
        }
    }
    
    private func sendCalendarToServer(calendar: PlanItCalendar, at index: Int, result: @escaping (Int) -> ()) {
        let newCalendar = NewCalendar(planItCalendar: calendar)
        CalendarService().addEditNewCalendar(newCalendar, callback: { response, error in
            if let _ = response {
                self.sendCalendarImageToServer(calendar: newCalendar, at: index, result: result)
            }
            else {
                result(index)
            }
        })
    }
    
    private func sendCalendarImageToServer(calendar: NewCalendar, at index: Int, result: @escaping (Int) -> ()) {
        if let user = Session.shared.readUser(), let planItCalendar = calendar.planItCalendar, let data = calendar.calendarImageData, !data.isEmpty {
            let fileName = String(Date().millisecondsSince1970) + Extensions.png
            CalendarService().uploadCalendarImages(planItCalendar, file: data.base64EncodedString(options: .lineLength64Characters), name: fileName, by: user) { (_, _) in
                result(index)
            }
        }
        else {
            result(index)
        }
    }
    
    func sendDeleteCalendarsToServer(_ finished: @escaping () -> ()) {
        let pendingDeletedCalendars = DatabasePlanItCalendar().readAllPendingDeletedCalendars()
        if pendingDeletedCalendars.isEmpty {
            finished()
        }
        else {
            self.startDeletedCalendarSending(pendingDeletedCalendars) {
                finished()
            }
        }
    }
    
    private func startDeletedCalendarSending(_ calendars: [PlanItCalendar], atIdex: Int = 0, finished: @escaping () -> ()) {
        if atIdex < calendars.count {
            self.sendDeletedCalendarToServer(calendar: calendars[atIdex], at: atIdex, result: { index in
                self.startDeletedCalendarSending(calendars, atIdex: index + 1, finished: finished)
            })
        }
        else {
            finished()
        }
    }
    
    private func sendDeletedCalendarToServer(calendar: PlanItCalendar, at index: Int, result: @escaping (Int) -> ()) {
        CalendarService().deleteCalendar(calendar) { (status, error) in
            result(index)
        }
    }
}
