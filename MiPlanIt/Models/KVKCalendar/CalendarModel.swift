//
//  CalendarModel.swift
//  KVKCalendar
//
//  Created by Sergei Kviatkovskii on 25.02.2020.
//

import UIKit

public enum TimeHourSystem: Int {
    case twelveHour = 12
    case twentyFourHour = 24
    
    var hours: [String] {
        switch self {
        case .twelveHour:
            let array = ["12"] + Array(1...11).map({ String($0) })
            let am = array.map { $0 + " AM" } + ["Noon"]
            var pm = array.map { $0 + " PM" }
            
            pm.removeFirst()
            if let item = am.first {
                pm.append(item)
            }
            return am + pm
        case .twentyFourHour:
            let array = ["00:00"] + Array(1...24).map({ (i) -> String in
                let i = i % 24
                var string = i < 10 ? "0" + "\(i)" : "\(i)"
                string.append(":00")
                return string
            })
            return array
        }
    }
}

public enum CalendarType: String, CaseIterable {
    case day, week, month, year
}

public struct EventColor {
    let value: UIColor
    let alpha: CGFloat
    
    public init(_ color: UIColor, alpha: CGFloat = 1.0) {
        self.value = color
        self.alpha = alpha
    }
}

public struct Event {
    public var id: String = ""
    public var text: String = ""
    public var start: Date = Date()
    public var end: Date = Date()
    public var initialDate: Date = Date()
    public var isAllDay: Bool = false
    public var isContainsFile: Bool = false
    public var textForMonth: String = ""
    public var eventData: Any?
    public var eventId: String = ""
    public var appEventId: String = ""
    public var isAccepted: Bool = true
    public var isOwnersEvent: Bool = true
    public var calendarId: String = ""
    public var calendar: PlanItCalendar?
    public var location: String = ""
    
    public var color: EventColor? {
        if self.isOwnersEvent {
            return EventColor(Storage().readEventBGColorFromCode(!Session.shared.readOthersCalendarAccessed() ? self.calendar?.readValueOfColorCode() : Strings.defaultColorCode))
        }
        else {
            if let event = self.eventData as? OtherUserEvent { return EventColor(event.readUserColorCode() ?? UIColor.blue.withAlphaComponent(0.3)) } else { return nil }
        }
    }
    
    public var backgroundColor: UIColor {
        guard let calendarColor = self.color else { return UIColor.blue.withAlphaComponent(0.3) }
        return calendarColor.value.withAlphaComponent(self.isAccepted ? calendarColor.alpha : 0.3)
    }
    
    public var colorText: UIColor {
        
        if self.isOwnersEvent {
            return Storage().readTextColorFromCode(!Session.shared.readOthersCalendarAccessed() ? self.calendar?.readValueOfColorCode() : Strings.defaultColorCode)
        }
        else {
            if let event = self.eventData as? OtherUserEvent { return event.readUserTextColorCode() ?? UIColor.blue.withAlphaComponent(0.3) } else { return UIColor.black }
        }
    }
    
    public var dotColor: UIColor {
        
        return Storage().readCalendarColorFromCode(calendar?.readValueOfColorCode())
    }
    
    init() {  }
    
    init(with event: PlanItEvent, startDate: Date, converter: DatabasePlanItEvent) {
        self.isOwnersEvent = true
        self.eventId = event.readValueOfEventId()
        self.appEventId = event.readValueOfAppEventId()
        let specificId = event.readValueOfEventId().isEmpty ? event.readValueOfAppEventId() : event.readValueOfEventId()
        self.id = event.readValueOfUserId() + specificId + "\(startDate)"
        self.isAllDay = event.isAllDay
        self.initialDate = startDate
        self.start = event.readStartDateTimeFromDate(startDate).trimSeconds()
        self.end = event.readEndDateTimeFromDate(startDate).trimSeconds()
        let miplanitCalendar = event.readMainCalendar()
        self.calendar = miplanitCalendar?.calendar
        let isFullAceesCalendar = miplanitCalendar?.accessLevel == 2
        let isTraveling = event.isAvailable == 1
        let eventAccessLevel = event.accessLevel == 1
        self.text = (isFullAceesCalendar || eventAccessLevel) ? event.readValueOfEventName() : isTraveling ? Strings.travelling : Strings.busy
        if text == "For checking accept"{
            print("asd")
        }
        self.isAccepted = event.isEventAccepted()
        self.location = event.readLocation()
        self.calendarId = miplanitCalendar?.readValueOfCalendarId() ?? Strings.empty
        self.eventData = try? converter.mainObjectContext.existingObject(with: event.objectID)
    }
    
    init(with event: PlanItEvent, startDate: Date) {
        self.isOwnersEvent = true
        self.eventId = event.readValueOfEventId()
        self.appEventId = event.readValueOfAppEventId()
        let specificId = event.readValueOfEventId().isEmpty ? event.readValueOfAppEventId() : event.readValueOfEventId()
        self.id = event.readValueOfUserId() + specificId + "\(startDate)"
        self.isAllDay = event.isAllDay
        self.initialDate = startDate
        self.start = event.readStartDateTimeFromDate(startDate).trimSeconds()
        self.end = event.readEndDateTimeFromDate(startDate).trimSeconds()
        let miplanitCalendar = event.readMainCalendar()
        self.calendar = miplanitCalendar?.calendar
        let isFullAceesCalendar = miplanitCalendar?.accessLevel == 2
        let isTraveling = event.isAvailable == 1
        let eventAccessLevel = event.accessLevel == 1
        self.text = (isFullAceesCalendar || eventAccessLevel) ? event.readValueOfEventName() : isTraveling ? Strings.travelling : Strings.busy
        self.eventData = event
        self.isAccepted = event.isEventAccepted()
        self.location = event.readLocation()
        self.calendarId = miplanitCalendar?.readValueOfCalendarId() ?? Strings.empty
    }
    
