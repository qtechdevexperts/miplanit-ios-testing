//
//  TimelineModel.swift
//  KVKCalendar
//
//  Created by Sergei Kviatkovskii on 09.03.2020.
//

import Foundation

struct CrossEvent: Hashable {
    let eventTime: EventTime
    var count: Int
    var eventId: String
    init(eventTime: EventTime, count: Int = 1, eventId: String = Strings.empty) {
        self.eventTime = eventTime
        self.count = count
        self.eventId = eventId
    }
    
    static func == (lhs: CrossEvent, rhs: CrossEvent) -> Bool {
        return lhs.eventTime == rhs.eventTime
            && lhs.count == rhs.count
    }
}

extension CrossEvent {
    var displayValue: String {
        return "\(Date(timeIntervalSince1970: eventTime.start).toLocalTime()) - \(Date(timeIntervalSince1970: eventTime.end).toLocalTime()) = \(count)"
    }
}

struct EventTime: Equatable, Hashable {
    let start: TimeInterval
    let end: TimeInterval
}

struct CrossPageTree: Hashable {
    let parent: Parent
    var children: [Child]
    var count: Int
    
    init(parent: Parent, children: [Child]) {
        self.parent = parent
        self.children = children
        self.count = children.count + 1
    }
    
    func indexOfChildren(_ event: Event) -> Int? {
        return children.firstIndex(where: { return $0.eventId == event.id })
    }
    
    func equalToChildren(_ event: Event) -> Bool {
        return children.contains(where: { $0.start == event.start.timeIntervalSince1970 })
    }
    
    func excludeToChildren(_ event: Event) -> Bool {
        return children.contains(where: { $0.start..<$0.end ~= event.start.timeIntervalSince1970 })
    }
    
    static func == (lhs: CrossPageTree, rhs: CrossPageTree) -> Bool {
        return lhs.parent == rhs.parent
            && lhs.children == rhs.children
            && lhs.count == rhs.count
    }
}

struct Parent: Equatable, Hashable {
    let start: TimeInterval
    let end: TimeInterval
    let eventId: String
}

struct Child: Equatable, Hashable {
    let start: TimeInterval
    let end: TimeInterval
    let eventId: String
}

protocol TimelineDelegate: AnyObject {
    func didDisplayEvents(_ events: [Event], dates: [Date?])
    func didSelectEvent(_ event: Event, frame: CGRect?)
    func nextDate()
    func previousDate()
    func swipeX(transform: CGAffineTransform, stop: Bool)
    func didChangeEvent(_ event: Event, minute: Int, hour: Int, point: CGPoint)
    func didAddEvent(minute: Int, hour: Int, point: CGPoint)
    func didTimeLineChanged(to dateTime: Date, with events: [Event], onDragging flag: Bool)
    func didTimeLineChangedFinished(to dateTime: Date, with events: [Event])
    func setVisibilityEventIcon(with status: Bool)
}

protocol CompareEventDateProtocol {
    func compareStartEndDate(event: Event, date: Date?) -> Bool
    func compareAllDayStartEndDate(event: Event, date: Date?) -> Bool
    func compareNormalDayStartEndDate(event: Event, date: Date?) -> Bool
}

extension CompareEventDateProtocol {
    
    func compareStartEndDate(event: Event, date: Date?) -> Bool {
        guard let endOfTheDay = date?.endOfDay, let startOfTheDay = date?.startOfDay else { return false }
        return event.start <= endOfTheDay && event.end > startOfTheDay
    }
    
    func compareNormalDayStartEndDate(event: Event, date: Date?) -> Bool {
        guard let endOfTheDay = date?.endOfDay, let startOfTheDay = date?.startOfDay else { return false }
        return !event.isAllDay && ((event.start >= startOfTheDay && event.start <= endOfTheDay) || (event.end >= startOfTheDay && event.end <= endOfTheDay))
    }
    
    func compareAllDayStartEndDate(event: Event, date: Date?) -> Bool {
        guard let endOfTheDay = date?.endOfDay, let startOfTheDay = date?.startOfDay else { return false }
        return (event.isAllDay && compareStartEndDate(event: event, date: date)) || (event.start < startOfTheDay && event.end > endOfTheDay)
    }
}