    init(with event: OtherUserEvent, startDate: Date) {
        self.isOwnersEvent = false
        self.eventId = event.eventId
        self.id = event.userId + event.eventId + "\(startDate)"
        self.eventData = event
        self.text = event.eventName
        self.initialDate = startDate
        self.isAllDay = event.isAllDay
        self.start = event.readStartDateTimeFromDate(startDate).trimSeconds()
        self.end = event.readEndDateTimeFromDate(startDate).trimSeconds()
        let eventAccessLevel = event.accessLevel == "1"
        let isTraveling = event.isAvailable == 1
        self.text = eventAccessLevel || event.visibility == 0 ? event.eventName : isTraveling ? Strings.travelling : Strings.busy
        self.isAccepted = event.isEventAccepted()
        self.location = event.location
    }
    
    func readStartDate() -> String {
        return self.start.stringFromDate(format: DateFormatters.DDSMMMSYYYYSHHCMMCSSSA)
    }
    
    func getLocationName() -> String {
        let locationData = self.location.split(separator: Strings.locationSeperator)
        if locationData.count > 0 {
            return String(locationData[0])
        }
        return Strings.empty
    }
}

extension Event: EventProtocol {
    public func compare(_ event: Event) -> Bool {
        return "\(id)".hashValue == "\(event.id)".hashValue
    }
}

public protocol EventProtocol {
    func compare(_ event: Event) -> Bool
}

protocol CalendarSettingProtocol {
    func reloadFrame(_ frame: CGRect)
    func updateStyle(_ style: Style)
    func setUI()
}

extension CalendarSettingProtocol {
    func setUI() {}
}

protocol CalendarPrivateDelegate: class {
    func didDisplayCalendarEvents(_ events: [Event], dates: [Date?], type: CalendarType)
    func didSelectCalendarDate(_ date: Date?, type: CalendarType, frame: CGRect?)
    func didSelectCalendarEvent(_ event: Event, frame: CGRect?)
    func didSelectCalendarMore(_ date: Date, frame: CGRect?)
    func calendarEventViewerFrame(_ frame: CGRect)
    func didChangeCalendarEvent(_ event: Event, start: Date?, end: Date?)
    func didAddCalendarEvent(_ date: Date?)
    func didChangeTimeLine(_ date: Date?, with events: [Event], onDragging flag: Bool)
    func didFinihChangeTimeLine(_ date: Date?, with events: [Event])
    func setVisibilityEventIcon(with status: Bool)
}

extension CalendarPrivateDelegate {
    func getEventViewerFrame(_ frame: CGRect) {}
}

public protocol CalendarDataSource: class {
    func eventsForCalendar() -> [Event]
    func willDisplayDate(_ date: Date?, events: [Event]) -> DateStyle?
}

extension CalendarDataSource {
    func willDisplayDate(_ date: Date?, events: [Event]) -> DateStyle? { return nil }
}

public protocol CalendarDelegate: AnyObject {
    func didSelectDate(_ date: Date?, type: CalendarType, frame: CGRect?)
    func didSelectEvent(_ event: Event, type: CalendarType, frame: CGRect?)
    func didSelectMore(_ date: Date, frame: CGRect?)
    func eventViewerFrame(_ frame: CGRect)
    func didChangeEvent(_ event: Event, start: Date?, end: Date?)
    func didAddEvent(_ date: Date?, type: CalendarType)
    func didDisplayEvents(_ events: [Event], dates: [Date?])
    func didChangeTimeLine(_ date: Date?, with events: [Event], onDragging flag: Bool)
    func didFinishChangeTimeLine(_ date: Date?, with events: [Event])
    func setVisibilityEventIcon(with status: Bool)
    func refereshCalendarData()
}

public extension CalendarDelegate {
    func didSelectDate(_ date: Date?, type: CalendarType, frame: CGRect?) {}
    func didSelectEvent(_ event: Event, type: CalendarType, frame: CGRect?) {}
    func didSelectMore(_ date: Date, frame: CGRect?) {}
    func eventViewerFrame(_ frame: CGRect) {}
    func didChangeEvent(_ event: Event, start: Date?, end: Date?) {}
    func didAddEvent(_ date: Date?, type: CalendarType) {}
    func didDisplayEvents(_ events: [Event], dates: [Date?]) {}
}

public struct DateStyle {
    public var backgroundColor: UIColor
    public var textColor: UIColor?
    public var dotBackgroundColor: UIColor?
    
    public init(backgroundColor: UIColor, textColor: UIColor? = nil, dotBackgroundColor: UIColor? = nil) {
        self.backgroundColor = backgroundColor
        self.textColor = textColor
        self.dotBackgroundColor = dotBackgroundColor
    }
}

typealias DayStyle = (day: Day, style: DateStyle?)

protocol DayStyleProtocol: class {
    associatedtype Model
        
    func styleForDay(_ day: Day) -> Model
}
